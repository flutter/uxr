import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(BooksApp());
  timeDilation = 3.0;
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

final List<Book> books = [
  Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
  Book('Foundation', 'Isaac Asimov'),
  Book('Fahrenheit 451', 'Ray Bradbury'),
];

class BooksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routerDelegate: BeamerRouterDelegate(
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '/': (context) => BooksListScreen(
                  books: books,
                  onTapped: (index) => context.beamToNamed('/books/$index'),
                ),
            '/books/:bookId': (context) {
              final bookId = int.parse(
                  context.currentBeamLocation.state.pathParameters['bookId']!);
              return BookDetailsScreen(
                book: books[bookId],
              );
            },
          },
        ),
      ),
      routeInformationParser: BeamerRouteInformationParser(),
    );
  }
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<int> onTapped;

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
              subtitle: Text(book.author),
              onTap: () => onTapped(books.indexOf(book)),
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
