import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giant_arrow/models/balance_model.dart';

class BalanceDisplay extends StatelessWidget {
  const BalanceDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Balance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Consumer<BalanceModel>(
              builder: (context, balanceModel, child) {
                return Text(
                  '₹${balanceModel.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 