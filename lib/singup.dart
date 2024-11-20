//인증받기 -> 비밀번호 약한 경우, 비밀번호 6자 이상 / 메일 관련 오류 / 아이디 중복되는지 / 메일 형식 / => validation?

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup2.dart';
import 'snackbar.dart';

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

  Future<void> _verifyEmail() async {
    try {
      User? user = _auth.currentUser;
      await user?.reload();
      if (user != null && user.emailVerified) {
        // ID 중복 확인
        bool isDuplicate = await _checkDuplicateID(_idController.text.trim());
        if (isDuplicate) {
          showCustomSnackbar(context, '중복된 아이디입니다. 다른 아이디를 사용하세요.');
          return;
        }

        showCustomSnackbar(context, '이메일 인증 완료!');

        // Firebase Firestore에 사용자 정보 저장
        await _firestore.collection('users').doc(user.uid).set({
          'id': _idController.text.trim(), // 아이디
          'birthdate': _birthdateController.text.trim(), // 생년월일
          'email': _emailController.text.trim(), // 이메일
        });

        // 이후 SignUpPage2로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignUpPage2(),
          ),
        );
      } else {
        showCustomSnackbar(context, '이메일 인증을 완료해주세요.');
      }
    } catch (e) {
      print("이메일 확인 실패: $e");
      showCustomSnackbar(context, '이메일 확인 실패: ${e.toString()}');
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

                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        // 현재 유저 정보 새로고침
                        await user.reload();
                        user =
                            FirebaseAuth.instance.currentUser; // 새로고침된 정보로 업데이트

                        if (user!.emailVerified) {
                          // 이메일이 인증된 경우
                          bool isDuplicate = await _checkDuplicateID(
                              _idController.text.trim());
                          if (isDuplicate) {
                            showCustomSnackbar(
                                context, '중복된 아이디입니다. 다른 아이디를 사용하세요.');
                            return;
                          }

                          // Firestore에 사용자 정보 저장
                          await _firestore
                              .collection('users')
                              .doc(user.uid)
                              .set({
                            'id': _idController.text.trim(),
                            'birthdate': _birthdateController.text.trim(),
                            'email': _emailController.text.trim(),
                          });

                          // 다음 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage2(),
                            ),
                          );
                        } else {
                          showCustomSnackbar(context, "메일 인증을 완료해주세요.");
                        }
                      } else {
                        showCustomSnackbar(context, "이메일 인증을 먼저 진행해주세요.");
                      }
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
