import 'package:flutter/material.dart';

class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  final List<Map<String, String>> _notes = [
    // {'id': '1', 'title': 'First Note', 'content': 'This is my first note'},
    // {'id': '2', 'title': 'Shopping List', 'content': 'Milk, Eggs, Bread'},
  ];

  void _deleteNote(String id) {
    setState(() {
      _notes.removeWhere((note) => note['id'] == id);
    });
  }

  void _navigateToCreateNotePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteCreatePage()),
    ).then((newNote) {
      if (newNote != null) {
        setState(() {
          _notes.add(newNote);
        });
      }
    });
  }

  void _navigateToEditNotePage(Map<String, String> note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditPage(note: note)),
    ).then((updatedNote) {
      if (updatedNote != null) {
        setState(() {
          final index = _notes.indexOf(note);
          _notes[index] = updatedNote;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EF),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _notes.isEmpty
                    ? const Center(
                        child: Text(
                          'No notes yet. Add one!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E2E2E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 16, bottom: 80), // Padding agar tidak tertutup FAB
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          final note = _notes[index];
                          return Card(
                            color: const Color(0xFFCCCBCA),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 0, // Sedikit bayangan untuk efek 3D
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Sudut lebih membulat
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              // leading: CircleAvatar(
                              //   backgroundColor: const Color(0xFF2E2E2E),
                              //   radius: 18,
                              //   child: Text(
                              //     '${index + 1}',
                              //     style: const TextStyle(
                              //       color: Colors.white,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // ),
                              title: Text(
                                note['title']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E2E2E),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  note['content']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteNote(note['id']!),
                              ),
                              onTap: () => _navigateToEditNotePage(note),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _navigateToCreateNotePage,
              backgroundColor: const Color(0xFF2E2E2E), // Ubah warna agar sesuai tema
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class NoteCreatePage extends StatelessWidget {
  const NoteCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Note',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E2E2E),
          ),
        ),
        backgroundColor: const Color(0xFFCCCBCA),
        centerTitle: true,
        elevation: 0, // Menghilangkan bayangan untuk tampilan lebih bersih
      ),
      body: Container(
        color: const Color(0xFFF2F0EF), // Sesuaikan dengan background HomePage
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Membuat elemen melebar penuh
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: const TextStyle(color: Color(0xFF2E2E2E)),
                filled: true,
                fillColor: const Color(0xFFCCCBCA).withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Color(0xFF2E2E2E)),
            ),
            const SizedBox(height: 16), // Jarak antar elemen
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                labelStyle: const TextStyle(color: Color(0xFF2E2E2E)),
                filled: true,
                fillColor: const Color(0xFFCCCBCA).withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 5,
              style: const TextStyle(color: Color(0xFF2E2E2E)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final newNote = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'title': _titleController.text,
                  'content': _contentController.text,
                };
                Navigator.pop(context, newNote);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E2E2E), // Warna tombol lebih gelap
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Save Note',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteEditPage extends StatelessWidget {
  final Map<String, String> note;

  const NoteEditPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final _titleController = TextEditingController(text: note['title']);
    final _contentController = TextEditingController(text: note['content']);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Note',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E2E2E),
          ),
        ),
        backgroundColor: const Color(0xFFCCCBCA),
        centerTitle: true,
        elevation: 0, // Menghilangkan bayangan untuk tampilan lebih bersih
      ),
      body: Container(
        color: const Color(0xFFF2F0EF), // Sesuaikan dengan background HomePage
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Membuat elemen melebar penuh
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: const TextStyle(color: Color(0xFF2E2E2E)),
                filled: true,
                fillColor: const Color(0xFFCCCBCA).withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Color(0xFF2E2E2E)),
            ),
            const SizedBox(height: 16), // Jarak antar elemen
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                labelStyle: const TextStyle(color: Color(0xFF2E2E2E)),
                filled: true,
                fillColor: const Color(0xFFCCCBCA).withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 5,
              style: const TextStyle(color: Color(0xFF2E2E2E)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final updatedNote = {
                  'id': note['id']!,
                  'title': _titleController.text,
                  'content': _contentController.text,
                };
                Navigator.pop(context, updatedNote);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E2E2E), // Warna tombol lebih gelap
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Update Note',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}