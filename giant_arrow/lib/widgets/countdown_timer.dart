import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giant_arrow/services/data_manager.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({Key? key}) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  Duration _remainingTime = const Duration();
  DateTime? _neetPGDate;

  @override
  void initState() {
    super.initState();
    _loadDate();
  }

  Future<void> _loadDate() async {
    final dataManager = context.read<DataManager>();
    final date = dataManager.neetPGDate;
    if (date != null) {
      setState(() {
        _neetPGDate = date;
        _updateRemainingTime();
      });
      _startTimer();
    }
  }

  void _updateRemainingTime() {
    if (_neetPGDate != null) {
      final now = DateTime.now();
      if (now.isBefore(_neetPGDate!)) {
        setState(() {
          _remainingTime = _neetPGDate!.difference(now);
        });
      } else {
        setState(() {
          _remainingTime = const Duration();
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NEET PG 2026',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (_neetPGDate != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeUnit('Days', _remainingTime.inDays),
                  _buildTimeUnit('Hours', _remainingTime.inHours % 24),
                  _buildTimeUnit('Minutes', _remainingTime.inMinutes % 60),
                  _buildTimeUnit('Seconds', _remainingTime.inSeconds % 60),
                ],
              )
            else
              const Text(
                'Please set NEET PG date in settings',
                style: TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUnit(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
} 