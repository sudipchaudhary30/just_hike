import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/services/storage/user_session_service.dart';
import 'package:just_hike/features/dashboard/domain/entities/package_entity.dart';

final localTripsProvider =
    NotifierProvider<LocalTripsNotifier, LocalTripsState>(
      LocalTripsNotifier.new,
    );

class LocalTripsState {
  final List<Map<String, dynamic>> bookings;
  final List<Map<String, dynamic>> wishlist;

  const LocalTripsState({required this.bookings, required this.wishlist});

  LocalTripsState copyWith({
    List<Map<String, dynamic>>? bookings,
    List<Map<String, dynamic>>? wishlist,
  }) {
    return LocalTripsState(
      bookings: bookings ?? this.bookings,
      wishlist: wishlist ?? this.wishlist,
    );
  }

  bool isWishlisted(String trekId) {
    return wishlist.any((trek) => (trek['id'] ?? '').toString() == trekId);
  }
}

class LocalTripsNotifier extends Notifier<LocalTripsState> {
  static const String _bookingsKey = 'local_bookings_v1';
  static const String _wishlistKey = 'local_wishlist_v1';

  @override
  LocalTripsState build() {
    return LocalTripsState(
      bookings: _readList(_bookingsKey),
      wishlist: _readList(_wishlistKey),
    );
  }

  Future<void> reloadFromStorage() async {
    state = LocalTripsState(
      bookings: _readList(_bookingsKey),
      wishlist: _readList(_wishlistKey),
    );
  }

  Future<void> addBooking({
    required PackageEntity trek,
    required DateTime startDate,
    required int participants,
  }) async {
    final bookingId = '${trek.id}_${startDate.millisecondsSinceEpoch}';
    final int tripDays = trek.daysCount <= 0 ? 1 : trek.daysCount;
    final endDate = startDate.add(Duration(days: tripDays - 1));

    final booking = <String, dynamic>{
      'id': bookingId,
      'trekId': trek.id,
      'participants': participants,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'bookedAt': DateTime.now().toIso8601String(),
      'trek': _toTrekMap(trek),
    };

    final alreadyExists = state.bookings.any((existing) {
      final sameTrek = (existing['trekId'] ?? '').toString() == trek.id;
      final sameStart =
          (existing['startDate'] ?? '').toString() ==
          startDate.toIso8601String();
      return sameTrek && sameStart;
    });

    if (alreadyExists) {
      return;
    }

    state = state.copyWith(bookings: [booking, ...state.bookings]);
    await _persist();
  }

  Future<bool> toggleWishlist(PackageEntity trek) async {
    final exists = state.isWishlisted(trek.id);
    if (exists) {
      state = state.copyWith(
        wishlist: state.wishlist
            .where((item) => (item['id'] ?? '').toString() != trek.id)
            .toList(),
      );
    } else {
      state = state.copyWith(wishlist: [_toTrekMap(trek), ...state.wishlist]);
    }

    await _persist();
    return !exists;
  }

  Future<bool> toggleWishlistFromMap(Map<String, dynamic> trekMap) async {
    final trekId = (trekMap['id'] ?? '').toString();
    if (trekId.isEmpty) {
      return false;
    }

    final exists = state.isWishlisted(trekId);
    if (exists) {
      state = state.copyWith(
        wishlist: state.wishlist
            .where((item) => (item['id'] ?? '').toString() != trekId)
            .toList(),
      );
    } else {
      state = state.copyWith(wishlist: [trekMap, ...state.wishlist]);
    }

    await _persist();
    return !exists;
  }

  List<Map<String, dynamic>> _readList(String key) {
    final prefs = ref.read(sharedPreferencesProvider);
    final raw = prefs.getStringList(key) ?? const <String>[];

    final parsed = <Map<String, dynamic>>[];
    for (final item in raw) {
      try {
        final decoded = json.decode(item);
        if (decoded is Map<String, dynamic>) {
          parsed.add(decoded);
        }
      } catch (_) {
        // Ignore malformed entry and continue.
      }
    }
    return parsed;
  }

  Future<void> _persist() async {
    final prefs = ref.read(sharedPreferencesProvider);

    final encodedBookings = state.bookings.map(json.encode).toList();
    final encodedWishlist = state.wishlist.map(json.encode).toList();

    await prefs.setStringList(_bookingsKey, encodedBookings);
    await prefs.setStringList(_wishlistKey, encodedWishlist);
  }

  Map<String, dynamic> _toTrekMap(PackageEntity trek) {
    return <String, dynamic>{
      'id': trek.id,
      'title': trek.title,
      'description': trek.description,
      'location': trek.location,
      'price': trek.price,
      'rating': trek.rating,
      'daysCount': trek.daysCount,
      'nightsCount': trek.nightsCount,
      'difficulty': trek.difficulty,
      'imageUrl': trek.imageUrl,
      'thumbnailUrl': trek.thumbnailUrl,
      'status': trek.status,
    };
  }
}
