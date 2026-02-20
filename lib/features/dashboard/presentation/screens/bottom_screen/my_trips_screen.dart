import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/features/dashboard/domain/entities/package_entity.dart';
import 'package:just_hike/features/dashboard/presentation/providers/packages_provider.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> {
  bool _showTreks = true;

  static const Color _primary = Color(0xFF00D0B0);
  static const Color _pageBg = Color(0xFFF5F6F7);
  static const Color _tileBg = Color(0xFFF2ECEC);

  @override
  Widget build(BuildContext context) {
    final upcomingState = ref.watch(upcomingPackagesProvider);
    final pastState = ref.watch(pastPackagesProvider);
    final wishlistState = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'My Treks',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  _circleActionButton(Icons.notifications_none_rounded),
                  const SizedBox(width: 10),
                  _circleActionButton(Icons.settings_outlined),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: _tileBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _tabChip(
                        label: 'Treks',
                        icon: Icons.hiking,
                        selected: _showTreks,
                        onTap: () => setState(() => _showTreks = true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _tabChip(
                        label: 'Wishlist',
                        icon: Icons.favorite_border,
                        selected: !_showTreks,
                        onTap: () => setState(() => _showTreks = false),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_showTreks) ...[
                if (upcomingState.isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primary),
                    ),
                  )
                else if (upcomingState.errorMessage != null)
                  Text('Error: ${upcomingState.errorMessage}')
                else if (upcomingState.packages.isEmpty)
                  const Text('No upcoming treks')
                else ...[
                  _sectionTitle('Upcoming Treks'),
                  const SizedBox(height: 10),
                  ...upcomingState.packages.map((pkg) => _trekCard(pkg)),
                ],
                const SizedBox(height: 14),
                if (pastState.isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primary),
                    ),
                  )
                else if (pastState.errorMessage != null)
                  Text('Error: ${pastState.errorMessage}')
                else if (pastState.packages.isEmpty)
                  const Text('No past treks')
                else ...[
                  _sectionTitle('Past Treks'),
                  const SizedBox(height: 10),
                  ...pastState.packages.map((pkg) => _trekCard(pkg)),
                ],
              ] else ...[
                if (wishlistState.isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primary),
                    ),
                  )
                else if (wishlistState.errorMessage != null)
                  Text('Error: ${wishlistState.errorMessage}')
                else if (wishlistState.packages.isEmpty)
                  const Text('No wishlist items')
                else ...[
                  _sectionTitle('Wishlist'),
                  const SizedBox(height: 10),
                  ...wishlistState.packages.map((pkg) => _trekCard(pkg)),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleActionButton(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
      child: Icon(icon, size: 19, color: _primary),
    );
  }

  Widget _tabChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? _primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: selected ? Colors.white : _primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
    );
  }

  Widget _trekCard(PackageEntity package) {
    final bool isCompleted = package.status == 'Completed';
    final String imageUrl = package.imageUrl ?? package.banner ?? '';
    final String formattedDate =
        '${package.startDate?.toLocal().toString().split(' ')[0]} – ${package.endDate?.toLocal().toString().split(' ')[0]}';
    final String durationText =
        '${package.daysCount} Days ${package.nightsCount} Nights';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    width: 92,
                    height: 84,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 92,
                        height: 84,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      );
                    },
                  )
                : Container(
                    width: 92,
                    height: 84,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    durationText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    package.status,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? _primary : _primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              package.isWishlisted ? Icons.favorite : Icons.favorite_border,
              size: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
