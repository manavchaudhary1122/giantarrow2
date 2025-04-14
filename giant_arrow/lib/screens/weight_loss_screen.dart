import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giant_arrow/services/data_manager.dart';
import 'dart:async';

class WeightLossScreen extends StatefulWidget {
  const WeightLossScreen({Key? key}) : super(key: key);

  @override
  State<WeightLossScreen> createState() => _WeightLossScreenState();
}

class _WeightLossScreenState extends State<WeightLossScreen> {
  Timer? _weeklyTimer;
  Duration _timeUntilMonday = Duration.zero;
  String _currentQuote = "Fitness is not about being better than someone else. It's about being better than you used to be.";
  Timer? _quoteTimer;
  double _currentWeight = 0.0;
  int _dailySession = 0;
  int _weeklySessionCount = 0;

  final List<String> _fitnessQuotes = [
    "Fitness is not about being better than someone else. It's about being better than you used to be.",
    "The only bad workout is the one that didn't happen.",
    "Your body can stand almost anything. It's your mind that you have to convince.",
    "The hardest lift of all is lifting your butt off the couch.",
    "Success starts with self-discipline.",
    "Your health is an investment, not an expense.",
    "The only person you are destined to become is the person you decide to be.",
    "Take care of your body. It's the only place you have to live.",
  ];

  @override
  void initState() {
    super.initState();
    _startWeeklyTimer();
    _startQuoteTimer();
    _loadWeeklySessionCount();
  }

  void _startWeeklyTimer() {
    // Calculate time until next Monday at 00:00
    final now = DateTime.now();
    final daysUntilMonday = (DateTime.monday - now.weekday) % 7;
    final nextMonday = DateTime(
      now.year,
      now.month,
      now.day + daysUntilMonday,
      0, // hour
      0, // minute
      0, // second
    );
    _timeUntilMonday = nextMonday.difference(now);

    _weeklyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeUntilMonday.inSeconds > 0) {
          _timeUntilMonday = _timeUntilMonday - const Duration(seconds: 1);
        } else {
          _resetWeeklyChallenge();
          // Reset timer for next Monday
          _startWeeklyTimer();
        }
      });
    });
  }

  void _startQuoteTimer() {
    _quoteTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      setState(() {
        _currentQuote = _fitnessQuotes[DateTime.now().hour % _fitnessQuotes.length];
      });
    });
  }

  Future<void> _loadWeeklySessionCount() async {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final sessions = dataManager.getWeightLoss().where((session) {
      final sessionDate = DateTime.parse(session['date']);
      final now = DateTime.now();
      return now.difference(sessionDate).inDays <= 7;
    }).toList();

    setState(() {
      _weeklySessionCount = sessions.length;
    });
  }

  void _resetWeeklyChallenge() {
    setState(() {
      _weeklySessionCount = 0;
      _timeUntilMonday = const Duration(days: 7);
    });
  }

  Widget _buildCountdownTimer() {
    final days = _timeUntilMonday.inDays;
    final hours = _timeUntilMonday.inHours % 24;
    final minutes = _timeUntilMonday.inMinutes % 60;
    final seconds = _timeUntilMonday.inSeconds % 60;

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Time Until Next Weekly Challenge',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeUnit('Days', days),
                _buildTimeUnit('Hours', hours),
                _buildTimeUnit('Minutes', minutes),
                _buildTimeUnit('Seconds', seconds),
              ],
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
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteCard() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Fitness Quote of the Hour',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _currentQuote,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySession() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Exercise Session',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Did you complete your exercise today? (+50₹)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _dailySession = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dailySession == 0 ? Colors.deepPurple : Colors.grey[800],
                  ),
                  child: const Text('No'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _dailySession = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dailySession == 1 ? Colors.deepPurple : Colors.grey[800],
                  ),
                  child: const Text('Yes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChallenge() {
    final now = DateTime.now();
    final isMonday = now.weekday == DateTime.monday;
    
    // Get the latest weight from DataManager
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final latestWeightEntry = dataManager.getWeightLoss().lastWhere(
      (entry) => entry['type'] == 'weekly_challenge',
      orElse: () => {'weight': 0.0},
    );
    final currentWeight = latestWeightEntry['weight'] as double;
    
    // Calculate target weight (0.5 kg loss per week)
    final targetWeight = currentWeight > 0 ? currentWeight - 0.5 : 0.0;

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Weight Challenge',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Weight Status Section
            if (currentWeight > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Current Weight:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${currentWeight.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Weekly Target:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${targetWeight.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            color: Colors.greenAccent[400],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Target: Lose 0.5 kg this week',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              enabled: isMonday,
              decoration: InputDecoration(
                labelText: isMonday ? 'Current Weight (kg)' : 'Weight can only be recorded on Mondays',
                labelStyle: TextStyle(color: isMonday ? Colors.white : Colors.grey),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                disabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _currentWeight = double.tryParse(value) ?? 0.0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitWeightLoss(BuildContext context) async {
    final now = DateTime.now();
    final isMonday = now.weekday == DateTime.monday;
    final dataManager = Provider.of<DataManager>(context, listen: false);

    // Daily Exercise Session - Add 50 rupees for completing exercise
    if (_dailySession == 1) {
      await dataManager.addWeightLoss({
        'type': 'daily_session',
        'completed': 1,
        'date': now.toIso8601String(),
        'balance_change': 50,
      });
      _weeklySessionCount++;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise completed! Added ₹50 to balance'),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Weekly Weight Challenge - Only allow on Mondays
    if (_currentWeight > 0 && isMonday) {
      final previousWeight = dataManager.getWeightLoss().lastWhere(
        (entry) => entry['type'] == 'weekly_challenge',
        orElse: () => {'weight': _currentWeight},
      )['weight'] as double;

      final weightLoss = previousWeight - _currentWeight;
      int balanceChange = 0;

      // Add 300 rupees for losing 1kg or more
      if (weightLoss >= 1.0) {
        balanceChange = 300;
      }

      await dataManager.addWeightLoss({
        'type': 'weekly_challenge',
        'weight': _currentWeight,
        'previous_weight': previousWeight,
        'weight_loss': weightLoss,
        'date': now.toIso8601String(),
        'balance_change': balanceChange,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(weightLoss >= 1.0 
            ? 'Weight recorded! You lost ${weightLoss.toStringAsFixed(1)}kg and earned ₹300!' 
            : 'Weight recorded successfully'),
          backgroundColor: weightLoss >= 1.0 ? Colors.green : Colors.blue,
        ),
      );
    } else if (_currentWeight > 0 && !isMonday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weight can only be recorded on Mondays'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Weekly Consistency Bonus (6 or more sessions) - Add 100 rupees
    if (_weeklySessionCount >= 6) {
      await dataManager.addWeightLoss({
        'type': 'weekly_consistency',
        'sessions_completed': _weeklySessionCount,
        'date': now.toIso8601String(),
        'balance_change': 100,
      });
    }

    if (_dailySession == 1 || (isMonday && _currentWeight > 0)) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _weeklyTimer?.cancel();
    _quoteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Weight Loss',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCountdownTimer(),
            const SizedBox(height: 16),
            _buildQuoteCard(),
            const SizedBox(height: 16),
            _buildDailySession(),
            const SizedBox(height: 16),
            _buildWeeklyChallenge(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _submitWeightLoss(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 