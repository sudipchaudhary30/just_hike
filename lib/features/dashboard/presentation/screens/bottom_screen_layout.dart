import 'package:flutter/material.dart';
import 'package:just_hike/features/dashboard/presentation/screens/bottom_screen/explore_screen.dart';
import 'package:just_hike/features/dashboard/presentation/screens/bottom_screen/home_screen.dart';
import 'package:just_hike/features/dashboard/presentation/screens/bottom_screen/my_trips_screen.dart';
import 'package:just_hike/features/dashboard/presentation/screens/bottom_screen/profile_screen.dart';

class BottomScreenLayout extends StatefulWidget {
  final int initialIndex;
  const BottomScreenLayout({super.key, this.initialIndex = 0});

  @override
  State<BottomScreenLayout> createState() => _BottomScreenLayoutState();
}

class _BottomScreenLayoutState extends State<BottomScreenLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const ExploreScreen(),
    const MyTripsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lstBottomScreen[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(
            icon: Icon(Icons.backpack),
            label: "My Trips",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],

        selectedItemColor: Color(0xFF00D0B0),
        unselectedItemColor: const Color.fromARGB(255, 30, 122, 121),
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
