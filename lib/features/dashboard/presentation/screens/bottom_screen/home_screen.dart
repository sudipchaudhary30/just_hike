import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/features/dashboard/domain/entities/package_entity.dart';
import 'package:just_hike/features/dashboard/presentation/providers/packages_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_hike/core/api/api_endpoints.dart';
import 'package:just_hike/features/dashboard/presentation/screens/bottom_screen/trek_detail_screen.dart';
// Make sure that TrekDetailScreen is defined as a widget class in the imported file.

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String getTrekImageUrl(PackageEntity trek) {
    final path = trek.imageUrl ?? trek.thumbnailUrl;
    if (path != null && path.isNotEmpty) {
      return ApiEndpoints.getImageUrl(path);
    }
    return '';
  }

  String getTrekThumbnailUrl(PackageEntity trek) {
    final path = trek.thumbnailUrl ?? trek.imageUrl;
    if (path != null && path.isNotEmpty) {
      return ApiEndpoints.getImageUrl(path);
    }
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trekPackagesAsync = ref.watch(trekPackagesProvider);

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
            Text(
              'Welcome back',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
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
        child: trekPackagesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(trekPackagesProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D0B0),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (state) {
            if (state.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.errorMessage}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(trekPackagesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.treks.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hiking, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No treks available',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBanner(
                        context,
                        state.treks.first,
                        maxWidth: constraints.maxWidth,
                      ),
                      const SizedBox(height: 24),
                      _sectionHeader('Popular Treks'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 260,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.treks.length > 5
                              ? 5
                              : state.treks.length,
                          itemBuilder: (context, index) {
                            return _popularTrekCard(
                              context,
                              state.treks[index],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      _sectionHeader('All Treks'),
                      const SizedBox(height: 12),
                      ...state.treks.map((trek) {
                        return _recommendedTrekCard(context, trek);
                      }).toList(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBanner(
    BuildContext context,
    PackageEntity trek, {
    double? maxWidth,
  }) {
    final imageUrl = getTrekImageUrl(trek);

    Widget imageWidget = imageUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                Image.asset('assets/images/trek_banner.jpg', fit: BoxFit.cover),
          )
        : Image.asset('assets/images/trek_banner.jpg', fit: BoxFit.cover);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrekDetailScreen(trek: trek)),
        );
      },
      child: Container(
        height: 200,
        width: maxWidth ?? double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageWidget,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    trek.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${trek.location} • ${trek.daysCount} days',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NPR ${trek.price.toStringAsFixed(0)} per person',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrekDetailScreen(trek: trek),
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
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recommendedTrekCard(BuildContext context, PackageEntity trek) {
    final imageUrl = getTrekThumbnailUrl(trek);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrekDetailScreen(trek: trek)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF00D0B0),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/trek_banner.jpg',
                        fit: BoxFit.cover,
                        height: 100,
                        width: 100,
                      ),
                    )
                  : Image.asset(
                      'assets/images/trek_banner.jpg',
                      fit: BoxFit.cover,
                      height: 100,
                      width: 100,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trek.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trek.location,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(
                            trek.difficulty,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          trek.difficulty,
                          style: TextStyle(
                            fontSize: 10,
                            color: _getDifficultyColor(trek.difficulty),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${trek.daysCount}D/${trek.nightsCount}N',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NPR ${trek.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D0B0),
                          fontSize: 16,
                        ),
                      ),
                      if (trek.rating > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            Text(
                              ' ${trek.rating.toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

  // Popular Trek Card widget
  Widget _popularTrekCard(BuildContext context, PackageEntity trek) {
    final imageUrl = getTrekThumbnailUrl(trek);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrekDetailScreen(trek: trek)),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 180,
                      height: 110,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 180,
                        height: 110,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF00D0B0),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/trek_banner.jpg',
                        fit: BoxFit.cover,
                        width: 180,
                        height: 110,
                      ),
                    )
                  : Image.asset(
                      'assets/images/trek_banner.jpg',
                      fit: BoxFit.cover,
                      width: 180,
                      height: 110,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trek.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trek.location,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(
                            trek.difficulty,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          trek.difficulty,
                          style: TextStyle(
                            fontSize: 10,
                            color: _getDifficultyColor(trek.difficulty),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${trek.daysCount}D/${trek.nightsCount}N',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NPR ${trek.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D0B0),
                          fontSize: 15,
                        ),
                      ),
                      if (trek.rating > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 15,
                            ),
                            Text(
                              ' ${trek.rating.toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            // Navigate to all treks
          },
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF00D0B0)),
          child: const Text('See All'),
        ),
      ],
    );
  }
}
