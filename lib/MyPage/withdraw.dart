import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../LogIn/login.dart';
import '../snackbar.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  _WithdrawPageState createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _nickname = ''; // 닉네임 저장할 변수 추가

  @override
  void initState() {
    super.initState();
    _fetchUserNickname(); // 페이지 로드 시 닉네임 가져오기
  }

  Future<void> _fetchUserNickname() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        setState(() {
          _nickname = userDoc['nickname'] ?? ''; // 닉네임 필드에서 가져오기
        });
      }
    } catch (e) {
      print("닉네임 가져오기 실패: $e");
      showCustomSnackbar(context, "닉네임을 불러오는 데 실패했습니다.");
    }
  }

  Future<void> _deleteAccount() async {
    String enteredNickname = _nicknameController.text.trim();

    if (enteredNickname == _nickname) {
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          // Firestore에서 사용자 문서 삭제
          await _firestore.collection('users').doc(user.uid).delete();

          // Firebase Authentication에서 계정 삭제
          await user.delete();

          showCustomSnackbar(context, "계정이 삭제되었습니다!");

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        print("계정 삭제 중 오류 발생: $e");
        if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
          showCustomSnackbar(context, "최근에 로그인하지 않았습니다. 다시 로그인해주세요.");
        }
      }
    } else {
      showCustomSnackbar(context, "닉네임이 일치하지 않습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '내 계정',
            style: TextStyle(
              color: Color(0xFF2D2D2D),
              fontSize: 20,
              fontFamily: 'Pretendard Variable',
              fontWeight: FontWeight.w700,
              height: 0,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _deleteAccount,
            child: const Text(
              '완료',
              style: TextStyle(
                color: Color(0XFFC5524C),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '계정 탈퇴',
              style: TextStyle(
                color: Color(0xFF2D2D2D),
                fontSize: 18,
                fontFamily: 'Pretendard Variable',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              cursorColor: const Color(0XFFFFDCB2),
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: _nickname, // 동적으로 가져온 닉네임 사용
                hintText: '닉네임을 입력해주세요',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(width: 1, color: Color(0xFFA7A7A7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '*탈퇴를 위해 닉네임을 입력해주세요.',
              style: TextStyle(
                color: Color(0xFF818181),
                fontSize: 15,
                fontFamily: 'Pretendard Variable',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}