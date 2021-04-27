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
  late final OverlayEntry _overlayEntry =
  OverlayEntry(builder: _overlayEntryBuilder);

  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    _appState.addListener(handleAppStateChanged);
  }

  void handleAppStateChanged() {
    notifyListeners();
    _overlayEntry.markNeedsBuild();
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

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [_overlayEntry],
    );
  }

  Widget _overlayEntryBuilder(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: navigatorKey,
        pages: [
          if (_appState.page == AppPage.settings)
            FadeTransitionPage(
              key: ValueKey('SettingsScreen'),
              child: SettingsScreen(),
            ),
          if (_appState.page == AppPage.newBooks ||
              _appState.page == AppPage.allBooks)
            FadeTransitionPage(
              key: ValueKey('BooksScreen'),
              child: BooksScreen(
                onTabSelected: (int idx) {
                  if (idx == 0) {
                    _appState.page = AppPage.newBooks;
                  } else {
                    _appState.page = AppPage.allBooks;
                  }
                },
                appPage: _appState.page,
              ),
            ),
        ],
        onPopPage: (route, result) {
          return route.didPop(result);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _appState.page == AppPage.settings ? 1 : 0,
        onTap: (idx) {
          if (idx == 0) {
            _appState.page = AppPage.newBooks;
          } else {
            _appState.page = AppPage.settings;
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

class AppRoutePath {}

class NewBooksRoutePath extends AppRoutePath {}

class AllBooksRoutePath extends AppRoutePath {}

class SettingsRoutePath extends AppRoutePath {}

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
        TabController(length: 2, vsync: this, initialIndex: initialIndex);
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

class FadeTransitionPage extends Page {
  final Widget child;

  FadeTransitionPage({LocalKey? key, required this.child}) : super(key: key);

  @override
  Route createRoute(BuildContext context) {
    return PageBasedFadeTransitionRoute(this);
  }
}

class PageBasedFadeTransitionRoute extends PageRoute {
  PageBasedFadeTransitionRoute(Page page)
      : super(
    settings: page,
  );

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    var curveTween = CurveTween(curve: Curves.easeIn);
    return FadeTransition(
      opacity: animation.drive(curveTween),
      child: (settings as FadeTransitionPage).child,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
