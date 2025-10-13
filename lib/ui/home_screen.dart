import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_games_list/blocs/home_bloc.dart';
import 'package:my_games_list/blocs/home_event.dart';
import 'package:my_games_list/blocs/home_state.dart';
import 'package:my_games_list/services/service_locator.dart';
import 'package:my_games_list/utils/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomeBloc>()..add(const HomeInitialized()),
      child: Scaffold(
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
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                final isFavorite = state.isFavorite(item.id);

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
                      onPressed: () => context.read<HomeBloc>().add(
                        HomeToggleFavorite(item.id),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
