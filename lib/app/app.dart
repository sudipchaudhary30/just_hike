import 'package:flutter/material.dart';
import 'package:just_hike/features/splash/presentation/pages/splash_screen.dart';
import 'package:just_hike/features/dashboard/presentation/screens/bottom_screen/my_trips_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {'/myTrips': (context) => MyTripsScreen()},
    );
  }
}
