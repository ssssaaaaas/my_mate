import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'setChat.dart';

class FindMatePage extends StatelessWidget {
  final String selectedCategory;

  const FindMatePage({Key? key, required this.selectedCategory})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '메이트 찾기 - $selectedCategory',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatPage(category: selectedCategory),
                      ),
                    );
                  },
                  child: _buildPostTile(post),
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
              builder: (context) => ChatPage(
                  category: selectedCategory), // Pass category to ChatPage
            ),
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildPostTile(QueryDocumentSnapshot post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          post['title'] ?? '제목 없음',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(post['memo'] ?? '설명 없음'),
        trailing: Text(
          post['count'] ?? '0명',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
