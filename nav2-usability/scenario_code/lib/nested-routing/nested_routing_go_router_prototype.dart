// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router_prototype/go_router_prototype.dart';

void main() {
  runApp(BooksApp());
}

class BooksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _router.parser,
      routerDelegate: _router.delegate,
    );
  }

  late final _router = GoRouter(
    routes: [
      ShellRoute(
        path: '/',
        redirect: (routeState) async {
          if (routeState.path == '/') {
            return '/books/new';
          }
        },
        builder: (context, child) {
          late final int selectedIndex;
          final childPath = RouteState.of(context).activeChild?.path;
          if (childPath == null || childPath == 'books') {
            selectedIndex = 0;
          } else if (childPath == 'settings') {
            selectedIndex = 1;
          }

          return AppScreen(
            currentIndex: selectedIndex,
            child: child,
          );
        },
        routes: [
          ShellRoute(
            path: 'books',
            defaultRoute: '/books/new',
            builder: (context, child) => BooksScreen(
              selectedTab:
                  RouteState.of(context).activeChild!.path == 'new' ? 0 : 1,
              child: child,
            ),
            routes: [
              StackedRoute(
                path: 'new',
                builder: (context) => NewBooksScreen(),
              ),
              StackedRoute(
                path: 'all',
                builder: (context) => AllBooksScreen(),
              ),
            ],
          ),
          StackedRoute(
            path: 'settings',
            builder: (context) {
              return SettingsScreen();
            },
          ),
        ],
      ),
    ],
  );
}

class AppScreen extends StatelessWidget {
  final int currentIndex;
  final Widget child;

  const AppScreen({
    Key? key,
    required this.currentIndex,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        child: child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (idx) {
          if (idx == 0) {
            RouteState.of(context).goTo('/books/new');
          } else {
            RouteState.of(context).goTo('/settings');
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
  final int selectedTab;
  final Widget child;

  BooksScreen({
    required this.selectedTab,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.selectedTab);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabController.animateTo(widget.selectedTab);
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeState = RouteState.of(context);
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          onTap: (int index) =>
              routeState.goTo(index == 0 ? 'new' : 'all'),
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
