// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file is tested with Navi 0.1.0.
// If it doesn't work with newer version, please check live version at https://github.com/zenonine/navi/tree/master/examples/uxr

import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(WishlistApp());
}

class Wishlist {
  final String id;

  Wishlist(this.id);
}

class AppState extends ChangeNotifier {
  final List<Wishlist> wishlists = <Wishlist>[];
  Wishlist? _selectedWishlist;

  Wishlist? get selectedWishlist => _selectedWishlist;

  set selectedWishlist(Wishlist? w) {
    _selectedWishlist = w;
    notifyListeners();
  }

  void addWishlist(Wishlist wishlist) {
    wishlists.add(wishlist);
    notifyListeners();
  }
}

class WishlistApp extends StatefulWidget {
  @override
  _WishlistAppState createState() => _WishlistAppState();
}

class _WishlistAppState extends State<WishlistApp> {
  final BookRouterDelegate _routerDelegate = BookRouterDelegate();
  final BookRouteInformationParser _routeInformationParser =
  BookRouteInformationParser();

  @override
  void dispose() {
    _routerDelegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

class BookRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    // Handle '/'
    if (uri.pathSegments.isEmpty) {
      return AppRoutePath();
    }

    // Handle '/wishlist/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] != 'wishlist') return AppRoutePath();
      final id = uri.pathSegments[1];
      return AppRoutePath(id: id);
    }

    // Handle unknown routes
    return AppRoutePath();
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath path) {
    late final String location;
    if (path.id == null) {
      location = '/';
    } else {
      location = '/wishlist/${path.id}';
    }
    return RouteInformation(location: location);
  }
}

class BookRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final AppState _appState = AppState();

  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    _appState.addListener(() => notifyListeners());
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  AppRoutePath get currentConfiguration {
    final selected = _appState.selectedWishlist;
    if (selected == null) {
      return AppRoutePath();
    } else {
      return AppRoutePath(id: selected.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedWishlist = _appState.selectedWishlist;
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: ValueKey('WishlistListPage'),
          child: WishlistListScreen(
            wishlists: _appState.wishlists,
            onTapped: _handleTapped,
            onCreate: (newId) {
              setNewRoutePath(AppRoutePath(id: newId));
            },
          ),
        ),
        if (selectedWishlist != null)
          MaterialPage(
            key: ValueKey('WishPage'),
            child: WishlistScreen(wishlist: selectedWishlist),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        // Update the list of pages by setting selected wishlist to null
        _appState.selectedWishlist = null;

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    var pathId = path.id;
    if (pathId == null) {
      _appState.selectedWishlist = null;
      return;
    }

    // Create a wishlist with the given ID if none exists
    Wishlist? wishlist;
    for (var w in _appState.wishlists) {
      if (w.id == path.id) {
        wishlist = w;
      }
    }
    if (wishlist == null) {
      wishlist = Wishlist(pathId);
      _appState.addWishlist(wishlist);
    }

    _appState.selectedWishlist = wishlist;
  }

  void _handleTapped(Wishlist wishlist) {
    _appState.selectedWishlist = wishlist;
  }
}

class AppRoutePath {
  final String? id;

  AppRoutePath({this.id});
}

class WishlistListScreen extends StatelessWidget {
  final List<Wishlist> wishlists;
  final ValueChanged<Wishlist> onTapped;
  final ValueChanged<String> onCreate;

  WishlistListScreen({
    required this.wishlists,
    required this.onTapped,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
            Text('Navigate to /wishlist/<ID> in the URL bar to dynamically '
                'create a new wishlist.'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                var randomInt = Random().nextInt(10000);
                onCreate('$randomInt');
              },
              child: Text('Create a new Wishlist'),
            ),
          ),
          for (var i = 0; i < wishlists.length; i++)
            ListTile(
              title: Text('Wishlist ${i + 1}'),
              subtitle: Text(wishlists[i].id),
              onTap: () => onTapped(wishlists[i]),
            )
        ],
      ),
    );
  }
}

class WishlistScreen extends StatelessWidget {
  final Wishlist wishlist;

  WishlistScreen({
    required this.wishlist,
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
            Text('ID: ${wishlist.id}',
                style: Theme.of(context).textTheme.headline6),
          ],
        ),
      ),
    );
  }
}
