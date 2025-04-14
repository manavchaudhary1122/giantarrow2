import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giant_arrow/models/balance_model.dart';

class MeditationButton extends StatelessWidget {
  final BalanceModel balanceModel;

  const MeditationButton({Key? key, required this.balanceModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meditation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Completed meditation today:'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    balanceModel.addMoney(50, 'Meditation session');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('+50 rupees added for meditation'),
                        duration: Duration(seconds: 2),
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
} 