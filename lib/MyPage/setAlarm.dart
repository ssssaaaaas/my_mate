import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class setAlarmPage extends StatefulWidget {
  const setAlarmPage({super.key});

  @override
  _setAlarmPageState createState() => _setAlarmPageState();
}

class _setAlarmPageState extends State<setAlarmPage> {
  bool _serviceAlarm = true; // 서비스 알림 받기
  bool _eventAlarm = false; // 이벤트 & 광고 알림 받기

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            '설정',
            style: TextStyle(
              color: Color(0xFF2D2D2D),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Pretendard Variable',
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Text(
              '알림',
              style: TextStyle(
                color: Color(0xFF2D2D2D),
                fontSize: 18,
                fontFamily: 'Pretendard Variable',
                fontWeight: FontWeight.w500,
                height: 0,
              ),
            ),
          ),
          _buildSwitchTile(
            '서비스 알림 받기',
            _serviceAlarm,
            (value) {
              setState(() {
                _serviceAlarm = value;
              });
            },
          ),
          _buildSwitchTile(
            '이벤트 & 광고 알림 받기',
            _eventAlarm,
            (value) {
              setState(() {
                _eventAlarm = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2D2D2D),
              fontSize: 18,
              fontFamily: 'Pretendard Variable',
              fontWeight: FontWeight.w500,
              height: 0,
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
