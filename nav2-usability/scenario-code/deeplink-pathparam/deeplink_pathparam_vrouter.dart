// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Deeplink path parameters example
/// Done using VRouter

import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

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
    return VRouter(
      routes: [
        VWidget(
          path: '/',
          widget: BooksListScreen(books: books),
          stackedRoutes: [
            VWidget(
              path: r'book/:id(\d+)',
              widget: Builder(
                builder: (context) => BookDetailsScreen(
                  book: books[int.parse(context.vRouter.pathParameters['id']!)],
                ),
              ),
            ),
          ],
        ),
        VRouteRedirector(path: ':_(.+)', redirectTo: '/'),
      ],
    );
  }
}

class BooksListScreen extends StatefulWidget {
  final List<Book> books;

  BooksListScreen({required this.books});

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
          for (var book in widget.books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () => context.vRouter.push('/book/${widget.books.indexOf(book)}'),
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
