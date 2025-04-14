import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class ChartsView extends StatefulWidget {
  const ChartsView({Key? key}) : super(key: key);

  @override
  State<ChartsView> createState() => _ChartsViewState();
}

class _ChartsViewState extends State<ChartsView> {
  String _selectedTimeFrame = 'Week';
  final List<String> _timeFrames = ['Week', 'Month', 'Year'];
  List<FlSpot> _spots = [];
  double _maxY = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      final List<dynamic> transactions = json.decode(transactionsJson);
      _updateChartData(transactions);
    }
  }

  void _updateChartData(List<dynamic> transactions) {
    final now = DateTime.now();
    final Map<DateTime, double> dailyTotals = {};

    for (var transaction in transactions) {
      final date = DateTime.parse(transaction['date']);
      final amount = transaction['amount'] as double;

      if (_isInTimeFrame(date, now)) {
        final key = DateTime(date.year, date.month, date.day);
        dailyTotals[key] = (dailyTotals[key] ?? 0) + amount;
      }
    }

    _spots = dailyTotals.entries
        .map((entry) => FlSpot(
              entry.key.millisecondsSinceEpoch.toDouble(),
              entry.value,
            ))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    _maxY = _spots.isEmpty ? 0 : _spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
  }

  bool _isInTimeFrame(DateTime date, DateTime now) {
    switch (_selectedTimeFrame) {
      case 'Week':
        return date.isAfter(now.subtract(const Duration(days: 7)));
      case 'Month':
        return date.isAfter(now.subtract(const Duration(days: 30)));
      case 'Year':
        return date.isAfter(now.subtract(const Duration(days: 365)));
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Charts',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedTimeFrame,
              items: _timeFrames.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTimeFrame = newValue;
                    _loadData();
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _spots,
                      isCurved: true,
                      color: Colors.deepPurple,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: true),
                    ),
                  ],
                  minY: 0,
                  maxY: _maxY * 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 