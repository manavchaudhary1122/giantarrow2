import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giant_arrow/models/balance_model.dart';
import 'package:giant_arrow/services/data_manager.dart';

class WeightLossButton extends StatelessWidget {
  const WeightLossButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weight Loss',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _showDailySessionDialog(context),
                  child: const Text('Daily Session'),
                ),
                ElevatedButton(
                  onPressed: () => _showWeightInputDialog(context),
                  child: const Text('Weekly Weight'),
                ),
                ElevatedButton(
                  onPressed: () => _showExerciseInputDialog(context),
                  child: const Text('Exercise'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDailySessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Did you complete today\'s session?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final balanceModel = context.read<BalanceModel>();
                    final dataManager = context.read<DataManager>();
                    
                    // Add money for daily session (₹50)
                    await balanceModel.addMoney(50.0, 'Daily session completed');
                    await dataManager.saveExerciseSession(1);
                    
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Daily session recorded!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWeightInputDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weekly Weight Check'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Current Weight (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final weight = double.tryParse(controller.text);
                if (weight != null) {
                  final balanceModel = context.read<BalanceModel>();
                  final dataManager = context.read<DataManager>();
                  
                  // Save weight
                  await dataManager.saveWeightEntry(weight);
                  
                  // Check for weekly challenge
                  final lastWeight = await dataManager.getLastWeekWeight();
                  if (lastWeight != null && weight <= lastWeight - 1) {
                    // Add money for achieving weekly goal (₹300)
                    await balanceModel.addMoney(300.0, 'Weekly weight loss goal achieved');
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Congratulations! You achieved your weekly weight loss goal!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExerciseInputDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Minutes exercised',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final minutes = int.tryParse(controller.text);
                if (minutes != null) {
                  final balanceModel = context.read<BalanceModel>();
                  final dataManager = context.read<DataManager>();
                  
                  // Add money for exercise (₹1 per minute)
                  await balanceModel.addMoney(minutes.toDouble(), 'Exercise completed');
                  await dataManager.saveExerciseSession(minutes);
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$minutes minutes of exercise recorded!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
} 