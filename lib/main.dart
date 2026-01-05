import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/mood_provider.dart';
import 'providers/watchlist_provider.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

Future<void> main() async {
  // Ensure we load the .env file before anything else
  // Note: Ensure the .env file exists in the root of your project
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print(
      "Warning: .env file not found or failed to load. API keys might be missing.",
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
      ],
      child: MaterialApp(
        title: 'MoodNow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
