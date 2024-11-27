import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mymate/HomePage/findMate.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Image.asset(
              'assets/logo.png',
            ),
          ),
          const SizedBox(height: 150),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLottieCircle(
                      context,
                      "https://lottie.host/38977bd0-40ec-4a0a-b57e-6b5ab196c761/Lp9GuVzlsK.json",
                      'Korean'),
                  const SizedBox(width: 10),
                  _buildLottieCircle(
                      context,
                      "https://lottie.host/bfc93f77-20a0-4f4b-9d87-4242beaad756/HqbFaYRD21.json",
                      'Chinese'),
                  const SizedBox(width: 10),
                  _buildLottieCircle(
                      context,
                      "https://lottie.host/e3d0f572-cc1a-47a2-9712-9c6a892fe684/kBtkxl7hoi.json",
                      'Japanese'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLottieCircle(
                      context,
                      "https://lottie.host/663b3be2-3e78-4a34-b804-00d1ec4e7d34/EPoCzQGDM4.json",
                      'Western'),
                  const SizedBox(width: 10),
                  _buildLottieCircle(
                      context,
                      "https://lottie.host/057124e7-20d3-49c9-9f9f-39aff106d9d7/yG4BgeBHOU.json",
                      'LateSnack'),
                  const SizedBox(width: 10),
                  _buildLottieCircle(
                      context,
                      "https://lottie.host/be08b500-e95e-4ca3-b993-6b021bfb1abc/K0L7LBexhS.json",
                      'Dessert'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLottieCircle(
      BuildContext context, String lottieUrl, String category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FindMatePage(selectedCategory: category),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: 110,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Lottie.network(
                  lottieUrl,
                  fit: BoxFit.cover,
                  repeat: true,
                  animate: true,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 40,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  category,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
