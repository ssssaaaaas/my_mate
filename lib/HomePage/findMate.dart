import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymate/HomePage/chat.dart';
import 'package:mymate/HomePage/map.dart';
import 'package:mymate/HomePage/setChat.dart';

class FindMatePage extends StatelessWidget {
  final String selectedCategory;

  const FindMatePage({Key? key, required this.selectedCategory})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _isJoining = false;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '나의 메이트 찾기',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFFE65951),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 30,
              height: 35,
              clipBehavior: Clip.none,
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
        child: Column(
          children: [
            Divider(
              color: Color(0xffE65951),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(selectedCategory)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('데이터 로드 중 오류가 발생했습니다.'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('표시할 데이터가 없습니다.'));
                  }

                  final posts = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];

                      final maxCount =
                          int.tryParse(post['count']?.toString() ?? '0') ?? 0;
                      final currentCount = post['currentCount'] ?? 0;

                      return InkWell(
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  post['title'] ?? '제목 없음',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(post['memo'] ?? '설명 없음'),
                                trailing: Text('$currentCount / $maxCount 명'),
                              ),
                              Divider(
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                          onTap: () async {
                            if (_isJoining) return;
                            _isJoining = true;

                            try {
                              if (currentCount >= maxCount) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('최대 인원에 도달하여 입장할 수 없습니다.')),
                                );
                              } else {
                                final docRef = FirebaseFirestore.instance
                                    .collection(selectedCategory)
                                    .doc(post.id);

                                await FirebaseFirestore.instance
                                    .runTransaction((transaction) async {
                                  final snapshot =
                                      await transaction.get(docRef);

                                  if (!snapshot.exists) {
                                    throw Exception("Document does not exist!");
                                  }

                                  final currentCountInTransaction =
                                      snapshot.data()?['currentCount'] ?? 0;

                                  if (currentCountInTransaction >= maxCount) {
                                    throw Exception(
                                        "Maximum participants reached.");
                                  }

                                  transaction.update(docRef, {
                                    'currentCount':
                                        currentCountInTransaction + 1,
                                  });
                                });

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      id: post.id,
                                      category: selectedCategory,
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('입장 처리 중 오류가 발생했습니다: $e')),
                              );
                            } finally {
                              _isJoining = false;
                            }
                          });
                    },
                  );
                },
              ),
            ),
          ],
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
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
