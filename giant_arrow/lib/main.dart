import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giant_arrow/services/data_manager.dart';
import 'package:giant_arrow/models/motivational_quote.dart';
import 'package:giant_arrow/screens/main_screen.dart';
import 'package:giant_arrow/screens/settings_screen.dart';
import 'package:giant_arrow/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dataManager = DataManager();
  await dataManager.initialize();
  runApp(MyApp(dataManager: dataManager));
}

class MyApp extends StatelessWidget {
  final DataManager dataManager;
  
  const MyApp({Key? key, required this.dataManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: dataManager,
        ),
        ChangeNotifierProvider(
          create: (_) => MotivationalQuote(),
        ),
      ],
      child: MaterialApp(
        title: 'Giant Arrow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/main': (context) => const MainScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
