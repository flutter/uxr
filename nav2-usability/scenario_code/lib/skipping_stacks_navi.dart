// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file is tested with Navi 0.1.0.
// If it doesn't work with newer version, please check live version at https://github.com/zenonine/navi/tree/master/examples/uxr

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:navi/navi.dart';

void main() {
  runApp(BooksApp());
}

class Book {
  final String id;
  final String title;
  final Author author;

  Book(this.id, this.title, this.author);
}

class Author {
  final String id;
  String name;

  Author(this.id, this.name);
}

final List<Book> books = [
  Book('0', 'Stranger in a Strange Land', Author('3', 'Robert A. Heinlein')),
  Book('1', 'Foundation', Author('4', 'Isaac Asimov')),
  Book('2', 'Fahrenheit 451', Author('5', 'Ray Bradbury')),
];

final List<Author> authors = [
  ...books.map((book) => book.author),
];

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  final NaviRouterDelegate _routerDelegate =
      NaviRouterDelegate.material(rootPage: RootPage());
  final NaviInformationParser _routeInformationParser = NaviInformationParser();

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

class BooksListScreen extends StatelessWidget {
  final List<Book> books;

  BooksListScreen({
    required this.books,
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
              onTap: () {
                context.navi.stack(BookStackMarker()).state = book;
              },
            )
        ],
      ),
    );
  }
}

class AuthorsListScreen extends StatelessWidget {
  final List<Author> authors;

  AuthorsListScreen({
    required this.authors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: () {
              context.navi.stack(RootStackMarker()).state = RootPageId.books;
            },
            child: Text('Go to Books Screen'),
          ),
          for (var author in authors)
            ListTile(
              title: Text(author.name),
              onTap: () {
                context.navi.stack(AuthorStackMarker()).state = author;
              },
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
                // TODO: https://github.com/zenonine/navi/issues/29 Wrong URL when switching to another stack
                context.navi.byUrl('/authors/${book.author.id}');
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

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RouteStack<RootPageId>(
      marker: RootStackMarker(),
      pages: (context, state) {
        switch (state) {
          case RootPageId.authors:
            return [
              MaterialPage<dynamic>(
                key: const ValueKey('AuthorStack'),
                child: AuthorStack(),
              )
            ];
          case RootPageId.books:
          default:
            return [
              MaterialPage<dynamic>(
                key: const ValueKey('BookStack'),
                child: BookStack(),
              )
            ];
        }
      },
      updateStateOnNewRoute: (routeInfo) {
        if (routeInfo.hasPrefixes(['authors'])) {
          return RootPageId.authors;
        }

        return RootPageId.books;
      },
      updateRouteOnNewState: (state) {
        switch (state) {
          case RootPageId.authors:
            return const RouteInfo(pathSegments: ['authors']);
          case RootPageId.books:
          default:
            return const RouteInfo(pathSegments: []);
        }
      },
    );
  }
}

enum RootPageId { books, authors }

class RootStackMarker extends StackMarker<RootPageId> {}

class AuthorStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RouteStack<Author?>(
      marker: AuthorStackMarker(),
      pages: (context, state) => [
        MaterialPage<dynamic>(
          key: const ValueKey('AuthorsListPage'),
          child: AuthorsListScreen(authors: authors),
        ),
        if (state != null)
          MaterialPage<dynamic>(
            key: ValueKey(state),
            child: AuthorDetailsScreen(author: state),
          ),
      ],
      updateStateOnNewRoute: (routeInfo) {
        final authorId = routeInfo.pathSegmentAt(0)?.trim();
        return authors.firstWhereOrNull((author) => author.id == authorId);
      },
      updateRouteOnNewState: (state) =>
          RouteInfo(pathSegments: state == null ? [] : [state.id]),
      updateStateBeforePop: (context, route, dynamic result, state) => null,
    );
  }
}

class AuthorStackMarker extends StackMarker<Author?> {}

class BookStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RouteStack<Book?>(
      marker: BookStackMarker(),
      pages: (context, state) => [
        MaterialPage<dynamic>(
          key: ValueKey('Books'),
          child: BooksListScreen(books: books),
        ),
        if (state != null)
          MaterialPage<dynamic>(
            key: ValueKey(state),
            child: BookDetailsScreen(book: state),
          ),
      ],
      updateStateOnNewRoute: (routeInfo) {
        if (routeInfo.hasPrefixes(['book'])) {
          final bookId = routeInfo.pathSegmentAt(1);
          return books.firstWhereOrNull((book) => book.id == bookId);
        }
      },
      updateRouteOnNewState: (state) {
        return RouteInfo(pathSegments: state == null ? [] : ['book', state.id]);
      },
      updateStateBeforePop: (context, route, dynamic result, state) => null,
    );
  }
}

class BookStackMarker extends StackMarker<Book?> {}
