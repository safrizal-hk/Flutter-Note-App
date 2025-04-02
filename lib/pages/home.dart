import 'package:flutter/material.dart';
import 'notes_page.dart';
import 'reminders_page.dart';
import 'pomodoro_timer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Daftar halaman untuk ditampilkan berdasarkan indeks
  static const List<Widget> _pages = <Widget>[
    NotesListPage(),
    RemindersListPage(),
    PomodoroTimerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Note App',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E2E2E),
          ),
        ),
        backgroundColor: const Color(0xFFCCCBCA),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF2F0EF),
        child: _pages[_selectedIndex], // Menampilkan halaman sesuai indeks
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Pomodoro',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2E2E2E),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFFCCCBCA),
        onTap: _onItemTapped,
      ),
    );
  }
}