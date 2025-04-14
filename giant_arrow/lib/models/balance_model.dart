import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalanceModel extends ChangeNotifier {
  double _balance = 0.0;
  final String _balanceKey = 'balance';
  List<Transaction> _transactions = [];

  BalanceModel() {
    _loadBalance();
  }

  double get balance => _balance;
  List<Transaction> get transactions => _transactions;

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getDouble(_balanceKey) ?? 0.0;
    notifyListeners();
  }

  Future<void> addMoney(double amount, String reason) async {
    _balance += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, _balance);
    _transactions.add(Transaction(amount, reason, DateTime.now()));
    notifyListeners();
  }

  Future<void> deductMoney(double amount, String reason) async {
    if (_balance >= amount) {
      _balance -= amount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_balanceKey, _balance);
      _transactions.add(Transaction(-amount, reason, DateTime.now()));
      notifyListeners();
    }
  }
}

class Transaction {
  final double amount;
  final String reason;
  final DateTime timestamp;

  Transaction(this.amount, this.reason, this.timestamp);
} 