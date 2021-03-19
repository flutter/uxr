import 'package:flutter/material.dart';

void main() {
  runApp(BooksApp());
}

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  bool _viewingBooks = false;

  bool get viewingBooks => _viewingBooks;

  set viewingBooks(bool value) {
    _viewingBooks = value;
    notifyListeners();
  }
}

class _BooksAppState extends State<BooksApp> {
  final BookRouterDelegate _routerDelegate = BookRouterDelegate();
  final BookRouteInformationParser _routeInformationParser =
  BookRouteInformationParser();

  @override
  void dispose() {
    _routerDelegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

class BookRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);

    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return HomeRoutePath();
    }

    if (uri.pathSegments.length == 1) {
      // Handle '/login'
      if (uri.pathSegments[0] == 'login') return LoginRoutePath();
      if (uri.pathSegments[0] == 'books') return BooksRoutePath();
    }

    // Handle unknown routes
    return HomeRoutePath();
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath path) {
    late final String location;
    if (path is HomeRoutePath) {
      location = '/';
    } else if (path is BooksRoutePath) {
      location = '/books';
    } else if (path is LoginRoutePath) {
      location = '/login';
    }
    return RouteInformation(location: location);
  }
}

class BookRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final AppState _appState = AppState();

  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    _appState.addListener(() => notifyListeners());
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  AppRoutePath get currentConfiguration {
    if (!_appState.isLoggedIn) {
      return LoginRoutePath();
    } else if (_appState.viewingBooks) {
      return BooksRoutePath();
    } else {
      return HomeRoutePath();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _appState.isLoggedIn;
    final viewingBooksScreen = _appState.viewingBooks;
    return Navigator(
      key: navigatorKey,
      pages: [
        if (isLoggedIn) ...[
          MaterialPage(
            key: ValueKey('HomeScreen'),
            child: HomeScreen(
              onGoToBooks: _handleGoToBooks,
            ),
          ),
          if (viewingBooksScreen)
            MaterialPage(
              key: ValueKey('BooksListPage'),
              child: BooksListScreen(),
            ),
        ] else
          MaterialPage(
            key: ValueKey('LoginScreen'),
            child: LoginScreen(
              onLoggedIn: _handleLoggedIn,
            ),
          )
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (_appState.viewingBooks) {
          _appState.viewingBooks = false;
        }

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    if (path is HomeRoutePath) {
      _appState.viewingBooks = false;
    } else if (path is BooksRoutePath) {
      _appState.viewingBooks = true;
    } else if (path is LoginRoutePath) {
      // Log out
      _appState.viewingBooks = false;
      _appState.isLoggedIn = false;
    }
  }

  void _handleGoToBooks() {
    _appState.viewingBooks = true;
  }

  void _handleLoggedIn() {
    _appState.isLoggedIn = true;
  }
}

class AppRoutePath {}

class HomeRoutePath extends AppRoutePath {}

class LoginRoutePath extends AppRoutePath {}

class BooksRoutePath extends AppRoutePath {}

class HomeScreen extends StatelessWidget {
  final VoidCallback onGoToBooks;

  HomeScreen({
    required this.onGoToBooks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
          onPressed: onGoToBooks,
          child: Text('View my bookshelf'),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final VoidCallback onLoggedIn;

  LoginScreen({
    required this.onLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
          onPressed: onLoggedIn,
          child: Text('Log in'),
        ),
      ),
    );
  }
}

class BooksListScreen extends StatelessWidget {
  BooksListScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ListTile(
            title: Text('Stranger in a Strange Land'),
            subtitle: Text('Robert A. Heinlein'),
          ),
          ListTile(
            title: Text('Foundation'),
            subtitle: Text('Isaac Asimov'),
          ),
          ListTile(
            title: Text('Fahrenheit 451'),
            subtitle: Text('Ray Bradbury'),
          ),
        ],
      ),
    );
  }
}
