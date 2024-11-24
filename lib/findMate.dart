import 'package:flutter/material.dart';
import 'setChat.dart';

class FindMatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '나의 메이트 찾기',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF49454F),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 24,
              height: 24,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: Icon(
                Icons.location_on,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCategoryChip('치킨'),
                      _buildCategoryChip('피자'),
                      _buildCategoryChip('햄버거'),
                      _buildCategoryChip('떡볶이'),
                    ],
                  ),
                  _buildMatePost(
                    title: '야식팟 모집중~',
                    description: '카벤에서 같이 꼬꼬뽀끼 먹을 분들 구해요!',
                    currentPeople: '7/10',
                  ),
                  _buildMatePost(
                    title: '치킨 메이트 찾아요',
                    description: '치코파닭 먹으면서 친해지고 싶어요!',
                    currentPeople: '2/5',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Opacity(
        opacity: 0.90,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatPage()),
            );
          },
          backgroundColor: const Color(0xFFC5524C),
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 12)),
    );
  }

  Widget _buildMatePost({
    required String title,
    required String description,
    required String currentPeople,
  }) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          Text(currentPeople, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
