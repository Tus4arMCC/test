import 'package:flutter/material.dart';
import '../../../../core/widgets/app_image.dart';
import '../../product/models/product_model.dart';
import '../screens/product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String title;
  final List<Product>? products;

  const ProductListScreen({
    super.key,
    required this.title,
    this.products,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface.withOpacity(0.95),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.withOpacity(0.1), height: 1.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 2),
                  ),
                  child: Text(
                    "2",
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(theme),
          Expanded(
            child: widget.products == null || widget.products!.isEmpty
                ? const Center(child: Text("No products found"))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.products!.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 24,
                    ),
                    itemBuilder: (context, index) {
                      return _ProductGridItem(product: widget.products![index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.tune, size: 18),
              label: const Text("Filter"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: const StadiumBorder(),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            Container(height: 24, width: 1, color: Colors.grey.withOpacity(0.3), margin: const EdgeInsets.symmetric(horizontal: 12)),
            _buildOutlinedFilterChip(theme, "Sort: Recommended"),
            const SizedBox(width: 8),
            _buildOutlinedFilterChip(theme, "Size"),
            const SizedBox(width: 8),
            _buildOutlinedFilterChip(theme, "Color"),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedFilterChip(ThemeData theme, String label) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  final Product product;

  const _ProductGridItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String imageUrl = product.primaryImage ?? "";

    return GestureDetector(
      onTap: () {
         Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productCode: product.code),
            ),
          );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppImage(
                    imageUrl: imageUrl, 
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 8,
                  ),
                ),
                
                // Badges
                Positioned(
                  top: 8,
                  left: 8,
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       if (product.mrp > product.price)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "-${(((product.mrp - product.price) / product.mrp) * 100).toInt()}%",
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                     ]
                  ),
                ),

                // Wishlist Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                         BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                      ]
                    ),
                    width: 32,
                    height: 32,
                    child: IconButton(
                       onPressed: () {},
                       padding: EdgeInsets.zero,
                       icon: Icon(
                          product.isFavourite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: product.isFavourite ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                       ),
                    ),
                  ),
                ),

                // Quick Add Button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                         BoxShadow(color: theme.colorScheme.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
                      ]
                    ),
                    child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Info
          Text(
            product.seller.isNotEmpty ? product.seller.toUpperCase() : "BRAND",
            style: theme.textTheme.labelSmall?.copyWith(
               color: Colors.grey[500],
               fontWeight: FontWeight.w600,
               letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: theme.textTheme.titleSmall?.copyWith(
               fontWeight: FontWeight.bold,
               color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                "₹${product.price.toStringAsFixed(2)}",
                style: theme.textTheme.bodyMedium?.copyWith(
                   color: theme.colorScheme.primary,
                   fontWeight: FontWeight.bold,
                ),
              ),
              if (product.mrp > product.price) ...[
                 const SizedBox(width: 8),
                 Text(
                    "₹${product.mrp.toStringAsFixed(2)}", 
                    style: theme.textTheme.bodySmall?.copyWith(
                       color: Colors.grey[400],
                       decoration: TextDecoration.lineThrough,
                    ),
                 ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
