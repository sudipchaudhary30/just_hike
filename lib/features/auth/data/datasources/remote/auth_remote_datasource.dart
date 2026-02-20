import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:just_hike/core/api/api_client.dart';
import 'package:just_hike/core/api/api_endpoints.dart';
import 'package:just_hike/core/services/storage/user_session_service.dart';
import 'package:just_hike/features/auth/data/datasources/user_auth_datasource.dart';
import 'package:just_hike/features/auth/data/models/auth_api_model.dart';

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
      ApiEndpoints.userRegister,
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
      // Get token from secure storage
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'auth_token');

      // Fallback to SharedPreferences if secure storage fails
      if (token == null || token.isEmpty) {
        print('⚠️ Token not in secure storage, attempting fallback...');
        // Note: Would need SharedPreferences injected here for full fallback
      } else {
        print('✅ Token retrieved from secure storage for profile update');
      }

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

      // Explicitly add Authorization header for multipart request
      final options = Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      print(
        '📤 Sending updateProfile request with token: ${token?.substring(0, 20)}...',
      );

      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: formData,
        options: options,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final updatedUser = AuthApiModel.fromJson(data);

        // Get token for session update
        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'auth_token');

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
