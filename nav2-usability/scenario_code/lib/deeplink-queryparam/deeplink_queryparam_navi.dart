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
  final String title;
  final String author;

  Book(this.title, this.author);
}

List<Book> books = [
  Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
  Book('Foundation', 'Isaac Asimov'),
  Book('Fahrenheit 451', 'Ray Bradbury'),
];

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  final _routeInformationParser = NaviInformationParser();
  final _routerDelegate = NaviRouterDelegate.material(child: BooksStack());

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

class BooksStack extends StatefulWidget {
  @override
  _BooksStackState createState() => _BooksStackState();
}

class _BooksStackState extends State<BooksStack>
    with NaviRouteMixin<BooksStack> {
  String? _filter;

  @override
  void onNewRoute(NaviRoute unprocessedRoute) {
    _filter = unprocessedRoute.queryParams['filter']?.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return NaviStack(
      pages: (context) => [
        NaviPage.material(
          key: const ValueKey('Books'),
          route: NaviRoute(queryParams: {
            'filter': [_filter ?? '']
          }),
          child: BooksListScreen(
            books: books,
            filter: _filter,
            onFilterChanged: (filter) => setState(() {
              _filter = filter;
            }),
          ),
        ),
      ],
    );
  }
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
