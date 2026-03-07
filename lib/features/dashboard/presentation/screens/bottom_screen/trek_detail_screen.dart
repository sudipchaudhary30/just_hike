import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/api/api_endpoints.dart';
import 'package:just_hike/features/dashboard/domain/entities/package_entity.dart';
import 'package:just_hike/features/dashboard/presentation/providers/local_trips_provider.dart';
import 'package:just_hike/features/dashboard/presentation/screens/booking_screen.dart';
import 'package:sensors_plus/sensors_plus.dart';

class TrekDetailScreen extends ConsumerStatefulWidget {
  final PackageEntity trek;
  const TrekDetailScreen({Key? key, required this.trek}) : super(key: key);

  @override
  ConsumerState<TrekDetailScreen> createState() => _TrekDetailScreenState();
}

class _TrekDetailScreenState extends ConsumerState<TrekDetailScreen> {
  static const double _shakeThreshold = 24;
  static const int _shakeCooldownMs = 2000;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  int _lastShakeAtMs = 0;
  bool _isShakeDialogOpen = false;
  bool _hasShownInitialShakeTip = false;

  @override
  void initState() {
    super.initState();
    _startShakeListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasShownInitialShakeTip) return;
      _hasShownInitialShakeTip = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tip: Shake your phone on this page to quick book.'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _startShakeListener() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      final magnitude = math.sqrt(
        (event.x * event.x) + (event.y * event.y) + (event.z * event.z),
      );
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final isPastCooldown = (nowMs - _lastShakeAtMs) > _shakeCooldownMs;
      if (magnitude > _shakeThreshold &&
          isPastCooldown &&
          !_isShakeDialogOpen) {
        _lastShakeAtMs = nowMs;
        _showShakeBookingDialog();
      }
    });
  }

  Future<void> _showShakeBookingDialog() async {
    if (!mounted) return;
    _isShakeDialogOpen = true;
    final shouldBook = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quick Book'),
          content: const Text(
            'Shake detected. Do you want to continue to booking?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D0B0),
                foregroundColor: Colors.white,
              ),
              child: const Text('Book Now'),
            ),
          ],
        );
      },
    );
    _isShakeDialogOpen = false;
    if (shouldBook == true && mounted) {
      _openBookingScreen();
    }
  }

  void _openBookingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookingScreen(trek: widget.trek)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWishlisted = ref.watch(
      localTripsProvider.select((state) => state.isWishlisted(widget.trek.id)),
    );

    print('========== TREK DETAIL DEBUG ==========');
    print('Trek Title: ${widget.trek.title}');
    print('Trek ID: ${widget.trek.id}');
    print('imageUrl: ${widget.trek.imageUrl}');
    print('thumbnailUrl: ${widget.trek.thumbnailUrl}');
    print('=======================================');

    String? imagePath = widget.trek.imageUrl ?? widget.trek.thumbnailUrl;
    print('Selected image path: $imagePath');

    final imageUrl = imagePath != null && imagePath.isNotEmpty
        ? ApiEndpoints.getImageUrl(imagePath)
        : '';

    print('Final constructed URL: $imageUrl');
    print('URL is empty: ${imageUrl.isEmpty}');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? Colors.redAccent : Colors.white,
                ),
                onPressed: () async {
                  final added = await ref
                      .read(localTripsProvider.notifier)
                      .toggleWishlist(widget.trek);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        added ? 'Added to wishlist' : 'Removed from wishlist',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.trek.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
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
                      : Image.asset('', fit: BoxFit.cover),
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
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        icon: Icons.attach_money,
                        label: 'Price',
                        value: 'NPR ${widget.trek.price.toStringAsFixed(0)}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                        icon: Icons.calendar_today,
                        label: 'Duration',
                        value:
                            '${widget.trek.daysCount}D/${widget.trek.nightsCount}N',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: widget.trek.location,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                        icon: Icons.terrain,
                        label: 'Difficulty',
                        value: widget.trek.difficulty,
                        color: _getDifficultyColor(widget.trek.difficulty),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.trek.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.trek.overview != null &&
                    widget.trek.overview!.isNotEmpty) ...[
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.trek.overview!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (widget.trek.itinerary != null &&
                    widget.trek.itinerary!.isNotEmpty) ...[
                  const Text(
                    'Itinerary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.trek.itinerary!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (widget.trek.highlights != null &&
                    widget.trek.highlights!.isNotEmpty) ...[
                  const Text(
                    'Highlights',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...widget.trek.highlights!.map(
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
                if (widget.trek.maxParticipants > 0) ...[
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
                              '${widget.trek.maxParticipants}',
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D0B0).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.vibration, color: Color(0xFF00D0B0), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tip: Shake your phone to quick book this trek',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF00A68C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _openBookingScreen,
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
