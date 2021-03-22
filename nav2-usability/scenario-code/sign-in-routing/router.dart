import 'package:flutter/material.dart';

void main() {
  runApp(BooksApp());
}

class Credentials {
  final String username;
  final String password;

  Credentials(this.username, this.password);
}

abstract class Authentication {
  bool isSignedIn();

  void signOut();

  Future<bool> signIn(String username, String password);
}

class MockAuthentication implements Authentication {
  bool _signedIn = false;

  @override
  bool isSignedIn() {
    return _signedIn;
  }

  @override
  void signOut() {
    _signedIn = false;
  }

  @override
  Future<bool> signIn(String username, String password) async {
    return _signedIn = true;
  }
}

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class AppState extends ChangeNotifier {
  final Authentication auth;

  AppState(this.auth);

  Future<bool> signIn(String username, String password) async {
    var success = await auth.signIn(username, password);
    notifyListeners();
    return success;
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
      // Handle '/signin'
      if (uri.pathSegments[0] == 'signin') return SignInRoutePath();
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
    } else if (path is SignInRoutePath) {
      location = '/signin';
    }
    return RouteInformation(location: location);
  }
}

class BookRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final AppState _appState = AppState(MockAuthentication());

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
    if (!_appState.auth.isSignedIn()) {
      return SignInRoutePath();
    } else if (_appState.viewingBooks) {
      return BooksRoutePath();
    } else {
      return HomeRoutePath();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignedIn = _appState.auth.isSignedIn();
    final viewingBooksScreen = _appState.viewingBooks;
    return Navigator(
      key: navigatorKey,
      pages: [
        if (isSignedIn) ...[
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
            key: ValueKey('SignInScreen'),
            child: SignInScreen(
              onSignedIn: _handleSignedIn,
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
    } else if (path is SignInRoutePath) {
      // Sign out
      _appState.viewingBooks = false;
      _appState.auth.signOut();
    }
  }

  void _handleGoToBooks() {
    _appState.viewingBooks = true;
  }

  Future _handleSignedIn(Credentials credentials) async {
    await _appState.signIn(credentials.username, credentials.password);
  }
}

class AppRoutePath {}

class HomeRoutePath extends AppRoutePath {}

class SignInRoutePath extends AppRoutePath {}

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

class SignInScreen extends StatefulWidget {
  final ValueChanged<Credentials> onSignedIn;

  SignInScreen({
    required this.onSignedIn,
  });

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(hintText: 'username (any)'),
              onChanged: (s) => _username = s,
            ),
            TextField(
              decoration: InputDecoration(hintText: 'password (any)'),
              onChanged: (s) => _password = s,
            ),
            ElevatedButton(
              onPressed: () =>
                  widget.onSignedIn(Credentials(_username, _password)),
              child: Text('Sign in'),
            ),
          ],
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
