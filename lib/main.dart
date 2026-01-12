import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/library_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'utils/theme.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env file not found or failed to load.");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkLoginStatus(),
        ),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'MoodNow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: authProvider.isLoggedIn
                ? _AuthWrapper(child: const DashboardScreen())
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}

// Wrapper to initialize user data when logged in
class _AuthWrapper extends StatefulWidget {
  final Widget child;
  const _AuthWrapper({required this.child});

  @override
  State<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).currentUser;
      if (user != null) {
        Provider.of<LibraryProvider>(
          context,
          listen: false,
        ).loadUserLists(user.username);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
