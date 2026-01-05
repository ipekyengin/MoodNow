import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../providers/watchlist_provider.dart';
import '../utils/constants.dart';
import 'watchlist_screen.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: Consumer<MoodProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Search'),
                    ),
                  ],
                ),
              ),
            );
          }

          final movie = provider.currentMovie;
          if (movie == null) {
            return const Center(child: Text("Start searching to see movies!"));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Poster
                        if (movie.posterPath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl:
                                  '${AppConstants.tmdbImageBaseUrl}${movie.posterPath}',
                              height: 400,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 400,
                                color: Colors.grey[900],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, _) => Container(
                                height: 400,
                                color: Colors.grey[900],
                                child: const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        // Title & Score
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Overview
                        Text(
                          movie.overview,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: 'reject',
                      backgroundColor: Colors.white12,
                      onPressed: () {
                        provider.nextMovie();
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.redAccent,
                        size: 30,
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: 'accept',
                      backgroundColor: Colors.redAccent,
                      onPressed: () {
                        Provider.of<WatchlistProvider>(
                          context,
                          listen: false,
                        ).addToWatchlist(movie);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${movie.title} added to watchlist!'),
                          ),
                        );
                        createWatchlistRoute(context);
                      },
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
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

  void createWatchlistRoute(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WatchlistScreen()),
    );
  }
}
