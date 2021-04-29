// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// If the file doesn't work with newer version, please check live version at
// https://github.com/zenonine/navi/tree/master/examples/uxr

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:navi/navi.dart';

void main() {
  runApp(BooksApp());
}

class Book {
  final int id;
  final String title;
  final Author author;

  Book(this.id, this.title, this.author);
}

class Author {
  final int id;
  String name;

  Author(this.id, this.name);
}

final List<Book> books = [
  Book(0, 'Stranger in a Strange Land', Author(0, 'Robert A. Heinlein')),
  Book(1, 'Foundation', Author(1, 'Isaac Asimov')),
  Book(2, 'Fahrenheit 451', Author(2, 'Ray Bradbury')),
];

final List<Author> authors = [...books.map((book) => book.author)];

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
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

enum RootPageId { books, authors }

class RootStack extends StatefulWidget {
  @override
  _RootStackState createState() => _RootStackState();
}

class _RootStackState extends State<RootStack> with NaviRouteMixin<RootStack> {
  RootPageId _pageId = RootPageId.books;

  @override
  void onNewRoute(NaviRoute unprocessedRoute) {
    _pageId = RootPageId.books;
    if (unprocessedRoute.pathSegmentAt(0) == 'authors' ||
        unprocessedRoute.hasPrefixes(['author'])) {
      _pageId = RootPageId.authors;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return NaviStack(
      pages: (context) {
        switch (_pageId) {
          case RootPageId.authors:
            return [
              NaviPage.material(
                key: const ValueKey('Authors'),
                child: AuthorsStack(),
              )
            ];
          case RootPageId.books:
          default:
            return [
              NaviPage.material(
                key: const ValueKey('Books'),
                child: BooksStack(),
              )
            ];
        }
      },
    );
  }
}

class AuthorsStack extends StatefulWidget {
  @override
  _AuthorsStackState createState() => _AuthorsStackState();
}

class _AuthorsStackState extends State<AuthorsStack>
    with NaviRouteMixin<AuthorsStack> {
  Author? _selectedAuthor;

  @override
  void onNewRoute(NaviRoute unprocessedRoute) {
    _selectedAuthor = null;
    if (unprocessedRoute.hasPrefixes(['author'])) {
      final authorId = int.tryParse(unprocessedRoute.pathSegmentAt(1) ?? '');
      _selectedAuthor =
          authors.firstWhereOrNull((author) => author.id == authorId);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return NaviStack(
      pages: (context) => [
        NaviPage.material(
          key: const ValueKey('Authors'),
          route: const NaviRoute(path: ['authors']),
          child: AuthorsListScreen(
            authors: authors,
            onTapped: (author) => setState(() {
              _selectedAuthor = author;
            }),
          ),
        ),
        if (_selectedAuthor != null)
          NaviPage.material(
            key: ValueKey(_selectedAuthor),
            route: NaviRoute(path: ['author', '${_selectedAuthor!.id}']),
            child: AuthorDetailsScreen(author: _selectedAuthor!),
          ),
      ],
      onPopPage: (context, route, dynamic result) {
        if (_selectedAuthor != null) {
          setState(() {
            _selectedAuthor = null;
          });
        }
      },
    );
  }
}

class BooksStack extends StatefulWidget {
  @override
  _BooksStackState createState() => _BooksStackState();
}

class _BooksStackState extends State<BooksStack>
    with NaviRouteMixin<BooksStack> {
  Book? _selectedBook;

  @override
  void onNewRoute(NaviRoute unprocessedRoute) {
    _selectedBook = null;
    if (unprocessedRoute.hasPrefixes(['book'])) {
      final bookId = int.tryParse(unprocessedRoute.pathSegmentAt(1) ?? '');
      if (bookId != null) {
        _selectedBook = books.firstWhereOrNull((book) => book.id == bookId);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return NaviStack(
      pages: (context) => [
        NaviPage.material(
          key: const ValueKey('Books'),
          child: BooksListScreen(
            books: books,
            onTapped: (book) => setState(() {
              _selectedBook = book;
            }),
          ),
        ),
        if (_selectedBook != null)
          NaviPage.material(
            key: ValueKey(_selectedBook),
            route: NaviRoute(path: ['book', '${_selectedBook!.id}']),
            child: BookDetailsScreen(
              book: _selectedBook!,
            ),
          ),
      ],
      onPopPage: (context, route, dynamic result) {
        if (_selectedBook != null) {
          setState(() {
            _selectedBook = null;
          });
        }
      },
    );
  }
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

  AuthorsListScreen({
    required this.authors,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: () => context.navi.to(['books']),
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
            ElevatedButton(
              onPressed: () {
                context.navi.to(['author', '${book.author.id}']);
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
