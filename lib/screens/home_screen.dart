import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../providers/movie_provider.dart';
import 'recommendation_screen.dart';
import '../models/movie_model.dart';
import '../services/tmdb_service.dart';
import 'movie_detail_screen.dart';
import '../utils/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _directSearchController = TextEditingController();
  final TextEditingController _moodController = TextEditingController();
  final TmdbService _tmdbService = TmdbService();
  late AnimationController _pulseController;

  List<Movie> _directSearchResults = [];
  bool _isDirectSearching = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Initial Data Load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).loadHomeScreenData();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _directSearchController.dispose();
    _moodController.dispose();
    super.dispose();
  }

  void _onDirectSearch(String query) async {
    if (query.isEmpty) {
      if (mounted) setState(() => _directSearchResults = []);
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
      Provider.of<MoodProvider>(context, listen: false).findMovies(mood);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RecommendationScreen()),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<Movie> movies) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final m = movies[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: m)),
              );
            },
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: m.posterPath != null
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w500${m.posterPath}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey[900]),
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.movie, color: Colors.white54),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/0/08/Netflix_2015_logo.svg',
          height: 30,
          errorBuilder: (c, e, s) => const Text(
            "MOODNOW",
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          // 1. Loading State
          if (movieProvider.isLoading && movieProvider.heroMovie == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          // 2. Error State
          if (movieProvider.error != null && movieProvider.heroMovie == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppTheme.primary,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      movieProvider.error!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: movieProvider.retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          }

          final heroMovie = movieProvider.heroMovie;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3. HERO SECTION
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 500,
                      width: double.infinity,
                      foregroundDecoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black,
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: [0.0, 0.2, 0.8, 1.0],
                        ),
                      ),
                      child: Image.network(
                        heroMovie?.posterPath != null
                            ? 'https://image.tmdb.org/t/p/original${heroMovie!.posterPath}'
                            : 'https://image.tmdb.org/t/p/original/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey[900]),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              heroMovie?.title ?? "Featured Title",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  heroMovie != null
                                      ? "Trending #${movieProvider.trendingMovies.isNotEmpty ? movieProvider.trendingMovies.indexOf(heroMovie) + 1 : '1'} Today"
                                      : "Trending • Movie",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (heroMovie != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MovieDetailScreen(
                                            movie: heroMovie,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.black,
                                  ),
                                  label: const Text(
                                    "Play",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (heroMovie != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MovieDetailScreen(
                                            movie: heroMovie,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "More Info",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.3,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 4. TRENDING MOVIES ROW
                if (movieProvider.trendingMovies.isNotEmpty) ...[
                  _buildSectionTitle("Trending Movies Today"),
                  _buildHorizontalList(
                    movieProvider.trendingMovies.skip(1).toList(),
                  ), // Skip hero if needed, but trending list has more
                ],

                // 5. POPULAR TV ROW
                if (movieProvider.popularTVSeries.isNotEmpty) ...[
                  _buildSectionTitle("Popular TV Series"),
                  _buildHorizontalList(movieProvider.popularTVSeries),
                ],

                const SizedBox(height: 20),

                // 6. SEARCH BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _directSearchController,
                    onSubmitted: _onDirectSearch,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search for a show, movie, genre, etc.",
                      fillColor: Colors.grey[800]?.withOpacity(0.5),
                      filled: true,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                if (_isDirectSearching)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  ),

                if (_directSearchResults.isNotEmpty) ...[
                  _buildSectionTitle("Top Search Results"),
                  _buildHorizontalList(_directSearchResults),
                ],

                const SizedBox(height: 40),

                // 7. MOOD SEARCH
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Find Something New",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "How are you feeling?",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _moodController,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          hintText: "E.g., Sad, Adventurous...",
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onMoodSearch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text("Get Recommendations"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}
