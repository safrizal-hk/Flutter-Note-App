import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  final List<Map<String, dynamic>> _notes = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showArchived = false;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await supabase
          .from('notes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      setState(() {
        _notes.clear();
        _notes.addAll(List<Map<String, dynamic>>.from(response));
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notes: $e')),
        );
      }
    }
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
        .where((note) => (note['archived'] ?? false) == _showArchived)
        .toList();
    filtered.sort((a, b) {
      final aPinned = a['pinned'] == true;
      final bPinned = b['pinned'] == true;

      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;

      final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now();
      final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
      return bDate.compareTo(aDate);
    });
    return filtered;
  }

  Future<void> _togglePin(String id) async {
    final noteIndex = _notes.indexWhere((note) => note['id'] == id);
    if (noteIndex != -1) {
      final newPinned = !(_notes[noteIndex]['pinned'] ?? false);
      try {
        await supabase.from('notes').update({'pinned': newPinned}).eq('id', id);
        setState(() {
          _notes[noteIndex]['pinned'] = newPinned;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to toggle pin: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleArchive(String id) async {
    final noteIndex = _notes.indexWhere((note) => note['id'] == id);
    if (noteIndex != -1) {
      final newArchived = !(_notes[noteIndex]['archived'] ?? false);
      try {
        await supabase
            .from('notes')
            .update({'archived': newArchived}).eq('id', id);
        setState(() {
          _notes[noteIndex]['archived'] = newArchived;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to toggle archive: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteNote(String id) async {
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
            onPressed: () async {
              try {
                await supabase.from('notes').delete().eq('id', id);
                setState(() {
                  _notes.removeWhere((note) => note['id'] == id);
                });
                Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete note: $e')),
                  );
                }
              }
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

  Future<void> _navigateToCreateNotePage() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteCreatePage()),
    ).then((_) async {
      await _loadNotes(); // Refresh list after creating a note
    });
  }

  Future<void> _navigateToEditNotePage(Map<String, dynamic> note) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditPage(note: note)),
    ).then((_) async {
      await _loadNotes(); // Refresh list after editing a note
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedNotes = _sortedNotes;

    return Scaffold(
      body: Column(
        children: [
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
                                        note['title'] ?? 'Untitled',
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
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                      ),
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          _deleteNote(note['id']);
                                        } else if (value == 'pin') {
                                          _togglePin(note['id']);
                                        } else if (value == 'archive') {
                                          _toggleArchive(note['id']);
                                        }
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                      color: Theme.of(context).cardTheme.color,
                                      itemBuilder: (BuildContext context) => [
                                        PopupMenuItem<String>(
                                          value: 'pin',
                                          child: Row(
                                            children: [
                                              Icon(
                                                isPinned
                                                    ? Icons.push_pin_outlined
                                                    : Icons.push_pin,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                isPinned ? 'Unpin' : 'Pin',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'archive',
                                          child: Row(
                                            children: [
                                              Icon(
                                                isArchived
                                                    ? Icons.unarchive
                                                    : Icons.archive,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                isArchived
                                                    ? 'Unarchive'
                                                    : 'Archive',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
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
                                                color: Color(0xFFE57373),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Delete',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color:
                                                          const Color(0xFFE57373),
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
                                    note['content'] ?? '',
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
                                  'Created: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(note['created_at']))}',
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
    final supabase = Supabase.instance.client;

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
              onPressed: () async {
                if (_titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title cannot be empty')),
                  );
                  return;
                }
                final now = DateTime.now();
                final userId = supabase.auth.currentUser?.id;
                if (userId != null) {
                  try {
                    await supabase.from('notes').insert({
                      'user_id': userId,
                      'title': _titleController.text,
                      'content': _contentController.text,
                      'pinned': false,
                      'archived': false,
                      'created_at': now.toIso8601String(),
                    });
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save note: $e')),
                    );
                  }
                }
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
    final _titleController = TextEditingController(text: note['title'] ?? '');
    final _contentController = TextEditingController(text: note['content'] ?? '');
    final supabase = Supabase.instance.client;

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
              onPressed: () async {
                if (_titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title cannot be empty')),
                  );
                  return;
                }
                try {
                  await supabase.from('notes').update({
                    'title': _titleController.text,
                    'content': _contentController.text,
                  }).eq('id', note['id']);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update note: $e')),
                  );
                }
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