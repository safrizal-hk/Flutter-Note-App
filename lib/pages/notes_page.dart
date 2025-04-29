import 'package:flutter/material.dart';

class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  final List<Map<String, String>> _notes = [];

  void _deleteNote(String id) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Sudut membulat sesuai tema aplikasi
      ),
      title: Text(
        'Delete Confirmation',
        style: Theme.of(context).textTheme.headlineSmall, // Menggunakan textTheme dari tema
      ),
      content: Text(
        'Are you sure you want to delete this reminder?',
        style: Theme.of(context).textTheme.bodyMedium, // Menggunakan textTheme dari tema
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Tutup dialog tanpa menghapus
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).textTheme.bodyMedium?.color, // Warna teks dari tema
          ),
          child: const Text(
            'No',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _notes.removeWhere((note) => note['id'] == id); // Hapus note
            });
            Navigator.pop(context); // Tutup dialog setelah menghapus
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red, // Warna merah untuk aksi hapus
          ),
          child: const Text(
            'Yes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor, // Background dari tema
      elevation: 4, // Bayangan ringan
    ),
  );
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
      body: Stack(
        children: [
          _notes.isEmpty
              ? const Center(
                  child: Text(
                    'No notes yet. Add one!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 80),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          note['title']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            note['content']!,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNote(note['id']!), // Panggil fungsi dengan konfirmasi
                        ),
                        onTap: () => _navigateToEditNotePage(note),
                      ),
                    );
                  },
                ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _navigateToCreateNotePage,
              elevation: 4,
              child: const Icon(Icons.add),
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
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                alignLabelWithHint: true,
              ),
              minLines: 5,
              maxLines: null,
              keyboardType: TextInputType.multiline,
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
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
              ),
              maxLines: 5,
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