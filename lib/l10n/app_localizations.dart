import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'My Games List'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to My Games List'**
  String get welcomeMessage;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong.'**
  String get errorMessage;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goHome;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpLink;

  /// No description provided for @signUpAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpAppBarTitle;

  /// No description provided for @signUpBodyTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUpBodyTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get signUpSubtitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a username'**
  String get usernameHint;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// No description provided for @usernameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at most 20 characters'**
  String get usernameMaxLength;

  /// No description provided for @passwordCreateHint.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get passwordCreateHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInLink;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @userInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get userInformationTitle;

  /// No description provided for @nameFormat.
  ///
  /// In en, this message translates to:
  /// **'Name: {name}'**
  String nameFormat(String name);

  /// No description provided for @emailFormat.
  ///
  /// In en, this message translates to:
  /// **'Email: {email}'**
  String emailFormat(String email);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @darkModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeTitle;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Toggle between light and dark theme'**
  String get darkModeSubtitle;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @searchGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Games'**
  String get searchGamesTitle;

  /// No description provided for @searchGamesHint.
  ///
  /// In en, this message translates to:
  /// **'Search for games...'**
  String get searchGamesHint;

  /// No description provided for @searchGamesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search Games'**
  String get searchGamesTooltip;

  /// No description provided for @searchGamesInitialMessage.
  ///
  /// In en, this message translates to:
  /// **'Search for your favorite games'**
  String get searchGamesInitialMessage;

  /// No description provided for @searchGamesNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\"'**
  String searchGamesNoResults(String query);

  /// No description provided for @searchGamesErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get searchGamesErrorMessage;

  /// No description provided for @searchGamesOffsetLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum search results reached. Please refine your search.'**
  String get searchGamesOffsetLimitReached;

  /// No description provided for @searchGamesLoadMoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more results'**
  String get searchGamesLoadMoreFailed;

  /// No description provided for @gameDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Details'**
  String get gameDetailsTitle;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @platforms.
  ///
  /// In en, this message translates to:
  /// **'Platforms'**
  String get platforms;

  /// No description provided for @storyline.
  ///
  /// In en, this message translates to:
  /// **'Storyline'**
  String get storyline;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @screenshots.
  ///
  /// In en, this message translates to:
  /// **'Screenshots'**
  String get screenshots;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @similarGames.
  ///
  /// In en, this message translates to:
  /// **'Similar Games'**
  String get similarGames;

  /// No description provided for @whereToBuy.
  ///
  /// In en, this message translates to:
  /// **'Where to Buy'**
  String get whereToBuy;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Read Less'**
  String get readLess;

  /// No description provided for @noVideosAvailable.
  ///
  /// In en, this message translates to:
  /// **'No videos available'**
  String get noVideosAvailable;

  /// No description provided for @noScreenshotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No screenshots available'**
  String get noScreenshotsAvailable;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @discoveryTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending Now'**
  String get discoveryTrending;

  /// No description provided for @discoveryIndie.
  ///
  /// In en, this message translates to:
  /// **'Indie Gems'**
  String get discoveryIndie;

  /// No description provided for @discoveryUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Games'**
  String get discoveryUpcoming;

  /// No description provided for @discoveryNewReleases.
  ///
  /// In en, this message translates to:
  /// **'New Releases'**
  String get discoveryNewReleases;

  /// No description provided for @discoveryComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get discoveryComingSoon;

  /// No description provided for @recommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommendationsTitle;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @browseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browseTitle;

  /// No description provided for @browseGenresError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load genres. Please try again.'**
  String get browseGenresError;

  /// No description provided for @browseGenresEmpty.
  ///
  /// In en, this message translates to:
  /// **'No genres available right now.'**
  String get browseGenresEmpty;

  /// No description provided for @browseGenreGamesError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load games for this genre. Please try again.'**
  String get browseGenreGamesError;

  /// No description provided for @browseGenreEmpty.
  ///
  /// In en, this message translates to:
  /// **'No games found in this genre yet.'**
  String get browseGenreEmpty;

  /// No description provided for @browseRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get browseRetry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
