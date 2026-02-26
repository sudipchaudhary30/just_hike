import 'package:flutter/material.dart';
import 'package:just_hike/features/dashboard/domain/entities/package_entity.dart';
import 'package:just_hike/core/api/api_endpoints.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_hike/features/dashboard/presentation/screens/booking_screen.dart';

class TrekDetailScreen extends StatelessWidget {
  final PackageEntity trek;
  const TrekDetailScreen({Key? key, required this.trek}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // DEBUG: Print everything about the trek entity
    print('========== TREK DETAIL DEBUG ==========');
    print('Trek Title: ${trek.title}');
    print('Trek ID: ${trek.id}');
    print('imageUrl: ${trek.imageUrl}');
    print('thumbnailUrl: ${trek.thumbnailUrl}');
    print('=======================================');

    // Try multiple possible image sources
    String? imagePath = trek.imageUrl ?? trek.thumbnailUrl;
    print('Selected image path: $imagePath');

    final imageUrl = imagePath != null && imagePath.isNotEmpty
        ? ApiEndpoints.getImageUrl(imagePath)
        : '';

    print('Final constructed URL: $imageUrl');
    print('URL is empty: ${imageUrl.isEmpty}');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                trek.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) {
                            print('Loading image from: $url');
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF00D0B0),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            print('ERROR loading image: $error');
                            print('Failed URL: $url');
                            return Container(
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Error: $error',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          '', // <-- your default asset
                          fit: BoxFit.cover,
                        ),

                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Rest of your content remains the same...
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Price and Duration
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        icon: Icons.attach_money,
                        label: 'Price',
                        value: 'NPR ${trek.price.toStringAsFixed(0)}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                        icon: Icons.calendar_today,
                        label: 'Duration',
                        value: '${trek.daysCount}D/${trek.nightsCount}N',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location and Difficulty
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: trek.location,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                        icon: Icons.terrain,
                        label: 'Difficulty',
                        value: trek.difficulty,
                        color: _getDifficultyColor(trek.difficulty),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  trek.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Overview
                if (trek.overview != null && trek.overview!.isNotEmpty) ...[
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trek.overview!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Itinerary
                if (trek.itinerary != null && trek.itinerary!.isNotEmpty) ...[
                  const Text(
                    'Itinerary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trek.itinerary!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Highlights
                if (trek.highlights != null && trek.highlights!.isNotEmpty) ...[
                  const Text(
                    'Highlights',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...trek.highlights!.map(
                    (highlight) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF00D0B0),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              highlight,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Max Group Size and Available Slots
                if (trek.maxParticipants > 0) ...[
                  const Text(
                    'Group Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.group, color: Color(0xFF00D0B0), size: 28),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Max Group Size',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${trek.maxParticipants}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00D0B0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Book Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(trek: trek),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D0B0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00D0B0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color ?? const Color(0xFF00D0B0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'difficult':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
