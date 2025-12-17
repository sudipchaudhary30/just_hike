import 'package:flutter/material.dart';
import 'package:just_hike/widgets/card_widget.dart';

void main() {
  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Card Widget',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Card Widget')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SimpleCard(
              title: 'Flutter Development',
              subtitle: 'Beginner',
              description:
                  'Learn how to build beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
            ),
          ],
        ),
      ),
    );
  }
}
