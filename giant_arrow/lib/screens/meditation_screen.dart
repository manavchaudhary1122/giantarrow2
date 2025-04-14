import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giant_arrow/services/data_manager.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({Key? key}) : super(key: key);

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _checkTodayMeditation();
  }

  Future<void> _checkTodayMeditation() async {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    final now = DateTime.now();
    
    // Check if meditation was already completed today
    final todayMeditations = dataManager.getMeditation().where((meditation) {
      final meditationDate = DateTime.parse(meditation['date']);
      return meditationDate.year == now.year &&
             meditationDate.month == now.month &&
             meditationDate.day == now.day;
    }).toList();

    setState(() {
      _completed = todayMeditations.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Daily Meditation',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Daily Meditation',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Take a moment to meditate and reflect.\nComplete your daily meditation to earn ₹50.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Icon(
                      _completed ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 64,
                      color: _completed ? Colors.green : Colors.white54,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _completed ? null : _completeMeditation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        disabledBackgroundColor: Colors.grey[800],
                      ),
                      child: Text(
                        _completed ? 'Already Completed Today' : 'Complete Meditation',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeMeditation() async {
    final dataManager = Provider.of<DataManager>(context, listen: false);
    
    // Add meditation record with 50 rupees reward
    await dataManager.addMeditation({
      'completed': true,
      'date': DateTime.now().toIso8601String(),
    });

    setState(() {
      _completed = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meditation completed! Added ₹50 to balance'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
} 