import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pie_chart/pie_chart.dart';
import 'findmate.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, double> _categoryCounts = {};
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = _fetchCategoryCounts(
      ['Korean', 'Chinese', 'Japanese', 'Western', 'Dessert', 'LateSnack'],
      _categoryCounts,
    ).then((_) {
      print("Final _categoryCounts: $_categoryCounts"); // 디버깅 로그
    });
  }

  Future<void> _fetchCategoryCounts(
      List<String> categories, Map<String, double> categoryCounts) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    for (String category in categories) {
      try {
        final QuerySnapshot snapshot =
            await firestore.collection(category).get();
        categoryCounts[_getCategoryLabel(category)] =
            snapshot.docs.length.toDouble();
      } catch (e) {
        print("Error fetching category $category: $e");
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 50),
          Center(
            child: Image.asset(
              'assets/logo.png',
              height: 100,
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                "현재 인기 있는 카테고리",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FutureBuilder(
              future: _fetchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("데이터 로드 중 오류 발생: ${snapshot.error}"),
                  );
                }

                if (_categoryCounts.isEmpty ||
                    _categoryCounts.values.every((count) => count == 0)) {
                  return const Center(child: Text("차트에 표시할 데이터가 없습니다."));
                }

                return Column(
                  children: [
                    _buildTopCategory(),
                    const SizedBox(height: 20),
                    _buildCategoryRanking(),
                    const SizedBox(height: 30),
                    _buildCategoryChart(),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 30),
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
                      '한식',
                      'Korean'),
                  const SizedBox(width: 10),
                  _buildLottieCircle(
                      context,
                      "https://lottie.host/bfc93f77-20a0-4f4b-9d87-4242beaad756/HqbFaYRD21.json",
                      '중식',
                      'Chinese'),
                  const SizedBox(width: 10),
                  _buildLottieCircle(
                      context,
                      "https://lottie.host/e3d0f572-cc1a-47a2-9712-9c6a892fe684/kBtkxl7hoi.json",
                      '일식',
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
                      '양식',
                      'Western'),
                  const SizedBox(width: 10),
                  _buildLottieCircle(
                      context,
                      "https://lottie.host/057124e7-20d3-49c9-9d9f-39aff106d9d7/yG4BgeBHOU.json",
                      '디저트',
                      'Dessert'),
                  const SizedBox(width: 10),
                  _buildLottieCircle(
                      context,
                      "https://lottie.host/be08b500-e95e-4ca3-b993-6b021bfb1abc/K0L7LBexhS.json",
                      '야식',
                      'LateSnack'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategory() {
    final sortedCategories = _categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final mostPopular =
        sortedCategories.isNotEmpty ? sortedCategories.first.key : null;

    return mostPopular != null
        ? Column(
            children: [
              Text(
                "🔥 $mostPopular 🔥",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "가장 많은 사람들이 선택했어요!",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          )
        : const SizedBox();
  }

  Widget _buildCategoryRanking() {
    final sortedCategories = _categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedCategories.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final category = entry.value.key;
        final count = entry.value.value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _getCategoryColor(category),
                child: Text(
                  rank.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                "$count명 참여",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryChart() {
    return PieChart(
      dataMap: _categoryCounts,
      animationDuration: const Duration(milliseconds: 800),
      chartType: ChartType.ring,
      ringStrokeWidth: 32,
      chartRadius: MediaQuery.of(context).size.width * 0.6,
      colorList: [
        Colors.blue,
        Colors.red,
        Colors.orange,
        Colors.green,
        Colors.purple,
        Colors.yellow,
      ],
      chartValuesOptions: const ChartValuesOptions(
        showChartValuesInPercentage: true,
        showChartValues: true,
        chartValueBackgroundColor: Colors.grey,
      ),
      legendOptions: const LegendOptions(
        showLegends: true,
      ),
      centerText: "Rooms",
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'Korean':
        return '한식';
      case 'Chinese':
        return '중식';
      case 'Japanese':
        return '일식';
      case 'Western':
        return '양식';
      case 'Dessert':
        return '디저트';
      case 'LateSnack':
        return '야식';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '한식':
        return Colors.blue;
      case '중식':
        return Colors.red;
      case '일식':
        return Colors.orange;
      case '양식':
        return Colors.green;
      case '디저트':
        return Colors.purple;
      case '야식':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLottieCircle(
      BuildContext context, String lottieUrl, String label, String category) {
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
                  label,
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
