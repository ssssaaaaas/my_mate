import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymate/navigationBar.dart';
import '/snackbar.dart';

class SignUpPage2 extends StatefulWidget {
  const SignUpPage2({Key? key}) : super(key: key);

  @override
  _SignUpPage2State createState() => _SignUpPage2State();
}

class _SignUpPage2State extends State<SignUpPage2> {
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isNicknameChecked = false;
  bool _isAllFieldsFilled = false;

  Future<void> _saveUserData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        showCustomSnackbar(context, "사용자 인증 정보를 찾을 수 없습니다.");
        return;
      }

      // 현재 사용자의 uid를 사용하여 기존 문서를 업데이트합니다
      await _firestore.collection('users').doc(currentUser.uid).update({
        'nickName': _nickNameController.text.trim(),
        'gender': _genderController.text.trim(),
        'location': _locationController.text.trim(),
      });

      showCustomSnackbar(context, "회원 정보가 저장되었습니다.");
    } catch (e) {
      showCustomSnackbar(context, "회원 정보 저장에 실패했습니다. 다시 시도해주세요.");
      print("Error saving user data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _nickNameController.addListener(_validateFields);
    _genderController.addListener(_validateFields);
    _locationController.addListener(_validateFields);
  }

  void _validateFields() {
    setState(() {
      _isAllFieldsFilled = _nickNameController.text.trim().isNotEmpty &&
          _genderController.text.trim().isNotEmpty &&
          _locationController.text.trim().isNotEmpty &&
          _isNicknameChecked;
    });
  }

  Future<void> _checkDuplicateNickname() async {
    String nickname = _nickNameController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임을 입력해주세요.'),
          duration: Duration(milliseconds: 500),
        ),
      );
      return;
    }

    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('nickName', isEqualTo: nickname)
        .get();

    if (result.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미 사용 중인 닉네임입니다. 다른 닉네임을 사용하세요.'),
          duration: Duration(milliseconds: 500),
        ),
      );
      setState(() {
        _isNicknameChecked = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사용 가능한 닉네임입니다.'),
          duration: Duration(milliseconds: 500),
        ),
      );
      setState(() {
        _isNicknameChecked = true;
      });
    }
    _validateFields();
  }

  Widget _buildNicknameField() {
    return Row(
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
                    '닉네임',
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
                        controller: _nickNameController,
                        cursorColor: Theme.of(context).colorScheme.primary,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: '느낌있게 알지?',
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
                          isCollapsed: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
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
              onPressed: _checkDuplicateNickname,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(width: 1, color: Color(0XFFC5524C)),
                ),
              ),
              child: const Text(
                '중복확인',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
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
                _buildNicknameField(),
                const SizedBox(height: 16.0),
                _buildTextField('성별', _genderController, false, hintText: '성별'),
                const SizedBox(height: 16),
                _buildTextField('위치', _locationController, false,
                    hintText: '나의 위치'),
                const SizedBox(height: 100),
                SizedBox(
                  width: 330,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nickNameController.text.trim().isEmpty ||
                          _genderController.text.trim().isEmpty ||
                          _locationController.text.trim().isEmpty ||
                          !_isNicknameChecked) {
                        showCustomSnackbar(context, '모든 필드를 올바르게 채워주세요.');
                      } else {
                        // Firestore에 데이터 저장
                        _saveUserData();

                        // 데이터를 성공적으로 저장한 후, navigationBar 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyNavigationBar(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFFC5524C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      '입장하기',
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
      padding: const EdgeInsets.fromLTRB(30.0, 0, 30, 0),
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
