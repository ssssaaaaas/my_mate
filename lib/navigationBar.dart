import 'package:flutter/material.dart';
import 'package:mymate/mypage/mypage.dart';
import 'CalenerPage/Calendar.dart';
import 'HomePage/home.dart';
import 'RecommendPage/foodAI.dart';

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({Key? key}) : super(key: key);

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const FoodAIPage(),
    Calendar(),
    const MyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
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
              offset: Offset(0, 1),
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
                    icon: Icon(
                      Icons.home_filled,
                      size: 28,
                    ),
                    label: '홈'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.restaurant_menu,
                      size: 28,
                    ),
                    label: '메뉴 추천'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.calendar_month,
                      size: 28,
                    ),
                    label: '캘린더'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person_2,
                      size: 28,
                    ),
                    label: '프로필')
              ],
              currentIndex: _selectedIndex,
              unselectedItemColor: const Color(0XFFB1B8C0),
              selectedItemColor: Theme.of(context).colorScheme.primary,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
