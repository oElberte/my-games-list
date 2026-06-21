import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_games_list/core/utils/app_router.dart';
import 'package:my_games_list/core/utils/l10n_extensions.dart';
import 'package:my_games_list/features/games/discovery_game_model.dart';
import 'package:my_games_list/features/games/widgets/anticipated_games_carousel.dart';
import 'package:my_games_list/features/games/widgets/discovery_games_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.pushNamed(AppRouter.searchName),
            tooltip: context.l10n.searchGamesTooltip,
          ),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anticipated games carousel at the top
            AnticipatedGamesCarousel(),
            // Trending games section
            DiscoveryGamesWidget(discoveryType: DiscoveryType.trending),
            SizedBox(height: 16),
            // Indie Gems section (lazy loaded)
            LazyDiscoveryGamesWidget(discoveryType: DiscoveryType.indie),
            SizedBox(height: 16),
            // New releases (lazy loaded)
            LazyDiscoveryGamesWidget(discoveryType: DiscoveryType.newReleases),
            SizedBox(height: 16),
            // Coming soon (lazy loaded)
            LazyDiscoveryGamesWidget(discoveryType: DiscoveryType.comingSoon),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
