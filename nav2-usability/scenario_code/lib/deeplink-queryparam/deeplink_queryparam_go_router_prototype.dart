// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router_prototype/go_router_prototype.dart';

void main() {
  runApp(BooksApp());
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class BooksApp extends StatelessWidget {
  final List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _router.parser,
      routerDelegate: _router.delegate,
    );
  }

  late final _router = GoRouter(
    routes: [
      StackedRoute(
        path: '/',
        builder: (context) => BooksListScreen(
          books: books,
          filter: RouteState.of(context).queryParameters['filter'],
        ),
      ),
    ],
  );
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  final String? filter;

  BooksListScreen({required this.books, required this.filter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'filter',
            ),
            onSubmitted: (value) =>
                RouteState.of(context).goTo('/?filter=$value'),
          ),
          for (var book in books)
            if (filter == null || book.title.toLowerCase().contains(filter!))
              ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
              )
        ],
      ),
    );
  }
}
