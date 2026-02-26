import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:just_hike/core/services/storage/user_session_service.dart';

final bookingProvider = Provider<BookingRepository>((ref) {
  final userSessionService = ref.read(UserSessionServiceProvider);
  assert(
    userSessionService is UserSessionService,
    'UserSessionServiceProvider is not initialized. Ensure ProviderScope with sharedPreferencesProvider override is at the root and app is fully initialized.',
  );
  return BookingRepository(userSessionService);
});

class BookingRepository {
  final Dio _dio = Dio();
  final UserSessionService _userSessionService;

  BookingRepository(this._userSessionService);

  Future<void> saveBooking(Map<String, dynamic> bookingData) async {
    final url = 'http://10.0.2.2:5050/api/bookings';
    final token = _userSessionService.getAuthToken();
    try {
      final response = await _dio.post(
        url,
        data: bookingData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to save booking');
      }
    } catch (e) {
      throw Exception('Failed to save booking: $e');
    }
  }
}
