import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class RemindersListPage extends StatefulWidget {
  const RemindersListPage({super.key});

  @override
  State<RemindersListPage> createState() => _RemindersListPageState();
}

class _RemindersListPageState extends State<RemindersListPage> {
  final Map<DateTime, List<Map<String, dynamic>>> _reminders = {};

  void _toggleReminder(DateTime date, String id) {
    setState(() {
      final reminder = _reminders[date]?.firstWhere((r) => r['id'] == id);
      if (reminder != null) {
        reminder['isCompleted'] = !reminder['isCompleted'];
      }
    });
  }

  void _deleteReminder(DateTime date, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Sudut membulat
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
                _reminders[date]?.removeWhere((reminder) => reminder['id'] == id); // Hapus reminder
                if (_reminders[date]?.isEmpty ?? false) {
                  _reminders.remove(date);
                }
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

  void _addReminder(DateTime date, String task) {
    setState(() {
      final reminderId = DateTime.now().millisecondsSinceEpoch.toString();
      final newReminder = {'id': reminderId, 'task': task, 'isCompleted': false};
      if (_reminders[date] == null) {
        _reminders[date] = [];
      }
      _reminders[date]!.add(newReminder);
    });
  }

  void _navigateToCreateReminder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReminderCreatePage(onSave: _addReminder),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _reminders.isEmpty
          ? const Center(
              child: Text(
                'No reminders yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView(
              children: _reminders.entries.map((entry) {
                final date = entry.key;
                final reminders = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        _formatDate(date),
                        style: Theme.of(context).textTheme.headlineSmall, // Gunakan tema
                      ),
                    ),
                    ...reminders.map((reminder) {
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: CheckboxListTile(
                          title: Text(
                            reminder['task'],
                            style: TextStyle(
                              decoration: reminder['isCompleted']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          value: reminder['isCompleted'],
                          onChanged: (value) => _toggleReminder(date, reminder['id']),
                          secondary: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteReminder(date, reminder['id']),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateReminder(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ReminderCreatePage extends StatefulWidget {
  final Function(DateTime, String) onSave;

  const ReminderCreatePage({super.key, required this.onSave});

  @override
  State<ReminderCreatePage> createState() => _ReminderCreatePageState();
}

class _ReminderCreatePageState extends State<ReminderCreatePage> {
  final _taskController = TextEditingController();
  DateTime _selectedDay = DateTime.now();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Reminder',
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
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({}) ??
                      Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.grey[Theme.of(context).brightness == Brightness.dark ? 700 : 300],
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Task',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  widget.onSave(_selectedDay, _taskController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save Reminder',
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