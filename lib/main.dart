import 'package:flutter/material.dart';
import 'pages/maps_page.dart';
import 'pages/home_page.dart';
import 'pages/about_page.dart';
import 'pages/profile_page.dart';
import 'widgets/custom_bottom_nav.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    HomePage(),
    AboutPage(),
    MapsPage(),
    ProfilePage(),
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
        child: _pages[_selectedIndex],
      ),
      // 🔵 Tombol Add (FloatingActionButton di tengah)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          // Use debugPrint for logging in Flutter
          debugPrint("Add button pressed");
          // Bisa diarahkan ke halaman Add atau popup dialog
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // 🔲 Bottom Navigation pakai BottomNavigationBar langsung (tanpa BottomAppBar)
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
