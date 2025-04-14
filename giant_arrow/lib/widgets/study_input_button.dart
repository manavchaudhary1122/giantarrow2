import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giant_arrow/models/balance_model.dart';
import 'package:giant_arrow/services/data_manager.dart';

class StudyInputButton extends StatelessWidget {
  const StudyInputButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Study Input',
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
                  onPressed: () => _showMCQsInputDialog(context),
                  child: const Text('MCQs'),
                ),
                ElevatedButton(
                  onPressed: () => _showTestInputDialog(context, 'Grand'),
                  child: const Text('Grand Test'),
                ),
                ElevatedButton(
                  onPressed: () => _showTestInputDialog(context, 'Custom'),
                  child: const Text('Custom Module'),
                ),
                ElevatedButton(
                  onPressed: () => _showTestInputDialog(context, 'Subject'),
                  child: const Text('Subject Test'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMCQsInputDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MCQs Attempted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Number of MCQs',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final mcqs = int.tryParse(controller.text);
                if (mcqs != null) {
                  final balanceModel = context.read<BalanceModel>();
                  final dataManager = context.read<DataManager>();
                  
                  // Add money for MCQs (₹1 per MCQ)
                  await balanceModel.addMoney(mcqs.toDouble(), 'MCQs attempted');
                  
                  // Show effectiveness dialog
                  Navigator.pop(context);
                  _showEffectivenessDialog(context, 'MCQs', mcqs);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTestInputDialog(BuildContext context, String testType) {
    int? selectedValue;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$testType Test Input'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Number of tests',
                border: OutlineInputBorder(),
              ),
              items: List.generate(5, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1}'),
                );
              }),
              onChanged: (value) {
                selectedValue = value;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (selectedValue != null) {
                  final balanceModel = context.read<BalanceModel>();
                  final dataManager = context.read<DataManager>();
                  
                  // Add money for tests (₹20 per test)
                  await balanceModel.addMoney(selectedValue! * 20.0, '$testType test completed');
                  
                  // Show effectiveness dialog
                  Navigator.pop(context);
                  _showEffectivenessDialog(context, '$testType test', selectedValue!);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEffectivenessDialog(BuildContext context, String activity, int count) {
    int? selectedValue;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$activity Effectiveness'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(5, (index) {
              return RadioListTile<int>(
                title: Text('Level ${index + 1}'),
                value: index + 1,
                groupValue: selectedValue,
                onChanged: (value) {
                  selectedValue = value;
                },
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (selectedValue != null) {
                  final balanceModel = context.read<BalanceModel>();
                  final dataManager = context.read<DataManager>();
                  
                  // Add money for effectiveness (₹10 per level)
                  await balanceModel.addMoney(selectedValue! * 10.0, '$activity effectiveness');
                  
                  // Save study progress
                  await dataManager.saveTestResult(activity, count, selectedValue!.toDouble());
                  
                  Navigator.pop(context);
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$activity recorded successfully!'),
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
} 