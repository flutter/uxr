// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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

class AppState extends ChangeNotifier {
  AppPage _page = AppPage.newBooks;

  AppPage get page => _page;

  set page(AppPage s) {
    _page = s;
    notifyListeners();
  }
}

class BooksApp extends StatefulWidget {
  @override
  _BooksAppState createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  final BookRouterDelegate _routerDelegate = BookRouterDelegate();
  final BookRouteInformationParser _routeInformationParser =
  BookRouteInformationParser();

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

class BookRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    var uri = Uri.parse(routeInformation.location!);
    if (uri.pathSegments.isEmpty) {
      return NewBooksRoutePath();
    }
    if (uri.pathSegments.length == 1) {
      if (uri.pathSegments[0] == 'books') return NewBooksRoutePath();
      if (uri.pathSegments[0] == 'settings') return SettingsRoutePath();
    }

    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[1] == 'new') return NewBooksRoutePath();
      if (uri.pathSegments[1] == 'all') return AllBooksRoutePath();
    }

    return NewBooksRoutePath();
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath path) {
    late final location;

    if (path is NewBooksRoutePath) {
      location = '/books/new';
    } else if (path is AllBooksRoutePath) {
      location = '/books/all';
    } else if (path is SettingsRoutePath) {
      location = '/settings';
    }

    return RouteInformation(location: location);
  }
}

class BookRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final AppState _appState = AppState();

  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    _appState.addListener(() => notifyListeners());
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    if (path is NewBooksRoutePath) {
      _appState.page = AppPage.newBooks;
    } else if (path is AllBooksRoutePath) {
      _appState.page = AppPage.allBooks;
    } else if (path is SettingsRoutePath) {
      _appState.page = AppPage.settings;
    }
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  AppRoutePath get currentConfiguration {
    if (_appState.page == AppPage.newBooks) {
      return NewBooksRoutePath();
    } else if (_appState.page == AppPage.allBooks) {
      return AllBooksRoutePath();
    } else if (_appState.page == AppPage.settings) {
      return SettingsRoutePath();
    }
    return AppRoutePath();
  }

  void _handleTabSelected(int idx) {
    if (idx == 0) {
      _appState.page = AppPage.newBooks;
    } else {
      _appState.page = AppPage.allBooks;
    }
  }

  @override
  Widget build(BuildContext context) {
    late final Widget innerScreen;
    if (_appState.page == AppPage.settings) {
      innerScreen = SettingsScreen();
    } else {
      innerScreen = BooksScreen(
        appPage: _appState.page,
        onTabSelected: _handleTabSelected,
      );
    }

    final bottomBarIndex =
    _appState.page == AppPage.allBooks || _appState.page == AppPage.newBooks
        ? 0
        : 1;
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: ValueKey('BooksScreen'),
          child: AppScaffold(
            currentIndex: bottomBarIndex,
            onIndexChanged: (idx) {
              if (idx == 0) {
                _appState.page = AppPage.newBooks;
              } else {
                _appState.page = AppPage.settings;
              }
            },
            child: innerScreen,
          ),
        ),
      ],
      onPopPage: (route, result) {
        return route.didPop(result);
      },
    );
  }
}

class AppRoutePath {}

class NewBooksRoutePath extends AppRoutePath {}

class AllBooksRoutePath extends AppRoutePath {}

class SettingsRoutePath extends AppRoutePath {}

class AppScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final Widget child;

  AppScaffold({
    required this.currentIndex,
    required this.onIndexChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onIndexChanged,
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
    required this.appPage,
    required this.onTabSelected,
  });

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    return Center(
      child: Text('Settings'),
    );
  }
}

class AllBooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('All Books'),
    );
  }
}

class NewBooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('New Books'),
    );
  }
}
