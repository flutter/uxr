// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file is tested with Navi 0.2.0.
// If it doesn't work with newer version, please check live version at https://github.com/zenonine/navi/tree/master/examples/uxr

import 'package:flutter/material.dart';
import 'package:navi/navi.dart';

void main() {
  runApp(BooksApp());
}

class BooksApp extends StatefulWidget {
  @override
  _BooksAppState createState() => _BooksAppState();
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
  int _currentIndex = 0;

  @override
  void onNewRoute(NaviRoute unprocessedRoute) {
    _currentIndex = 0;
    if (unprocessedRoute.pathSegmentAt(0) == 'settings') {
      _currentIndex = 1;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: NaviStack(
          key: ValueKey(_currentIndex),
          pages: (context) => [
            _currentIndex == 0
                ? NaviPage.material(
                    key: ValueKey(_currentIndex),
                    route: NaviRoute(path: ['books']),
                    child: BooksScreen(),
                  )
                : NaviPage.material(
                    key: ValueKey(_currentIndex),
                    route: NaviRoute(path: ['settings']),
                    child: SettingsScreen(),
                  )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
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
        onTap: (newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
      ),
    );
  }
}

class BooksScreen extends StatefulWidget {
  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with SingleTickerProviderStateMixin, NaviRouteMixin<BooksScreen> {
  int _currentIndex = 0;
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void onNewRoute(NaviRoute unprocessedRoute) {
    _currentIndex = 0;
    if (unprocessedRoute.pathSegmentAt(0) == 'all') {
      _currentIndex = 1;
    }

    setState(() {
      _tabController.animateTo(_currentIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          onTap: (newIndex) => setState(() {
            _currentIndex = newIndex;
          }),
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
              NaviStack(
                active: _currentIndex == 0,
                pages: (context) => [
                  NaviPage.material(
                    key: ValueKey('New'),
                    route: NaviRoute(path: ['new']),
                    child: NewBooksScreen(),
                  )
                ],
              ),
              NaviStack(
                active: _currentIndex == 1,
                pages: (context) => [
                  NaviPage.material(
                    key: ValueKey('All'),
                    route: NaviRoute(path: ['all']),
                    child: AllBooksScreen(),
                  )
                ],
              ),
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
