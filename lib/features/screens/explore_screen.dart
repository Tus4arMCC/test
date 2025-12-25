import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock Data
  final List<String> _recentSearches = [
    "Oversized T-shirt",
    "Nike Air Max",
    "Denim Jacket"
  ];

  final List<String> _trending = [
    "Summer Dress",
    "Leather Boots",
    "Baggy Jeans",
    "Crop Tops",
    "Accessories",
    "Vintage"
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.95),
                border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: "Search clothes, brands...",
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune, size: 20),
                      color: Colors.grey[600],
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recent Searches
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Recent", style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text("Clear All", style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Column(
                      children: _recentSearches.map((term) => _buildRecentItem(context, term)).toList(),
                    ),

                    // Trending
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Row(
                        children: [
                          Icon(Icons.trending_up, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text("Trending Now", style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _trending.map((term) => _buildTrendingChip(context, term)).toList(),
                      ),
                    ),

                    // Recommended
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                      child: Text("Recommended for you", style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    
                    // Recommended Grid (Skeleton-like based on HTML)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) => _buildRecommendedSkeleton(context),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(BuildContext context, String term) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.history, color: Colors.grey[400], size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(term, style: const TextStyle(fontSize: 14))),
            Icon(Icons.close, color: Colors.grey[300], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
    );
  }

  Widget _buildRecommendedSkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8, right: 8,
                  child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle)),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 14, width: 100, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(7))),
        const SizedBox(height: 4),
        Container(height: 12, width: 60, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6))),
      ],
    );
  }
}
