// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Skipping stacks example
/// Done using go_router

import 'package:flutter/material.dart';
import 'package:go_router_prototype/go_router_prototype.dart';

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
    return MaterialApp.router(
      routeInformationParser: _router.parser,
      routerDelegate: _router.delegate,
    );
  }

  late final _router = GoRouter(
    routes: [
      ShellRoute(
        path: '/',
        // Home just redirects to the list of books
        defaultRoute: 'books',
        builder: (context, child) => AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          child: child,
        ),
        routes: [
          StackedRoute(
            path: 'books',
            builder: (context) => BooksListScreen(books: _appState.books),
            routes: [
              StackedRoute(
                path: r':bookId',
                builder: (context) {
                  final state = RouteState.of(context);
                  final bookId = int.parse(state.pathParameters['bookId']!);
                  return BookDetailsScreen(
                    bookId: bookId,
                    book: _appState.books[bookId],
                  );
                },
              ),
            ],
          ),
          StackedRoute(
            path: 'authors',
            builder: (context) => AuthorsListScreen(authors: _appState.authors),
            routes: [
              StackedRoute(
                path: r':bookId',
                builder: (context) {
                  final state = RouteState.of(context);
                  final bookId = int.parse(state.pathParameters['bookId']!);
                  return AuthorDetailsScreen(
                    author: _appState.books[bookId].author,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
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
              onTap: () =>
                  RouteState.of(context).goTo('/books/${books.indexOf(book)}'),
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
            onPressed: () => RouteState.of(context).goTo('/'),
            child: Text('Go to Books Screen'),
          ),
          for (var author in authors)
            ListTile(
              title: Text(author.name),
              onTap: () => RouteState.of(context)
                  .goTo('/authors/${authors.indexOf(author)}'),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final int bookId;
  final Book book;

  BookDetailsScreen({required this.book, required this.bookId});

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
              onPressed: () => RouteState.of(context).goTo('/authors/$bookId'),
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

class ErrorScreen extends StatelessWidget {
  const ErrorScreen(this.error, {Key? key}) : super(key: key);
  final Exception? error;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error?.toString() ?? 'page not found'),
              TextButton(
                onPressed: () => RouteState.of(context).goTo('/'),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      );
}
