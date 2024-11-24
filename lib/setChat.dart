import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _selectedOption = 'men';
  String? _selectedValue;
  final List<String> _dropdownItems = ['1명', '2명', '3명', '4명', '5명', '6명이상'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.close))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '채팅방 생성',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: '채팅방 이름',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: '카테고리',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        value: 'men',
                        groupValue: _selectedOption,
                        onChanged: (value) {
                          setState(() {
                            _selectedOption = value!;
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
                        groupValue: _selectedOption,
                        onChanged: (value) {
                          setState(() {
                            _selectedOption = value!;
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
                        groupValue: _selectedOption,
                        onChanged: (value) {
                          setState(() {
                            _selectedOption = value!;
                          });
                        },
                      ),
                      Text('남녀무관'),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButton<String>(
                hint: const Text('인원 수'),
                value: _selectedValue,
                items: _dropdownItems.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                },
              ),
              SizedBox(
                height: 100,
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                width: 350,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: '메모',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 16),
                        cursorColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
