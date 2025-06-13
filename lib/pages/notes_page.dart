import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  final List<Map<String, dynamic>> _notes = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showArchived = false; // <--- Tambahkan ini

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredNotes {
    if (_searchQuery.isEmpty) {
      return _notes;
    }
    return _notes.where((note) {
      final title = note['title']?.toString().toLowerCase() ?? '';
      final content = note['content']?.toString().toLowerCase() ?? '';
      return title.contains(_searchQuery) || content.contains(_searchQuery);
    }).toList();
  }

  List<Map<String, dynamic>> get _sortedNotes {
    final filtered = _filteredNotes
        .where((note) =>
            (note['archived'] ?? false) ==
            _showArchived) // <--- filter archived
        .toList();
    filtered.sort((a, b) {
      final aPinned = a['pinned'] == true;
      final bPinned = b['pinned'] == true;

      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;

      final aDate =
          DateTime.tryParse(a['created_timestamp'] ?? '') ?? DateTime.now();
      final bDate =
          DateTime.tryParse(b['created_timestamp'] ?? '') ?? DateTime.now();
      return bDate.compareTo(aDate);
    });
    return filtered;
  }

  void _togglePin(String id) {
    setState(() {
      final noteIndex = _notes.indexWhere((note) => note['id'] == id);
      if (noteIndex != -1) {
        _notes[noteIndex]['pinned'] = !(_notes[noteIndex]['pinned'] ?? false);
      }
    });
  }

  void _toggleArchive(String id) {
    setState(() {
      final noteIndex = _notes.indexWhere((note) => note['id'] == id);
      if (noteIndex != -1) {
        _notes[noteIndex]['archived'] =
            !(_notes[noteIndex]['archived'] ?? false);
      }
    });
  }

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

  void _navigateToEditNotePage(Map<String, dynamic> note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditPage(note: note)),
    ).then((updatedNote) {
      if (updatedNote != null) {
        setState(() {
          final index = _notes.indexWhere((n) => n['id'] == note['id']);
          if (index != -1) {
            _notes[index] = updatedNote;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedNotes = _sortedNotes;

    return Scaffold(
      body: Column(
        children: [
          // Search Bar + Archive Toggle
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: _showArchived
                          ? 'Search archived notes...'
                          : 'Search notes...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            ),
                          IconButton(
                            tooltip: _showArchived
                                ? 'Show active notes'
                                : 'Show archived notes',
                            icon: Icon(
                              _showArchived
                                  ? Icons.sticky_note_2
                                  : Icons.archive,
                              color: _showArchived
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                            onPressed: () {
                              setState(() {
                                _showArchived = !_showArchived;
                              });
                            },
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Notes List
          Expanded(
            child: sortedNotes.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'No notes found matching "$_searchQuery"'
                          : _showArchived
                              ? 'No archived notes.'
                              : 'No notes yet. Add one!',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.only(
                        top: 0, bottom: 80, left: 16, right: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: sortedNotes.length,
                    itemBuilder: (context, index) {
                      final note = sortedNotes[index];
                      final isPinned = note['pinned'] == true;
                      final isArchived = note['archived'] == true;

                      return Card(
                        elevation: isPinned ? 4 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isPinned
                              ? BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3),
                                  width: 2,
                                )
                              : BorderSide.none,
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
                                    if (isPinned)
                                      Icon(
                                        Icons.push_pin,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    if (isPinned) const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        note['title']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isPinned
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
  icon: Icon(
    Icons.more_vert,
    color: Theme.of(context).textTheme.bodyMedium!.color, // Menggunakan bodyMedium color
  ),
  onSelected: (value) {
    if (value == 'delete') {
      _deleteNote(note['id']!);
    } else if (value == 'pin') {
      _togglePin(note['id']!);
    } else if (value == 'archive') {
      _toggleArchive(note['id']!);
    }
  },
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12), // Konsisten dengan tema
  ),
  elevation: 4, // Konsisten dengan cardTheme dan dialogTheme
  color: Theme.of(context).cardTheme.color, // Menggunakan cardTheme color untuk latar belakang
  itemBuilder: (BuildContext context) => [
    PopupMenuItem<String>(
      value: 'pin',
      child: Row(
        children: [
          Icon(
            isPinned ? Icons.push_pin_outlined : Icons.push_pin,
            size: 20,
            color: Theme.of(context).textTheme.bodyMedium!.color, // Warna ikon dari bodyMedium
          ),
          const SizedBox(width: 8),
          Text(
            isPinned ? 'Unpin' : 'Pin',
            style: Theme.of(context).textTheme.bodyMedium, // Menggunakan bodyMedium
          ),
        ],
      ),
    ),
    PopupMenuItem<String>(
      value: 'archive',
      child: Row(
        children: [
          Icon(
            isArchived ? Icons.unarchive : Icons.archive,
            size: 20,
            color: Theme.of(context).textTheme.bodyMedium!.color, // Warna ikon dari bodyMedium
          ),
          const SizedBox(width: 8),
          Text(
            isArchived ? 'Unarchive' : 'Archive',
            style: Theme.of(context).textTheme.bodyMedium, // Menggunakan bodyMedium
          ),
        ],
      ),
    ),
    PopupMenuItem<String>(
      value: 'delete',
      child: Row(
        children: [
          const Icon(
            Icons.delete,
            size: 20,
            color: Color(0xFFE57373), // Light red untuk aksi destruktif, kontras di kedua tema
          ),
          const SizedBox(width: 8),
          Text(
            'Delete',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFE57373), // Light red untuk teks
                ),
          ),
        ],
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
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Created: ${note['created_at']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateNotePage,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// NoteCreatePage
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
              minLines: 24,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final now = DateTime.now();
                final newNote = {
                  'id': now.millisecondsSinceEpoch.toString(),
                  'title': _titleController.text,
                  'content': _contentController.text,
                  'created_at': DateFormat('dd/MM/yyyy').format(now),
                  'created_timestamp': now.toIso8601String(),
                  'pinned': false,
                  'archived': false, // <--- Tambahkan field archived
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

// NoteEditPage
class NoteEditPage extends StatelessWidget {
  final Map<String, dynamic> note;

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
                final updatedNote = {
                  ...note,
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
