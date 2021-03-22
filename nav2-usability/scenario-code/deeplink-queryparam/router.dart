// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Full sample that shows a custom RouteInformationParser and RouterDelegate
/// parsing named routes and declaratively building the stack of pages for the
/// [Navigator].
import 'package:flutter/material.dart';

void main() {
  runApp(BooksApp());
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class AppState extends ChangeNotifier {
  List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];
  String? _filter;

  String? get filter => _filter;

  set filter(String? filter) {
    _filter = filter;
    notifyListeners();
  }
}

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
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

class BookRouteInformationParser extends RouteInformationParser<BookRoutePath> {
  @override
  Future<BookRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    var filter = uri.queryParameters['filter'];
    return BookRoutePath(filter);
  }

  @override
  RouteInformation restoreRouteInformation(BookRoutePath path) {
    var filter = path.filter;
    var uri =
    Uri(path: '/', queryParameters: <String, dynamic>{'filter': filter});
    return RouteInformation(location: uri.toString());
  }
}

class BookRouterDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final AppState _appState;

  BookRouterDelegate()
      : navigatorKey = GlobalKey<NavigatorState>(),
        _appState = AppState() {
    _appState.addListener(() => notifyListeners());
  }

  @override
  BookRoutePath get currentConfiguration {
    return BookRoutePath(_appState.filter);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: ValueKey('BooksListPage'),
          child: BooksListScreen(
            books: _appState.books,
            filter: _appState.filter,
            onFilterChanged: (filter) {
              _appState.filter = filter;
            },
          ),
        ),
      ],
      onPopPage: (route, result) {
        return route.didPop(result);
      },
    );
  }

  @override
  Future<void> setNewRoutePath(BookRoutePath path) async {
    _appState.filter = path.filter;
  }
}

class BookRoutePath {
  String? filter;

  BookRoutePath(this.filter);
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  final String? filter;
  final ValueChanged onFilterChanged;

  BooksListScreen({
    required this.books,
    required this.onFilterChanged,
    this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final filter = this.filter;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'filter',
            ),
            onSubmitted: onFilterChanged,
          ),
          for (var book in books)
            if (filter == null || book.title.toLowerCase().contains(filter))
              ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
              )
        ],
      ),
    );
  }
}
