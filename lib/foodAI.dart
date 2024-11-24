import 'package:flutter/material.dart';

class FoodAIPage extends StatelessWidget {
  const FoodAIPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Food AI Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Explore the AI-powered food recommendations!')
          ],
        ),
      ),
    );
  }
}
