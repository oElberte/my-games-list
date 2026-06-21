// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Games List';

  @override
  String get welcomeMessage => 'Welcome to My Games List';

  @override
  String get errorTitle => 'Error';

  @override
  String get errorMessage => 'Oops! Something went wrong.';

  @override
  String get goHome => 'Go to Home';

  @override
  String get signInTitle => 'Sign In';

  @override
  String get signInSubtitle => 'Sign in to continue';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get signInButton => 'Sign In';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUpLink => 'Sign Up';

  @override
  String get signUpAppBarTitle => 'Sign Up';

  @override
  String get signUpBodyTitle => 'Create Account';

  @override
  String get signUpSubtitle => 'Sign up to get started';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'Choose a username';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get usernameMinLength => 'Username must be at least 3 characters';

  @override
  String get usernameMaxLength => 'Username must be at most 20 characters';

  @override
  String get passwordCreateHint => 'Create a password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signInLink => 'Sign In';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get userInformationTitle => 'User Information';

  @override
  String nameFormat(String name) {
    return 'Name: $name';
  }

  @override
  String emailFormat(String email) {
    return 'Email: $email';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get darkModeTitle => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Toggle between light and dark theme';

  @override
  String get logoutButton => 'Logout';

  @override
  String get searchGamesTitle => 'Search Games';

  @override
  String get searchGamesHint => 'Search for games...';

  @override
  String get searchGamesTooltip => 'Search Games';

  @override
  String get searchGamesInitialMessage => 'Search for your favorite games';

  @override
  String searchGamesNoResults(String query) {
    return 'No results found for \"$query\"';
  }

  @override
  String get searchGamesErrorMessage => 'An error occurred';

  @override
  String get searchGamesOffsetLimitReached =>
      'Maximum search results reached. Please refine your search.';

  @override
  String get searchGamesLoadMoreFailed => 'Failed to load more results';

  @override
  String get gameDetailsTitle => 'Game Details';

  @override
  String get developer => 'Developer';

  @override
  String get rating => 'Rating';

  @override
  String get genres => 'Genres';

  @override
  String get platforms => 'Platforms';

  @override
  String get storyline => 'Storyline';

  @override
  String get summary => 'Summary';

  @override
  String get screenshots => 'Screenshots';

  @override
  String get videos => 'Videos';

  @override
  String get similarGames => 'Similar Games';

  @override
  String get whereToBuy => 'Where to Buy';

  @override
  String get readMore => 'Read More';

  @override
  String get readLess => 'Read Less';

  @override
  String get noVideosAvailable => 'No videos available';

  @override
  String get noScreenshotsAvailable => 'No screenshots available';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get discoveryTrending => 'Trending Now';

  @override
  String get discoveryIndie => 'Indie Gems';

  @override
  String get discoveryUpcoming => 'Upcoming Games';

  @override
  String get discoveryNewReleases => 'New Releases';

  @override
  String get discoveryComingSoon => 'Coming Soon';

  @override
  String get recommendationsTitle => 'Recommended for You';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get browseTitle => 'Browse';

  @override
  String get browseGenresError => 'Couldn\'t load genres. Please try again.';

  @override
  String get browseGenresEmpty => 'No genres available right now.';

  @override
  String get browseGenreGamesError =>
      'Couldn\'t load games for this genre. Please try again.';

  @override
  String get browseGenreEmpty => 'No games found in this genre yet.';

  @override
  String get browseRetry => 'Try again';
}
