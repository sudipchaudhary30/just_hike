import 'package:flutter/material.dart';

class SimpleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final Color backgroundColor;

  const SimpleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              description,
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle button press
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Learn More pressed!')),
                    );
                  },
                  child: const Text(
                    'LEARN MORE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
