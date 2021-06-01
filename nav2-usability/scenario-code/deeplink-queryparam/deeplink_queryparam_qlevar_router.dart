import 'package:flutter/material.dart';
import 'package:qlevar_router/qlevar_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        routeInformationParser: QRouteInformationParser(),
        routerDelegate: QRouterDelegate(
            [QRoute(path: '/', builder: () => BooksListScreen())]));
  }
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class BooksListScreen extends StatelessWidget {
  final books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];
  @override
  Widget build(BuildContext context) {
    final filter = QR.params['filter'];
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          TextField(
              decoration: InputDecoration(hintText: 'filter'),
              onSubmitted: (v) => QR.to('/${v.isEmpty ? '' : '/?filter=$v'}')),
          for (var book in books)
            if (filter == null ||
                book.title.toLowerCase().contains(filter.toString()))
              ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
              )
        ],
      ),
    );
  }
}
