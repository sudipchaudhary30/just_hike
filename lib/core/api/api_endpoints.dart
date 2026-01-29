class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  static const String baseUrl = 'http://10.0.2.2:5050/api/auth';

  // Media server URL (for static files like images)
  static const String mediaServerUrl = 'http://10.0.2.2:5050';

  //static const String baseUrl = 'http://localhost:3000/api/v1';
  // For Android Emulator use: 'http://10.0.2.2:3000/api/v1'
  // For iOS Simulator use: 'http://localhost:5000/api/v1'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:5000/api/v1'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String user = '/register';
  static const String userLogin = '/login';
  static const String userRegister = '/register';
  static String userById(String id) => '/user/$id';
  static String userPhoto(String id) => '/user/$id/photo';
  static const String updateProfile = '/update-profile';

  // Profile picture URL helper - following teacher's pattern
  static String profilePicture(String filename) {
    // If already a full URL, return as-is
    if (filename.startsWith('http')) return filename;

    // If filename includes 'uploads/', use it directly
    if (filename.contains('uploads/')) {
      return '$mediaServerUrl/$filename';
    }

    // Otherwise, assume it's in uploads folder
    return '$mediaServerUrl/uploads/$filename';
  }

  // Legacy helper for backward compatibility
  static String getImageUrl(String imagePath) => profilePicture(imagePath);
}
