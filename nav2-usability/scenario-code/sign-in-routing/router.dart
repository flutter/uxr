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
  Future<bool> isSignedIn();

  Future<void> signOut();

  Future<bool> signIn(String username, String password);
}

class MockAuthentication implements Authentication {
  bool _signedIn = false;

  @override
  Future<bool> isSignedIn() async {
    return _signedIn;
  }

  @override
  Future<void> signOut() async {
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
  bool _isViewingBooks = false;
  bool _isViewingSignIn = false;

  AppState(this.auth);

  Future<bool> signIn(String username, String password) async {
    var success = await auth.signIn(username, password);
    if (success) {
      _isViewingSignIn = false;
    }
    notifyListeners();
    return success;
  }

  Future<void> signOut() async {
    await auth.signOut();
    _isViewingSignIn = true;
    notifyListeners();
  }

  bool get isViewingBooks => _isViewingBooks;

  set isViewingBooks(bool value) {
    _isViewingBooks = value;
    if (_isViewingBooks) {
      _isViewingSignIn = false;
    }

    notifyListeners();
  }

  bool get isViewingSignIn => _isViewingSignIn;

  set isViewingSignIn(bool value) {
    _isViewingSignIn = value;
    if (_isViewingSignIn) {
      _isViewingBooks = false;
    }

    notifyListeners();
  }
}

class _BooksAppState extends State<BooksApp> {
  final AppState _appState = AppState(MockAuthentication());
  late final BookRouterDelegate _routerDelegate = BookRouterDelegate(_appState);
  late final BookRouteInformationParser _routeInformationParser =
  BookRouteInformationParser(_appState);

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
  final AppState _appState;

  BookRouteInformationParser(this._appState);

  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);

    // Check if the user is signed in.
    if (!await _appState.auth.isSignedIn()) {
      return SignInRoutePath();
    }

    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return HomeRoutePath();
    }

    if (uri.pathSegments.length == 1 && uri.pathSegments[0] == 'books') {
      return BooksRoutePath();
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
  final AppState _appState;

  BookRouterDelegate(this._appState)
      : navigatorKey = GlobalKey<NavigatorState>() {
    _appState.addListener(() => notifyListeners());
  }

  void _handleGoToBooks() {
    _appState.isViewingBooks = true;
  }

  Future _handleSignOut() async {
    await _appState.signOut();
  }

  Future _handleSignedIn(Credentials credentials) async {
    await _appState.signIn(credentials.username, credentials.password);
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  AppRoutePath get currentConfiguration {
    if (_appState.isViewingSignIn) {
      return SignInRoutePath();
    } else if (_appState.isViewingBooks) {
      return BooksRoutePath();
    } else {
      return HomeRoutePath();
    }
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    if (path is HomeRoutePath) {
      _appState.isViewingBooks = false;
      _appState.isViewingSignIn = false;
    } else if (path is BooksRoutePath) {
      _appState.isViewingBooks = true;
      _appState.isViewingSignIn = false;
    } else if (path is SignInRoutePath) {
      _appState.isViewingSignIn = true;
      _appState.isViewingBooks = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewingSignIn = _appState.isViewingSignIn;
    final viewingBooksScreen = _appState.isViewingBooks;
    return Navigator(
      key: navigatorKey,
      pages: [
        if (viewingSignIn)
          MaterialPage(
            key: ValueKey('SignInScreen'),
            child: SignInScreen(
              onSignedIn: _handleSignedIn,
            ),
          )
        else ...[
          MaterialPage(
            key: ValueKey('HomeScreen'),
            child: HomeScreen(
              onGoToBooks: _handleGoToBooks,
              onSignOut: _handleSignOut,
            ),
          ),
          if (viewingBooksScreen)
            MaterialPage(
              key: ValueKey('BooksListPage'),
              child: BooksListScreen(),
            ),
        ]
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (_appState.isViewingBooks) {
          _appState.isViewingBooks = false;
        }

        return true;
      },
    );
  }
}

class AppRoutePath {}

class HomeRoutePath extends AppRoutePath {}

class SignInRoutePath extends AppRoutePath {}

class BooksRoutePath extends AppRoutePath {}

class HomeScreen extends StatelessWidget {
  final VoidCallback onGoToBooks;
  final VoidCallback onSignOut;

  HomeScreen({
    required this.onGoToBooks,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: onGoToBooks,
              child: Text('View my bookshelf'),
            ),
            ElevatedButton(
              onPressed: onSignOut,
              child: Text('Sign out'),
            ),
          ],
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
              obscureText: true,
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
