import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/api/api_endpoints.dart';
import 'package:just_hike/features/dashboard/presentation/providers/local_trips_provider.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> {
  int selectedTab = 0; // 0 = Treks, 1 = Wishlist

  @override
  Widget build(BuildContext context) {
    final localTrips = ref.watch(localTripsProvider);
    final Color tabBg = Color(0xFFF9F6F6);
    final Color selectedTabColor = Color(0xFF20D6C6);
    final Color unselectedTabColor = Color(0xFFBDBDBD);

    // Group bookings into upcoming and past
    final now = DateTime.now();
    final bookings = localTrips.bookings;
    final wishlist = localTrips.wishlist;

    List upcoming = bookings.where((b) {
      final start = _resolveBookingStartDate(b);
      return start == null || !start.isBefore(now);
    }).toList();
    List past = bookings.where((b) {
      final start = _resolveBookingStartDate(b);
      return start != null && start.isBefore(now);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'My Treks',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.favorite_border, color: Colors.black),
              onPressed: () {},
            ),
          ],
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(localTripsProvider.notifier).reloadFromStorage(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tabBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTab = 0),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedTab == 0
                                    ? selectedTabColor
                                    : tabBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.hiking,
                                    color: selectedTab == 0
                                        ? Colors.white
                                        : unselectedTabColor,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Treks',
                                    style: TextStyle(
                                      color: selectedTab == 0
                                          ? Colors.white
                                          : unselectedTabColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTab = 1),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedTab == 1
                                    ? selectedTabColor
                                    : tabBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    color: selectedTab == 1
                                        ? Colors.white
                                        : unselectedTabColor,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Wishlist',
                                    style: TextStyle(
                                      color: selectedTab == 1
                                          ? Colors.white
                                          : unselectedTabColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedTab == 0) ...[
                  if (upcoming.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Upcoming Treks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  if (upcoming.isNotEmpty)
                    ...upcoming.map(
                      (booking) => _tripCard(context, booking, true),
                    ),
                  if (past.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Past Treks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  if (past.isNotEmpty)
                    ...past.map(
                      (booking) => _tripCard(context, booking, false),
                    ),
                  if (upcoming.isEmpty && past.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 48),
                        child: Text(
                          'No booked treks yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                ] else ...[
                  if (wishlist.isEmpty)
                    const SizedBox(
                      height: 300,
                      child: Center(
                        child: Text(
                          'Wishlist is empty',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...wishlist.map(
                      (trek) => _wishlistCard(
                        context,
                        Map<String, dynamic>.from(trek),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tripCard(BuildContext context, Map booking, bool isUpcoming) {
    final trek = _extractBookingTrek(booking);
    final imageUrl = fixImageUrl(
      (trek['imageUrl'] ?? trek['thumbnailUrl'] ?? '').toString(),
    );
    final tripName =
        (trek['title'] ?? trek['name'] ?? trek['_id'] ?? 'Unknown Trek')
            .toString();
    final startDate = (_resolveDateString(
      booking,
      keys: const ['startDate', 'tripStartDate', 'date'],
      fallback: _resolveDateString(
        trek,
        keys: const ['startDate', 'tripStartDate', 'date'],
      ),
    ));
    final endDate = _resolveDateString(
      booking,
      keys: const ['endDate', 'tripEndDate'],
      fallback: _resolveDateString(
        trek,
        keys: const ['endDate', 'tripEndDate'],
      ),
    );
    final days = (trek['durationDays'] ?? trek['daysCount'] ?? '').toString();
    final tripType = (trek['difficulty'] ?? trek['type'] ?? '').toString();
    final now = DateTime.now();
    DateTime? start = DateTime.tryParse(startDate);
    String tripInfo = '';
    if (days != '' && tripType != '') {
      tripInfo = '$days Days $tripType';
    }
    String tripStartsIn = '';
    if (isUpcoming && start != null) {
      final diff = start.difference(now);
      if (diff.inDays > 0) {
        tripStartsIn = 'Trip starts in ${diff.inDays} days';
      } else if (diff.inDays == 0) {
        tripStartsIn = 'Trip starts today';
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(color: Color(0xFFE0E0E0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 92,
                        height: 92,
                        color: Colors.grey[300],
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 92,
                      height: 92,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, color: Colors.grey),
                    ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tripName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 2),
                  if (startDate != '' && endDate != '')
                    Text(
                      _formatDateRange(startDate, endDate),
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  if (tripInfo.isNotEmpty)
                    Text(
                      tripInfo,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  if (isUpcoming && tripStartsIn.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        tripStartsIn,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF20D6C6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (!isUpcoming)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF20D6C6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                ref
                        .watch(localTripsProvider)
                        .isWishlisted((trek['id'] ?? '').toString())
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Color(0xFF20D6C6),
              ),
              onPressed: () async {
                final added = await ref
                    .read(localTripsProvider.notifier)
                    .toggleWishlistFromMap(Map<String, dynamic>.from(trek));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      added ? 'Added to wishlist' : 'Removed from wishlist',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _wishlistCard(BuildContext context, Map<String, dynamic> trek) {
    final imageUrl = fixImageUrl(
      (trek['imageUrl'] ?? trek['thumbnailUrl'] ?? '').toString(),
    );
    final title = (trek['title'] ?? trek['name'] ?? 'Unknown Trek').toString();
    final location = (trek['location'] ?? 'Nepal').toString();
    final days = (trek['daysCount'] ?? trek['durationDays'] ?? '').toString();
    final rating = ((trek['rating'] ?? 0) as num).toDouble();
    final price = ((trek['price'] ?? 0) as num).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 88,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 88,
                        height: 72,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    )
                  : Container(
                      width: 88,
                      height: 72,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    days.isNotEmpty ? '$location - $days Days' : location,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  if (rating > 0)
                    Row(
                      children: [
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '★ ★ ★ ★ ★',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs.${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF20D6C6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Color(0xFF20D6C6)),
              onPressed: () async {
                await ref
                    .read(localTripsProvider.notifier)
                    .toggleWishlistFromMap(Map<String, dynamic>.from(trek));
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(String start, String end) {
    try {
      final startDate = DateTime.parse(start);
      final endDate = DateTime.parse(end);
      final startStr = '${_monthShort(startDate.month)} ${startDate.day}';
      final endStr =
          '${_monthShort(endDate.month)} ${endDate.day}, ${endDate.year}';
      return '$startStr - $endStr';
    } catch (e) {
      return '';
    }
  }

  String _monthShort(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  // Fixes or completes the image URL if needed
  String fixImageUrl(String url) {
    if (url.isEmpty) return '';
    final normalized = url.toLowerCase();
    // Ignore backend placeholder paths that often do not exist.
    if (normalized.contains('default-profile.png')) return '';
    return ApiEndpoints.getImageUrl(url);
  }

  DateTime? _resolveBookingStartDate(dynamic booking) {
    if (booking is! Map) return null;
    final map = Map<String, dynamic>.from(booking);
    final trek = _extractBookingTrek(map);
    final startDate = _resolveDateString(
      map,
      keys: const ['startDate', 'tripStartDate', 'date'],
      fallback: _resolveDateString(
        trek,
        keys: const ['startDate', 'tripStartDate', 'date'],
      ),
    );
    return DateTime.tryParse(startDate);
  }

  String _resolveDateString(
    Map source, {
    required List<String> keys,
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return fallback;
  }

  Map<String, dynamic> _extractBookingTrek(Map booking) {
    final dynamic trekField = booking['trek'];
    if (trekField is Map) {
      return Map<String, dynamic>.from(trekField);
    }

    final dynamic packageField = booking['package'];
    if (packageField is Map) {
      return Map<String, dynamic>.from(packageField);
    }

    final dynamic dataField = booking['data'];
    if (dataField is Map) {
      if (dataField['trek'] is Map) {
        return Map<String, dynamic>.from(dataField['trek'] as Map);
      }
      if (dataField['package'] is Map) {
        return Map<String, dynamic>.from(dataField['package'] as Map);
      }
    }

    return <String, dynamic>{};
  }
}
