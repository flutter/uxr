// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

void main() {
  runApp(BooksApp());
}

class Book {
  final String title;
  final Author author;

  Book(this.title, this.author);
}

class Author {
  String name;

  Author(this.name);
}

class AppState extends ChangeNotifier {
  bool _showAuthorsPage = false;
  Book? _selectedBook;
  Author? _selectedAuthor;
  final List<Book> books = [
    Book('Stranger in a Strange Land', Author('Robert A. Heinlein')),
    Book('Foundation', Author('Isaac Asimov')),
    Book('Fahrenheit 451', Author('Ray Bradbury')),
  ];

  List<Author> get authors => [
    ...books.map((book) => book.author),
  ];

  Book? get selectedBook => _selectedBook;

  set selectedBook(Book? book) {
    _selectedBook = book;
    clearSelectedAuthor();
    notifyListeners();
  }

  Author? get selectedAuthor => _selectedAuthor;

  set selectedAuthor(Author? author) {
    _selectedAuthor = author;
    clearSelectedBook();
    notifyListeners();
  }

  set showAuthorsPage(bool show) {
    _showAuthorsPage = show;
    notifyListeners();
  }

  bool get showAuthorsPage => _showAuthorsPage;

  int getBookId(Book book) {
    return books.indexOf(book);
  }

  int getAuthorId(Author author) {
    return books.indexWhere((book) => book.author == author);
  }

  bool setSelectedBook(int? id) {
    if (id == null || id < 0 || id > books.length - 1) {
      return false;
    }

    _showAuthorsPage = false;
    selectedBook = books[id];
    clearSelectedAuthor();
    return true;
  }

  bool setSelectedAuthor(int? id) {
    if (id == null || id < 0 || id > books.length - 1) {
      return false;
    }

    _showAuthorsPage = false;
    selectedAuthor = books[id].author;
    clearSelectedBook();
    return true;
  }

  void clearSelectedBook() {
    _selectedBook = null;
    notifyListeners();
  }

  void clearSelectedAuthor() {
    _selectedAuthor = null;
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

class BookRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return AppRoutePath();
    }

    if (uri.pathSegments.length == 2) {
      // Handle '/book/:id'
      if (uri.pathSegments[0] == 'book') {
        final remaining = uri.pathSegments[1];
        final id = int.tryParse(remaining);
        if (id != null) {
          return BookRoutePath(id);
        }
        // Handle '/author/:id'
      } else if (uri.pathSegments[0] == 'author') {
        final remaining = uri.pathSegments[1];
        final id = int.tryParse(remaining);
        if (id != null) {
          return AuthorRoutePath(id);
        }
      }
    } else if (uri.pathSegments.length == 1 &&
        uri.pathSegments[0] == 'authors') {
      return AuthorsRoutePath();
    }

    // Handle unknown routes
    return AppRoutePath();
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath path) {
    late final String location;
    if (path.isHomePage) {
      location = '/';
    } else if (path is AuthorsRoutePath) {
      location = '/authors';
    } else if (path is BookRoutePath) {
      location = '/book/${path.id}';
    } else if (path is AuthorRoutePath) {
      location = '/author/${path.id}';
    } else {
      location = '/';
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
  AppRoutePath get currentConfiguration {
    final selectedBook = _appState.selectedBook;
    final selectedAuthor = _appState.selectedAuthor;
    final showAuthorsPage = _appState.showAuthorsPage;
    if (showAuthorsPage) {
      return AuthorsRoutePath();
    }
    if (selectedAuthor != null) {
      return AuthorRoutePath(_appState.getAuthorId(selectedAuthor));
    }
    if (selectedBook != null) {
      return BookRoutePath(_appState.getBookId(selectedBook));
    }
    return AppRoutePath();
  }

  @override
  Widget build(BuildContext context) {
    final selectedBook = _appState.selectedBook;
    final selectedAuthor = _appState.selectedAuthor;
    return Navigator(
      key: navigatorKey,
      pages: [
        if (selectedAuthor != null) ...[
          MaterialPage(
            key: ValueKey('AuthorsListPage'),
            child: AuthorsListScreen(
              authors: _appState.authors,
              onTapped: _handleAuthorTapped,
              onGoToBooksTapped: _handleGoToBooksTapped,
            ),
          ),
          AuthorDetailPage(
            author: selectedAuthor,
          ),
        ] else if (selectedBook != null) ...[
          MaterialPage(
            key: ValueKey('BooksListPage'),
            child: BooksListScreen(
              books: _appState.books,
              onTapped: _handleBookTapped,
            ),
          ),
          BookDetailsPage(
            book: selectedBook,
            onAuthorTapped: _handleAuthorTapped,
          )
        ] else if (_appState.showAuthorsPage)
          MaterialPage(
            key: ValueKey('AuthorsListPage'),
            child: AuthorsListScreen(
              authors: _appState.authors,
              onTapped: _handleAuthorTapped,
              onGoToBooksTapped: _handleGoToBooksTapped,
            ),
          )
        else
          MaterialPage(
            key: ValueKey('BooksListPage'),
            child: BooksListScreen(
              books: _appState.books,
              onTapped: _handleBookTapped,
            ),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (_appState.selectedAuthor != null) {
          _appState.showAuthorsPage = true;
        }

        _appState.clearSelectedBook();
        _appState.clearSelectedAuthor();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    if (path is AuthorRoutePath) {
      _appState.setSelectedAuthor(path.id);
    } else if (path is AuthorsRoutePath) {
      _appState.showAuthorsPage = true;
    } else if (path is BookRoutePath) {
      _appState.setSelectedBook(path.id);
    } else {
      _appState.clearSelectedBook();
      _appState.clearSelectedAuthor();
    }
  }

  void _handleBookTapped(Book book) {
    _appState.selectedBook = book;
  }

  void _handleAuthorTapped(Author author) {
    _appState.selectedAuthor = author;
  }

  void _handleGoToBooksTapped() {
    _appState.showAuthorsPage = false;
    _appState.clearSelectedAuthor();
    _appState.clearSelectedBook();
  }
}

class BookDetailsPage extends Page<dynamic> {
  final Book book;
  final ValueChanged<Author> onAuthorTapped;

  BookDetailsPage({
    required this.book,
    required this.onAuthorTapped,
  }) : super(key: ValueKey(book));

  @override
  Route<dynamic> createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return BookDetailsScreen(
          book: book,
          onAuthorTapped: onAuthorTapped,
        );
      },
    );
  }
}

class AuthorDetailPage extends Page<dynamic> {
  final Author author;

  AuthorDetailPage({
    required this.author,
  }) : super(key: ValueKey(author));

  @override
  Route<dynamic> createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return AuthorDetailsScreen(
          author: author,
        );
      },
    );
  }
}

class AppRoutePath {
  bool get isHomePage => true;
}

class AuthorsRoutePath extends AppRoutePath {
  @override
  bool get isHomePage => false;
}

class AuthorRoutePath extends AppRoutePath {
  final int id;

  AuthorRoutePath(this.id);

  @override
  bool get isHomePage => false;
}

class BookRoutePath extends AppRoutePath {
  final int id;

  BookRoutePath(this.id);

  @override
  bool get isHomePage => false;
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<Book> onTapped;

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
              subtitle: Text(book.author.name),
              onTap: () => onTapped(book),
            )
        ],
      ),
    );
  }
}

class AuthorsListScreen extends StatelessWidget {
  final List<Author> authors;
  final ValueChanged<Author> onTapped;
  final VoidCallback onGoToBooksTapped;

  AuthorsListScreen({
    required this.authors,
    required this.onTapped,
    required this.onGoToBooksTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: onGoToBooksTapped,
            child: Text('Go to Books Screen'),
          ),
          for (var author in authors)
            ListTile(
              title: Text(author.name),
              onTap: () => onTapped(author),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;
  final ValueChanged<Author> onAuthorTapped;

  BookDetailsScreen({
    required this.book,
    required this.onAuthorTapped,
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
            ElevatedButton(
              onPressed: () {
                onAuthorTapped(book.author);
              },
              child: Text(book.author.name),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthorDetailsScreen extends StatelessWidget {
  final Author author;

  AuthorDetailsScreen({
    required this.author,
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
            Text(author.name, style: Theme.of(context).textTheme.headline6),
          ],
        ),
      ),
    );
  }
}
