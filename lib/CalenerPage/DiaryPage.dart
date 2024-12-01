import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import '../snackbar.dart';
import 'UploadImage.dart';
import 'firestore_service.dart';

class DiaryPage extends StatefulWidget {
  final DateTime date;
  final String? initialNote;
  final String? initialImageUrl;
  final String? initialFoodType;
  final void Function(String? imageUrl, String foodType, String note) onSave;
  final VoidCallback onDelete;

  DiaryPage({
    required this.date,
    this.initialNote,
    this.initialImageUrl,
    this.initialFoodType,
    required this.onSave,
    required this.onDelete,
  });

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  late TextEditingController _noteController;
  final FirestoreService _firestoreService = FirestoreService();
  final List<String> _dropdownItems = ['한식', '중식', '일식', '양식', '야식', '디저트'];
  bool _isSaved = false;
  bool _isEditing = false;
  Uint8List? _imageBytes;
  String? _imageUrl;
  String? _foodType;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
    _imageUrl = widget.initialImageUrl;
    // 처음에는 수정 모드 활성화, 일기를 불러오면 비활성화
    _isEditing = widget.initialNote == null && widget.initialImageUrl == null;
    _loadDiaryEntry();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadDiaryEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 상태가 아닙니다.')),
      );
      return;
    }
    try {
      final diaryEntry =
          await _firestoreService.getDiaryEntry(user.uid, widget.date);
      if (diaryEntry != null) {
        setState(() {
          _noteController.text = diaryEntry.note ?? '';
          _foodType = diaryEntry.foodType;
          _imageUrl = diaryEntry.imageUrl;
          _isSaved = true;
        });
      } else {
        print('No diary entry found for this date.');
        _isSaved = false; // 일기가 없는 경우 저장 상태가 아님
      }
    } catch (e) {
      print('Failed to load diary entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('다이어리를 불러오는 데 실패했습니다.')),
      );
    }
  }

  void _handleImagePick(Uint8List? imageBytes) {
    setState(() {
      _imageBytes = imageBytes;
    });
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 상태가 아닙니다.')),
      );
      return;
    }

    String? imageUrl;
    if (_imageBytes != null) {
      final fileName =
          '${widget.date.toIso8601String()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      try {
        final storageRef =
            FirebaseStorage.instance.ref().child('images').child(fileName);
        final uploadTask = storageRef.putData(_imageBytes!);
        final snapshot = await uploadTask.whenComplete(() {});
        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        print('Failed to upload image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 업로드 실패')),
        );
        return;
      }
    }

    try {
      // foodType과 note 순서 맞춰서 호출
      await _firestoreService.saveDiaryEntry(
        user.uid, // userId
        widget.date, // date
        _noteController.text,
        _foodType!,
        imageUrl ?? _imageUrl, // imageUrl
      );
      showCustomSnackbar(context, '저장되었습니다!');
      widget.onSave(imageUrl ?? _imageUrl, _foodType!, _noteController.text);
      setState(() {
        _isSaved = true;
        _isEditing = false;
        _imageUrl = imageUrl ?? _imageUrl;
        _foodType = _foodType;
      });

      // 캘린더 페이지 새로고침
      Navigator.of(context).pop(); // 현재 DiaryPage 닫기
    } catch (e) {
      print('Failed to save diary entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('다이어리 저장 실패')),
      );
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _isSaved = false; // 수정 모드로 바뀌면 저장 상태가 아님
    });
  }

  void customDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('assets/deletedialog.png'),
              Positioned(
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: const Text(
                          '예',
                          style: TextStyle(
                            color: Color(0XFF2D2D2D),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _deleteDiaryEntry();
                        },
                      ),
                      const SizedBox(width: 80),
                      TextButton(
                        child: const Text(
                          '아니오',
                          style: TextStyle(
                            color: Color(0XFF2D2D2D),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Container _buildBottomSheetTile({
    IconData? icon,
    required String text,
    required VoidCallback onTap,
    bool isCancel = false,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isCancel ? Colors.transparent : const Color(0XFFFFF4E7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: <Widget>[
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Icon(icon),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteDiaryEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 상태가 아닙니다.')),
      );
      return;
    }

    try {
      // Firestore 문서 삭제
      await _firestoreService.deleteDiaryEntry(user.uid, widget.date);

      // Firebase Storage에서 이미지 삭제
      if (_imageUrl != null) {
        final storageRef = FirebaseStorage.instance.refFromURL(_imageUrl!);
        await storageRef.delete();
      }

      // 앱 상태 업데이트
      widget.onDelete();
      _resetState(); // 상태 초기화
      Navigator.pop(context);
    } catch (e) {
      print('Failed to delete diary entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제 실패')),
      );
    }
  }

  void _resetState() {
    setState(() {
      _isSaved = false;
      _isEditing = true; // 삭제 후 수정 모드로 전환
      _noteController.text = '';
      _imageBytes = null;
      _imageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.xmark),
        ),
        centerTitle: true,
        title: Text(
          DateFormat('yyyy년 M월').format(widget.date),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_isEditing || !_isSaved) // 수정 모드이거나 저장되지 않은 경우 체크마크 표시
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _save,
            ),
        ],
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    Text(
                      '${DateFormat('d ').format(widget.date)}',
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${DateFormat('EEEE').format(widget.date)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (_isSaved &&
                        !_isEditing) // 저장된 상태이면서 수정 모드가 아닐 때 팝업메뉴버튼 표시
                      PopupMenuButton(
                        elevation: 4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(19),
                        ),
                        icon: const Icon(
                          size: 24,
                          color: Color(0XFF666667),
                          CupertinoIcons.ellipsis_vertical,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _startEditing();
                          } else if (value == 'delete') {
                            customDeleteDialog();
                          }
                        },
                        position: PopupMenuPosition.under,
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Container(
                              width: 200,
                              height: 20,
                              child: const Row(
                                children: [
                                  Icon(Icons.flag),
                                  SizedBox(width: 8),
                                  Text('수정하기'),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Container(
                              width: 200,
                              height: 20,
                              child: const Row(
                                children: [
                                  Icon(Icons.delete),
                                  SizedBox(width: 8),
                                  Text('삭제하기'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        DropdownButton<String>(
                          hint: const Text('음식 메뉴'),
                          value: _foodType,
                          items: _dropdownItems.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _foodType = value;
                            });
                          },
                        ),
                      ],
                    ),
                    TextField(
                        controller: _noteController,
                        cursorColor: const Color(0XFFC5524C),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '소중한 추억을 입력하세요...',
                          hintStyle: TextStyle(color: Color(0XFF74828D)),
                        ),
                        style: const TextStyle(color: Color(0XFF4E5968)),
                        maxLines: null,
                        enabled: _isEditing),
                    const SizedBox(height: 10),
                    Container(
                      height: 300,
                      width: double.infinity,
                      color: Colors.white,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_imageBytes != null)
                            Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            )
                          else if (_imageUrl != null)
                            Image.network(
                              _imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                .expectedTotalBytes!)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return const Center(
                                    child: Text('이미지를 불러오는 중 문제가 발생했습니다.'));
                              },
                            ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: UploadImage(onPickImage: _handleImagePick),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
