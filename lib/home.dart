import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'findMate.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Image.asset(
              'assets/my_mate.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildLottieCircle(
                  "https://lottie.host/38977bd0-40ec-4a0a-b57e-6b5ab196c761/Lp9GuVzlsK.json",
                  context),
              _buildLottieCircle(
                  "https://lottie.host/bfc93f77-20a0-4f4b-9d87-4242beaad756/HqbFaYRD21.json",
                  context),
              _buildLottieCircle(
                  "https://lottie.host/e3d0f572-cc1a-47a2-9712-9c6a892fe684/kBtkxl7hoi.json",
                  context),
              _buildLottieCircle(
                  "https://lottie.host/663b3be2-3e78-4a34-b804-00d1ec4e7d34/EPoCzQGDM4.json",
                  context),
              _buildLottieCircle(
                  "https://lottie.host/057124e7-20d3-49c9-9f9f-39aff106d9d7/yG4BgeBHOU.json",
                  context),
              _buildLottieCircle(
                  "https://lottie.host/be08b500-e95e-4ca3-b993-6b021bfb1abc/K0L7LBexhS.json",
                  context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLottieCircle(String lottieUrl, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FindMatePage(),
          ),
        );
      },
      child: ClipOval(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
      ),
    );
  }
}
