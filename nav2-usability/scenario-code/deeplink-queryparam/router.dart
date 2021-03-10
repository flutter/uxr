// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
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

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  final BookRouterDelegate _routerDelegate = BookRouterDelegate();
  final BookRouteInformationParser _routeInformationParser =
  BookRouteInformationParser();

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
    print('parseRouteInformation');
    print('location = ${uri.path}');
    var filter = uri.queryParameters['filter'];
    return BookRoutePath(filter);
  }

  @override
  RouteInformation restoreRouteInformation(BookRoutePath path) {
    late final String location;
    var filter = path.filter;
    if (filter != null) {
      location = '/?filter=$filter';
    } else {
      location = '/';
    }
    print('restoreRouteInformation');
    print('location = $location');
    return RouteInformation(location: location);
  }
}

class BookRouterDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;

  List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  String? filter;

  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  BookRoutePath get currentConfiguration {
    return BookRoutePath(filter);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: ValueKey('BooksListPage'),
          child: BooksListScreen(
            books: books,
            filter: filter,
            onFilterChanged: (filter) {
              this.filter = filter;
              notifyListeners();
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
    filter = path.filter;
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
    print('filter = $filter');
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'filter',
            ),
            onChanged: this.onFilterChanged,
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
