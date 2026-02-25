import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_hike/features/dashboard/data/repositories/booking_repository.dart';

final bookingProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});

class BookingRepository {
  final List<Map<String, dynamic>> _bookings = [];

  Future<void> saveBooking(Map<String, dynamic> bookingData) async {
    await Future.delayed(const Duration(seconds: 1));
    _bookings.add(bookingData);
  }

  List<Map<String, dynamic>> getBookings() => _bookings;
}
