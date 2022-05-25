// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Sign-in example
/// Done using go_router

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(BooksApp());
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
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }

  late final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: HomeScreen(onSignOut: () async {
            await _appState.signOut();
          }),
        ),
        routes: [
          GoRoute(
            path: 'books',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: BooksListScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/signin',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: SignInScreen(onSignedIn: (Credentials credentials) async {
            await _appState.signIn(
              credentials.username,
              credentials.password,
            );
          }),
        ),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: ErrorScreen(state.error),
    ),
    redirect: (state) {
      final signedIn = _appState.auth.isSignedIn();
      if (!signedIn) return '/signin';
      return null;
    },
    refreshListenable: _appState.auth,
  );
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onSignOut;

  HomeScreen({required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => context.go('/books'),
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

  SignInScreen({required this.onSignedIn});

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
                onPressed: () => context.go('/'),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      );
}
