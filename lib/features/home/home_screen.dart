import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_games_list/core/utils/l10n_extensions.dart';
import 'package:my_games_list/features/games/widgets/anticipated_games_carousel.dart';
import 'package:my_games_list/features/home/bloc/home_bloc.dart';
import 'package:my_games_list/features/home/bloc/home_event.dart';
import 'package:my_games_list/features/home/bloc/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appTitle)),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anticipated games carousel at the top
            AnticipatedGamesCarousel(),
            // Existing items list
            _ItemsList(),
          ],
        ),
      ),
    );
  }
}

class _ItemsList extends StatelessWidget {
  const _ItemsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
                  onPressed: () =>
                      context.read<HomeBloc>().add(HomeToggleFavorite(item.id)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
