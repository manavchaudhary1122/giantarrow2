import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giant_arrow/services/data_manager.dart';

class StudyInputScreen extends StatefulWidget {
  const StudyInputScreen({Key? key}) : super(key: key);

  @override
  State<StudyInputScreen> createState() => _StudyInputScreenState();
}

class _StudyInputScreenState extends State<StudyInputScreen> {
  bool _mcqsCompleted = true;
  bool _chotiCopyCompleted = true;
  int _lectureWatchCount = 0;
  int _activeLearningCount = 0;
  String _selectedTestType = 'grand';
  int _testCount = 0;
  int _mcqsAttempted = 0;
  int _effectiveness = 3;

  Future<void> _submitStudyInput(BuildContext context) async {
    final dataManager = Provider.of<DataManager>(context, listen: false);

    // Record MCQs attempted
    if (_mcqsAttempted > 0) {
      await dataManager.addStudyInput({
        'type': 'mcq_attempt',
        'count': _mcqsAttempted,
        'date': DateTime.now().toIso8601String(),
      });
    }

    // Daily Tasks - Deduct 50 rupees for each incomplete task
    if (!_mcqsCompleted) {
      await dataManager.addStudyInput({
        'type': 'daily_mcq',
        'completed': false,
        'task': 'mcqs',
        'balance_change': -50,
        'date': DateTime.now().toIso8601String(),
      });
    }

    if (!_chotiCopyCompleted) {
      await dataManager.addStudyInput({
        'type': 'daily_mcq',
        'completed': false,
        'task': 'choti_copy',
        'balance_change': -50,
        'date': DateTime.now().toIso8601String(),
      });
    }

    // Lecture Watch - Add 20 rupees per count
    if (_lectureWatchCount > 0) {
      final balanceChange = _lectureWatchCount * 20;
      await dataManager.addStudyInput({
        'type': 'lecture_watch',
        'count': _lectureWatchCount,
        'effectiveness': _effectiveness,
        'balance_change': balanceChange,
      });
    }

    // Active Learning - Add 20 rupees per count
    if (_activeLearningCount > 0) {
      final balanceChange = _activeLearningCount * 20;
      await dataManager.addStudyInput({
        'type': 'active_learning',
        'count': _activeLearningCount,
        'effectiveness': _effectiveness,
        'balance_change': balanceChange,
      });
    }

    // Test - Add 20 rupees per count
    if (_testCount > 0) {
      final balanceChange = _testCount * 20;
      await dataManager.addStudyInput({
        'type': 'test',
        'test_type': _selectedTestType,
        'count': _testCount,
        'effectiveness': _effectiveness,
        'balance_change': balanceChange,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_mcqsAttempted > 0 
          ? 'Recorded $_mcqsAttempted MCQs attempted' 
          : 'Study progress recorded'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  Widget _buildDailyTasks() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                '50 MCQs Completed',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                '-₹50 if not completed',
                style: TextStyle(color: Colors.red),
              ),
              value: _mcqsCompleted,
              onChanged: (bool value) {
                setState(() {
                  _mcqsCompleted = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text(
                'Choti Copy Revision',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                '-₹50 if not completed',
                style: TextStyle(color: Colors.red),
              ),
              value: _chotiCopyCompleted,
              onChanged: (bool value) {
                setState(() {
                  _chotiCopyCompleted = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(String title, int value, Function(int) onChanged) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white),
                  onPressed: () {
                    if (value > 0) {
                      onChanged(value - 1);
                    }
                  },
                ),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    onChanged(value + 1);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedTestType,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(
                  value: 'grand',
                  child: Text('Grand Test'),
                ),
                DropdownMenuItem(
                  value: 'custom',
                  child: Text('Custom Modules'),
                ),
                DropdownMenuItem(
                  value: 'subject',
                  child: Text('Subject Test'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTestType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white),
                  onPressed: () {
                    if (_testCount > 0) {
                      setState(() {
                        _testCount--;
                      });
                    }
                  },
                ),
                Text(
                  _testCount.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _testCount++;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectivenessRating() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Effectiveness Rating',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _effectiveness.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _effectiveness.toString(),
              onChanged: (value) {
                setState(() {
                  _effectiveness = value.round();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Poor', style: TextStyle(color: Colors.white)),
                Text('Excellent', style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Study Input',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Daily Tasks Card
            _buildDailyTasks(),
            const SizedBox(height: 16),

            // Lecture Watch
            _buildInputSection(
              'Lecture Watch',
              _lectureWatchCount,
              (value) => setState(() => _lectureWatchCount = value),
            ),
            const SizedBox(height: 16),

            // Active Learning
            _buildInputSection(
              'Active Learning',
              _activeLearningCount,
              (value) => setState(() => _activeLearningCount = value),
            ),
            const SizedBox(height: 16),

            // Test Section
            _buildTestSection(),
            const SizedBox(height: 16),

            // MCQs Attempted - Text Input
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MCQs Attempted',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter the number of MCQs you attempted today',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Number of MCQs',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple),
                        ),
                        hintText: 'e.g., 50',
                        hintStyle: TextStyle(color: Colors.white30),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _mcqsAttempted = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Effectiveness Rating
            _buildEffectivenessRating(),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: () => _submitStudyInput(context),
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