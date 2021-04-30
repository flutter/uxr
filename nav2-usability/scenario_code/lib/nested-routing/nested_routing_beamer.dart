// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(BooksApp());
}

// The state of the bottom navigation bar
enum AppPage {
  newBooks, // /books/new
  allBooks, // /books/all
  settings, // /settings
}

class BooksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routerDelegate: BeamerRouterDelegate(
        initialPath: '/books/new',
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '/*/*': (context) => HomeScreen(),
          },
        ),
      ),
      routeInformationParser: BeamerRouteInformationParser(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _innerBeamer = GlobalKey<BeamerState>();

  @override
  Widget build(BuildContext context) {
    final beamerState = Beamer.of(context).state;
    return Scaffold(
      body: Beamer(
        key: _innerBeamer,
        routerDelegate: BeamerRouterDelegate(
          transitionDelegate: NoAnimationTransitionDelegate(),
          locationBuilder: SimpleLocationBuilder(
            routes: {
              '/books/*': (context) => BooksScreen(
                  appPage: beamerState.uri.pathSegments.contains('all')
                      ? AppPage.allBooks
                      : AppPage.newBooks,
                  onTabSelected:
                      (index) {} // added a listener to TabController: line 118
                  ),
              '/settings': (context) => SettingsScreen(),
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: beamerState.uri.path == '/settings' ? 1 : 0,
        onTap: (idx) {
          if (idx == 0) {
            _innerBeamer.currentState?.routerDelegate.beamToNamed('/books/new');
            setState(() {});
          } else {
            _innerBeamer.currentState?.routerDelegate.beamToNamed('/settings');
            setState(() {});
          }
        },
        items: [
          BottomNavigationBarItem(
            label: 'Books',
            icon: Icon(Icons.chrome_reader_mode_outlined),
          ),
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}

class BooksScreen extends StatefulWidget {
  final AppPage appPage;
  final ValueChanged<int> onTabSelected;

  BooksScreen({
    Key? key,
    required this.appPage,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    var initialIndex = widget.appPage == AppPage.newBooks ? 0 : 1;

    _tabController =
        TabController(length: 2, vsync: this, initialIndex: initialIndex)
          ..addListener(() {
            if (!_tabController.indexIsChanging) {
              Beamer.of(context).updateRouteInformation(
                _tabController.index == 0
                    ? Uri.parse('/books/new')
                    : Uri.parse('/books/all'),
              );
            }
          });
  }

  @override
  void didUpdateWidget(BooksScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appPage == AppPage.newBooks) {
      _tabController.index = 0;
    } else {
      _tabController.index = 1;
    }
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          onTap: widget.onTabSelected,
          labelColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(icon: Icon(Icons.bathtub), text: 'New'),
            Tab(icon: Icon(Icons.group), text: 'All'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              NewBooksScreen(),
              AllBooksScreen(),
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Settings'),
      ),
    );
  }
}

class AllBooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('All Books'),
      ),
    );
  }
}

class NewBooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('New Books'),
      ),
    );
  }
}
