import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mymate/snackbar.dart';
import 'changepassword.dart';

class Profile2 extends StatefulWidget {
  final String? existingName;
  final String? existingEmail;
  final String? existingGender;
  final String? existingBirthdate;
  final String? existingImageUrl;

  const Profile2({
    super.key,
    this.existingName,
    this.existingEmail,
    this.existingGender,
    this.existingBirthdate,
    this.existingImageUrl,
  });

  @override
  State<Profile2> createState() => _Profile2State();
}

class _Profile2State extends State<Profile2> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  Uint8List? _imageBytes;
  String? _profileImageUrl;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<String?> _uploadImage(Uint8List imageBytes) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${DateTime.now().toIso8601String()}.jpg');
      await ref.putData(imageBytes);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          setState(() {
            _nicknameController.text = data?['nickName'] ?? '';
            _emailController.text = data?['email'] ?? '';
            _genderController.text = data?['gender'] ?? '';
            _birthdateController.text = data?['birthdate'] ?? '';
            _profileImageUrl = data?['profileImage'];
          });
        }
      } catch (e) {
        print('Failed to load user data: $e');
        showCustomSnackbar(context, '사용자 데이터를 불러오는데 실패했습니다.');
      }
    } else {
      showCustomSnackbar(context, '로그인된 사용자가 없습니다.');
    }
  }

  Future<void> _submitForm() async {
    final nickName = _nicknameController.text;
    final email = _emailController.text;
    final birthdate = _birthdateController.text;
    final gender = _genderController.text;

    if (nickName.isNotEmpty &&
        email.isNotEmpty &&
        birthdate.isNotEmpty &&
        gender.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? profileImageUrl = _profileImageUrl;

        if (_imageBytes != null) {
          profileImageUrl = await _uploadImage(_imageBytes!);
        }

        // 문서 ID를 user.uid로 설정
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        final updateData = {
          'nickName': nickName,
          'email': email,
          'birthdate': birthdate,
          'gender': gender,
          'profileImage': profileImageUrl ?? widget.existingImageUrl,
        };

        // 문서 업데이트
        await userDoc.set(updateData, SetOptions(merge: true));

        showCustomSnackbar(context, '프로필이 성공적으로 업데이트되었습니다.');
        Navigator.pop(context);
      } else {
        showCustomSnackbar(context, '로그인된 사용자가 없습니다.');
      }
    } else {
      showCustomSnackbar(context, '모든 필드를 채워주세요.');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingName != null) {
      _nicknameController.text = widget.existingName!;
    }
    if (widget.existingEmail != null) {
      _emailController.text = widget.existingEmail!;
    }
    if (widget.existingGender != null) {
      _genderController.text = widget.existingGender!;
    }
    if (widget.existingBirthdate != null) {
      _birthdateController.text = widget.existingBirthdate!;
    }
    _profileImageUrl = widget.existingImageUrl;
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('프로필 편집'),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: Text(
              '완료',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
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
                      child: Icon(Icons.person, color: Colors.grey, size: 100),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt, size: 30),
            tooltip: '갤러리에서 이미지 선택',
          ),
          const SizedBox(height: 10),
          _buildTextField('닉네임', _nicknameController),
          const SizedBox(height: 10),
          _buildTextField('이메일', _emailController),
          const SizedBox(height: 10),
          _buildTextField('성별', _genderController),
          const SizedBox(height: 10),
          _buildTextField('출생', _birthdateController),
          ListTile(
            trailing: TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChangePasswordPage())),
              child: Text(
                '비밀번호 변경',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          hintStyle: const TextStyle(color: Color(0xFFA7A7A7), fontSize: 16),
          focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
