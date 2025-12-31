import 'package:flutter/material.dart';
import 'package:just_hike/widgets/card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Hi, Sudip Chaudhary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 2),
            Text('Welcome', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/trek_banner.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Shey Phoksundo Lake Trek',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '40% Off Summer Escapes',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D0B0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Explore Now',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _sectionHeader('Popular Right Now'),
              const SizedBox(height: 12),

              // Popular Right Now horizontal list
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _popularTrekCard(
                      imagePath: 'assets/images/abc_trek2.jpg',
                      title: 'ABC Trek',
                      subtitle: '4.9 ★',
                      description: 'Rs 21000 (4D/5N)',
                      width: 210,
                    ),
                    const SizedBox(width: 12),
                    _popularTrekCard(
                      imagePath: 'assets/images/langtang_valley.jpg',
                      title: 'Langtang Valley Trek',
                      subtitle: '4.8 ★',
                      description: 'Rs 33000 (7D/6N)',
                      width: 220,
                    ),
                    const SizedBox(width: 12),
                    _popularTrekCard(
                      imagePath: 'assets/images/manaslu_trek.jpg',
                      title: 'Manaslu Base Camp',
                      subtitle: '4.8 ★',
                      description: 'Rs 29000 (6D/5N)',
                      width: 210,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _sectionHeader('Recommended for You'),
              const SizedBox(height: 12),

              // Recommended Treks
              Column(
                children: [
                  _recommendedTrekCard(
                    imagePath: 'assets/images/poon_hill_trek.jpg',
                    title: 'Poon Hill Trek',
                    rating: '4.9 ★',
                    price: 'Rs 12000 (3D/2N)',
                  ),
                  _recommendedTrekCard(
                    imagePath: 'assets/images/ruby_valley.jpg',
                    title: 'Ruby Valley Trek',
                    rating: '4.7 ★',
                    price: 'Rs 18000 (4D/5N)',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Popular Right Now Card with Wishlist
  Widget _popularTrekCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required String description,
    required double width,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  imagePath,
                  width: width,
                  height: 120,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                color: Color.fromARGB(255, 16, 191, 185),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Recommended Treks Card
  Widget _recommendedTrekCard({
    required String imagePath,
    required String title,
    required String rating,
    required String price,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Image.asset(
                  imagePath,
                  width: 140,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Color.fromARGB(255, 16, 191, 185),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rating,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      print('Book $title');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D0B0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 36),
                    ),
                    child: const Text(
                      'Book',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: () {}, child: const Text('More')),
      ],
    );
  }
}
