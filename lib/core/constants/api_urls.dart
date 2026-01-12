class PkSoftUrls {
  static const customer = _Customer();
  static const guest = _Guest();
  static const order = _Order();
  static const address = _Address();
  static const cancel = _Cancel();
}

class _Customer {
  const _Customer();
  final String register = "api/pk/Customer/register";
  final String registerOtp = "api/pk/Customer/verify-otp";
  final String login = "api/pk/Customer/auth";
  final String product = "api/pk/Customer/product";
  final String category = "api/pk/Customer/load/category";
  final String details = "api/pk/Customer/load/details";

  final String count = "api/pk/Customer/Count"; //{count}
  final String checklist = "api/pk/Customer/CheckList"; //{wishlist-list}
  final String bag = "api/pk/Customer/Bag"; //{get cart & wishlist}

  final String wishlist ="api/pk/Customer/wishlist"; //{add/remove from wishlist}
  final String cart = "api/pk/Customer/Cart"; //{add/remove from cart}

  final String cartAdd = "api/pk/Customer/Cart/add";
  final String cartRemove = "api/pk/Customer/Cart/remove";

  final String wishlistAdd = "api/pk/Customer/wishlist/add";
  final String wishlistRemove = "api/pk/Customer/wishlist/remove";
}

class _Guest {
  const _Guest();
  final String guestRegister = "api/pk/Customer/guest/auth";
  final String guestOtp = "api/pk/Customer/verify-guest";
  final String guestOrder = "api/pk/Order/GuestOrders";
}

class _Order {
  const _Order();
  final String proceed = "api/pk/Order/proceed";
  final String success = "api/pk/Order/success";
  final String userOrder = "api/pk/User/Orders";
}

class _Address {
  const _Address();
  final String create = "api/pk/Customer/Address/Create";
  final String update = "api/pk/Customer/Address/Update";
  final String delete = "api/pk/Customer/Address/Delete";
  final String get = "api/pk/Customer/Address/List";
  final String setDefault = "api/pk/Customer/Address/Primary";
}

class _Cancel {
  const _Cancel();
  final String order = "api/pk/Order/cancel";
}
