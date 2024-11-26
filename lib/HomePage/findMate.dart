import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'category_provider.dart';
import 'chat.dart';
import 'map.dart';
import 'setChat.dart';

class FindMatePage extends StatelessWidget {
  final String selectedCategory;

  const FindMatePage({Key? key, required this.selectedCategory})
      : super(key: key);

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
              width: 30,
              height: 35,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyMap(category: selectedCategory),
                    ),
                  );
                },
                icon: Icon(
                  Icons.location_on,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(selectedCategory)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('데이터 로드 중 오류가 발생했습니다.'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('표시할 데이터가 없습니다.'));
            }

            final posts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return InkWell(
                  child: Wrap(children: [
                    ListTile(
                      title: Text(post['title'] ?? '제목 없음'),
                      subtitle: Text(post['memo'] ?? '설명 없음'),
                      trailing: Text(post['count'] ?? '0명'),
                    ),
                  ]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          id: post.id,
                          category: selectedCategory,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(category: selectedCategory),
            ),
          );
        },
        child: const Icon(Icons.edit, color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 둥글기 설정
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label) {
    final selectedCategory = context.watch<CategoryProvider>().selectedCategory;

    return GestureDetector(
      onTap: () {
        context.read<CategoryProvider>().setSelectedCategory(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selectedCategory == label ? Colors.red : Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildMatePost({
    required String title,
    required String memo,
    required String count,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                memo,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
