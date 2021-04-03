// This file is tested with Navi 0.1.0.
// If it doesn't work with newer version, please check live version at https://github.com/zenonine/navi/tree/master/examples/uxr

import 'package:flutter/material.dart';
import 'package:navi/navi.dart';

void main() {
  runApp(BooksApp());
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

class AuthService extends ChangeNotifier {
  // In real app, DI is a better solution
  factory AuthService() => _instance;

  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  final Authentication _auth = MockAuthentication();

  Future<bool> get isSignedIn => _auth.isSignedIn();

  Future<bool> signIn(String username, String password) async {
    final success = await _auth.signIn(username, password);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}

class _BooksAppState extends State<BooksApp> {
  final NaviRouterDelegate _routerDelegate =
      NaviRouterDelegate.material(rootPage: RootPage());
  final NaviInformationParser _routeInformationParser = NaviInformationParser();

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

class HomeScreen extends StatelessWidget {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                context.navi.stack(BookStackMarker()).state = true;
              },
              child: Text('View my bookshelf'),
            ),
            ElevatedButton(
              onPressed: () => _authService.signOut(),
              child: Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String _username = '';
  String _password = '';

  final _authService = AuthService();

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
              onPressed: () => _authService.signIn(_username, _password),
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

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final _authService = AuthService();
  late final VoidCallback _authListener;

  bool _isSignedIn = false;

  final _stackController = StackController<bool>();

  @override
  void initState() {
    super.initState();

    _authListener = () async {
      _isSignedIn = await _authService.isSignedIn;
      _stackController.state = _isSignedIn;
    };

    _authService.addListener(_authListener);
  }

  @override
  void dispose() {
    _authService.removeListener(_authListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RouteStack<bool>(
      controller: _stackController,
      pages: (context, state) => [
        // true means authenticated
        if (state)
          MaterialPage<dynamic>(
            key: const ValueKey('BookStack'),
            child: BookStack(),
          )
        else
          MaterialPage<dynamic>(
            key: const ValueKey('SignInScreen'),
            child: SignInScreen(),
          ),
      ],
      updateStateOnNewRoute: (routeInfo) => _isSignedIn,
      updateRouteOnNewState: (state) =>
          RouteInfo(pathSegments: state ? [] : ['signin']),
    );
  }
}

class BookStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // true means showing BooksListPage
    return RouteStack<bool>(
      marker: BookStackMarker(),
      pages: (context, state) => [
        MaterialPage<dynamic>(
          key: const ValueKey('HomeScreen'),
          child: HomeScreen(),
        ),
        if (state)
          MaterialPage<dynamic>(
            key: const ValueKey('BooksListPage'),
            child: BooksListScreen(),
          ),
      ],
      updateStateOnNewRoute: (routeInfo) => routeInfo.hasPrefixes(['books']),
      updateRouteOnNewState: (state) =>
          RouteInfo(pathSegments: state ? ['books'] : []),
      updateStateBeforePop: (context, route, dynamic result, state) => false,
    );
  }
}

class BookStackMarker extends StackMarker<bool> {}
