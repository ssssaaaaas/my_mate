import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _nicknameController.text = userData['nickname'] ?? '';
        _emailController.text = userData['email'] ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지를 선택할 수 없습니다: $e')),
      );
    }
  }

  Future<String?> _uploadImage(Uint8List imageBytes) async {
    try {
      final fileName = _nicknameController.text.isNotEmpty
          ? _nicknameController.text
          : 'default_image_name';
      final ref = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child('$fileName.jpg');
      await ref.putData(imageBytes);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'nickname': _nicknameController.text.trim(),
        'email': _emailController.text.trim(),
      });
      if (_imageBytes != null) {
        final imageUrl = await _uploadImage(_imageBytes!);
        if (imageUrl != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'profileImage': imageUrl,
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 편집'),
        actions: [
          TextButton(
            onPressed: () async {
              await _updateUserData();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 5, right: 20),
              child: Text(
                '완료',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: _buildProfileImage(),
            ),
            IconButton(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt, size: 30),
              tooltip: '갤러리에서 이미지 선택',
            ),
            const SizedBox(height: 30),
            _buildTextField('닉네임', _nicknameController),
            _buildTextField('이메일', _emailController),
            _buildTextField('성별', _genderController),
            _buildTextField('나이', _ageController),
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
                    fontSize: 17,
                  ),
                ),
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
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

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('새 비밀번호와 비밀번호 확인이 일치하지 않습니다.')),
      );
      return;
    }

    try {
      await Future.delayed(const Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호 변경 실패: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 변경'),
        actions: [
          TextButton(
            onPressed: () async {
              await _changePassword();
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 5, right: 20),
              child: Text(
                '완료',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPasswordField('현재 비밀번호', _currentPasswordController),
            const SizedBox(height: 16),
            _buildPasswordField('새 비밀번호', _newPasswordController),
            const SizedBox(height: 16),
            _buildPasswordField('비밀번호 확인', _confirmPasswordController),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: TextField(
        controller: controller,
        obscureText: true,
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
