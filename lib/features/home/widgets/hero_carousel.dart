import 'dart:async';
import 'package:flutter/material.dart';

import '../../../app/constant/fallback_images.dart';
import '../services/home_api_services.dart';
import 'hero_carousel_item.dart';

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late PageController _controller;
  Timer? _timer;

  int _currentIndex = 1;
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1);
    _loadImages();
  }

  Future<void> _loadImages() async {
    final apiImages = await HomeApiService.fetchHeroBanners();
    final baseImages =
        apiImages.isNotEmpty ? apiImages : FallbackImages.heroBanners;

    // Duplicate first & last for infinite scroll
    setState(() {
      _images = [
        baseImages.last,
        ...baseImages,
        baseImages.first,
      ];
    });

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_controller.hasClients) {
        _currentIndex++;
        _controller.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    final lastIndex = _images.length - 1;

    setState(() => _currentIndex = index);

    // Jump without animation (seamless loop)
    if (index == 0) {
      _controller.jumpToPage(lastIndex - 1);
      _currentIndex = lastIndex - 1;
    } else if (index == lastIndex) {
      _controller.jumpToPage(1);
      _currentIndex = 1;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_images.isEmpty) {
      return const SizedBox(height: 320);
    }

    final dotCount = _images.length - 2;
    final activeDot =
        (_currentIndex - 1 + dotCount) % dotCount;

    return Column(
      children: [
        SizedBox(
          height: 360,
          child: PageView.builder(
            controller: _controller,
            itemCount: _images.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (_, index) {
              return HeroCarouselItem(
                imageUrl: _images[index],
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Pagination dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(dotCount, (index) {
            final isActive = index == activeDot;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }
}
