// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'My Games List';

  @override
  String get errorTitle => 'Erro';

  @override
  String get errorMessage => 'Ops! Algo deu errado.';

  @override
  String get goHome => 'Ir para o Início';

  @override
  String get signInTitle => 'Entrar';

  @override
  String get signInSubtitle => 'Entre para continuar';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'Digite seu e-mail';

  @override
  String get emailRequired => 'E-mail é obrigatório';

  @override
  String get emailInvalid => 'Digite um e-mail válido';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get passwordHint => 'Digite sua senha';

  @override
  String get passwordRequired => 'Senha é obrigatória';

  @override
  String get passwordMinLength => 'A senha deve ter pelo menos 6 caracteres';

  @override
  String get signInButton => 'Entrar';

  @override
  String get noAccount => 'Não tem uma conta?';

  @override
  String get signUpLink => 'Cadastre-se';

  @override
  String get signUpAppBarTitle => 'Cadastro';

  @override
  String get signUpBodyTitle => 'Criar Conta';

  @override
  String get signUpSubtitle => 'Cadastre-se para começar';

  @override
  String get usernameLabel => 'Nome de usuário';

  @override
  String get usernameHint => 'Escolha um nome de usuário';

  @override
  String get usernameRequired => 'Nome de usuário é obrigatório';

  @override
  String get usernameMinLength =>
      'Nome de usuário deve ter pelo menos 3 caracteres';

  @override
  String get usernameMaxLength =>
      'Nome de usuário deve ter no máximo 20 caracteres';

  @override
  String get passwordCreateHint => 'Crie uma senha';

  @override
  String get confirmPasswordLabel => 'Confirmar Senha';

  @override
  String get confirmPasswordHint => 'Digite sua senha novamente';

  @override
  String get confirmPasswordRequired => 'Por favor, confirme sua senha';

  @override
  String get passwordMismatch => 'As senhas não coincidem';

  @override
  String get signUpButton => 'Cadastrar';

  @override
  String get alreadyHaveAccount => 'Já tem uma conta?';

  @override
  String get signInLink => 'Entrar';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get userInformationTitle => 'Informações do Usuário';

  @override
  String nameFormat(String name) {
    return 'Nome: $name';
  }

  @override
  String emailFormat(String email) {
    return 'E-mail: $email';
  }

  @override
  String get unknown => 'Desconhecido';

  @override
  String get appearanceTitle => 'Aparência';

  @override
  String get darkModeTitle => 'Modo Escuro';

  @override
  String get darkModeSubtitle => 'Alternar entre tema claro e escuro';

  @override
  String get logoutButton => 'Sair';

  @override
  String get searchGamesTitle => 'Buscar Jogos';

  @override
  String get searchGamesHint => 'Buscar jogos...';

  @override
  String get searchGamesTooltip => 'Buscar Jogos';

  @override
  String get searchGamesInitialMessage => 'Busque seus jogos favoritos';

  @override
  String searchGamesNoResults(String query) {
    return 'Nenhum resultado encontrado para \"$query\"';
  }

  @override
  String get searchGamesErrorMessage => 'Ocorreu um erro';

  @override
  String get searchGamesOffsetLimitReached =>
      'Limite máximo de resultados atingido. Por favor, refine sua busca.';

  @override
  String get searchGamesLoadMoreFailed => 'Falha ao carregar mais resultados';

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
}
