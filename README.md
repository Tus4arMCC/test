# Legal Disclaimer

**IMPORTANT: PRIVATE PROPERTY**

This source code and all associated documentation, files, and assets are the exclusive property of **PkSoft** (or the respective private entity owning this repository).

*   **Unauthorized Access**: Accessing this repository without explicit permission is strictly prohibited.
*   **Unauthorized Use**: Copying, modifying, distributing, or using this code for any purpose without written consent is invalid and illegal.
*   **Legal Consequences**: Any unauthorized use, reproduction, or dissemination of this material will be met with immediate legal action to the fullest extent of the law.

---

# Cart & Wishlist Flow Documentation

This document provides a deep dive into the technical implementation of the Cart and Wishlist flows for the three user types: **Random User**, **Guest User**, and **Login User**.

It focuses on the interaction between **State Management (Context)**, **Business Logic (Hooks)**, and **API Services**.

---

## 1. User Identification Utilities
**File**: `src/utilits/cookieUtils.ts`

The foundation of the entire flow is the `resolveUid()` and `getUserType()` functions. Every API call relies on these to tell the backend *who* is making the request.

| Function | Type | Logic |
| :--- | :--- | :--- |
| `resolveUid()` | `string` | Returns `user_id` (cookie) **OR** `guest_id` (cookie) **OR** `random_user` (cookie UUID). |
| `getUserType()` | `enum` | Checks cookies in priority order: `user` > `guest` > `random`. |

---

## 2. Cart Flow
**Primary Logic File**: `src/logic/useCartLogic.ts`
**State File**: `src/context/CartContext.tsx`

### A. The Hydration Process (`fetchCartItems`)
The frontend stores **Item IDs** locally (Cookie) but needs the Server to provide **Prices & Details**. This process is called "Hydration".

#### **Random User Flow**
1.  **Read Cookies**: `getCartItems()` retrieves the list of `{ variationId, qty }` from the `cart` cookie.
2.  **API Call**: `fetchBag` is called with:
    ```json
    {
      "uid": "UUID-1234...",
      "variations": [{ "variationId": "101", "qty": 1 }]
    }
    ```
3.  **Validation**:
    *   The server calculates prices ephemerally (does not save to DB).
    *   **Success**: Returns fully hydrated product objects.
    *   **Failure/Empty**: If the API fails (e.g., backend ignores random UUIDs), the code **FALLS BACK**. It creates a "Skeleton Cart" using the cookie data (Price: 0, Name: "Unknown"). **See `useCartLogic.ts` lines 97-113.**

#### **Login / Guest User Flow**
1.  **Read Cookies**: Optimistically reads `cart` cookie.
2.  **API Call**: `fetchBag` is called with:
    ```json
    {
      "uid": "USER-DB-ID-555",
      "variations": [{ "variationId": "101", "qty": 1 }] // Pushes local items to server
    }
    ```
3.  **Server Action**: The server **merges** the payload items into the user's permanent database cart.
4.  **Response**: Returns the *new* definitive list from the database.
5.  **No Fallback**: If the API returns empty, the cart is shown as empty. We trust the server as the detailed Source of Truth for logged-in users.

### B. Quantity Updates & Stock Checks
**Function**: `handleQuantityChange` & `checkStockStatus`

| User Type | Behavior | Utils Used |
| :--- | :--- | :--- |
| **Random** | **Debounced**: Updates are delayed by **800ms**. logic waits for the user to stop clicking `+` before asking the server "Is this in stock?". This prevents API spam from anonymous bots/users. | `setTimeout`, `window.clearTimeout` |
| **Login/Guest** | **Immediate**: Triggers `checkStockStatus` instantly. We assume high purchase intent and want to validate stock/price immediately. | `updateCartItem` (cookie), `fetchBag` (API) |

---

## 3. Wishlist Flow
**Primary Logic File**: `src/logic/useWishlistLogic.ts`
**State File**: `src/context/WishlistContext.tsx`

### A. Architecture
*   **Write Operations**: Handled by `WishlistContext.tsx`. Everything is written to the `wishlist` cookie **first**.
*   **Read Operations**: Handled by `useWishlistLogic.ts`.

### B. The Fetch Process (`fetchWishlistItems`)
1.  **Trigger**: Page Load.
2.  **Resolution**: Calls `resolveUid()`.
3.  **API**: Calls `fetchWishlistAPI(uid)`.
    *   **Random**: Sends UUID. If the backend doesn't support temporary storage for UUIDs, this may return an empty list even if the user just clicked "Heart".
    *   **Login**: Sends DB ID. Returns the persistent database list.
4.  **Syncing**: `WishlistContext` watches Redux/API state. If an item is removed on the server, the `useEffect` at line 75 cleans it up from the local cookie to keep them in sync.

---

## 4. The Sync Process (Bridging the Gap)
**File**: `src/api/cartWishlistSyncService.ts`

This is the most critical flow. It converts a **Random User** into a **Login User** without losing their data.

### **Function**: `syncCartWishlistWithCounts`
**Trigger**: Application Mount (`App.tsx`) or successful Login.

#### **Step-by-Step Flow:**
1.  **Identify User**:
    *   If `getUserType() === 'random'`, **ABORT**. We do not sync random users to the server (privacy/spam protection).
    *   If `getUserType() === 'user' | 'guest'`, **PROCEED**.
2.  **Gather Local Data**:
    *   Calls `getCartItems()` -> `['ItemA', 'ItemB']`
    *   Calls `getWishlistItems()` -> `['ItemC']`
3.  **The "Push" Payload**:
    Sends a specialized payload to `CUSTOMER.COUNT` endpoint:
    ```json
    {
      "c_products": ["ItemA", "ItemB"],
      "w_products": ["ItemC"]
    }
    ```
4.  **Server Magic**:
    *   The server takes these IDs and **ADDs** them to the user's account in the database.
    *   If the user already had "ItemD" in their DB cart, the result is now "ItemA, ItemB, ItemD".
5.  **Result**:
    *   Returns new `cartCount` and `wishlistCount`.
    *   The UI updates immediately to show the unified total.

---

## 5. Summary of Key Differences

| Feature | Random User | Guest / Login User |
| :--- | :--- | :--- |
| **Identity** | Client-generated UUID (Cookie) | Database ID (Cookie) |
| **Cart Storage** | Cookie (Fallback: Skeleton) | Database (Primary) |
| **Wishlist Storage** | Cookie (Primary) | Database (Primary) |
| **Stock Checks** | Debounced (800ms) | Immediate |
| **Persistence** | 7 Days (Browser only) | Permanent (Cross-device) |
