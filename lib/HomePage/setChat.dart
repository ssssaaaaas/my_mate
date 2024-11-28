import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mymate/moveMap.dart';
import 'products.dart';

class ChatPage extends StatefulWidget {
  final String category;

  const ChatPage({Key? key, required this.category}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  String _selectedGender = 'men';
  int? _selectedCount;
  LatLng? _location;

  final List<int> _dropdownItems = [1, 2, 3, 4, 5, 6]; // 인원 수를 정수로 정의

  Future<void> _saveChat() async {
    final String title = _titleController.text;
    final String memo = _memoController.text;

    if (title.isEmpty ||
        memo.isEmpty ||
        _selectedCount == null ||
        _location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    try {
      await _firestoreService.addMate(
        category: widget.category,
        title: title,
        memo: memo,
        gender: _selectedGender,
        count: _selectedCount!, // 정수형으로 저장
        location: GeoPoint(_location!.latitude, _location!.longitude), // 위치 저장
        currentCount: 0, // 기본값 설정
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('채팅방이 성공적으로 저장되었습니다!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
      );
    }
  }

  Future<void> _pickLocation() async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Movelocation(),
      ),
    );
    if (selectedLocation != null) {
      setState(() {
        _location = selectedLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅방 생성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '채팅방 이름',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _memoController,
              decoration: InputDecoration(
                labelText: '메모',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    hint: const Text('인원 수'),
                    value: _selectedCount,
                    items: _dropdownItems.map((int item) {
                      return DropdownMenuItem<int>(
                        value: item,
                        child: Text('$item명'), // 정수 값을 '1명', '2명' 형태로 표시
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        _selectedCount = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: 'men',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                    Text('남자'),
                  ],
                ),
                SizedBox(width: 10),
                Row(
                  children: [
                    Radio<String>(
                      value: 'woman',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                    Text('여자'),
                  ],
                ),
                SizedBox(width: 10),
                Row(
                  children: [
                    Radio<String>(
                      value: 'doncare',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                    Text('남녀무관'),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _pickLocation,
              child: Text(_location == null ? '위치 설정' : '위치 수정'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveChat,
              child: const Text('저장'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
