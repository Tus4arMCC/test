import 'package:flutter/material.dart';
import '../../../../core/widgets/skeleton.dart';

class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageHeight = size.height * 0.65;
    
    return Stack(
      children: [
        // Image Skeleton
        ScheduledSkeleton(
          width: double.infinity,
          height: imageHeight,
          borderRadius: 0,
        ),
        
        // Content Skeleton
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: imageHeight - 32),
              Container(
                 decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                 ),
                 padding: const EdgeInsets.all(24),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Center(child: ScheduledSkeleton(width: 48, height: 6)),
                     const SizedBox(height: 24),
                     
                     // Header
                     Row(
                       children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                 ScheduledSkeleton(width: 60, height: 14),
                                 SizedBox(height: 8),
                                 ScheduledSkeleton(width: 200, height: 32),
                              ],
                            ),
                          ),
                          const ScheduledSkeleton(width: 80, height: 32),
                       ],
                     ),
                     const SizedBox(height: 32),
                     
                     // Color
                     const ScheduledSkeleton(width: 100, height: 20),
                     const SizedBox(height: 12),
                     Row(
                       children: List.generate(4, (i) => const Padding(
                         padding: EdgeInsets.only(right: 16),
                         child: ScheduledSkeleton(width: 32, height: 32, borderRadius: 16),
                       )),
                     ),
                     const SizedBox(height: 32),
                     
                     // Size
                     const ScheduledSkeleton(width: 100, height: 20),
                     const SizedBox(height: 12),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: List.generate(5, (i) => const ScheduledSkeleton(width: 60, height: 40)),
                     ),
                     
                     const SizedBox(height: 32),
                     // Desc
                     const ScheduledSkeleton(width: 120, height: 20),
                     const SizedBox(height: 8),
                     const ScheduledSkeleton(width: double.infinity, height: 14),
                     const SizedBox(height: 6),
                     const ScheduledSkeleton(width: double.infinity, height: 14),
                     const SizedBox(height: 6),
                     const ScheduledSkeleton(width: 200, height: 14),
                   ],
                 ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
