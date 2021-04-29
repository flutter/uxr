import 'package:beamer/beamer.dart';
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

class _BooksAppState extends State<BooksApp> {
  final Authentication _auth = MockAuthentication();
  late final List<BeamGuard> _guards;
  late final BeamerRouterDelegate _delegate;
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _guards = [
      BeamGuard(
        pathBlueprints: ['/signin'],
        guardNonMatching: true,
        check: (_, __) => _isSignedIn,
        beamToNamed: '/signin',
      ),
      BeamGuard(
        pathBlueprints: ['/signin'],
        check: (_, __) => !_isSignedIn,
        beamToNamed: '/',
      )
    ];
    _delegate = BeamerRouterDelegate(
      guards: _guards,
      locationBuilder: SimpleLocationBuilder(
        routes: {
          '/': (context) => HomeScreen(
                onGoToBooks: () => Beamer.of(context).beamToNamed('/books'),
                onSignOut: () => _auth
                    .signOut()
                    .then((value) => setState(() => _isSignedIn = false)),
              ),
          '/signin': (context) => SignInScreen(
                onSignedIn: (credentials) => _auth
                    .signIn(credentials.username, credentials.password)
                    .then((value) => setState(() => _isSignedIn = value)),
              ),
          '/books': (context) => BooksListScreen(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routerDelegate: _delegate,
      routeInformationParser: BeamerRouteInformationParser(),
    );
  }
}

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
      appBar: AppBar(leading: SizedBox.shrink()),
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
