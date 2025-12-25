import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../../core/widgets/app_image.dart';
import '../widgets/skeletons/product_detail_skeleton.dart';
import '../../../core/widgets/skeleton.dart';
import '../repository/product_repository.dart';
import '../models/product_detail_model.dart';
import '../models/product_image_model.dart';
// Note: We don't import app_theme.dart directly, we use Theme.of(context)

class ProductDetailScreen extends StatefulWidget {
  final String productCode;

  const ProductDetailScreen({
    super.key,
    required this.productCode,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<ProductDetail> _future;
  int _currentImageIndex = 0;
  
  // Interactive Selection State
  // Default selections
  int _selectedColorIndex = 0;
  String _selectedSize = "US 7";

  // Mock options for interactivity (Visual Demo)
  final List<String> _sizes = ["US 6", "US 7", "US 8", "US 9", "US 10"];
  // Colors will be defined in build method to access Theme

  @override
  void initState() {
    super.initState();
    _future = ProductRepository().getProduct(widget.productCode);
  }

  @override
  Widget build(BuildContext context) {
    // Theme references
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    final size = MediaQuery.of(context).size;
    final imageHeight = size.height * 0.65;
    
    // Mock Colors using Theme Primary + standard colors to simulate variants
    final List<Color> colors = [
      colorScheme.primary,
      Colors.black,
      Colors.grey,
      const Color(0xFF3B82F6), // Blue 500
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<ProductDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ProductDetailSkeleton();
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: colorScheme.error)));
          }

          if (!snapshot.hasData) {
            return Center(child: Text("Product not found", style: textTheme.bodyLarge));
          }

          final product = snapshot.data!;
          final images = product.images.isNotEmpty ? product.images : [];

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // 1. App Bar with Carousel (Flexible Space)
                  SliverAppBar(
                    expandedHeight: imageHeight,
                    backgroundColor: Colors.transparent, 
                    elevation: 0,
                    pinned: true, // Keep header visible/interactive
                    leadingWidth: 70,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      child: _buildHeaderButton(
                        Icons.arrow_back, 
                        () => Navigator.pop(context),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                        child: _buildHeaderButton(
                          Icons.ios_share, 
                          () {},
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          if (images.isNotEmpty)
                            PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return AppImage(
                                  imageUrl: images[index].image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                );
                              },
                            )
                          else
                            Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.image, size: 50))),
                            
                          // Pagination Dots
                          if (images.length > 1)
                            Positioned(
                              bottom: 48, // Lifted up to be above the overlapping sheet
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(images.length, (index) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: _currentImageIndex == index ? 32 : 8,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _currentImageIndex == index
                                          ? colorScheme.primary
                                          : Colors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Product Details Content
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -32), // Visual Overlap
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor, // Theme background
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        // Add bottom padding to account for overlap + fixed bar + safe area
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120), 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            // Handle bar
                            Center(
                              child: Container(
                                width: 48,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Header Info
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.seller.isNotEmpty ? product.seller.toUpperCase() : "BRAND",
                                        style: textTheme.labelLarge?.copyWith(
                                          color: Colors.grey[500],
                                          letterSpacing: 1.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Plus Jakarta Sans',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.name,
                                        style: textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                          color: colorScheme.onSurface,
                                          fontFamily: 'Plus Jakarta Sans',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "\$${product.price.toStringAsFixed(2)}",
                                      style: textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${product.rating} (120)",
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Color Selection
                            Text(
                              "Select Color", 
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: List.generate(colors.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                       setState(() {
                                          _selectedColorIndex = index;
                                       });
                                    },
                                    child: _buildColorCircle(
                                      colors[index], 
                                      _selectedColorIndex == index,
                                      colorScheme,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 32),

                            // Size Selection
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Select Size",
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    foregroundColor: colorScheme.primary,
                                  ),
                                  child: const Text(
                                    "Size Guide",
                                    style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _sizes.map((sizeOption) {
                                final isSelected = _selectedSize == sizeOption;
                                final isDisabled = sizeOption == "US 10"; // Demo disabled state
                                
                                return GestureDetector(
                                  onTap: isDisabled ? null : () {
                                    setState(() {
                                       _selectedSize = sizeOption;
                                    });
                                  },
                                  child: _buildSizeOption(
                                    sizeOption, 
                                    isSelected: isSelected, 
                                    isDisabled: isDisabled,
                                    colorScheme: colorScheme,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 32),

                            // Description
                            Text(
                              "Description",
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                  height: 1.6,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Engineered for comfort and speed, the Air Zoom Pegasus features a breathable mesh upper and responsive foam cushioning. "
                                  ),
                                  TextSpan(
                                    text: "Read more",
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // You might also like
                            Text(
                              "You might also like",
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildSkeletonItem(),
                                  _buildSkeletonItem(),
                                  _buildSkeletonItem(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 3. Bottom Action Bar (Fixed at bottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: IconButton(
                          icon: Icon(
                            product.isFavourite ? Icons.favorite : Icons.favorite_border,
                            color: product.isFavourite ? Colors.red : Colors.grey[400],
                          ),
                          onPressed: () {
                             // Toggle logic could go here
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 4,
                              shadowColor: colorScheme.primary.withOpacity(0.4),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Add to Bag",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onPressed) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 40,
          height: 40,
          color: Colors.white.withOpacity(0.2), // Always use light bg for glass effect on image
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 24),
            onPressed: onPressed,
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color, bool isSelected, ColorScheme colorScheme) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: colorScheme.surface, width: 2) : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 0,
                  spreadRadius: 2,
                )
              ]
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 1,
                  spreadRadius: 1,
                )
              ],
      ),
    );
  }

  Widget _buildSizeOption(String label, {required bool isSelected, bool isDisabled = false, required ColorScheme colorScheme}) {
    if (isDisabled) {
        return Container(
        width: 60,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
             fontSize: 14, 
             fontWeight: FontWeight.w500, 
             color: Colors.grey[400],
             fontFamily: 'Plus Jakarta Sans',
          ),
        ),
      );
    }
    
    return Container(
      width: 60,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? null : Border.all(color: Colors.grey[300]!),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontFamily: 'Plus Jakarta Sans',
        ),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return const Padding(
      padding: EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScheduledSkeleton(width: 140, height: 180, borderRadius: 8),
          SizedBox(height: 8),
          ScheduledSkeleton(width: 100, height: 16, borderRadius: 4),
          SizedBox(height: 4),
          ScheduledSkeleton(width: 60, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}
