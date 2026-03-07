import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/utils/my_snackbar.dart';
import 'package:just_hike/features/auth/presentation/state/user_auth_state.dart';
import 'package:just_hike/features/auth/presentation/view_model/user_auth_viewmodel.dart';
import 'package:just_hike/features/dashboard/presentation/screens/bottom_screen_layout.dart';
import 'package:just_hike/core/widgets/my_button.dart';
import 'package:just_hike/core/widgets/my_textfield.dart';
import 'package:just_hike/features/auth/presentation/pages/register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool showPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(authViewmodelProvider.notifier)
          .login(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // () {
    //                     Navigator.pushReplacement(
    //                       context,
    //                       MaterialPageRoute(
    //                         builder: (_) => const BottomScreenLayout(),
    //                       ),
    //                     );
    //                   },

    ref.listen<AuthState>(authViewmodelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const BottomScreenLayout(),
          ),
        );
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        showMySnackBar(context: context, message: next.errorMessage!);
      }
    });
    return Scaffold(
      backgroundColor: const Color(0xFF00D0B0),

      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Top Logo Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/images/logo_justhike.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Log In",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  "Start your Adventure today.",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),

              const SizedBox(height: 20),

              // White Panel
              Container(
                width: double.infinity,
                height: 600,
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextformfield(
                      labelText: "Email",
                      hintText: "Enter your email address",
                      controller: emailController,
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Enter your password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Sign In button
                    MyButton(label: "Log in", onPressed: _handleLogin),

                    const SizedBox(height: 20),

                    // Google Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Colors.black12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/icons/google.png",
                              width: 22,
                              height: 22,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Login with Google",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
