// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Nested example
/// Done using VRouter

import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

void main() {
  runApp(BooksApp());
}

class BooksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VRouter(
      initialUrl: '/books/new',
      routes: [
        VNester(
          path: null,
          widgetBuilder: (child) => AppScreen(child: child),
          nestedRoutes: [
            VWidget(
              path: '/books/all',
              aliases: ['/books/new'],
              // We don't want an animation between path and alias so we use a constant key
              key: ValueKey('books'),
              widget: Builder(
                builder: (context) => BooksScreen(
                  initialSelectedTab:
                      context.vRouter.url!.contains('/new') ? 0 : 1,
                ),
              ),
              buildTransition: (animation, _, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
            VWidget(
              path: '/settings',
              widget: SettingsScreen(),
              buildTransition: (animation, _, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
          ],
        ),
      ],
    );
  }
}

class AppScreen extends StatelessWidget {
  final Widget child;

  const AppScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: context.vRouter.url!.contains('/books') ? 0 : 1,
        onTap: (idx) {
          if (idx == 0) {
            context.vRouter.push('/books/new');
          } else {
            context.vRouter.push('/settings');
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
  final int initialSelectedTab;

  BooksScreen({
    Key? key,
    required this.initialSelectedTab,
  }) : super(key: key);

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialSelectedTab);
    super.initState();
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VWidgetGuard(
      beforeUpdate: (vRedirector) async => _tabController
          .animateTo(vRedirector.newVRouterData!.url!.contains('/new') ? 0 : 1),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            onTap: (int index) =>
                context.vRouter.push(index == 1 ? '/books/all' : '/books/new'),
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
      ),
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
