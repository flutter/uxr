// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Skipping stacks example
/// Done using VRouter

import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

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

class AppState extends ChangeNotifier {
  final List<Book> books = [
    Book('Stranger in a Strange Land', Author('Robert A. Heinlein')),
    Book('Foundation', Author('Isaac Asimov')),
    Book('Fahrenheit 451', Author('Ray Bradbury')),
  ];

  List<Author> get authors => [...books.map((book) => book.author)];
}

class BooksApp extends StatelessWidget {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return VRouter(
      routes: [
        // Books
        VWidget(
          path: '/',
          widget: BooksListScreen(books: _appState.books),
          stackedRoutes: [
            VWidget(
              path: r'book/:bookId(\d+)',
              widget: Builder(
                builder: (context) {
                  final bookId =
                      int.parse(context.vRouter.pathParameters['bookId']!);
                  return BookDetailsScreen(
                    book: _appState.books[bookId],
                  );
                },
              ),
            ),
          ],
        ),

        // Authors
        VWidget(
          path: '/authors',
          widget: AuthorsListScreen(authors: _appState.authors),
          stackedRoutes: [
            VWidget(
              path: r'/author/:bookId(\d+)',
              widget: Builder(
                builder: (context) {
                  final bookId =
                      int.parse(context.vRouter.pathParameters['bookId']!);
                  return AuthorDetailsScreen(
                    author: _appState.books[bookId].author,
                  );
                },
              ),
            ),
          ],
        ),

        // Redirect unknown
        VRouteRedirector(path: r'.+', redirectTo: '/'),
      ],
    );
  }
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;

  BooksListScreen({required this.books});

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
              onTap: () => context.vRouter.push('/book/${books.indexOf(book)}'),
            )
        ],
      ),
    );
  }
}

class AuthorsListScreen extends StatelessWidget {
  final List<Author> authors;

  AuthorsListScreen({required this.authors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: () => context.vRouter.push('/'),
            child: Text('Go to Books Screen'),
          ),
          for (var author in authors)
            ListTile(
              title: Text(author.name),
              onTap: () =>
                  context.vRouter.push('/author/${authors.indexOf(author)}'),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({required this.book});

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
              onPressed: () => context.vRouter
                  .push('/author/${context.vRouter.pathParameters['bookId']}'),
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
