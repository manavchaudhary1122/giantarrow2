import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MotivationalQuote extends ChangeNotifier {
  String _currentQuote = '';
  String _currentAuthor = '';
  Timer? _quoteTimer;
  final List<Map<String, String>> _quotes = [
    {
      'quote': 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      'author': 'Winston Churchill',
    },
    {
      'quote': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs',
    },
    {
      'quote': 'Believe you can and you\'re halfway there.',
      'author': 'Theodore Roosevelt',
    },
  ];

  String get currentQuote => _currentQuote;
  String get currentAuthor => _currentAuthor;

  MotivationalQuote() {
    _loadQuote();
    _startQuoteTimer();
  }

  Future<void> _loadQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt('last_quote_update');
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastUpdate == null || now - lastUpdate >= 3600000) {
      _updateQuote();
      await prefs.setInt('last_quote_update', now);
    } else {
      _currentQuote = prefs.getString('current_quote') ?? '';
      _currentAuthor = prefs.getString('current_author') ?? '';
      if (_currentQuote.isEmpty) {
        _updateQuote();
      }
    }
  }

  void _updateQuote() {
    final random = Random();
    final index = random.nextInt(_quotes.length);
    _currentQuote = _quotes[index]['quote']!;
    _currentAuthor = _quotes[index]['author']!;
    notifyListeners();
  }

  void _startQuoteTimer() {
    _quoteTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _updateQuote();
    });
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }
} 