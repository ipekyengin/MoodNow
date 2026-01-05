import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import 'recommendation_screen.dart';
import 'watchlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _moodController = TextEditingController();

  void _findMood(BuildContext context) async {
    final mood = _moodController.text.trim();
    if (mood.isEmpty) return;

    final moodProvider = Provider.of<MoodProvider>(context, listen: false);

    // Start the search
    moodProvider.findMovies(mood);

    // Navigate immediately to Recommendation Screen which will handle the loading state
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecommendationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MoodNow',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WatchlistScreen()),
              );
            },
            tooltip: 'My Watchlist',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "How are you feeling?",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Describe your mood or what you want to watch...",
              style: TextStyle(fontSize: 16, color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _moodController,
              decoration: const InputDecoration(
                hintText: "e.g., I want a dark detective thriller like Seven",
                prefixIcon: Icon(Icons.search, color: Colors.white54),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _findMood(context),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _findMood(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Find Mood",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
