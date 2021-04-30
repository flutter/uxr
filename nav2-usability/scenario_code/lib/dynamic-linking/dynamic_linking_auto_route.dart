// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
/// Dynamic linking example
/// Done using AutoRoute

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_uxr/main.gr.dart';

void main() {
  runApp(WishListApp());
}

class Wishlist {
  final String id;

  Wishlist(this.id);
}

class AppState extends ChangeNotifier {
  final List<Wishlist> wishlists = <Wishlist>[];

  void addWishlist(Wishlist wishlist) {
    wishlists.add(wishlist);
    notifyListeners();
  }
}

// Declare routing setup
@MaterialAutoRouter(
  replaceInRouteName: 'Screen,Route',
  routes: <AutoRoute>[
    AutoRoute(
      path: "/",
      page: WishlistListScreen,
    ),
    AutoRoute(
      path: "/wishlist/:id",
      guards: [CreateIfNotExistGuard],
      page: WishlistScreen,
    ),
    RedirectRoute(path: "*", redirectTo: "/")
  ],
)
class $AppRouter {}

class CreateIfNotExistGuard extends AutoRouteGuard {
  @override
  Future<bool> canNavigate(
      List<PageRouteInfo> pendingRoutes, StackRouter router) async {
    final id = pendingRoutes.first.params["id"];
    if (appState.wishlists.indexWhere((element) => element.id == id) == -1) {
      appState.addWishlist(Wishlist(id));
    }
    return true;
  }
}

final AppState appState = AppState();

class WishListApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WishListAppState();
}

class _WishListAppState extends State<WishListApp> {
  late final _appRouter = AppRouter(
    createIfNotExistGuard: CreateIfNotExistGuard(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser:
          // includePrefixMatches can toggle whether the root / route is also pushed when you
          // hit /wishlist/:id directly in the browser
          _appRouter.defaultRouteParser(includePrefixMatches: true),
      routerDelegate: _appRouter.delegate(),
    );
  }
}

class WishlistListScreen extends StatelessWidget {
  void onCreate(BuildContext context, String value) {
    final wishlist = Wishlist(value);
    appState.addWishlist(wishlist);
    context.router.pushNamed('/wishlist/$value');
  }

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
                onCreate(context, '$randomInt');
              },
              child: Text('Create a new Wishlist'),
            ),
          ),
          for (var i = 0; i < appState.wishlists.length; i++)
            ListTile(
              title: Text('Wishlist ${i + 1}'),
              subtitle: Text(appState.wishlists[i].id),
              onTap: () => context.router
                  .pushNamed("/wishlist/${appState.wishlists[i].id}"),
            )
        ],
      ),
    );
  }
}

class WishlistScreen extends StatelessWidget {
  WishlistScreen({@PathParam('id') required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $id', style: Theme.of(context).textTheme.headline6),
          ],
        ),
      ),
    );
  }
}
