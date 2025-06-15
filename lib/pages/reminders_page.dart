import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemindersListPage extends StatefulWidget {
  const RemindersListPage({super.key});

  @override
  State<RemindersListPage> createState() => _RemindersListPageState();
}

class _RemindersListPageState extends State<RemindersListPage>
    with SingleTickerProviderStateMixin {
  final Map<DateTime, List<Map<String, dynamic>>> _reminders = {};
  DateTime _focusedDay = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadReminders();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await supabase
          .from('reminders')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: true)
          .order('time', ascending: true);
      setState(() {
        _reminders.clear();
        for (var reminder in response) {
          final date = DateTime.parse(reminder['date']);
          final normalizedDate = DateTime(date.year, date.month, date.day);
          if (_reminders[normalizedDate] == null) {
            _reminders[normalizedDate] = [];
          }
          _reminders[normalizedDate]!.add({
            'id': reminder['id'],
            'task': reminder['task'],
            'isCompleted': reminder['is_completed'],
            'label': reminder['label'],
            'time': TimeOfDay(
              hour: TimeOfDay.fromDateTime(DateTime.parse('1970-01-01 ${reminder['time']}')).hour,
              minute: TimeOfDay.fromDateTime(DateTime.parse('1970-01-01 ${reminder['time']}')).minute,
            ),
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reminders: $e')),
        );
      }
    }
  }

  Future<void> _deleteReminder(DateTime date, String id, Function closeBottomSheet) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Delete Confirmation',
          style: Theme.of(context).dialogTheme.titleTextStyle,
        ),
        content: Text(
          'Are you sure you want to delete this reminder?',
          style: Theme.of(context).dialogTheme.contentTextStyle,
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
                await supabase.from('reminders').delete().eq('id', id);
                setState(() {
                  _reminders[normalizedDate]?.removeWhere((reminder) => reminder['id'] == id);
                  if (_reminders[normalizedDate]?.isEmpty ?? false) {
                    _reminders.remove(normalizedDate);
                  }
                });
                Navigator.pop(context);
                closeBottomSheet();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete reminder: $e')),
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

  Future<void> _updateReminder(DateTime date, String id, String newTask, String newLabel, TimeOfDay newTime) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    try {
      await supabase.from('reminders').update({
        'task': newTask,
        'label': newLabel,
        'is_completed': newLabel == 'Done',
        'time': '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}:00',
      }).eq('id', id);
      setState(() {
        final reminder = _reminders[normalizedDate]?.firstWhere((r) => r['id'] == id);
        if (reminder != null) {
          reminder['task'] = newTask;
          reminder['label'] = newLabel;
          reminder['isCompleted'] = newLabel == 'Done';
          reminder['time'] = newTime;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update reminder: $e')),
        );
      }
    }
  }

  Future<void> _addReminder(DateTime date, String task, TimeOfDay time) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to add a reminder')),
        );
      }
      return;
    }
    try {
      final reminderId = DateTime.now().millisecondsSinceEpoch.toString();
      await supabase.from('reminders').insert({
        'user_id': userId,
        'date': normalizedDate.toIso8601String().split('T')[0],
        'task': task,
        'is_completed': false,
        'label': 'To Do',
        'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
      });
      setState(() {
        if (_reminders[normalizedDate] == null) {
          _reminders[normalizedDate] = [];
        }
        _reminders[normalizedDate]!.add({
          'id': reminderId,
          'task': task,
          'isCompleted': false,
          'label': 'To Do',
          'time': time,
        });
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add reminder: $e')),
        );
      }
    }
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
    final DateFormat formatter = DateFormat('EEEE, d MMMM yyyy', 'en_US');
    return formatter.format(date);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dateTime);
  }

  TimeOfDay? _parseTime(String input) {
    final RegExp timeRegExp = RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$');
    if (timeRegExp.hasMatch(input)) {
      final parts = input.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }

  void _showTimeEditBottomSheet(
      BuildContext context, TimeOfDay initialTime, Function(TimeOfDay) onSave) {
    int hour = initialTime.hour;
    int minute = initialTime.minute;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Time',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NumberPicker(
                        value: hour,
                        minValue: 0,
                        maxValue: 23,
                        zeroPad: true,
                        onChanged: (value) {
                          setModalState(() {
                            hour = value;
                          });
                        },
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey),
                        selectedTextStyle:
                            Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Text(':'),
                      NumberPicker(
                        value: minute,
                        minValue: 0,
                        maxValue: 59,
                        zeroPad: true,
                        onChanged: (value) {
                          setModalState(() {
                            minute = value;
                          });
                        },
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey),
                        selectedTextStyle:
                            Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        child: Text(
                          'Cancel',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final newTime = TimeOfDay(hour: hour, minute: minute);
                          onSave(newTime);
                          Navigator.pop(context);
                        },
                        style: Theme.of(context)
                            .elevatedButtonTheme
                            .style
                            ?.copyWith(
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                        child: Text(
                          'Set Time',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .elevatedButtonTheme
                                        .style
                                        ?.foregroundColor
                                        ?.resolve({}),
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditReminderBottomSheet(
      DateTime date, Map<String, dynamic> reminder) {
    final TextEditingController taskController =
        TextEditingController(text: reminder['task']);
    String selectedLabel = reminder['label'];
    TimeOfDay selectedTime = reminder['time'] ?? TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Reminder',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      labelText: 'Task',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      _showTimeEditBottomSheet(context, selectedTime,
                          (newTime) {
                        setModalState(() {
                          selectedTime = newTime;
                        });
                      });
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                      ),
                      child: Text(
                        _formatTime(selectedTime),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedLabel,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).inputDecorationTheme.fillColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: ['To Do', 'In Progress', 'Done'].map((String label) {
                      return DropdownMenuItem<String>(
                        value: label,
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setModalState(() {
                          selectedLabel = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          _deleteReminder(date, reminder['id'], () {
                            Navigator.pop(context);
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text(
                          'Delete',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (taskController.text.isNotEmpty) {
                            _updateReminder(
                              date,
                              reminder['id'],
                              taskController.text,
                              selectedLabel,
                              selectedTime,
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please enter a valid task')),
                            );
                          }
                        },
                        style: Theme.of(context)
                            .elevatedButtonTheme
                            .style
                            ?.copyWith(
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                        child: Text(
                          'Save',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .elevatedButtonTheme
                                        .style
                                        ?.foregroundColor
                                        ?.resolve({}),
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  List<DateTime> _getWeekDates(DateTime weekStart) {
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final normalizedFocusedDay =
        DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    final todayReminders = _reminders[normalizedFocusedDay] ?? [];
    final weekStart = _getWeekStart(_focusedDay);
    final weekDates = _getWeekDates(weekStart);

    // Mengurutkan reminder berdasarkan waktu
    todayReminders.sort((a, b) {
      final timeA = a['time'] as TimeOfDay;
      final timeB = b['time'] as TimeOfDay;
      final dateA = DateTime(
          2025, 6, 15, timeA.hour, timeA.minute); // Tanggal acuan (15/6/2025)
      final dateB = DateTime(
          2025, 6, 15, timeB.hour, timeB.minute); // Tanggal acuan (15/6/2025)
      return dateA.compareTo(dateB);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_left,
                            color: Theme.of(context).iconTheme.color),
                        onPressed: () {
                          setState(() {
                            _focusedDay =
                                _focusedDay.subtract(const Duration(days: 7));
                            _animationController.reset();
                            _animationController.forward();
                          });
                        },
                      ),
                      Text(
                        '${DateFormat('MMMM yyyy', 'en_US').format(weekStart)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_right,
                            color: Theme.of(context).iconTheme.color),
                        onPressed: () {
                          setState(() {
                            _focusedDay =
                                _focusedDay.add(const Duration(days: 7));
                            _animationController.reset();
                            _animationController.forward();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 70,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final availableWidth = constraints.maxWidth;
                        final itemWidth = (availableWidth - 32) / 7;

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: weekDates.length,
                          itemBuilder: (context, index) {
                            final date = weekDates[index];
                            final isSelected = isSameDay(date, _focusedDay);
                            final hasReminders = _reminders[DateTime(
                                        date.year, date.month, date.day)]
                                    ?.isNotEmpty ??
                                false;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _focusedDay = date;
                                  _animationController.reset();
                                  _animationController.forward();
                                });
                              },
                              child: Container(
                                width: itemWidth,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black
                                      : Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('EEE', 'en_US').format(date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? const Color.fromARGB(
                                                    255, 0, 0, 0)
                                                : Colors.white
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.black
                                                : Colors.white
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                      ),
                                    ),
                                    if (hasReminders) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: todayReminders.isEmpty
                  ? Center(
                      child: Text(
                        'No reminders for this day',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    )
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: todayReminders.length,
                        itemBuilder: (context, index) {
                          final reminder = todayReminders[index];
                          final time = _formatTime(reminder['time']);
                          final color = reminder['label'] == 'To Do'
                              ? Colors.blue[400]
                              : reminder['label'] == 'In Progress'
                                  ? Colors.orange[400]
                                  : Colors.green[400];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    time,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withOpacity(0.7),
                                        ),
                                  ),
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 2,
                                      height: 80,
                                      color: Theme.of(context).dividerColor,
                                    ),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        _showEditReminderBottomSheet(
                                            normalizedFocusedDay, reminder),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 40,
                                            color: color,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  reminder['task'],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        decoration: reminder[
                                                                'isCompleted']
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : TextDecoration
                                                                .none,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        color?.withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    reminder['label'],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: color,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.more_vert,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateReminder(context),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ReminderCreatePage extends StatefulWidget {
  final Function(DateTime, String, TimeOfDay) onSave;

  const ReminderCreatePage({super.key, required this.onSave});

  @override
  State<ReminderCreatePage> createState() => _ReminderCreatePageState();
}

class _ReminderCreatePageState extends State<ReminderCreatePage> {
  final _taskController = TextEditingController();
  DateTime _selectedDay = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final supabase = Supabase.instance.client;

  void _showTimePickerBottomSheet() {
    int hour = _selectedTime.hour;
    int minute = _selectedTime.minute;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Time',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NumberPicker(
                        value: hour,
                        minValue: 0,
                        maxValue: 23,
                        zeroPad: true,
                        onChanged: (value) {
                          setModalState(() {
                            hour = value;
                          });
                        },
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey),
                        selectedTextStyle:
                            Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Text(':'),
                      NumberPicker(
                        value: minute,
                        minValue: 0,
                        maxValue: 59,
                        zeroPad: true,
                        onChanged: (value) {
                          setModalState(() {
                            minute = value;
                          });
                        },
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey),
                        selectedTextStyle:
                            Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        child: Text(
                          'Cancel',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final newTime = TimeOfDay(hour: hour, minute: minute);
                          setState(() {
                            _selectedTime = newTime;
                          });
                          Navigator.pop(context);
                        },
                        style: Theme.of(context)
                            .elevatedButtonTheme
                            .style
                            ?.copyWith(
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                        child: Text(
                          'Set Time',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .elevatedButtonTheme
                                        .style
                                        ?.foregroundColor
                                        ?.resolve({}),
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dateTime);
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.grey[
                      Theme.of(context).brightness == Brightness.dark
                          ? 700
                          : 300],
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
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
            InkWell(
              onTap: _showTimePickerBottomSheet,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time',
                ),
                child: Text(
                  _formatTime(_selectedTime),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  widget.onSave(
                      _selectedDay, _taskController.text, _selectedTime);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid task')),
                  );
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