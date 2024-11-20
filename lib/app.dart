import 'package:flutter/material.dart';
import 'package:mymate/navigationbar.dart';
import 'home.dart';
import 'login.dart';

class MyMateApp extends StatelessWidget {
  const MyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyMate',
      routes: {
        '/': (context) => const MyNavigationBar(),
        '/home': (context) => const HomePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
