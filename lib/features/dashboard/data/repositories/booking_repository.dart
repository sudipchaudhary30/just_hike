import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:just_hike/features/dashboard/domain/entities/package_entity.dart';

class BookingRepository {
  final Dio _dio;
  BookingRepository(this._dio);

  Future<bool> bookTrek({
    required PackageEntity trek,
    required DateTime fromDate,
    required String nationality,
    required int adults,
    required int children,
  }) async {
    final url = 'http://localhost:5050/api/bookings';
    final payload = {
      'trekId': trek.id,
      'fromDate': fromDate.toIso8601String(),
      'nationality': nationality,
      'adults': adults,
      'children': children,
    };
    try {
      final response = await _dio.post(
        url,
        data: jsonEncode(payload),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> fetchBookings() async {
    final url = 'http://localhost:5050/api/bookings';
    try {
      final response = await _dio.get(url);
      return response.data['data'] ?? [];
    } catch (e) {
      return [];
    }
  }
}
