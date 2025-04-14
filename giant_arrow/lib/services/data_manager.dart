import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class DataManager extends ChangeNotifier {
  static final DataManager _instance = DataManager._internal();
  late SharedPreferences _prefs;
  double _balance = 0;
  DateTime? _neetPGDate;
  final Map<String, List<String>> _photos = {};
  final List<Map<String, dynamic>> _studyInputs = [];
  final List<Map<String, dynamic>> _weightLoss = [];
  final List<Map<String, dynamic>> _meditation = [];
  final List<Map<String, dynamic>> _withdrawals = [];
  
  factory DataManager() {
    return _instance;
  }

  DataManager._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
  }

  Future<void> _loadData() async {
    _balance = _prefs.getDouble('balance') ?? 0;
    
    final dateStr = _prefs.getString('neet_pg_date');
    if (dateStr != null) {
      _neetPGDate = DateTime.parse(dateStr);
    }
    
    final photosJson = _prefs.getString('photos');
    if (photosJson != null) {
      final Map<String, dynamic> decoded = json.decode(photosJson);
      _photos.clear();
      decoded.forEach((key, value) {
        _photos[key] = List<String>.from(value);
      });
    }
    
    notifyListeners();
  }

  // Balance Management
  Future<void> updateBalance(double amount) async {
    _balance += amount;
    await _prefs.setDouble('balance', _balance);
    await _saveTransaction(amount);
    notifyListeners();
  }

  double get balance => _balance;

  // Transaction History
  Future<void> _saveTransaction(double amount) async {
    final transactions = getTransactions();
    transactions.add({
      'date': DateTime.now().toIso8601String(),
      'amount': amount,
    });
    await _prefs.setString('transactions', json.encode(transactions));
  }

  List<Map<String, dynamic>> getTransactions() {
    final String? transactionsJson = _prefs.getString('transactions');
    if (transactionsJson == null) return [];
    final List<dynamic> decoded = json.decode(transactionsJson);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // Photo Management
  Future<void> savePhoto(String date, File photo) async {
    if (!_photos.containsKey(date)) {
      _photos[date] = [];
    }
    _photos[date]!.add(photo.path);
    await _prefs.setString('photos', json.encode(_photos));
    notifyListeners();
  }

  Map<String, List<String>> get photos => Map.unmodifiable(_photos);

  Map<String, List<String>> getPhotos() {
    return Map.unmodifiable(_photos);
  }

  // Meditation Progress
  Future<void> addMeditation(Map<String, dynamic> data) async {
    final meditation = getMeditation();
    final now = DateTime.now().toIso8601String();
    
    // Add 50 rupees for completing meditation
    const balanceChange = 50.0;

    meditation.add({
      ...data,
      'date': now,
      'balance_change': balanceChange,
    });

    await _prefs.setString('meditation', json.encode(meditation));
    await updateBalance(balanceChange);
    notifyListeners();
  }

  List<Map<String, dynamic>> getMeditation() {
    final String? meditationJson = _prefs.getString('meditation');
    if (meditationJson == null) return [];
    final List<dynamic> decoded = json.decode(meditationJson);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // NEET PG Date
  Future<void> setNEETPGDate(DateTime date) async {
    _neetPGDate = date;
    await _prefs.setString('neet_pg_date', date.toIso8601String());
    notifyListeners();
  }

  DateTime? get neetPGDate => _neetPGDate;

  // Study Inputs
  Future<void> addStudyInput(Map<String, dynamic> input) async {
    final studyInputs = getStudyInputs();
    final now = DateTime.now().toIso8601String();
    
    // Calculate balance change based on input type
    double balanceChange = 0;
    
    switch (input['type']) {
      case 'daily_mcq':
        if (input['completed'] == false) {
          balanceChange = -50; // Deduct 50 if MCQs not completed
        }
        break;
      case 'lecture_watch':
      case 'active_learning':
      case 'test':
        final count = input['count'] as int;
        balanceChange = count * 20; // 20 rupees per count
        break;
      case 'mcq_attempt':
        // Just record the number of MCQs attempted
        break;
    }

    // Save the study input with effectiveness
    studyInputs.add({
      ...input,
      'date': now,
      'balance_change': balanceChange,
    });
    
    await _prefs.setString('study_inputs', json.encode(studyInputs));
    if (balanceChange != 0) {
      await updateBalance(balanceChange);
    }
    notifyListeners();
  }

  List<Map<String, dynamic>> getStudyInputs() {
    final String? studyInputsJson = _prefs.getString('study_inputs');
    if (studyInputsJson == null) return [];
    final List<dynamic> decoded = json.decode(studyInputsJson);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // Weight Loss
  Future<void> addWeightLoss(Map<String, dynamic> data) async {
    final weightLoss = getWeightLoss();
    final now = DateTime.now();
    double balanceChange = 0;

    switch (data['type']) {
      case 'daily_session':
        if (data['completed'] == 1) {
          balanceChange = 50;
        }
        break;
      case 'weekly_challenge':
        if (data['weight_loss'] >= 1.0) { // 1 kg or more
          balanceChange = 300;
        }
        break;
      case 'weekly_consistency':
        if (data['sessions_completed'] >= 6) {
          balanceChange = 100;
        }
        break;
    }

    weightLoss.add({
      ...data,
      'date': now.toIso8601String(),
      'balance_change': balanceChange,
    });

    await _prefs.setString('weight_loss', json.encode(weightLoss));
    if (balanceChange > 0) {
      await updateBalance(balanceChange);
    }
    notifyListeners();
  }

  List<Map<String, dynamic>> getWeightLoss() {
    final String? weightLossJson = _prefs.getString('weight_loss');
    if (weightLossJson == null) return [];
    final List<dynamic> decoded = json.decode(weightLossJson);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // Withdrawals
  Future<bool> addWithdrawal(Map<String, dynamic> data) async {
    final amount = data['amount'] as double;
    
    // Check if balance would be sufficient after withdrawal
    if (_balance - amount < 0) {
      return false; // Insufficient balance
    }

    final withdrawals = getWithdrawals();
    withdrawals.add({
      ...data,
      'date': DateTime.now().toIso8601String(),
      'amount': amount,
      'reason': data['reason'], // food, patrol, or miscellaneous
    });

    await _prefs.setString('withdrawals', json.encode(withdrawals));
    await updateBalance(-amount); // Deduct the withdrawal amount
    notifyListeners();
    return true; // Withdrawal successful
  }

  List<Map<String, dynamic>> getWithdrawals() {
    final String? withdrawalsJson = _prefs.getString('withdrawals');
    if (withdrawalsJson == null) return [];
    final List<dynamic> decoded = json.decode(withdrawalsJson);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }
} 