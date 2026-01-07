import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import 'movie_detail_screen.dart';

class ListDetailScreen extends StatelessWidget {
  final String listName;

  const ListDetailScreen({super.key, required this.listName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(listName)),
      body: Consumer<LibraryProvider>(
        builder: (context, libProvider, _) {
          final movies = libProvider.getList(listName);
          if (movies.isEmpty) {
            return const Center(
              child: Text(
                "This list is empty.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return ListTile(
                leading: movie.posterPath != null
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                        width: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.movie, size: 50),
                title: Text(
                  movie.title,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${movie.voteAverage.toStringAsFixed(1)} ★',
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailScreen(movie: movie),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
