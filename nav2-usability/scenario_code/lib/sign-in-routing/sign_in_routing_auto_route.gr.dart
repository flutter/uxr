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
    AppStackRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i3.AppStackScreen();
        }),
    SignInRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final args = data.argsAs<SignInRouteArgs>();
          return _i3.SignInScreen(onSignedIn: args.onSignedIn);
        }),
    HomeRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i3.HomeScreen();
        }),
    BooksListRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i3.BooksListScreen();
        })
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig(AppStackRoute.name, path: '/', children: [
          _i1.RouteConfig(HomeRoute.name, path: ''),
          _i1.RouteConfig(BooksListRoute.name, path: 'books')
        ]),
        _i1.RouteConfig(SignInRoute.name, path: '/signIn'),
        _i1.RouteConfig('*#redirect',
            path: '*', redirectTo: '/', fullMatch: true)
      ];
}

class AppStackRoute extends _i1.PageRouteInfo {
  const AppStackRoute({List<_i1.PageRouteInfo>? children})
      : super(name, path: '/', initialChildren: children);

  static const String name = 'AppStackRoute';
}

class SignInRoute extends _i1.PageRouteInfo<SignInRouteArgs> {
  SignInRoute({required void Function(_i3.Credentials) onSignedIn})
      : super(name,
            path: '/signIn', args: SignInRouteArgs(onSignedIn: onSignedIn));

  static const String name = 'SignInRoute';
}

class SignInRouteArgs {
  const SignInRouteArgs({required this.onSignedIn});

  final void Function(_i3.Credentials) onSignedIn;
}

class HomeRoute extends _i1.PageRouteInfo {
  const HomeRoute() : super(name, path: '');

  static const String name = 'HomeRoute';
}

class BooksListRoute extends _i1.PageRouteInfo {
  const BooksListRoute() : super(name, path: 'books');

  static const String name = 'BooksListRoute';
}
