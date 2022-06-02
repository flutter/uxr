// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router_prototype/go_router_prototype.dart';

void main() {
  runApp(const BooksApp());
}

class Credentials {
  final String username;
  final String password;

  Credentials(this.username, this.password);
}

class Authentication extends ChangeNotifier {
  bool _signedIn = false;

  bool isSignedIn() => _signedIn;

  Future<void> signOut() async {
    _signedIn = false;
    notifyListeners();
  }

  Future<bool> signIn(String username, String password) async {
    _signedIn = true;
    notifyListeners();
    return true;
  }
}

class BooksApp extends StatefulWidget {
  const BooksApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class AppState {
  final Authentication auth;

  AppState(this.auth);

  Future<bool> signIn(String username, String password) async {
    var success = await auth.signIn(username, password);
    return success;
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}

class _BooksAppState extends State<BooksApp> {
  final AppState _appState = AppState(Authentication());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _router.parser,
      routerDelegate: _router.delegate,
    );
  }

  late final _router = GoRouter(
    refreshListenable: _appState.auth,
    routes: [
      ShellRoute(
        path: '/',
        builder: (context, child) => child,
        redirect: (state) async {
          final signedIn = _appState.auth.isSignedIn();
          if (!signedIn) return '/signin';
          return null;
        },
        routes: [
          StackedRoute(
            path: 'home',
            builder: (context) => HomeScreen(
              onSignOut: () async {
                await _appState.signOut();
              },
            ),
            routes: [
              StackedRoute(
                path: 'books',
                builder: (context) => const BooksListScreen(),
              ),
            ],
          ),
          StackedRoute(
            path: 'signin',
            builder: (context) => SignInScreen(
              onSignedIn: (credentials) async {
                await _appState.signIn(
                    credentials.username, credentials.password);
                RouteState.of(context).goTo('/home');
              },
            ),
          ),
        ],
      ),
    ],
  );
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onSignOut;

  const HomeScreen({required this.onSignOut, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => RouteState.of(context).goTo('books'),
              child: const Text('View my bookshelf'),
            ),
            ElevatedButton(
              onPressed: onSignOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  final ValueChanged<Credentials> onSignedIn;

  const SignInScreen({required this.onSignedIn, Key? key}) : super(key: key);

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
              decoration: const InputDecoration(hintText: 'username (any)'),
              onChanged: (s) => _username = s,
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'password (any)'),
              obscureText: true,
              onChanged: (s) => _password = s,
            ),
            ElevatedButton(
              onPressed: () =>
                  widget.onSignedIn(Credentials(_username, _password)),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class BooksListScreen extends StatelessWidget {
  const BooksListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: const [
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

class ErrorScreen extends StatelessWidget {
  const ErrorScreen(this.error, {Key? key}) : super(key: key);
  final Exception? error;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(error?.toString() ?? 'page not found'),
          TextButton(
            onPressed: () => RouteState.of(context).goTo('/'),
            child: const Text('Home'),
          ),
        ],
      ),
    ),
  );
}
