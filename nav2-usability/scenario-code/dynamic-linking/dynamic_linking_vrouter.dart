// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Dynamic linking example
/// Done using VRouter

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

void main() {
  runApp(WishlistApp());
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

class WishlistApp extends StatefulWidget {
  @override
  _WishlistAppState createState() => _WishlistAppState();
}

class _WishlistAppState extends State<WishlistApp> {
  final AppState _appState = AppState();
  final vRouterKey;

  _WishlistAppState() : vRouterKey = GlobalKey<VRouterState>() {
    _appState.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VRouter(
      key: vRouterKey,
      routes: [
        VWidget(
          path: '/',
          widget: WishlistListScreen(wishlists: _appState.wishlists, onCreate: onCreate),
          stackedRoutes: [
            VWidget(
              path: r'wishlist/:id(\d+)',
              widget: Builder(
                builder: (context) => WishlistScreen(
                    wishlist: _appState.wishlists.firstWhere(
                            (element) => element.id == context.vRouter.pathParameters['id']
                    )),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void onCreate(String value) {
    final wishlist = Wishlist(value);
    _appState.addWishlist(wishlist);
    vRouterKey.currentState!.push('/wishlist/$value');
  }
}

class WishlistListScreen extends StatelessWidget {
  final List<Wishlist> wishlists;
  final ValueChanged<String> onCreate;

  WishlistListScreen({
    required this.wishlists,
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
            child: Text('Navigate to /wishlist/<ID> in the URL bar to dynamically '
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
              onTap: () => context.vRouter.push('/wishlist/${wishlists[i].id}'),
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
            Text('ID: ${wishlist.id}', style: Theme.of(context).textTheme.headline6),
          ],
        ),
      ),
    );
  }
}