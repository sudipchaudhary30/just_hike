import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/api/api_client.dart';
import 'package:just_hike/core/api/api_endpoints.dart';
import 'package:just_hike/features/dashboard/data/models/package_model.dart';

final packagesRemoteDatasourceProvider = Provider<IPackagesRemoteDatasource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return PackagesRemoteDatasource(apiClient);
});

abstract class IPackagesRemoteDatasource {
  Future<List<PackageModel>> getAllPackages();
  Future<List<PackageModel>> getUpcomingPackages();
  Future<List<PackageModel>> getPastPackages();
  Future<List<PackageModel>> getWishlist();
  Future<PackageModel> getPackageById(String id);
  Future<bool> toggleWishlist(String packageId);
}

class PackagesRemoteDatasource implements IPackagesRemoteDatasource {
  final ApiClient _apiClient;

  PackagesRemoteDatasource(this._apiClient);

  @override
  Future<List<PackageModel>> getAllPackages() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getAllPackages);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return List<PackageModel>.from(
          data.map((x) => PackageModel.fromJson(x as Map<String, dynamic>)),
        );
      }
      return [];
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PackageModel>> getUpcomingPackages() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getUpcomingPackages);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return List<PackageModel>.from(
          data.map((x) => PackageModel.fromJson(x as Map<String, dynamic>)),
        );
      }
      return [];
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PackageModel>> getPastPackages() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getPastPackages);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return List<PackageModel>.from(
          data.map((x) => PackageModel.fromJson(x as Map<String, dynamic>)),
        );
      }
      return [];
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PackageModel>> getWishlist() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getWishlist);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return List<PackageModel>.from(
          data.map((x) => PackageModel.fromJson(x as Map<String, dynamic>)),
        );
      }
      return [];
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PackageModel> getPackageById(String id) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.getAllPackages}/$id',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PackageModel.fromJson(response.data['data'] ?? response.data);
      }
      throw Exception('Failed to fetch package');
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> toggleWishlist(String packageId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.wishlistToggle(packageId),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
