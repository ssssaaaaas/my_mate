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
  final Map<String, double> _categoryCounts = {}; // 카테고리별 문서 개수 저장
  late Future<void> _fetchFuture; // FutureBuilder용 Future

  // initState() 메서드에 print 추가
  @override
  void initState() {
    super.initState();
    _fetchFuture = _fetchCategoryCounts(
      ['Korean', 'Chinese', 'Japanese', 'Western', 'Dessert', 'LateSnack'],
      _categoryCounts,
    ).then((_) {
      print("Final _categoryCounts: $_categoryCounts"); // 데이터 확인
    });
  }

  /// Firestore에서 카테고리별 문서 개수를 가져오는 함수
  Future<void> _fetchCategoryCounts(
      List<String> categories, Map<String, double> categoryCounts) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    for (String category in categories) {
      try {
        final QuerySnapshot snapshot =
            await firestore.collection(category).get();
        categoryCounts[category] = snapshot.docs.length.toDouble(); // 문서 개수 저장
        print("Category: $category, Count: ${snapshot.docs.length}"); // 디버깅 로그
      } catch (e) {
        print("Error fetching category $category: $e"); // 오류 로그
      }
    }
    print("Final Category Counts: $categoryCounts"); // 최종 데이터 로그
    setState(() {}); // 상태 업데이트
  }

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
          const SizedBox(height: 50),

          // Pie Chart Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FutureBuilder(
              future: _fetchFuture, // 데이터를 가져오는 Future
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("데이터 로드 중 오류 발생: ${snapshot.error}"),
                  );
                }

                // 데이터가 없거나 값이 모두 0일 경우
                if (_categoryCounts.isEmpty ||
                    _categoryCounts.values.every((count) => count == 0)) {
                  return const Center(child: Text("차트에 표시할 데이터가 없습니다."));
                }

                // PieChart 렌더링
                return PieChart(
                  dataMap: _categoryCounts, // 카테고리 데이터
                  animationDuration: const Duration(milliseconds: 800),
                  chartType: ChartType.ring,
                  ringStrokeWidth: 32,
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
                    legendShape: BoxShape.rectangle,
                    legendPosition: LegendPosition.bottom,
                    legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerText: "Rooms",
                );
              },
            ),
          ),

          const SizedBox(height: 50),

          // 카테고리 버튼 섹션
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
                      'Dessert'),
                  const SizedBox(width: 10),
                  _buildLottieCircle(
                      context,
                      "https://lottie.host/be08b500-e95e-4ca3-b993-6b021bfb1abc/K0L7LBexhS.json",
                      'LateSnack'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Lottie 애니메이션 버튼
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
