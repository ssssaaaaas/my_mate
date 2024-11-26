import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup2.dart';
import '/snackbar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignUpPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _sendVerificationEmail() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        showCustomSnackbar(context, "인증 이메일이 발송되었습니다. 이메일을 확인하세요.");
      }
    } catch (e) {
      print("이메일 인증 실패: $e");
      showCustomSnackbar(context, "이메일 인증 실패: ${e.toString()}");
    }
  }

  Future<void> _signUp() async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        showCustomSnackbar(context, "로그인 상태를 확인해주세요.");
        return;
      }

      // 사용자 정보 최신화
      await user.reload();
      user = _auth.currentUser;

      if (user != null && !user.emailVerified) {
        showCustomSnackbar(context, "이메일 인증을 완료해주세요.");
        return;
      }

      // 아이디 중복 체크
      bool isDuplicate = await _checkDuplicateID(_idController.text.trim());
      if (isDuplicate) {
        showCustomSnackbar(context, '중복된 아이디입니다. 다른 아이디를 사용하세요.');
        return;
      }

      // Firestore에 사용자 정보 저장
      String profileImageUrl = await _getDefaultProfileImage();
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'id': _idController.text.trim(),
          'birthdate': _birthdateController.text.trim(),
          'email': _emailController.text.trim(),
          'profileImage': profileImageUrl,
        });
      } else {
        showCustomSnackbar(context, "유저 정보를 확인할 수 없습니다.");
      }

      // 다음 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignUpPage2(),
        ),
      );
    } catch (e) {
      print("회원가입 실패: $e");
      showCustomSnackbar(context, "회원가입 중 오류가 발생했습니다.");
    }
  }

  Future<String> _getDefaultProfileImage() async {
    try {
      // Firebase Storage에 미리 업로드된 기본 이미지의 URL 사용
      return 'https://firebasestorage.googleapis.com/v0/b/my-mate-b5aee.firebasestorage.app/o/profile_images%2Fdefault.png?alt=media&token=f248e183-075a-46c3-9051-036f9b4c651f';
    } catch (e) {
      print("기본 프로필 이미지 URL 가져오기 실패: $e");
      return ''; // 실패 시 빈 문자열 반환
    }
  }

  Future<bool> _checkDuplicateID(String id) async {
    final QuerySnapshot result =
        await _firestore.collection('users').where('id', isEqualTo: id).get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.isNotEmpty;
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 120),
                Image.asset('assets/logo.png'),
                _buildTextField('아이디', _idController, false,
                    hintText: '먹부림 준비됐어?'),
                const SizedBox(height: 16.0),
                _buildTextField('비밀번호', _passwordController, true,
                    hintText: '난 달달한거!'),
                const SizedBox(height: 16.0),
                _buildTextField('생년월일', _birthdateController, false,
                    hintText: 'YYYY/MM/DD',
                    keyboardType: TextInputType.datetime),
                const SizedBox(height: 16.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 15, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '이메일 인증',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontFamily: 'Pretendard Variable',
                                  fontWeight: FontWeight.w600,
                                  height: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Container(
                              width: 330,
                              height: 31,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: 330,
                                  child: TextField(
                                    controller: _emailController,
                                    cursorColor:
                                        Theme.of(context).colorScheme.primary,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      hintText: '~@gmail.com',
                                      hintStyle: TextStyle(
                                        color: Color(0xFFA7A7A7),
                                        fontSize: 13,
                                        fontFamily: 'Pretendard Variable',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFA8A8A8)),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFA7A7A7)),
                                      ),
                                      isCollapsed: true,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Container(
                        width: 69,
                        height: 27,
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                          onPressed: _sendVerificationEmail,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: const BorderSide(
                                  width: 1, color: Color(0XFFC5524C)),
                            ),
                          ),
                          child: const Text(
                            '인증받기',
                            style: TextStyle(
                              color: Color(0XFFC5524C),
                              fontSize: 13,
                              fontFamily: 'Pretendard Variable',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70),
                SizedBox(
                  width: 330,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_idController.text.isEmpty ||
                          _passwordController.text.isEmpty ||
                          _birthdateController.text.isEmpty ||
                          _emailController.text.isEmpty) {
                        showCustomSnackbar(context, "모든 필드를 입력해주세요.");
                        return;
                      }

                      await _signUp();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFFC5524C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      '다음으로',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Pretendard Variable',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '뒤로가기',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isPassword, {
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Pretendard Variable',
                fontWeight: FontWeight.w600,
                height: 0,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            width: 330,
            height: 31,
            child: Center(
              child: TextField(
                controller: controller,
                cursorColor: Theme.of(context).colorScheme.primary,
                obscureText: isPassword,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Color(0xFFA7A7A7),
                    fontSize: 13,
                    fontFamily: 'Pretendard Variable',
                    fontWeight: FontWeight.w500,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA8A8A8)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA7A7A7)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
