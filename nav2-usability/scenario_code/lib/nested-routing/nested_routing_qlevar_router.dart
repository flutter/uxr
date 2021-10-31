// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Nested example
/// Done using Qlevar Router

import 'package:flutter/material.dart';
import 'package:qlevar_router/qlevar_router.dart';

void main() {
  runApp(BooksApp());
}

class BooksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp.router(
      routeInformationParser: QRouteInformationParser(),
      routerDelegate: QRouterDelegate([
        QRoute.withChild(
            path: '!',
            builderChild: (c) => AppScreen(c),
            children: [
              QRoute.withChild(
                  name: 'Books',
                  path: '/books',
                  initRoute: '/new',
                  builderChild: (c) => BooksScreen(c),
                  children: [
                    QRoute(
                        name: 'New Book',
                        path: '/new',
                        builder: () => const SizedBox()),
                    QRoute(
                        name: 'All Books',
                        path: '/all',
                        builder: () => const SizedBox())
                  ]),
              QRoute(
                  name: 'Settings',
                  path: '/settings',
                  builder: () => SettingsScreen())
            ])
      ], initPath: '/books'));
}

class AppScreen extends StatefulWidget {
  final QRouter router;
  const AppScreen(this.router, {Key? key}) : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  final tabs = const ['Books', 'Settings'];

  @override
  void initState() {
    super.initState();
    widget.router.navigator.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: widget.router,
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Books'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings')
          ],
          currentIndex: tabs.indexOf(widget.router.routeName),
          onTap: (v) => QR.toName(tabs[v]),
        ),
      );
}

class BooksScreen extends StatefulWidget {
  final QRouter router;

  BooksScreen(this.router, {Key? key}) : super(key: key);

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with SingleTickerProviderStateMixin {
  final tabs = const ['New Book', 'All Books'];
  late final TabController _tabController;

  @override
  void initState() {
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: getTapIndex);

    widget.router.navigator.addListener(() {
      _tabController.animateTo(getTapIndex);
    });

    super.initState();
  }

  int get getTapIndex => widget.router.routeName == 'New Book' ? 0 : 1;

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
          onTap: (int index) {
            widget.router.navigator.replaceAllWithName(tabs[index]);
          },
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
