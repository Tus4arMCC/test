import 'package:flutter/material.dart';
import '../../product/models/product_model.dart';
import '../../product/models/product_image_model.dart';
import '../../../core/widgets/app_image.dart';
import 'dart:ui' as ui; // Needed if we re-introduce ImageFilter later, but removing for now

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // View Mode: 'Grid' or 'List'
  String _viewMode = 'Grid';

  // Mock Data mimicking the HTML content
  final List<Product> _wishlistItems = [
    Product(
      code: "1",
      name: "Oversized Wool Blazer",
      mrp: 129.00,
      price: 129.00,
      isFavourite: true,
      isInCart: false,
      seller: "Acme Studios",
      isOutOfStock: false,
      images: [
        ProductImage(
          image: "https://lh3.googleusercontent.com/aida-public/AB6AXuA2lq4h6J608tAoG7YY8RXAGRPf5U57xlNUoNGixTeTPdg9YWo6h4aDJtc9ImmmWZUqcAJM_5X_-Hslr0kbmSTpxTYae8S7xY4kARNQPiX0dCHHhWeXe-L0HFk-rQclMBgbD0STZ-HtHvOBacsLmTNsvXGAI0lovTaRGz-DnOLsar_eWWNWmcyPRxtoVPlmyi43fpVPKK8EpmiMY33litqE_AGNH90sE_kmVLSs8tlCJFLxHCkHezLOF0ONq3mhJySO16-0Kz48AMgc",
          primary: true,
        )
      ],
    ),
    Product(
      code: "2",
      name: "Silk Midi Dress",
      mrp: 245.00,
      price: 245.00,
      isFavourite: true,
      isInCart: false,
      seller: "Luxe",
      isOutOfStock: false,
      images: [
        ProductImage(
          image: "https://lh3.googleusercontent.com/aida-public/AB6AXuCxRz6SgcOiR2jgImbc4OPXFCmzZPT6FijZ701QYkxdeQyhuI12wsmw7WsYFkX94HDv8T7_PV9N8ZfEoZiJ0jOzFI1n63j-hNTlE36r0XtwVYAeEpXL4CaxeTAet2TWeHASoKeUVL42Do5DVa_aDfKhnXafQrHIMdkhgODKt473kYWh5rMutcBb-orOPAEtjaccY-eFk96SiECAp8jdQ4LaHxC9FM9w8kGGc1R1MWolKkVmwRxgdLa2CyYfOYPPIhklo1LsCmTrRNBL",
          primary: true,
        )
      ],
    ),
    Product(
      code: "3",
      name: "Mini Leather Bag",
      mrp: 890.00,
      price: 890.00,
      isFavourite: true,
      isInCart: false,
      seller: "Vogue",
      isOutOfStock: false,
      images: [
        ProductImage(
          image: "https://lh3.googleusercontent.com/aida-public/AB6AXuDRG2sutZ7Q777Lr6DekUG3NR2aRnYR-WPjiuVggQo_4_6dWHZ2-tdZ07QVFEsqwBiYpHbt4It0kqpzPCSEp8IVxHqqt8zpm6Bsoprf3AqucN0fic3nltgnoP9n-YsaRRka-E8C456w8VePaTvWFCTXW0EqfAKnF4-ht3IBS9aX-n3urbwMM3QtQoLOno9bOZwSKfs2EghGreRurBJfbnVL_ybGDdvQNfIDX2f4Nf1o-g-90xQIezA8coMfzIOSHkhYRe1c8dmf8UJi",
          primary: true,
        )
      ],
    ),
    Product(
      code: "4",
      name: "Chunky Sole Sneakers",
      mrp: 145.00,
      price: 115.00,
      isFavourite: true,
      isInCart: false,
      seller: "Street",
      isOutOfStock: false,
      images: [
        ProductImage(
          image: "https://lh3.googleusercontent.com/aida-public/AB6AXuCmcVmIskSrFdfwfQCBlcdpiNPjf67ROpPJ_yMaOIi-NBQ_4fAQ89GLQT7BosClAtBqag1pOehTLOmQikKMjEdZypaRARZnBXeq8MAIXxcLxygX-Ce_gag8EgFk8Iz9UNPWSpVW41vnIaxis3dP5owFbVzhDv9qxKQpG8QuSbUTSHum_01C83TyV3gZ5XDJMZq7iJbarOjFjE1Coz8gBlSdtVtS9fbTGUFd0zijN2TKOfJkjYAyJIZcRZMFn_0HPsZ4NiOm_AoR2aTQ",
          primary: true,
        )
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface.withOpacity(0.95),
        centerTitle: true,
        title: Text(
          "My Wishlist",
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_bag_outlined),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: colorScheme.onSurface,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_wishlistItems.length} items saved",
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Custom Segmented Control
                Container(
                  height: 36,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildViewToggleBtn(Icons.grid_view, "Grid", colorScheme),
                      const SizedBox(width: 4),
                      _buildViewToggleBtn(Icons.view_list, "List", colorScheme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _viewMode == 'Grid'
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _wishlistItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.60,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
              ),
              itemBuilder: (context, index) {
                return _WishlistGridItem(product: _wishlistItems[index]);
              },
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _wishlistItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _WishlistGridItem(product: _wishlistItems[index]); 
              },
            ),
    );
  }

  Widget _buildViewToggleBtn(IconData icon, String mode, ColorScheme colorScheme) {
    final isSelected = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? colorScheme.primary : Colors.grey,
        ),
      ),
    );
  }
}

class _WishlistGridItem extends StatelessWidget {
  final Product product;

  const _WishlistGridItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    // Explicitly getting String for image
    String imageUrl = product.primaryImage ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image & Actions
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AppImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              
              // Close/Remove Button - Removing BackdropFilter to avoid nullable issues for now
              Positioned(
                top: 8,
                right: 8,
                child: ClipOval(
                  child: Container(
                    color: Colors.white.withOpacity(0.6),
                    width: 32,
                    height: 32,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      color: Colors.black87,
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
              
              // Low Stock Badge (Conditional - just demoing on first item for visual match)
              if (product.code == "1") 
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "LOW STOCK",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Brand
        Text(
          product.seller.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.primary, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Name
        Text(
          product.name,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Price
        Row(
          children: [
            Text(
              "\$${product.price.toStringAsFixed(2)}",
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product.mrp > product.price) ...[
              const SizedBox(width: 8),
              Text(
                "\$${product.mrp.toStringAsFixed(2)}",
                style: textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            ]
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Move to Bag Button
        SizedBox(
          width: double.infinity,
          height: 36,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Move to Bag",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
