import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../providers/auth_provider.dart';

import 'list_detail_screen.dart';

class MyListsScreen extends StatelessWidget {
  const MyListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Solid Black
      appBar: AppBar(
        title: const Text(
          'My Lists',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showCreateListDialog(context),
          ),
        ],
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, libProvider, _) {
          final movieList = libProvider.movies;
          final seriesList = libProvider.series;
          final customLists = libProvider.customListNames;

          // Prepare data for grid
          final List<Map<String, dynamic>> gridItems = [
            {
              'title': 'Movies',
              'count': movieList.length,
              'cover': movieList.isNotEmpty ? movieList.first.posterPath : null,
            },
            {
              'title': 'TV Series',
              'count': seriesList.length,
              'cover': seriesList.isNotEmpty
                  ? seriesList.first.posterPath
                  : null,
            },
          ];

          for (var name in customLists) {
            final list = libProvider.allLists[name] ?? [];
            gridItems.add({
              'title': name,
              'count': list.length,
              'cover': list.isNotEmpty ? list.first.posterPath : null,
            });
          }

          if (gridItems.isEmpty) {
            return const Center(
              child: Text(
                "No lists found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio:
                  0.8, // Slightly squarer than posters for "Folder" look
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: gridItems.length,
            itemBuilder: (context, index) {
              final item = gridItems[index];
              return _buildListCard(
                context,
                item['title'],
                item['count'],
                item['cover'],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildListCard(
    BuildContext context,
    String title,
    int count,
    String? posterPath,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ListDetailScreen(listName: title)),
        );
      },
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (Cover)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: posterPath != null
                ? CachedNetworkImage(
                    imageUrl: 'https://image.tmdb.org/t/p/w500$posterPath',
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(
                      0.4,
                    ), // Darken for text readability
                    colorBlendMode: BlendMode.darken,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[900]),
                    errorWidget: (context, url, err) =>
                        Container(color: Colors.grey[900]),
                  )
                : Container(
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.folder,
                      color: Colors.white24,
                      size: 40,
                    ),
                  ),
          ),

          // Overlay content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$count items',
                  style: const TextStyle(
                    color: Color(0xFFE50914), // Netflix Red accent
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateListDialog(BuildContext context) {
    // ... existing dialog code retained but styled to be dark ...
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF191919),
        title: const Text("New List", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          cursorColor: const Color(0xFFE50914),
          decoration: const InputDecoration(
            hintText: "List Name",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE50914)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final user = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).currentUser;
                if (user != null) {
                  await Provider.of<LibraryProvider>(
                    context,
                    listen: false,
                  ).createCustomList(user.username, name);
                  if (context.mounted) Navigator.pop(ctx);
                }
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
