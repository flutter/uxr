import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

void main() {
  runApp(BooksApp());
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class BooksLocation extends BeamLocation {
  BooksLocation(BeamState state) : super(state);

  final List<Book> _books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  @override
  List<String> get pathBlueprints => ['/books'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('books-${state.queryParameters['filter'] ?? ''}'),
          child: BooksListScreen(
            books: _books,
            filter: state.queryParameters['filter'] ?? '',
            onFilterChanged: (filter) => update(
              (state) => state.copyWith(
                queryParameters: {'filter': filter},
              ),
            ),
            //OR
            // onFilterChanged: (filter) =>
            //     Beamer.of(context).beamToNamed('/?filter=$filter'),
          ),
        ),
      ];
}

class BooksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routerDelegate: BeamerRouterDelegate(
        locationBuilder: (state) => BooksLocation(state),
      ),
      routeInformationParser: BeamerRouteInformationParser(),
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
