import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymate/home.dart';

class navigationBar extends StatefulWidget {
  const navigationBar({Key? key}) : super(key: key);

  @override
  State<navigationBar> createState() => _navigationBarState();
}

class _navigationBarState extends State<navigationBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 1) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(),
          // AIfood(),
          // MyPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(23),
            topRight: Radius.circular(23),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(23),
            topRight: Radius.circular(23),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              unselectedFontSize: 10,
              selectedFontSize: 10,
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.bold),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_filled), label: '홈'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.games_outlined), label: '메뉴 추천'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_2_outlined), label: '프로필')
              ],
              currentIndex: _selectedIndex,
              unselectedItemColor: const Color(0XFFB1B8C0),
              selectedItemColor: const Color(0XFFD1726D),
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
