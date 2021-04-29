// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

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

final List<Book> books = [
  Book('Stranger in a Strange Land', Author('Robert A. Heinlein')),
  Book('Foundation', Author('Isaac Asimov')),
  Book('Fahrenheit 451', Author('Ray Bradbury')),
];

List<Author> get authors => books.map<Author>((book) => book.author).toList();

class BooksLocation extends BeamLocation {
  BooksLocation(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => ['/books/:bookId'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) {
    String? rawBookId = state.pathParameters['bookId'];
    int? bookId = rawBookId != null ? int.parse(rawBookId) : null;
    return [
      BeamPage(
        key: ValueKey('books'),
        child: BooksListScreen(
          books: books,
          onTapped: (book) => update(
            (state) => state.copyWith(
              pathBlueprintSegments: ['books', ':bookId'],
              pathParameters: {'bookId': books.indexOf(book).toString()},
            ),
          ),
          // OR
          // onTapped: (book) =>
          //     Beamer.of(context).beamToNamed('/books/${books.indexOf(book)}'),
        ),
      ),
      if (bookId != null)
        BeamPage(
          key: ValueKey('books-$bookId'),
          child: BookDetailsScreen(
            book: books[bookId],
            onAuthorTapped: (author) => Beamer.of(context).update(
              state: BeamState(
                pathBlueprintSegments: ['authors', ':authorId'],
                pathParameters: {
                  'authorId': authors.indexOf(author).toString()
                },
              ),
            ),
            // OR
            // onAuthorTapped: (author) => Beamer.of(context)
            //     .beamToNamed('/authors/${authors.indexOf(author)}'),
          ),
        ),
    ];
  }
}

class AuthorsLocation extends BeamLocation {
  AuthorsLocation(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => ['/authors/:authorId'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) {
    String? rawAuthorId = state.pathParameters['authorId'];
    int? authorId = rawAuthorId != null ? int.parse(rawAuthorId) : null;
    return [
      if (state.pathBlueprintSegments.contains('authors'))
        BeamPage(
          key: ValueKey('authors'),
          child: AuthorsListScreen(
            authors: authors,
            onTapped: (author) => update(
              (state) => state.copyWith(
                pathBlueprintSegments: state.pathBlueprintSegments
                  ..add(':authorId'),
                pathParameters: {
                  'authorId': authors.indexOf(author).toString()
                },
              ),
            ),
            // OR
            // onTapped: (author) => Beamer.of(context)
            //     .beamToNamed('/authors/${authors.indexOf(author)}'),
            onGoToBooksTapped: () => Beamer.of(context).update(
              state: BeamState(),
            ),
            // OR
            // onGoToBooksTapped: () => Beamer.of(context).beamToNamed('/'),
          ),
        ),
      if (authorId != null)
        BeamPage(
          key: ValueKey('author-$authorId'),
          child: AuthorDetailsScreen(
            author: authors[authorId],
          ),
        ),
    ];
  }
}

class BooksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routerDelegate: BeamerRouterDelegate(
        locationBuilder: (state) {
          if (state.uri.path.contains('authors')) {
            return AuthorsLocation(state);
          }
          return BooksLocation(state);
        },
      ),
      routeInformationParser: BeamerRouteInformationParser(),
    );
  }
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<Book> onTapped;

  BooksListScreen({
    required this.books,
    required this.onTapped,
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
              subtitle: Text(book.author.name),
              onTap: () => onTapped(book),
            )
        ],
      ),
    );
  }
}

class AuthorsListScreen extends StatelessWidget {
  final List<Author> authors;
  final ValueChanged<Author> onTapped;
  final VoidCallback onGoToBooksTapped;

  AuthorsListScreen({
    required this.authors,
    required this.onTapped,
    required this.onGoToBooksTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: onGoToBooksTapped,
            child: Text('Go to Books Screen'),
          ),
          for (var author in authors)
            ListTile(
              title: Text(author.name),
              onTap: () => onTapped(author),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;
  final ValueChanged<Author> onAuthorTapped;

  BookDetailsScreen({
    required this.book,
    required this.onAuthorTapped,
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
            ElevatedButton(
              onPressed: () {
                onAuthorTapped(book.author);
              },
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
