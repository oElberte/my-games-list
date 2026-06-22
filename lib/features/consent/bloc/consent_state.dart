import 'package:equatable/equatable.dart';
import 'package:my_games_list/core/services/consent/consent_category.dart';

/// Snapshot of the user's consent choices, surfaced to the UI.
///
/// Mirrors [ConsentService]: [hasAnswered] drives the first-run prompt and the
/// per-[ConsentCategory] flags in [granted] drive the settings switches.
class ConsentState extends Equatable {
  const ConsentState({required this.hasAnswered, required this.granted});

  /// Whether the user has made an explicit consent choice (prompt dismissed).
  final bool hasAnswered;

  /// Current grant flag per category. Missing keys are treated as denied.
  final Map<ConsentCategory, bool> granted;

  /// Whether [category] is currently granted. Denied by default.
  bool isGranted(ConsentCategory category) => granted[category] ?? false;

  @override
  List<Object?> get props => [
    hasAnswered,
    for (final category in ConsentCategory.values) granted[category] ?? false,
  ];
}
