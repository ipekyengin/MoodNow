import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie_model.dart';
import '../providers/library_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late TextEditingController _noteController;
  bool _isEditing = false;
  final GlobalKey _notesSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.movie.userNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Helper to get the latest movie object (with up-to-date note/status)
  Movie _getLatestMovie(LibraryProvider libProvider) {
    for (var list in libProvider.allLists.values) {
      for (var m in list) {
        if (m.id == widget.movie.id) return m;
      }
    }
    return widget.movie;
  }

  void _scrollToNotes() {
    Scrollable.ensureVisible(
      _notesSectionKey.currentContext!,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<LibraryProvider>(
        builder: (context, libProvider, _) {
          final movie = _getLatestMovie(libProvider);
          final isFav = libProvider.isFavorite(movie);
          final isInWatchList = libProvider.isInWatchList(movie);

          // If note exists but controller is empty (first load mismatch), sync it
          if (!_isEditing &&
              movie.userNote != null &&
              _noteController.text != movie.userNote) {
            _noteController.text = movie.userNote!;
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 450, // Cinematic height
                pinned: true,
                backgroundColor: AppTheme.background,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'movie_poster_${movie.id}',
                        child: movie.posterPath != null
                            ? CachedNetworkImage(
                                imageUrl:
                                    '${AppConstants.tmdbImageBaseUrl}${movie.posterPath}',
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey[900]),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.error,
                                      color: Colors.white54,
                                    ),
                              )
                            : Container(color: Colors.grey[900]),
                      ),
                      // Gradient overlay
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                              AppTheme.background,
                            ],
                            stops: [0.6, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Netflix Meta Row
                        Row(
                          children: [
                            Text(
                              "${(movie.voteAverage * 10).toInt()}% Match",
                              style: const TextStyle(
                                color: Color(0xFF46D369),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              movie.releaseDate?.split('-').first ?? '',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                movie.mediaType.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Buttons Row: My List, Favorite, Notes
                        Row(
                          children: [
                            // MY LIST BUTTON (Watchlist)
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(
                                  isInWatchList ? Icons.check : Icons.add,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  isInWatchList ? "✓ In My List" : "+ My List",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isInWatchList
                                      ? Colors.grey[800]
                                      : AppTheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: () => _toggleWatchList(
                                  context,
                                  libProvider,
                                  movie,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // FAVORITE HEART ICON
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: IconButton(
                                onPressed: () => _toggleFavorite(
                                  context,
                                  libProvider,
                                  movie,
                                  isFav,
                                ),
                                icon: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.white,
                                ),
                                tooltip: isFav
                                    ? "Remove from Favorites"
                                    : "Add to Favorites",
                              ),
                            ),
                            const SizedBox(width: 12),
                            // NOTE SHORTCUT BUTTON
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: IconButton(
                                onPressed: _scrollToNotes,
                                icon: const Icon(
                                  Icons.edit_note,
                                  color: Colors.white,
                                ),
                                tooltip: "Jump to Notes",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.playlist_add,
                              color: Colors.black,
                            ),
                            label: const Text(
                              "Custom Lists",
                              style: TextStyle(color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => _showAddToListDialog(
                              context,
                              libProvider,
                              movie,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          "Overview",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.overview,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // --- My Notes Section ---
                        Container(key: _notesSectionKey), // Anchor
                        _buildNotesSection(context, libProvider, movie, isFav),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotesSection(
    BuildContext context,
    LibraryProvider libProvider,
    Movie movie,
    bool isFav,
  ) {
    final hasNote = movie.userNote != null && movie.userNote!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "My Notes",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (hasNote && !_isEditing)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white54, size: 20),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!_isEditing && hasNote)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05), // Glassmorphism base
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              movie.userNote!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          )
        else
          Column(
            children: [
              TextField(
                controller: _noteController,
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
                cursorColor: const Color(0xFFE50914), // Netflix Red
                decoration: InputDecoration(
                  hintText: "Write your thoughts about this movie...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE50914)),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    final username = authProvider.currentUser?.username;
                    if (username != null) {
                      await libProvider.saveNote(
                        username,
                        movie,
                        _noteController.text,
                      );
                      if (mounted) {
                        setState(() {
                          _isEditing = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Note saved"),
                            backgroundColor: Color(0xFFE50914),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please log in to save notes."),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914), // Netflix Red
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text("Save Note"),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    LibraryProvider libProvider,
    Movie movie,
    bool isFav,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.currentUser?.username;
    if (username != null) {
      await libProvider.toggleFavorite(username, movie);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFav ? "Removed from Favorites" : "Added to Favorites",
            ),
            backgroundColor: isFav ? Colors.grey : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleWatchList(
    BuildContext context,
    LibraryProvider libProvider,
    Movie movie,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.currentUser?.username;
    if (username != null) {
      final wasInList = libProvider.isInWatchList(movie);
      await libProvider.toggleWatchList(username, movie);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasInList ? "Removed from My List" : "Added to My List",
            ),
            backgroundColor: wasInList ? Colors.grey : AppTheme.primary,
          ),
        );
      }
    }
  }

  void _showAddToListDialog(
    BuildContext context,
    LibraryProvider libProvider,
    Movie movie,
  ) {
    if (libProvider.customListNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No custom lists created yet.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text("Add to List", style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: libProvider.customListNames.length,
            itemBuilder: (ctx, index) {
              final listName = libProvider.customListNames[index];
              return ListTile(
                title: Text(
                  listName,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final username = authProvider.currentUser?.username;
                  if (username != null) {
                    await libProvider.addToList(username, movie, listName);
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Added to $listName"),
                          backgroundColor: AppTheme.primary,
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
