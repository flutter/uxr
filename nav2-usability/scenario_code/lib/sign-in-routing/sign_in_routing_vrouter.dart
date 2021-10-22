// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Sign-in example
/// Done using VRouter

import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

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
  final AppState _appState = AppState(MockAuthentication());

  @override
  Widget build(BuildContext context) {
    return VRouter(
      routes: [
        VGuard(
          beforeEnter: (vRedirector) async {
            if (await _appState.auth.isSignedIn()) {
              vRedirector.push('/');
            }
          },
          stackedRoutes: [
            VWidget(
              path: '/signIn',
              widget: Builder(
                builder: (context) => SignInScreen(
                  onSignedIn: (Credentials credentials) async {
                    await _appState.signIn(credentials.username, credentials.password);
                    context.vRouter.push('/');
                  },
                ),
              ),
            ),
          ],
        ),
        VGuard(
          beforeEnter: (vRedirector) async {
            if (!await _appState.auth.isSignedIn()) {
              vRedirector.push('/signIn');
            }
          },
          stackedRoutes: [
            VWidget(
              path: '/',
              widget: Builder(
                builder: (context) => HomeScreen(
                  onSignOut: () async {
                    await _appState.signOut();
                    context.vRouter.push('/signIn');
                  },
                ),
              ),
              stackedRoutes: [
                VWidget(path: 'books', widget: BooksListScreen()),
              ],
            ),
          ],
        ),
      ],
    );
  }
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
              onPressed: () => context.vRouter.push('/books'),
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
              onPressed: () => widget.onSignedIn(Credentials(_username, _password)),
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
