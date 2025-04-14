import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giant_arrow/models/balance_model.dart';
import 'package:intl/intl.dart';

class TransactionHistory extends StatelessWidget {
  const TransactionHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<BalanceModel>(
              builder: (context, balanceModel, child) {
                final transactions = balanceModel.transactions;
                if (transactions.isEmpty) {
                  return const Center(
                    child: Text('No transactions yet'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return ListTile(
                      leading: Icon(
                        transaction.amount > 0
                            ? Icons.add_circle_outline
                            : Icons.remove_circle_outline,
                        color: transaction.amount > 0 ? Colors.green : Colors.red,
                      ),
                      title: Text(transaction.reason),
                      subtitle: Text(
                        DateFormat('MMM dd, yyyy HH:mm')
                            .format(transaction.timestamp),
                      ),
                      trailing: Text(
                        '₹${transaction.amount.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          color: transaction.amount > 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 