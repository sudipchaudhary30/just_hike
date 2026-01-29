import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:just_hike/core/api/api_client.dart';
import 'package:just_hike/core/api/api_endpoints.dart';
import 'package:just_hike/core/services/storage/user_session_service.dart';
import 'package:just_hike/features/auth/data/datasources/user_auth_datasource.dart';
import 'package:just_hike/features/auth/data/models/auth_api_model.dart';
import 'package:just_hike/features/auth/data/models/user_auth_hive_model.dart';

//provider
final authRemoteProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(UserSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {'email': email, 'password': password},
    );

    print('=== LOGIN RESPONSE DEBUG ===');
    print('Full response: ${response.data}');
    print('Success: ${response.data['success']}');
    print('Data keys: ${(response.data['data'] as Map).keys}');
    print('Root level token: ${response.data['token']}');
    print('Data level token: ${response.data['data']['token']}');
    print('============================');

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;

      // Token might be at root level or inside data
      final token =
          response.data['token'] as String? ?? data['token'] as String?;

      // Add token to user data for parsing
      if (token != null) {
        data['token'] = token;
      }

      final user = AuthApiModel.fromJson(data);

      // Save auth token to secure storage
      if (token != null) {
        const storage = FlutterSecureStorage();
        await storage.write(key: 'auth_token', value: token);
        print(
          '✅ Token saved successfully: ${token.substring(0, 20)}...',
        ); // Debug log
      } else {
        print('❌ WARNING: No token received from login response');
      }

      //Save user session
      if (user.userAuthId != null) {
        await _userSessionService.saveUserSession(
          userId: user.userAuthId!,
          email: user.email,
          fullName: user.fullName,
          phoneNumber: user.phoneNumber,
          profileImage: user.profilePicture,
          authToken: token,
        );
      }
      return user;
    }
    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.user,
      data: {...user.toJson(), 'confirmPassword': user.password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }

    return user;
  }

  @override
  Future<AuthApiModel?> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    File? profileImage,
  }) async {
    try {
      // Manually get token from storage
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'auth_token');
      token ??= _userSessionService.getAuthToken();

      print('=== Update Profile Debug ===');
      print(
        'Token from storage: ${token != null ? token.substring(0, 20) + "..." : "NULL"}',
      );

      // Create FormData for multipart upload
      FormData formData = FormData.fromMap({
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        if (profileImage != null)
          'image': await MultipartFile.fromFile(
            profileImage.path,
            filename: profileImage.path.split('/').last,
          ),
      });

      // Upload using PUT request with explicit authorization header
      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final updatedUser = AuthApiModel.fromJson(data);
        if (updatedUser.userAuthId != null) {
          await _userSessionService.saveUserSession(
            userId: updatedUser.userAuthId!,
            email: updatedUser.email,
            fullName: updatedUser.fullName,
            phoneNumber: updatedUser.phoneNumber,
            profileImage: updatedUser.profilePicture,
            authToken: token,
          );
        }
        return updatedUser;
      }
      return null;
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
}
