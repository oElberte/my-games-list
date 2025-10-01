import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import '../services/service_locator.dart';
import '../stores/home_store.dart';
import '../utils/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeStore = getIt<HomeStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Games List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(AppRouter.settingsPath),
          ),
          IconButton(
            icon: const Icon(Icons.web),
            onPressed: () => context.go(AppRouter.webviewPath),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: homeStore.items.length,
        itemBuilder: (context, index) {
          final item = homeStore.items[index];

          return Observer(
            builder: (context) {
              // This Observer will track changes to favoriteItemIds
              final isFavorite = homeStore.favoriteItemIds.contains(item.id);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.description),
                  trailing: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => homeStore.toggleFavorite(item.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
