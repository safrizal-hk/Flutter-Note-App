import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Indeks tab yang aktif (0 untuk Notes, 1 untuk Reminders)

  // Fungsi untuk mengubah tab saat ditekan
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Konten untuk masing-masing tab
  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Notes Page', style: TextStyle(color: Colors.white, fontSize: 24))),
    Center(child: Text('Reminders Page', style: TextStyle(color: Colors.white, fontSize: 24))),
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
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFF232323),
        child: _pages[_selectedIndex], // Menampilkan halaman sesuai tab yang dipilih
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
        ],
        currentIndex: _selectedIndex, // Indeks tab aktif
        selectedItemColor: Colors.white, // Warna item yang dipilih
        unselectedItemColor: Colors.grey, // Warna item yang tidak dipilih
        backgroundColor: const Color(0xFF1E1E1E), // Warna latar BottomNavigationBar
        onTap: _onItemTapped, // Fungsi saat item ditekan
      ),
    );
  }
}