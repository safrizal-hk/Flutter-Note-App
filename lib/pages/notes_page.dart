import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Delete Confirmation',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          'Are you sure you want to delete this reminder?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
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
                _notes.removeWhere((note) => note['id'] == id);
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
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
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        elevation: 4,
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
              : GridView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 80, left: 16, right: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _navigateToEditNotePage(note),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      note['title']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _deleteNote(note['id']!);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  note['content']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Created: ${note['created_at']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
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
              shape: const CircleBorder(),
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
  Widget build(context) {
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
              minLines: 24,
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
                  'created_at': DateFormat('dd/MM/yyyy').format(DateTime.now()),
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
              minLines: 24,
              maxLines: null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final updatedNote = {
                  'id': note['id']!,
                  'title': _titleController.text,
                  'content': _contentController.text,
                  'created_at': note['created_at']!, // Preserve original creation date
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