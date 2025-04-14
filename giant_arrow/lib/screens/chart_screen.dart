import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giant_arrow/services/data_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _timeRange = 'Week'; // Default time range

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<FlSpot> _getSpots(List<Map<String, dynamic>> data, String valueKey, String dateKey) {
    if (data.isEmpty) return [];

    // Filter data based on time range
    final now = DateTime.now();
    final filteredData = data.where((entry) {
      final date = DateTime.parse(entry[dateKey]);
      switch (_timeRange) {
        case 'Week':
          return now.difference(date).inDays <= 7;
        case 'Month':
          return now.difference(date).inDays <= 30;
        case 'Year':
          return now.difference(date).inDays <= 365;
        default:
          return true;
      }
    }).toList();

    // Sort data by date
    filteredData.sort((a, b) => 
      DateTime.parse(a[dateKey]).compareTo(DateTime.parse(b[dateKey]))
    );

    // Convert to spots
    final spots = <FlSpot>[];
    if (filteredData.isNotEmpty) {
      final firstDate = DateTime.parse(filteredData.first[dateKey]);
      
      for (var entry in filteredData) {
        final date = DateTime.parse(entry[dateKey]);
        final daysDifference = date.difference(firstDate).inDays.toDouble();
        
        final value = entry[valueKey];
        if (value != null) {
          double yValue;
          if (value is int) {
            yValue = value.toDouble();
          } else if (value is double) {
            yValue = value;
          } else {
            continue;
          }
          spots.add(FlSpot(daysDifference, yValue));
        }
      }
    }

    return spots;
  }

  String _getXAxisLabel(double value, String timeRange) {
    if (value < 0) return '';
    
    final now = DateTime.now();
    DateTime date;
    
    switch (timeRange) {
      case 'Week':
        date = now.subtract(Duration(days: 7 - value.toInt()));
        return '${DateFormat('E').format(date)}\n${DateFormat('d').format(date)}'; // Mon\n1
      case 'Month':
        date = now.subtract(Duration(days: 30 - value.toInt()));
        return DateFormat('d/M').format(date); // 1/1
      case 'Year':
        date = now.subtract(Duration(days: 365 - value.toInt()));
        return DateFormat('MMM').format(date); // Jan
      default:
        return value.toInt().toString();
    }
  }

  Widget _buildChart(List<FlSpot> spots, String title, {Color color = Colors.blue}) {
    if (spots.isEmpty) {
      return Center(
        child: Text(
          'No data available for selected time range',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white10,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.white10,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final label = _getXAxisLabel(value, _timeRange);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                      interval: _timeRange == 'Week' ? 1 : 
                              _timeRange == 'Month' ? 5 : 
                              _timeRange == 'Year' ? 30 : 1,
                      reservedSize: _timeRange == 'Week' ? 40 : 25,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.white10),
                ),
                minX: 0,
                maxX: _timeRange == 'Week' ? 7 :
                      _timeRange == 'Month' ? 30 :
                      _timeRange == 'Year' ? 365 : spots.length.toDouble(),
                minY: spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 1,
                maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          'Progress Charts',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onSelected: (String value) {
              setState(() {
                _timeRange = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'Week',
                child: Text('Last Week'),
              ),
              const PopupMenuItem(
                value: 'Month',
                child: Text('Last Month'),
              ),
              const PopupMenuItem(
                value: 'Year',
                child: Text('Last Year'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Study'),
            Tab(text: 'Weight'),
            Tab(text: 'Meditation'),
            Tab(text: 'Balance'),
          ],
        ),
      ),
      body: Consumer<DataManager>(
        builder: (context, dataManager, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Study Progress Chart - Shows all study related metrics
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildChart(
                      _getSpots(
                        dataManager.getStudyInputs().where((input) => 
                          input['type'] == 'mcq_attempt' && input['count'] != null
                        ).toList(),
                        'count',
                        'date'
                      ),
                      'MCQs Attempted',
                      color: Colors.purple,
                    ),
                    _buildChart(
                      _getSpots(
                        dataManager.getStudyInputs().where((input) => 
                          input['type'] == 'lecture_watch'
                        ).toList(),
                        'count',
                        'date'
                      ),
                      'Lecture Watch Sessions',
                      color: Colors.blue,
                    ),
                    _buildChart(
                      _getSpots(
                        dataManager.getStudyInputs().where((input) => 
                          input['type'] == 'active_learning'
                        ).toList(),
                        'count',
                        'date'
                      ),
                      'Active Learning Sessions',
                      color: Colors.green,
                    ),
                    _buildChart(
                      _getSpots(
                        dataManager.getStudyInputs().where((input) => 
                          input['type'] == 'test'
                        ).toList(),
                        'count',
                        'date'
                      ),
                      'Tests Taken',
                      color: Colors.orange,
                    ),
                    _buildChart(
                      _getSpots(
                        dataManager.getStudyInputs().where((input) => 
                          input['type'] == 'effectiveness'
                        ).toList(),
                        'rating',
                        'date'
                      ),
                      'Study Effectiveness (1-5)',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              // Weight Loss Chart - Shows weight and exercise progress
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildChart(
                      _getSpots(
                        dataManager.getWeightLoss().where((entry) => 
                          entry['type'] == 'weekly_challenge' && entry['weight'] != null
                        ).toList(),
                        'weight',
                        'date'
                      ),
                      'Weight Progress (kg)',
                      color: Colors.green,
                    ),
                    _buildChart(
                      _getSpots(
                        dataManager.getWeightLoss().where((entry) => 
                          entry['type'] == 'daily_session'
                        ).toList(),
                        'completed',
                        'date'
                      ),
                      'Exercise Sessions',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              // Meditation Chart - Shows meditation streaks and durations
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildChart(
                      _getSpots(
                        dataManager.getMeditation().where((entry) => 
                          entry['completed'] == true
                        ).toList().asMap().entries.map((e) => {
                          'value': 1.0,
                          'date': e.value['date'],
                        }).toList(),
                        'value',
                        'date'
                      ),
                      'Meditation Streak',
                      color: Colors.orange,
                    ),
                    _buildChart(
                      _getSpots(
                        dataManager.getMeditation(),
                        'duration',
                        'date'
                      ),
                      'Meditation Duration (minutes)',
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
              // Balance Chart - Shows balance history and transactions
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildChart(
                      _getSpots(
                        dataManager.getTransactions(),
                        'amount',
                        'date'
                      ),
                      'Balance History',
                      color: Colors.blue,
                    ),
                    _buildChart(
                      _getSpots(
                        dataManager.getTransactions().where((t) => t['amount'] > 0).toList(),
                        'amount',
                        'date'
                      ),
                      'Earnings',
                      color: Colors.green,
                    ),
                    _buildChart(
                      _getSpots(
                        dataManager.getTransactions().where((t) => t['amount'] < 0).toList(),
                        'amount',
                        'date'
                      ),
                      'Withdrawals',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 