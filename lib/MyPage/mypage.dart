import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../MyPage/setAlarm.dart';
import 'package:mymate/MyPage/withdraw.dart';
import '../MyPage/profile2.dart';
import '../snackbar.dart';
import '../LogIn/login.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Uint8List? _imageBytes;
  String? _profileImageUrl;
  String nickName = '';

  @override
  void initState() {
    super.initState();
    _loadNickName();
  }

  Future<void> _loadNickName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          setState(() {
            nickName = snapshot['nickName'] ?? '';
            _profileImageUrl = snapshot['profileImage'] ?? '';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_imageBytes != null)
                      ClipOval(
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      )
                    else if (_profileImageUrl != null)
                      ClipOval(
                        child:
                            Image.network(_profileImageUrl!, fit: BoxFit.cover),
                      )
                    else
                      const Center(
                        child:
                            Icon(Icons.person, color: Colors.grey, size: 100),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              nickName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "Pretendard Variable",
                color: Color(0xFF2D2D2D),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(
                          thickness: 5, height: 67, color: Color(0XFFF5F3EF)),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Profile2(),
                            ),
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: Color(0XFF5E5E5E),
                            ),
                            Text(
                              " 프로필 편집",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Pretendard Variable",
                                color: Color(0XFF5E5E5E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const setAlarmPage(),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.settings_outlined,
                                  color: Color(0XFF5E5E5E),
                                ),
                                Text(
                                  " 알림 설정",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Pretendard Variable",
                                    color: Color(0XFF5E5E5E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          GestureDetector(
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              showCustomSnackbar(context, "로그아웃되었습니다!");
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Color(0XFF5E5E5E),
                                ),
                                Text(
                                  " 로그아웃",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Pretendard Variable",
                                    color: Color(0XFF5E5E5E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WithdrawPage(),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.cancel_outlined,
                                  color: Color(0XFF5E5E5E),
                                ),
                                Text(
                                  " 계정 탈퇴",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Pretendard Variable",
                                    color: Color(0XFF5E5E5E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 37),
                        ],
                      ),
                      const Divider(thickness: 4, color: Color(0XFFF5F3EF)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 80,
      backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) : null,
      child: _imageBytes == null ? const Icon(Icons.person, size: 50) : null,
    );
  }
}
