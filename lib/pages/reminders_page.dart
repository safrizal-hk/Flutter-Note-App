import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class RemindersListPage extends StatefulWidget {
  const RemindersListPage({super.key});

  @override
  State<RemindersListPage> createState() => _RemindersListPageState();
}

class _RemindersListPageState extends State<RemindersListPage> {
  final Map<DateTime, List<Map<String, dynamic>>> _reminders = {};
  DateTime _selectedDay = DateTime.now();

  void _toggleReminder(String id) {
    setState(() {
      final reminder = _reminders[_selectedDay]?.firstWhere((r) => r['id'] == id);
      if (reminder != null) {
        reminder['isCompleted'] = !reminder['isCompleted'];
      }
    });
  }

  void _deleteReminder(String id) {
    setState(() {
      _reminders[_selectedDay]?.removeWhere((reminder) => reminder['id'] == id);
    });
  }

  void _addReminder(String task) {
    setState(() {
      final reminderId = DateTime.now().millisecondsSinceEpoch.toString();
      final newReminder = {'id': reminderId, 'task': task, 'isCompleted': false};
      if (_reminders[_selectedDay] == null) {
        _reminders[_selectedDay] = [];
      }
      _reminders[_selectedDay]!.add(newReminder);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F0EF), // Set background color to match home
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
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              titleTextStyle: const TextStyle(color: Color(0xFF2E2E2E)), // Header text color
              formatButtonVisible: false,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _reminders[_selectedDay]?.length ?? 0,
              itemBuilder: (context, index) {
                final reminder = _reminders[_selectedDay]![index];
                return Card(
                  color: const Color(0xFFCCCBCA), // Card color
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: CheckboxListTile(
                    title: Text(
                      reminder['task'],
                      style: TextStyle(
                        color: const Color(0xFF2E2E2E), // Set text color to match home
                        decoration: reminder['isCompleted']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    value: reminder['isCompleted'],
                    onChanged: (value) => _toggleReminder(reminder['id']),
                    secondary: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteReminder(reminder['id']),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderCreatePage extends StatefulWidget {
  final Function(String) onSave;

  const ReminderCreatePage({super.key, required this.onSave});

  @override
  State<ReminderCreatePage> createState() => _ReminderCreatePageState();
}

class _ReminderCreatePageState extends State<ReminderCreatePage> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Reminder', style: TextStyle(color: Color(0xFF2E2E2E))), // Title color
        backgroundColor: const Color(0xFFCCCBCA), // AppBar background color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E2E2E)), // Back button color
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFF2F0EF), // Background color
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              style: const TextStyle(color: Color(0xFF2E2E2E)), // Set text color to match home
              decoration: InputDecoration(
                labelText: 'Task',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF2E2E2E)), // Focused border color
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onSave(_taskController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Save Reminder', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}