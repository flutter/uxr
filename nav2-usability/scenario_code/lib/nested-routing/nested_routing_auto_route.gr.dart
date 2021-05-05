// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i2;

import 'main.dart' as _i3;

class AppRouter extends _i1.RootStackRouter {
  AppRouter([_i2.GlobalKey<_i2.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    AppRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i3.AppScreen();
        }),
    BooksRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<BooksRouteArgs>(
              orElse: () =>
                  BooksRouteArgs(tab: pathParams.getString('tab', 'new')));
          return _i3.BooksScreen(key: args.key, tab: args.tab);
        }),
    SettingsRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i3.SettingsScreen();
        })
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig(AppRoute.name, path: '/', children: [
          _i1.RouteConfig('#redirect',
              path: '', redirectTo: 'books/new', fullMatch: true),
          _i1.RouteConfig(BooksRoute.name, path: 'books/:tab'),
          _i1.RouteConfig(SettingsRoute.name, path: 'settings')
        ]),
        _i1.RouteConfig('*#redirect',
            path: '*', redirectTo: '/', fullMatch: true)
      ];
}

class AppRoute extends _i1.PageRouteInfo {
  const AppRoute({List<_i1.PageRouteInfo>? children})
      : super(name, path: '/', initialChildren: children);

  static const String name = 'AppRoute';
}

class BooksRoute extends _i1.PageRouteInfo<BooksRouteArgs> {
  BooksRoute({_i2.Key? key, String tab = 'new'})
      : super(name,
            path: 'books/:tab',
            args: BooksRouteArgs(key: key, tab: tab),
            rawPathParams: {'tab': tab});

  static const String name = 'BooksRoute';
}

class BooksRouteArgs {
  const BooksRouteArgs({this.key, this.tab = 'new'});

  final _i2.Key? key;

  final String tab;
}

class SettingsRoute extends _i1.PageRouteInfo {
  const SettingsRoute() : super(name, path: 'settings');

  static const String name = 'SettingsRoute';
}
