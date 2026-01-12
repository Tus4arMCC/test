import 'package:flutter/material.dart';

class ReviewCarousel extends StatefulWidget {
  const ReviewCarousel({super.key});

  @override
  State<ReviewCarousel> createState() => _ReviewCarouselState();
}

class _ReviewCarouselState extends State<ReviewCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  // Mock data from reviews.json
  final List<Map<String, dynamic>> _reviews = [
    {
      "id": 1,
      "name": "Arjun Sharma",
      "location": "Mumbai",
      "rating": 5,
      "title": "Great Quality Products",
      "description":
          "I ordered a few items and the quality is amazing. Delivery was super fast too. Highly recommended!",
    },
    {
      "id": 2,
      "name": "Priya Singh",
      "location": "Delhi",
      "rating": 4,
      "title": "Good Experience",
      "description":
          "The checkout process was smooth and easy. Had a small issue with size but return was hassle-free.",
    },
    {
      "id": 3,
      "name": "Rahul Verma",
      "location": "Bangalore",
      "rating": 5,
      "title": "Excellent Service",
      "description":
          "Customer support is very responsive. They helped me track my order which was delayed by courier.",
    },
    {
      "id": 4,
      "name": "Sneha Gupta",
      "location": "Pune",
      "rating": 5,
      "title": "Lovely Collection",
      "description":
          "The trendy collection is just what I was looking for. Will definitely shop again.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Text(
                "Loved By Millions Of Happy Customers",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                "Heart warming experiences shared by our customers",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _reviews.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final review = _reviews[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          Icons.star,
                          size: 16,
                          color: starIndex < (review['rating'] as int)
                              ? Colors.amber
                              : Colors.grey[300],
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "“${review['title']}”",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        review['description'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[200],
                          child: Text(
                            (review['name'] as String)[0],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              review['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              review['location'],
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_reviews.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
