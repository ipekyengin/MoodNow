import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/watchlist_provider.dart';
import '../utils/constants.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Watchlist')),
      body: Consumer<WatchlistProvider>(
        builder: (context, provider, child) {
          final watchlist = provider.watchlist;

          if (watchlist.isEmpty) {
            return const Center(child: Text("Your watchlist is empty."));
          }

          return ListView.builder(
            itemCount: watchlist.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final movie = watchlist[index];
              return Card(
                color: const Color(0xFF2A2A2A),
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: movie.posterPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl:
                                '${AppConstants.tmdbImageBaseUrl}${movie.posterPath}',
                            width: 50,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, _) =>
                                const Icon(Icons.movie),
                          ),
                        )
                      : const Icon(Icons.movie),
                  title: Text(
                    movie.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Rating: ${movie.voteAverage}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Details",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movie.overview,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "My Notes",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: movie.userNote,
                            decoration: const InputDecoration(
                              hintText: "Add a note...",
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            onChanged: (value) {
                              // Debounce could be added here for optimization
                              provider.updateNote(movie.id, value);
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                provider.removeFromWatchlist(movie.id);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              label: const Text(
                                'Remove',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
