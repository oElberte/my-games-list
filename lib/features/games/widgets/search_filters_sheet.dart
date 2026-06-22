import 'package:flutter/material.dart';
import 'package:my_games_list/core/utils/l10n_extensions.dart';
import 'package:my_games_list/features/games/bloc/game_search_filters.dart';
import 'package:my_games_list/features/games/search_game_model.dart';

/// Localized label for a [GameSearchSort] option.
String sortLabel(BuildContext context, GameSearchSort sort) {
  switch (sort) {
    case GameSearchSort.relevance:
      return context.l10n.searchSortRelevance;
    case GameSearchSort.nameAsc:
      return context.l10n.searchSortNameAsc;
    case GameSearchSort.yearDesc:
      return context.l10n.searchSortYearDesc;
    case GameSearchSort.yearAsc:
      return context.l10n.searchSortYearAsc;
  }
}

/// Bottom sheet that edits the search [GameSearchFilters] (sort + genre,
/// platform and year facets) over the currently loaded results.
///
/// Facets ([genres], [platforms], [years]) are derived from the loaded results
/// by the caller, so the sheet only ever offers values that can match.
class SearchFiltersSheet extends StatefulWidget {
  const SearchFiltersSheet({
    super.key,
    required this.filters,
    required this.genres,
    required this.platforms,
    required this.years,
  });

  final GameSearchFilters filters;
  final List<GameGenre> genres;
  final List<GamePlatform> platforms;
  final List<int> years;

  /// Shows the sheet and returns the edited filters, or null if dismissed.
  static Future<GameSearchFilters?> show({
    required BuildContext context,
    required GameSearchFilters filters,
    required List<GameGenre> genres,
    required List<GamePlatform> platforms,
    required List<int> years,
  }) {
    return showModalBottomSheet<GameSearchFilters>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SearchFiltersSheet(
        filters: filters,
        genres: genres,
        platforms: platforms,
        years: years,
      ),
    );
  }

  @override
  State<SearchFiltersSheet> createState() => _SearchFiltersSheetState();
}

class _SearchFiltersSheetState extends State<SearchFiltersSheet> {
  late GameSearchSort _sort;
  late Set<int> _genreIds;
  late Set<int> _platformIds;
  int? _year;

  @override
  void initState() {
    super.initState();
    _sort = widget.filters.sort;
    _genreIds = {...widget.filters.genreIds};
    _platformIds = {...widget.filters.platformIds};
    _year = widget.filters.year;
  }

  void _reset() {
    setState(() {
      _sort = GameSearchSort.relevance;
      _genreIds = {};
      _platformIds = {};
      _year = null;
    });
  }

  GameSearchFilters get _result => GameSearchFilters(
    sort: _sort,
    genreIds: _genreIds,
    platformIds: _platformIds,
    year: _year,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFacets =
        widget.genres.isNotEmpty ||
        widget.platforms.isNotEmpty ||
        widget.years.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.searchFiltersTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _result.isEmpty ? null : _reset,
                  child: Text(context.l10n.searchFiltersClearAll),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(context.l10n.searchSortLabel),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: GameSearchSort.values.map((sort) {
                        return ChoiceChip(
                          label: Text(sortLabel(context, sort)),
                          selected: _sort == sort,
                          onSelected: (_) => setState(() => _sort = sort),
                        );
                      }).toList(),
                    ),
                    if (widget.genres.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionLabel(context.l10n.searchFilterGenresLabel),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.genres.map((genre) {
                          return FilterChip(
                            label: Text(genre.name),
                            selected: _genreIds.contains(genre.id),
                            onSelected: (selected) => setState(() {
                              if (selected) {
                                _genreIds.add(genre.id);
                              } else {
                                _genreIds.remove(genre.id);
                              }
                            }),
                          );
                        }).toList(),
                      ),
                    ],
                    if (widget.platforms.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionLabel(context.l10n.searchFilterPlatformsLabel),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.platforms.map((platform) {
                          return FilterChip(
                            label: Text(platform.name),
                            selected: _platformIds.contains(platform.id),
                            onSelected: (selected) => setState(() {
                              if (selected) {
                                _platformIds.add(platform.id);
                              } else {
                                _platformIds.remove(platform.id);
                              }
                            }),
                          );
                        }).toList(),
                      ),
                    ],
                    if (widget.years.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionLabel(context.l10n.searchFilterYearLabel),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.years.map((year) {
                          return ChoiceChip(
                            label: Text('$year'),
                            selected: _year == year,
                            onSelected: (selected) =>
                                setState(() => _year = selected ? year : null),
                          );
                        }).toList(),
                      ),
                    ],
                    if (!hasFacets)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          context.l10n.searchFilterNoFacets,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_result),
                child: Text(context.l10n.searchFiltersApply),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
