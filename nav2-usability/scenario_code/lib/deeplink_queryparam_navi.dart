// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
  final String? filter;

  BooksListScreen({
    required this.books,
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
            onSubmitted: (searchTerm) {
              context.navi.stack(BookStackMarker()).state = searchTerm;
            },
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

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RouteStack<String?>(
      marker: BookStackMarker(),
      pages: (context, state) => [
        MaterialPage<dynamic>(
          key: const ValueKey('Books'),
          child: BooksListScreen(books: books, filter: state),
        ),
      ],
      updateStateOnNewRoute: (routeInfo) {
        return routeInfo.queryParams['filter']?.firstOrNull?.trim();
      },
      updateRouteOnNewState: (state) {
        if (state?.trim().isNotEmpty == true) {
          return RouteInfo(
            queryParams: {
              'filter': [state!]
            },
          );
        }

        return const RouteInfo();
      },
    );
  }
}

class BookStackMarker extends StackMarker<String?> {}
