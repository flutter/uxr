// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i2;

import 'skipping_stacks_auto_route.dart' as _i3;

class AppRouter extends _i1.RootStackRouter {
  AppRouter([_i2.GlobalKey<_i2.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    BooksListRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i3.BooksListScreen();
        }),
    BookDetailsRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<BookDetailsRouteArgs>(
              orElse: () =>
                  BookDetailsRouteArgs(bookId: pathParams.getInt('bookId')));
          return _i3.BookDetailsScreen(bookId: args.bookId);
        }),
    AuthorsListRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i3.AuthorsListScreen();
        }),
    AuthorDetailsRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<AuthorDetailsRouteArgs>(
              orElse: () =>
                  AuthorDetailsRouteArgs(bookId: pathParams.getInt('bookId')));
          return _i3.AuthorDetailsScreen(bookId: args.bookId);
        })
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig(BooksListRoute.name, path: '/'),
        _i1.RouteConfig(BookDetailsRoute.name, path: '/book/:bookId'),
        _i1.RouteConfig(AuthorsListRoute.name, path: '/authors'),
        _i1.RouteConfig(AuthorDetailsRoute.name, path: '/author/:bookId'),
        _i1.RouteConfig('*#redirect',
            path: '*', redirectTo: '/', fullMatch: true)
      ];
}

class BooksListRoute extends _i1.PageRouteInfo {
  const BooksListRoute() : super(name, path: '/');

  static const String name = 'BooksListRoute';
}

class BookDetailsRoute extends _i1.PageRouteInfo<BookDetailsRouteArgs> {
  BookDetailsRoute({required int bookId})
      : super(name,
            path: '/book/:bookId',
            args: BookDetailsRouteArgs(bookId: bookId),
            rawPathParams: {'bookId': bookId});

  static const String name = 'BookDetailsRoute';
}

class BookDetailsRouteArgs {
  const BookDetailsRouteArgs({required this.bookId});

  final int bookId;
}

class AuthorsListRoute extends _i1.PageRouteInfo {
  const AuthorsListRoute() : super(name, path: '/authors');

  static const String name = 'AuthorsListRoute';
}

class AuthorDetailsRoute extends _i1.PageRouteInfo<AuthorDetailsRouteArgs> {
  AuthorDetailsRoute({required int bookId})
      : super(name,
            path: '/author/:bookId',
            args: AuthorDetailsRouteArgs(bookId: bookId),
            rawPathParams: {'bookId': bookId});

  static const String name = 'AuthorDetailsRoute';
}

class AuthorDetailsRouteArgs {
  const AuthorDetailsRouteArgs({required this.bookId});

  final int bookId;
}
