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
      appBar: AppBar(
        title: const Text('My Lists'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateListDialog(context),
          ),
        ],
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, libProvider, _) {
          final moviesCount = libProvider.movies.length;
          final seriesCount = libProvider.series.length;
          final customLists = libProvider.customListNames;

          return ListView(
            children: [
              _buildListTile(context, 'Movies', moviesCount, Icons.movie),
              _buildListTile(context, 'TV Series', seriesCount, Icons.tv),
              const Divider(),
              if (customLists.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No custom lists created.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ...customLists.map((name) {
                final count = libProvider.allLists[name]?.length ?? 0;
                return _buildListTile(context, name, count, Icons.folder);
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    int count,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.purpleAccent),
      title: Text(title),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$count',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ListDetailScreen(listName: title)),
        );
      },
    );
  }

  void _showCreateListDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("New List"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "List Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
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
