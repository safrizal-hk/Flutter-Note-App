import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroTimerPage extends StatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  int _focusMinutes = 25; // Default waktu fokus
  int _breakMinutes = 5;  // Default waktu istirahat
  int _remainingSeconds = 25 * 60; // Default dalam detik
  bool _isRunning = false;
  bool _isFocus = true; // True untuk fokus, False untuk istirahat
  Timer? _timer;

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
            _isFocus = !_isFocus; // Ganti mode fokus/istirahat
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
        builder: (context) => PomodoroSettingsPage(
          initialFocusMinutes: _focusMinutes,
          initialBreakMinutes: _breakMinutes,
        ),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          _focusMinutes = result['focusMinutes'];
          _breakMinutes = result['breakMinutes'];
          if (!_isRunning) {
            _remainingSeconds = _focusMinutes * 60; // Reset hanya jika timer tidak berjalan
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF2F0EF),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isFocus ? 'Fokus' : 'Istirahat',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E2E2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(_isRunning ? 'Pause' : 'Mulai'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
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
        backgroundColor: const Color(0xFF2E2E2E),
        elevation: 4,
        child: const Icon(Icons.settings, color: Colors.white),
      ),
    );
  }
}

class PomodoroSettingsPage extends StatefulWidget {
  final int initialFocusMinutes;
  final int initialBreakMinutes;

  const PomodoroSettingsPage({
    super.key,
    required this.initialFocusMinutes,
    required this.initialBreakMinutes,
  });

  @override
  State<PomodoroSettingsPage> createState() => _PomodoroSettingsPageState();
}

class _PomodoroSettingsPageState extends State<PomodoroSettingsPage> {
  late TextEditingController _focusController;
  late TextEditingController _breakController;

  @override
  void initState() {
    super.initState();
    _focusController = TextEditingController(text: widget.initialFocusMinutes.toString());
    _breakController = TextEditingController(text: widget.initialBreakMinutes.toString());
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
            color: Color(0xFF2E2E2E),
          ),
        ),
        backgroundColor: const Color(0xFFCCCBCA),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF2F0EF),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _focusController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Waktu Fokus (menit)',
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
            const SizedBox(height: 16),
            TextField(
              controller: _breakController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Waktu Istirahat (menit)',
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final newFocusMinutes = int.tryParse(_focusController.text) ?? widget.initialFocusMinutes;
                final newBreakMinutes = int.tryParse(_breakController.text) ?? widget.initialBreakMinutes;
                Navigator.pop(context, {
                  'focusMinutes': newFocusMinutes,
                  'breakMinutes': newBreakMinutes,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E2E2E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Simpan',
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