import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notes_page.dart';
import 'reminders_page.dart';
import 'pomodoro_timer.dart';
import '../theme/theme_provider.dart';
import 'settings_page.dart';

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

  static const List<Widget> _pages = <Widget>[
    RemindersListPage(),
    PomodoroTimerPage(),
    NotesListPage(),
    SettingsPage(),
  ];

  static const List<String> _pageTitles = <String>[
    'Reminders',
    'Pomodoro Timer',
    'Notes',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitles[_selectedIndex],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}