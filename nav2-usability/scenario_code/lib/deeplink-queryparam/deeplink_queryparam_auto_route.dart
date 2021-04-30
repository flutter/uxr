// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Deeplink query parameters example
/// Done using AutoRoute
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_uxr/main.gr.dart';

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
    RedirectRoute(path: "*", redirectTo: "/")
  ],
)
class $AppRouter {}

class BooksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _appRouter = AppRouter();

    return MaterialApp.router(
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}

class BooksListScreen extends StatelessWidget {
  final String? filter;
  BooksListScreen({@QueryParam('filter') this.filter});

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
                context.router.replaceNamed('/?filter=$value'),
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
