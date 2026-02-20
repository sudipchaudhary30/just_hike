import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/api/api_endpoints.dart';
import 'package:just_hike/features/dashboard/domain/entities/package_entity.dart';
import 'package:just_hike/features/dashboard/presentation/providers/packages_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesState = ref.watch(allPackagesProvider);

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
              // Banner - Use first package if available
              if (packagesState.packages.isNotEmpty)
                _buildBanner(packagesState.packages.first)
              else
                _buildDefaultBanner(),
              const SizedBox(height: 24),
              _sectionHeader('Popular Right Now'),
              const SizedBox(height: 12),
              if (packagesState.isLoading)
                const SizedBox(
                  height: 220,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF00D0B0)),
                    ),
                  ),
                )
              else if (packagesState.errorMessage != null)
                SizedBox(
                  height: 220,
                  child: Center(
                    child: Text('Error: ${packagesState.errorMessage}'),
                  ),
                )
              else if (packagesState.packages.isEmpty)
                const SizedBox(
                  height: 220,
                  child: Center(
                    child: Text('No packages available'),
                  ),
                )
              else
                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...packagesState.packages.take(2).map((pkg) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _popularTrekCard(pkg),
                        );
                      }),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              _sectionHeader('Recommended for You'),
              const SizedBox(height: 12),
              if (packagesState.isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D0B0)),
                  ),
                )
              else if (packagesState.errorMessage != null)
                Text('Error: ${packagesState.errorMessage}')
              else if (packagesState.packages.isEmpty)
                const Text('No packages available')
              else
                ...packagesState.packages.skip(2).take(3).map(
                      (pkg) => _recommendedTrekCard(pkg),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultBanner() {
    return Container(
      height: 200,
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
              'Explore Our Treks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Discover amazing mountain adventures',
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
    );
  }

  Widget _buildBanner(PackageEntity package) {
    final imageUrl = package.banner ?? package.imageUrl ?? '';

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: imageUrl.startsWith('http')
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            : const DecorationImage(
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
            Text(
              package.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${package.location} • Rs ${package.price.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
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
    );
  }

  Widget _popularTrekCard(PackageEntity package) {
    final imageUrl = package.imageUrl ?? '';

    return Container(
      width: 210,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    height: 130,
                    width: 210,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 130,
                        width: 210,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      );
                    },
                  )
                : Container(
                    height: 130,
                    width: 210,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('${package.rating.toStringAsFixed(1)} ★',
                    style: const TextStyle(color: Colors.grey)),
                Text('Rs ${package.price.toStringAsFixed(0)} (${package.daysCount}D/${package.nightsCount}N)',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendedTrekCard(PackageEntity package) {
    final imageUrl = package.imageUrl ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    width: 120,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 110,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      );
                    },
                  )
                : Container(
                    width: 120,
                    height: 110,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text('${package.rating.toStringAsFixed(1)} ★',
                    style: const TextStyle(color: Colors.grey)),
                Text('Rs ${package.price.toStringAsFixed(0)} (${package.daysCount}D/${package.nightsCount}N)',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    )),
              ],
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
