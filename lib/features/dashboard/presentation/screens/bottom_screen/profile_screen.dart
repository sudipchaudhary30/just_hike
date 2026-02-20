import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/api/api_endpoints.dart';
import 'package:just_hike/core/services/storage/user_session_service.dart';
import 'package:just_hike/features/auth/presentation/pages/login_screen.dart';
import 'package:just_hike/features/auth/presentation/state/user_auth_state.dart';
import 'package:just_hike/features/auth/presentation/view_model/user_auth_viewmodel.dart';
import 'package:just_hike/features/editprofile/presentation/pages/editprofile_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _imageCacheBuster = DateTime.now().millisecondsSinceEpoch;
  String? _lastProfilePicture;

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewmodelProvider, (previous, next) {
      final newPicture = next.authEntity?.profilePicture;
      if (newPicture != null && newPicture != _lastProfilePicture) {
        setState(() {
          _lastProfilePicture = newPicture;
          _imageCacheBuster = DateTime.now().millisecondsSinceEpoch;
        });
      }
    });
    return Scaffold(
      backgroundColor: const Color(0xFF00D0B0),
      body: SafeArea(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final authState = ref.watch(authViewmodelProvider);
                          final userSession = ref.read(
                            UserSessionServiceProvider,
                          );
                          final profilePicture =
                              authState.authEntity?.profilePicture ??
                              userSession.getUserProfileImage();

                          return profilePicture != null
                              ? CachedNetworkImage(
                                  key: Key(
                                    '$profilePicture-$_imageCacheBuster',
                                  ),
                                  imageUrl:
                                      '${ApiEndpoints.profilePicture(profilePicture)}?v=$_imageCacheBuster',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF00D0B0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Color(0xFF00D0B0),
                                      ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFF00D0B0),
                                );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // White Content Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Edit Profile Button
                        Align(
                          alignment: Alignment.topRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Editprofile(),
                                ),
                                (route) =>
                                    false, // This removes all previous routes
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D0B0),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Name and Email
                        const Text(
                          'Sudip Chaudhary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'sudip253@gmail.com',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),

                        const SizedBox(height: 16),

                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statItem('12', 'Countries Visited'),
                            _statItem('3', 'Booking'),
                            _statItem('25', 'Completed Treks'),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Account Section
                        const Text(
                          'Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        _menuItem(
                          icon: Icons.calendar_today_outlined,
                          title: 'My Treks',
                          onTap: () {},
                        ),
                        _menuItem(
                          icon: Icons.payment_outlined,
                          title: 'Payment Methods',
                          onTap: () {},
                        ),
                        _menuItem(
                          icon: Icons.description_outlined,
                          title: 'Travel Documents',
                          onTap: () {},
                        ),
                        _menuItem(
                          icon: Icons.campaign_outlined,
                          title: 'Be a Partner',
                          onTap: () {},
                        ),

                        const SizedBox(height: 16),

                        // Other Section
                        const Text(
                          'Other',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        _menuItem(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          onTap: () {},
                        ),
                        _menuItem(
                          icon: Icons.help_outline,
                          title: 'Support / Help Center',
                          onTap: () {},
                        ),
                        _menuItem(
                          icon: Icons.logout,
                          title: 'Logout',
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) =>
                                  false, // This removes all previous routes
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00D0B0),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF00D0B0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF00D0B0), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}
