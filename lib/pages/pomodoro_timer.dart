import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PomodoroTimerPage extends StatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isFocus = true;
  Timer? _timer;
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isRunning) {
      _startTimer();
    }
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _loadSettings() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final data = await _supabase
          .from('pomodoro_settings')
          .select('id, focus_minutes, break_minutes')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        setState(() {
          _focusMinutes = data['focus_minutes'] ?? 25;
          _breakMinutes = data['break_minutes'] ?? 5;
          _remainingSeconds = _focusMinutes * 60;
          _isLoading = false;
        });
      } else {
        await _saveSettings(25, 5);
        setState(() {
          _focusMinutes = 25;
          _breakMinutes = 5;
          _remainingSeconds = _focusMinutes * 60;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading settings: $e')),
      );
    }
  }

  Future<void> _saveSettings(int focusMinutes, int breakMinutes) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final existingData = await _supabase
          .from('pomodoro_settings')
          .select('id')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (existingData != null) {
        await _supabase
            .from('pomodoro_settings')
            .update({
              'focus_minutes': focusMinutes,
              'break_minutes': breakMinutes,
            })
            .eq('id', existingData['id']);
      } else {
        await _supabase.from('pomodoro_settings').insert({
          'user_id': user.id,
          'focus_minutes': focusMinutes,
          'break_minutes': breakMinutes,
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    }
  }

  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            _isFocus = !_isFocus;
            _remainingSeconds = (_isFocus ? _focusMinutes : _breakMinutes) * 60;
            _showCompletionDialog();
          }
        });
      });
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isFocus = true;
      _remainingSeconds = _focusMinutes * 60;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isFocus ? 'Focus Selesai!' : 'Istirahat Selesai!'),
        content: Text(_isFocus
            ? 'Waktu fokus telah selesai. Mulai waktu istirahat?'
            : 'Waktu istirahat telah selesai. Mulai waktu fokus?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startTimer();
            },
            child: const Text('Ya'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(),
      ),
    ).then((result) async {
      if (result != null) {
        final newFocusMinutes = result['focusMinutes'];
        final newBreakMinutes = result['breakMinutes'];
        await _saveSettings(newFocusMinutes, newBreakMinutes);
        setState(() {
          _focusMinutes = newFocusMinutes;
          _breakMinutes = newBreakMinutes;
          if (!_isRunning) {
            _remainingSeconds = _focusMinutes * 60;
          }
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isFocus ? 'Focus' : 'Rest',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 20),
            Text(
              _formatTime(_remainingSeconds),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(_isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[600]
                        : Colors.grey[400],
                    foregroundColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToSettings,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.settings),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _focusController;
  late TextEditingController _breakController;

  @override
  void initState() {
    super.initState();
    // This assumes initial values are passed or fetched; adjust as needed
    _focusController = TextEditingController(text: '25');
    _breakController = TextEditingController(text: '5');
  }

  @override
  void dispose() {
    _focusController.dispose();
    _breakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pomodoro Settings',
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
              controller: _focusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Focus Time (minute)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _breakController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Break Time (minute)',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final newFocusMinutes = int.tryParse(_focusController.text) ?? 25;
                final newBreakMinutes = int.tryParse(_breakController.text) ?? 5;
                Navigator.pop(context, {
                  'focusMinutes': newFocusMinutes,
                  'breakMinutes': newBreakMinutes,
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Save Settings',
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