/// The legal documents rendered by [LegalDocumentScreen].
///
/// Each value maps to a pair of markdown-ish placeholder assets under
/// `assets/legal/` — one per supported locale. The real text is supplied later
/// (see issue #26); the screen only needs to know which asset to load.
enum LegalDocument {
  privacyPolicy(
    enAsset: 'assets/legal/privacy_policy_en.md',
    ptAsset: 'assets/legal/privacy_policy_pt.md',
  ),
  terms(
    enAsset: 'assets/legal/terms_en.md',
    ptAsset: 'assets/legal/terms_pt.md',
  );

  const LegalDocument({required this.enAsset, required this.ptAsset});

  final String enAsset;
  final String ptAsset;

  /// Resolves the asset path for the given [languageCode], defaulting to English
  /// for any locale we don't ship a translation for.
  String assetFor(String languageCode) =>
      languageCode == 'pt' ? ptAsset : enAsset;
}
