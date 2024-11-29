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
    bool _isJoining = false; // 클릭 중복 방지용 플래그
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

                // Firestore 데이터 안전하게 변환
                final maxCount =
                    int.tryParse(post['count']?.toString() ?? '0') ??
                        0; // 최대 인원
                final currentCount = post['currentCount'] ?? 0; // 현재 인원 (기본값 0)

                return InkWell(
                    child: Wrap(
                      children: [
                        ListTile(
                          title: Text(post['title'] ?? '제목 없음'),
                          subtitle: Text(post['memo'] ?? '설명 없음'),
                          trailing: Text('$currentCount / $maxCount 명'),
                        ),
                      ],
                    ),
                    onTap: () async {
                      if (_isJoining) return; // 이미 클릭한 상태라면 함수 종료
                      _isJoining = true; // 클릭 중복 방지 플래그 설정

                      try {
                        if (currentCount >= maxCount) {
                          // 입장 제한
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('최대 인원에 도달하여 입장할 수 없습니다.')),
                          );
                        } else {
                          // Firestore 트랜잭션을 사용하여 currentCount 안전하게 증가
                          final docRef = FirebaseFirestore.instance
                              .collection(selectedCategory)
                              .doc(post.id);

                          await FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            final snapshot = await transaction.get(docRef);

                            if (!snapshot.exists) {
                              throw Exception("Document does not exist!");
                            }

                            final currentCountInTransaction =
                                snapshot.data()?['currentCount'] ?? 0;

                            if (currentCountInTransaction >= maxCount) {
                              throw Exception("Maximum participants reached.");
                            }

                            transaction.update(docRef, {
                              'currentCount': currentCountInTransaction + 1,
                            });
                          });

                          // 트랜잭션 성공 후 채팅 화면으로 이동
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
                        // 에러 처리
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('입장 처리 중 오류가 발생했습니다: $e')),
                        );
                      } finally {
                        _isJoining = false; // 작업 완료 후 플래그 해제
                      }
                    });
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
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
