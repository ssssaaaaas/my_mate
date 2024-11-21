import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'navigationBar.dart';
import 'singup.dart';
import 'snackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> _getEmailById(String id) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['email'] as String?;
      }
    } catch (e) {
      print("이메일 조회 실패: $e");
    }
    return null;
  }

  Future<void> _login() async {
    // 입력값 확인
    if (_idController.text.isEmpty || _passwordController.text.isEmpty) {
      showCustomSnackbar(context, "아이디와 비밀번호를 모두 입력해주세요.");
      return;
    }

    try {
      String? email = await _getEmailById(_idController.text.trim());
      if (email != null) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: _passwordController.text.trim(),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyNavigationBar()),
          (Route<dynamic> route) => false,
        );
      } else {
        showCustomSnackbar(context, "아이디를 찾을 수 없습니다.");
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("로그인 실패: ${e.message}");
      showCustomSnackbar(context, "아이디 또는 비밀번호가 올바르지 않습니다.");
    } catch (e) {
      debugPrint("로그인 실패: $e");
      showCustomSnackbar(context, "잠시 후 다시 시도해주세요.");
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0XFFFFBAB6)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 120),
                Image.asset('assets/logo.png'),
                const SizedBox(height: 90),
                const Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '아이디',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Pretendard Variable',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: Container(
                    width: 350,
                    height: 31,
                    child: Center(
                      child: TextField(
                        controller: _idController,
                        cursorColor: const Color(0XFFC5524C),
                        decoration: const InputDecoration(
                          hintText: '먹부림 준비됐어?',
                          hintStyle: TextStyle(
                            color: Color(0xFFA7A7A7),
                            fontSize: 13,
                            fontFamily: 'Pretendard Variable',
                            fontWeight: FontWeight.w500,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFA8A8A8)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFA7A7A7)),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26.0),
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '비밀번호',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Pretendard Variable',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: Container(
                    width: 350,
                    height: 31,
                    child: Center(
                      child: TextField(
                        controller: _passwordController,
                        cursorColor: const Color(0XFFC5524C),
                        decoration: const InputDecoration(
                          hintText: '난 달달한거!',
                          hintStyle: TextStyle(
                            color: Color(0xFFA7A7A7),
                            fontSize: 13,
                            fontFamily: 'Pretendard Variable',
                            fontWeight: FontWeight.w500,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFA8A8A8)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFA7A7A7)),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        obscureText: true,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 330,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            '입장하기',
                            style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'Pretendard Variable',
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 330,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            '가입하기',
                            style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'Pretendard Variable',
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
