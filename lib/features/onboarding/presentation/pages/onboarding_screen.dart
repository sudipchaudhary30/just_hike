import 'package:flutter/material.dart';
import 'package:just_hike/features/auth/presentation/pages/login_screen.dart';
import 'package:just_hike/core/widgets/my_button.dart' as my_button;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboard1.jpg",
      "title": "Explore Mountains",
      "subtitle": "Discover the best trails and scenic views.",
    },
    {
      "image": "assets/images/onboard2.jpg",
      "title": "Track Your Hikes",
      "subtitle": "Log your progress and stay motivated.",
    },
    {
      "image": "assets/images/onboard3.jpg",
      "title": "Share Adventures",
      "subtitle": "Connect with friends and the hiking community.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildPageContent(Map<String, String> data, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(data["image"]!, fit: BoxFit.cover),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.1),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 115),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedOpacity(
                opacity: _currentPage == index ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                child: Text(
                  data["title"]!,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              AnimatedOpacity(
                opacity: _currentPage == index ? 1 : 0,
                duration: const Duration(milliseconds: 800),
                child: Text(
                  data["subtitle"]!,
                  style: const TextStyle(fontSize: 17, color: Colors.white70),
                ),
              ),

              const SizedBox(height: 20),

              my_button.MyButton(
                label: _currentPage == onboardingData.length - 1
                    ? "Get Started"
                    : "Next",
                onPressed: () {
                  if (_currentPage == onboardingData.length - 1) {
                    goHome();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            itemBuilder: (context, index) {
              return _buildPageContent(onboardingData[index], index);
            },
          ),

          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: goHome,
              child: const Text(
                "Skip",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(onboardingData.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 18 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
