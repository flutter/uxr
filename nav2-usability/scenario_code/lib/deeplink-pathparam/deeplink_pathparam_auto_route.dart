// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Deeplink path parameters example
/// Done using AutoRoute
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'deeplink_pathparam_auto_route.gr.dart';

void main() {
  runApp(BooksApp());
}

final List<Book> books = [
  Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
  Book('Foundation', 'Isaac Asimov'),
  Book('Fahrenheit 451', 'Ray Bradbury'),
];

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

// Declare routing setup
@MaterialAutoRouter(
  replaceInRouteName: 'Screen,Route',
  routes: <AutoRoute>[
    AutoRoute(path: "/", page: BooksListScreen),
    AutoRoute(path: "/book/:id", page: BookDetailsScreen),
    RedirectRoute(path: "*", redirectTo: "/")
  ],
)
class $AppRouter {}

class BooksApp extends StatelessWidget {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _appRouter.delegate(),
      routeInformationParser:
          _appRouter.defaultRouteParser(includePrefixMatches: true),
    );
  }
}

class BooksListScreen extends StatefulWidget {
  @override
  _BooksListScreenState createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
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
              onTap: () =>
                  context.pushRoute(BookDetailsRoute(id: books.indexOf(book))),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final int id;

  BookDetailsScreen({@pathParam required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(books[id].title, style: Theme.of(context).textTheme.headline6),
            Text(books[id].author,
                style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
    );
  }
}
