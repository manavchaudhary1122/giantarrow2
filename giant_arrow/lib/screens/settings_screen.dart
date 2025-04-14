import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class PhoenixIcon extends StatelessWidget {
  final double size;
  final Color color;

  const PhoenixIcon({
    Key? key,
    required this.size,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PhoenixPainter(color: color),
      ),
    );
  }
}

class PhoenixPainter extends CustomPainter {
  final Color color;

  PhoenixPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Drawing the phoenix shape
    path.moveTo(size.width * 0.5, size.height * 0.1); // Head
    path.lineTo(size.width * 0.3, size.height * 0.4); // Left wing
    path.lineTo(size.width * 0.5, size.height * 0.6); // Body
    path.lineTo(size.width * 0.7, size.height * 0.4); // Right wing
    path.close();

    // Drawing the wings
    final leftWing = Path()
      ..moveTo(size.width * 0.3, size.height * 0.4)
      ..lineTo(size.width * 0.15, size.height * 0.6)
      ..lineTo(size.width * 0.4, size.height * 0.5)
      ..close();

    final rightWing = Path()
      ..moveTo(size.width * 0.7, size.height * 0.4)
      ..lineTo(size.width * 0.85, size.height * 0.6)
      ..lineTo(size.width * 0.6, size.height * 0.5)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(leftWing, paint);
    canvas.drawPath(rightWing, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSavedDate();
  }

  Future<void> _loadSavedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('neet_pg_date');
    if (savedDate != null) {
      setState(() {
        _selectedDate = DateTime.parse(savedDate);
        _dateController.text = _formatDate(_selectedDate!);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026, 12, 31),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('neet_pg_date', picked.toIso8601String());
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildRuleCard(String title, String amount, Color amountColor) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                color: amountColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleSection(String title, List<Widget> rules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...rules,
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NEET PG 2026 Date',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Select Exam Date',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () => _selectDate(context),
                ),
                labelStyle: const TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rules & Rewards',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRuleSection(
              'Study Rules',
              [
                _buildRuleCard('Complete MCQs (100 questions)', '+₹50', Colors.green),
                _buildRuleCard('Complete Subject Test', '+₹100', Colors.green),
                _buildRuleCard('Complete Grand Test', '+₹200', Colors.green),
                _buildRuleCard('Skip MCQs', '-₹50', Colors.red),
                _buildRuleCard('Skip Subject Test', '-₹100', Colors.red),
                _buildRuleCard('Skip Grand Test', '-₹200', Colors.red),
              ],
            ),
            _buildRuleSection(
              'Weight Loss Rules',
              [
                _buildRuleCard('Daily Exercise (30 mins)', '+₹50', Colors.green),
                _buildRuleCard('Weekly Weight Goal Met', '+₹200', Colors.green),
                _buildRuleCard('Skip Exercise', '-₹50', Colors.red),
                _buildRuleCard('Miss Weekly Goal', '-₹200', Colors.red),
              ],
            ),
            _buildRuleSection(
              'Meditation Rules',
              [
                _buildRuleCard('15 minutes session', '+₹30', Colors.green),
                _buildRuleCard('30 minutes session', '+₹60', Colors.green),
                _buildRuleCard('60 minutes session', '+₹100', Colors.green),
              ],
            ),
            _buildRuleSection(
              'Withdrawal Rules',
              [
                _buildRuleCard('Entertainment', '-₹500', Colors.red),
                _buildRuleCard('Social Media', '-₹200', Colors.red),
                _buildRuleCard('Gaming', '-₹300', Colors.red),
                _buildRuleCard('Other Distractions', '-₹100', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }
} 