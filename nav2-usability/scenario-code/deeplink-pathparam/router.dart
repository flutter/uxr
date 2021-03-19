// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Full sample that shows a custom RouteInformationParser and RouterDelegate
/// parsing named routes and declaratively building the stack of pages for the
/// [Navigator].
import 'package:flutter/material.dart';

final List<Book> books = [
  Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
  Book('Foundation', 'Isaac Asimov'),
  Book('Fahrenheit 451', 'Ray Bradbury'),
];

void main() {
  runApp(BooksApp());
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class AppState extends ChangeNotifier {
  int? _selectedBookId;

  int? get selectedBookId => _selectedBookId;

  set selectedBookId(int? id) {
    _selectedBookId = id;
    notifyListeners();
  }

  Book? get selectedBook {
    var idx = _selectedBookId;
    if (idx == null) {
      return null;
    }
    return books[idx];
  }

  set selectedBook(Book? book) {
    if (book == null) {
      _selectedBookId = null;
      notifyListeners();
      return;
    }

    var id = books.indexOf(book);
    if (id == -1) {
      _selectedBookId = null;
    } else {
      _selectedBookId = id;
    }

    notifyListeners();
  }

  void clearSelectedBook() {
    _selectedBookId = null;
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
    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return BookRoutePath.home();
    }

    // Handle '/book/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] != 'book') return BookRoutePath.home();
      final remaining = uri.pathSegments[1];
      final id = int.tryParse(remaining);
      if (id == null) return BookRoutePath.home();
      return BookRoutePath.details(id);
    }

    // Handle unknown routes
    return BookRoutePath.home();
  }

  @override
  RouteInformation restoreRouteInformation(BookRoutePath path) {
    late final String location;
    if (path.isHomePage) {
      location = '/';
    }
    if (path.isDetailsPage) {
      location = '/book/${path.id}';
    }
    return RouteInformation(location: location);
  }
}

class BookRouterDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final AppState _appState = AppState();

  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    _appState.addListener(() => notifyListeners());
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  BookRoutePath get currentConfiguration {
    final id = _appState.selectedBookId;
    if (id == null) {
      return BookRoutePath.home();
    } else {
      return BookRoutePath.details(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedBook = _appState.selectedBook;
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: ValueKey('BooksListPage'),
          child: BooksListScreen(
            books: books,
            onTapped: _handleBookTapped,
          ),
        ),
        if (selectedBook != null) BookDetailsPage(book: selectedBook)
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        // Update the list of pages by setting _selectedBook to null
        _appState.clearSelectedBook();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(BookRoutePath path) async {
    if (path.isDetailsPage) {
      final id = path.id;
      _appState.selectedBookId = id;
    } else {
      _appState.clearSelectedBook();
    }
  }

  void _handleBookTapped(int bookId) {
    _appState.selectedBookId = bookId;
  }
}

class BookDetailsPage extends Page<dynamic> {
  final Book book;

  BookDetailsPage({
    required this.book,
  }) : super(key: ValueKey(book));

  @override
  Route<dynamic> createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return BookDetailsScreen(book: book);
      },
    );
  }
}

class BookRoutePath {
  final int? id;

  BookRoutePath.home() : id = null;

  BookRoutePath.details(this.id);

  bool get isHomePage => id == null;

  bool get isDetailsPage => id != null;
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<int> onTapped;

  BooksListScreen({
    required this.books,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () => onTapped(books.indexOf(book)),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, style: Theme.of(context).textTheme.headline6),
            Text(book.author, style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
    );
  }
}
