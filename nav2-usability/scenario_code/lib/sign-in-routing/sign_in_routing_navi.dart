// If the file doesn't work with newer version, please check live version at
// https://github.com/zenonine/navi/tree/master/examples/uxr

import 'package:flutter/material.dart';
import 'package:navi/navi.dart';

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

class AuthService extends ChangeNotifier {
  AuthService(this.auth);

  final Authentication auth;

  bool _authenticated = false;

  bool get authenticated => _authenticated;

  Future<bool> signIn(String username, String password) async {
    final success = await auth.signIn(username, password);
    if (success) {
      _authenticated = true;
      notifyListeners();
    }
    return success;
  }

  Future<void> signOut() async {
    await auth.signOut();
    _authenticated = false;
    notifyListeners();
  }
}

final authService = AuthService(MockAuthentication());

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  final _routeInformationParser = NaviInformationParser();
  final _routerDelegate = NaviRouterDelegate.material(child: RootStack());

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

class RootStack extends StatefulWidget {
  @override
  _RootStackState createState() => _RootStackState();
}

class _RootStackState extends State<RootStack> with NaviRouteMixin<RootStack> {
  late final VoidCallback _authListener;
  bool _showBooks = false;

  @override
  void initState() {
    super.initState();
    _authListener = () => setState(() {});
    authService.addListener(_authListener);
  }

  @override
  void onNewRoute(NaviRoute unprocessedRoute) {
    setState(() {
      _showBooks = unprocessedRoute.hasPrefixes(['books']);
    });
  }

  @override
  void dispose() {
    authService.removeListener(_authListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NaviStack(
      pages: (context) => [
        if (authService.authenticated) ...[
          NaviPage.material(
            key: const ValueKey('Home'),
            child: HomeScreen(),
          ),
          if (_showBooks)
            NaviPage.material(
              key: const ValueKey('Books'),
              route: const NaviRoute(path: ['books']),
              child: BooksListScreen(),
            ),
        ] else
          NaviPage.material(
            key: const ValueKey('Auth'),
            route: const NaviRoute(path: ['signin']),
            child: SignInScreen(),
          ),
      ],
      onPopPage: (context, route, result) {
        if (_showBooks) {
          setState(() {
            _showBooks = false;
          });
        }
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => context.navi.to(['books']),
              child: Text('View my bookshelf'),
            ),
            ElevatedButton(
              onPressed: () => authService.signOut(),
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
              onPressed: () => authService.signIn(_username, _password),
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
