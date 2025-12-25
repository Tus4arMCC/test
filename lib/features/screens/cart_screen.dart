import 'package:flutter/material.dart';
import '../../core/widgets/app_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface.withOpacity(0.9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {}, // Since it's a tab, maybe no back action or goes to Home
        ),
        title: RichText(
          text: TextSpan(
            text: "My Bag ",
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: "(3)",
                style: TextStyle(color: colorScheme.primary, fontSize: 14),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCartItem(
                    context,
                    "Oversized Denim Jacket",
                    "Blue • Size M",
                    89.00,
                    1,
                    "https://lh3.googleusercontent.com/aida-public/AB6AXuCk9vu1KQ9zA2rtK2hgOgbo-Effh-VwfP_hIzFF6dN5m8yO92iFfSwUpH73jnRmhw2YTdZKFDnEuVN9_3RaF9g9-TKStLH7X3VFUo-ZgUUGZqgUJfeLHwnfKb8H1z6RVvZv56EohwAfoHlmeYVd9kXQ8xUL4RmZkzqLdvlf53f1Fm1GnQsMZI9LSwRBAj8N4A2yEUdlMVgGokTGy7Iixu4MAJSDHj2D4811DT9jR5MUolEu1vxfOWJBt8qDzoLb3_XyEpry7_-4kxLC",
                  ),
                  const SizedBox(height: 16),
                  _buildCartItem(
                    context,
                    "Chunky Knit Sweater",
                    "Cream • Size S",
                    45.00,
                    1,
                    "https://lh3.googleusercontent.com/aida-public/AB6AXuCn8XO8UXErZjkRjrsA2MRiIGd05mv_Eg2JA_co9bKt1zBwU7QYYVjcwWiSOlkRXqlasd4-oECJ5K-VEj7yWMpbDt-OvGlvu7vLCB7nRmcA2T6nJmPmL7icuhM51GWNyzOY3QHTOKJtoPoZAfiti0I00Bgh8G75CqZcTMQY9nCdasZZD9NU7XDIic4qwv_cG44RpggyAJ3TrKqCR2GFFqk_jahLzr87lvxEJxrzC8m5UoMBhOEZ7JIV3srXab-p-4fYMNlNr8JxB6Cy",
                    oldPrice: 60.00,
                  ),
                  const SizedBox(height: 16),
                  // Skeleton Demo Item
                  _buildSkeletonItem(context),
                  
                  const SizedBox(height: 24),
                  
                  // Promo Code
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Have a promo code?",
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text("Apply", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Order Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ORDER SUMMARY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                        const SizedBox(height: 16),
                        _buildSummaryRow("Subtotal", "\$134.00"),
                        const SizedBox(height: 12),
                        _buildSummaryRow("Discount", "-\$15.00", valueColor: Colors.green),
                        const SizedBox(height: 12),
                        _buildSummaryRow("Shipping", "Free"),
                        const Divider(height: 24),
                        _buildSummaryRow("Total", "\$119.00", isBold: true),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Saved For Later Header
                  Row(
                    children: [
                       Icon(Icons.favorite, size: 16, color: Colors.grey[400]),
                       const SizedBox(width: 8),
                       Text("Saved for later (1)", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                   // Saved Item
                  Opacity(
                    opacity: 0.8,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: const SizedBox(
                            width: 60, height: 80,
                            child: AppImage(imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuCC7Fu6ptl2Rrv5KGDcMuhvgEZOqOVD5r20_k5xUyAr10JRx-UYVVIAqwytX_18qA9vnEIVg8xTUfGdBKOcWn3KjRaWk3fApYRozbGKHa-m5DxcXOspNZKUOhfQrsHH4THnaDMicEEokhjQasmaOEwmCIX9l07503UwutbXkwMWqAaBt-Wf4HRBDkYrFioVAmsCWYjYINgJqnuhwvIUP_G1DVrOCa7xfBFoJdZf6k1LnVri0K9GrE75_tmaZfdZ-BQs2mpMf-IpcR_P", fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text("Floral Summer Dress", style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                             const SizedBox(height: 4),
                             Text("\$59.00", style: textTheme.bodySmall),
                             const SizedBox(height: 8),
                             Text("Move to bag", style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 80), // Space for bottom bar
                ],
              ),
            ),
          ),
          
          // Fixed Bottom Bar
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
             decoration: BoxDecoration(
               color: colorScheme.surface,
               border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
             ),
             child: Row(
               children: [
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text("Grand Total", style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
                     Text("\$119.00", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                   ],
                 ),
                 const SizedBox(width: 24),
                 Expanded(
                   child: ElevatedButton(
                     onPressed: () {},
                     style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                        elevation: 4,
                        shadowColor: colorScheme.primary.withOpacity(0.4),
                     ),
                     child: const Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         SizedBox(width: 8),
                         Icon(Icons.arrow_forward, size: 20),
                       ],
                     ),
                   ),
                 )
               ],
             ),
          )
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context, 
    String title, 
    String subtitle,
    double price,
    int qty,
    String imageUrl,
    {double? oldPrice}
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           ClipRRect(
             borderRadius: BorderRadius.circular(12),
             child: SizedBox(
               width: 90, height: 120,
               child: AppImage(imageUrl: imageUrl, fit: BoxFit.cover),
             ),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2)),
                       const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           if (oldPrice != null)
                             Text("\$${oldPrice.toStringAsFixed(2)}", style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey[400], fontSize: 12)),
                           Text("\$${price.toStringAsFixed(2)}", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                         ],
                       ),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(
                           color: Colors.grey.withOpacity(0.05),
                           borderRadius: BorderRadius.circular(20),
                         ),
                         child: Row(
                           children: [
                             _buildQtyBtn(Icons.remove),
                             const SizedBox(width: 12),
                             Text(qty.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                             const SizedBox(width: 12),
                             _buildQtyBtn(Icons.add),
                           ],
                         ),
                       )
                    ],
                  )
               ],
             ),
           )
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(blurRadius: 1, color: Colors.black12)]),
      child: Icon(icon, size: 14, color: Colors.grey[700]),
    );
  }
  
  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? valueColor}) {
     return Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
          Text(label, style: TextStyle(color: isBold ? null : Colors.grey, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
          Text(value, style: TextStyle(color: valueColor, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, fontSize: isBold ? 20 : 14)),
       ],
     );
  }
  
  Widget _buildSkeletonItem(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
             Container(width: 90, height: 120, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12))),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Container(width: 150, height: 16, color: Colors.grey[200]),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 12, color: Colors.grey[200]),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 60, height: 20, color: Colors.grey[200]),
                        Container(width: 80, height: 24, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12))),
                      ],
                    )
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }
}
