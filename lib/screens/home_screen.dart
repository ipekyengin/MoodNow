import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import 'recommendation_screen.dart';
import '../models/movie_model.dart';
import '../services/tmdb_service.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _directSearchController = TextEditingController();
  final TextEditingController _moodController = TextEditingController();
  final TmdbService _tmdbService = TmdbService();

  List<Movie> _directSearchResults = [];
  bool _isDirectSearching = false;

  void _onDirectSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _directSearchResults = []);
      return;
    }
    setState(() => _isDirectSearching = true);
    final results = await _tmdbService.searchMoviesAndSeries(query);
    if (mounted) {
      setState(() {
        _directSearchResults = results;
        _isDirectSearching = false;
      });
    }
  }

  void _onMoodSearch() {
    final mood = _moodController.text.trim();
    if (mood.isNotEmpty) {
      // Start searching
      Provider.of<MoodProvider>(context, listen: false).findMovies(mood);
      // Navigate immediately to recommendation screen which handles loading state
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RecommendationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Direct Search Section
            const Text(
              "Direct Search",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _directSearchController,
              onSubmitted: _onDirectSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search titles...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_isDirectSearching) const LinearProgressIndicator(),

            if (_directSearchResults.isNotEmpty)
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _directSearchResults.length,
                  itemBuilder: (context, index) {
                    final m = _directSearchResults[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(movie: m),
                          ),
                        );
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 10),
                        child: Column(
                          children: [
                            Expanded(
                              child: m.posterPath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        'https://image.tmdb.org/t/p/w200${m.posterPath}',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey,
                                      child: const Icon(Icons.movie),
                                    ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              m.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 30),

            // Mood Search Section
            const Text(
              "Mood-Based Recommendations",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _moodController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText:
                            "I'm feeling nostalgic and want to watch a 90s action movie...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text("Find for me"),
                        onPressed: _onMoodSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
