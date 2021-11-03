// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:qlevar_router/qlevar_router.dart';

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

class BooksApp extends StatelessWidget {
  final List<Book> books = [
    Book('Stranger in a Strange Land', Author('Robert A. Heinlein')),
    Book('Foundation', Author('Isaac Asimov')),
    Book('Fahrenheit 451', Author('Ray Bradbury')),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routerDelegate: QRouterDelegate([
        QRoute(path: '/', builder: () => BooksListScreen(books: books)),
        QRoute(
            path:
                '/books/:bookIndex([0-${books.length - 1}])', // The only available pages are the pages in the list
            builder: () =>
                BookDetailsScreen(book: books[QR.params['bookIndex']!.asInt!])),
        QRoute(
            path: '/authors',
            builder: () =>
                AuthorsListScreen(authors: books.map((e) => e.author).toList()),
            children: [
              QRoute(
                  path: '/:authorIndex([0-${books.length - 1}])',
                  builder: () => AuthorDetailsScreen(
                      author: books[QR.params['authorIndex']!.asInt!].author))
            ])
      ]),
      routeInformationParser: QRouteInformationParser(),
    );
  }
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;

  BooksListScreen({required this.books});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: [
            for (var book in books)
              ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.author.name),
                  onTap: () => QR.to('/books/${books.indexOf(book)}'))
          ],
        ),
      );
}

class AuthorsListScreen extends StatelessWidget {
  final List<Author> authors;

  AuthorsListScreen({required this.authors});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: [
            ElevatedButton(
              onPressed: () => QR.navigator.replaceAll('/'),
              child: Text('Go to Books Screen'),
            ),
            for (var author in authors)
              ListTile(
                title: Text(author.name),
                onTap: () => QR.to('/authors/${authors.indexOf(author)}'),
              )
          ],
        ),
      );
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({required this.book});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.title, style: Theme.of(context).textTheme.headline6),
              ElevatedButton(
                onPressed: () => QR.navigator
                    .replaceAll('/authors/${QR.params['bookIndex']!.asInt!}'),
                child: Text(book.author.name),
              ),
            ],
          ),
        ),
      );
}

class AuthorDetailsScreen extends StatelessWidget {
  final Author author;

  AuthorDetailsScreen({required this.author});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(author.name, style: Theme.of(context).textTheme.headline6)
            ],
          ),
        ),
      );
}
