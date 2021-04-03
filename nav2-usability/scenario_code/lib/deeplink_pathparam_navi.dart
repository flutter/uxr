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
  final String author;

  Book(this.id, this.title, this.author);
}

final List<Book> books = [
  Book('0', 'Stranger in a Strange Land', 'Robert A. Heinlein'),
  Book('1', 'Foundation', 'Isaac Asimov'),
  Book('2', 'Fahrenheit 451', 'Ray Bradbury'),
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
              subtitle: Text(book.author),
              onTap: () => context.navi.stack(BookStackMarker()).state = book,
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

class RootPage extends StatelessWidget {
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
            key: ValueKey(state.id),
            child: BookDetailsScreen(book: state),
          ),
      ],
      updateStateOnNewRoute: (routeInfo) {
        if (routeInfo.hasPrefixes(['book'])) {
          final bookId = routeInfo.pathSegmentAt(1)?.trim();
          return books.firstWhereOrNull((book) => book.id == bookId);
        }
      },
      updateRouteOnNewState: (state) => RouteInfo(
        pathSegments: state != null ? ['book', state.id] : [],
      ),
      updateStateBeforePop: (context, route, dynamic result, state) => null,
    );
  }
}

class BookStackMarker extends StackMarker<Book?> {}
