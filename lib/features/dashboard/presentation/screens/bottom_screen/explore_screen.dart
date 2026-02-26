import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/api/api_endpoints.dart';
import 'package:just_hike/features/dashboard/presentation/providers/packages_provider.dart';
import 'package:just_hike/features/dashboard/presentation/providers/profile_provider.dart';
import 'package:just_hike/features/dashboard/presentation/screens/bottom_screen/trek_detail_screen.dart';
import 'package:just_hike/models/guide.dart';

// Make sure you have a Guide model imported or defined somewhere
// Example:
// class Guide {
//   final String? name;
//   final String? email;
//   final String? phoneNumber;
//   final String? bio;
//   final int? experienceYears;
//   final List<String>? languages;
//   final String? imageUrl;
//   final String? profileImage;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   Guide({ ... });
// }

class Guide {
  final String? imageUrl;
  // ... other fields ...
  Guide({this.imageUrl /*, ...*/});
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D0B0),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What do you want to\nexplore?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Hike you want to join',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Icon(Icons.mic, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Section with white background
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Guides Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Top Guides',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'explore',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 110,
                          child: Consumer(
                            builder: (context, ref, child) {
                              final guidesAsync = ref.watch(guidesProvider);
                              return guidesAsync.when(
                                data: (guides) {
                                  final topGuides = guides.take(5).toList();
                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: topGuides.length,
                                    itemBuilder: (context, index) {
                                      final guide = topGuides[index];
                                      return _guideInfoCard(guide);
                                    },
                                  );
                                },
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (err, stack) => Text('Error: $err'),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Popular Destinations Section (dynamic)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Popular Destinations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Row(
                                children: const [
                                  Text(
                                    'More',
                                    style: TextStyle(color: Color(0xFF00D0B0)),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: Color(0xFF00D0B0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Dynamic trek list
                        _buildTrekList(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrekList(BuildContext context) {
    return Builder(
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final trekPackagesAsync = ref.watch(trekPackagesProvider);
            return trekPackagesAsync.when(
              data: (state) {
                final treks = state.treks;
                if (treks == null || treks.isEmpty) {
                  return const Text('No treks found');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: treks.length,
                  itemBuilder: (context, index) {
                    final trek = treks[index];
                    final imageUrl = ApiEndpoints.getImageUrl(trek.imageUrl);
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrekDetailScreen(trek: trek),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: imageUrl != null && imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height: 180,
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                  ),
                                                ),
                                              ),
                                    )
                                  : Container(
                                      height: 180,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(Icons.image),
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trek.title ?? trek.id ?? 'Unknown Trek',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    trek.description ??
                                        'No description available',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    trek.price != null
                                        ? 'Rs ${trek.price}'
                                        : 'Price not available',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            );
          },
        );
      },
    );
  }

  Widget _guideInfoCard(dynamic guide) {
    // Use dynamic if Guide is not imported, otherwise use Guide
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: guide.imageUrl ?? guide.avatar ?? guide.photo ?? ''
                ? NetworkImage(
                    guide.imageUrl ?? guide.avatar ?? guide.photo ?? '',
                  )
                : const AssetImage('assets/images/guide_placeholder.png')
                      as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guide.name ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (guide.bio != null && guide.bio.isNotEmpty)
                  Text(
                    guide.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                if (guide.email != null && guide.email.isNotEmpty)
                  Text(
                    'Email: ${guide.email}',
                    style: const TextStyle(fontSize: 11),
                  ),
                if (guide.phoneNumber != null && guide.phoneNumber.isNotEmpty)
                  Text(
                    'Phone: ${guide.phoneNumber}',
                    style: const TextStyle(fontSize: 11),
                  ),
                if (guide.experienceYears != null)
                  Text(
                    'Exp: ${guide.experienceYears} yrs',
                    style: const TextStyle(fontSize: 11),
                  ),
                if (guide.languages != null && guide.languages.isNotEmpty)
                  Text(
                    'Lang: ${guide.languages.join(", ")}',
                    style: const TextStyle(fontSize: 11),
                  ),
                if (guide.createdAt != null)
                  Text(
                    'Joined: ${guide.createdAt.toString().substring(0, 10)}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                if (guide.updatedAt != null)
                  Text(
                    'Updated: ${guide.updatedAt.toString().substring(0, 10)}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _destinationCard(String title, String subtitle, String price) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.4,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
