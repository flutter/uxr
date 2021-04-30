// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// If the file doesn't work with newer version, please check live version at
// https://github.com/zenonine/navi/tree/master/examples/uxr

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:navi/navi.dart';

void main() {
  runApp(WishlistApp());
}

class Wishlist {
  final String id;

  Wishlist(this.id);
}

final List<Wishlist> wishlists = <Wishlist>[];

class WishlistApp extends StatefulWidget {
  @override
  _WishlistAppState createState() => _WishlistAppState();
}

class _WishlistAppState extends State<WishlistApp> {
  final _routeInformationParser = NaviInformationParser();
  final _routerDelegate = NaviRouterDelegate.material(child: WishlistsStack());

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

class WishlistsStack extends StatefulWidget {
  @override
  _WishlistsStackState createState() => _WishlistsStackState();
}

class _WishlistsStackState extends State<WishlistsStack>
    with NaviRouteMixin<WishlistsStack> {
  Wishlist? _selectedWishlist;

  @override
  void onNewRoute(NaviRoute unprocessedRoute) {
    String? id;
    if (unprocessedRoute.hasPrefixes(['wishlist'])) {
      id = unprocessedRoute.pathSegmentAt(1);
    }

    _selectedWishlist = id == null
        ? null
        : wishlists.firstWhere(
            (w) => w.id == id,
            orElse: () {
              final newWishlist = Wishlist(id!);
              wishlists.add(newWishlist);
              return newWishlist;
            },
          );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return NaviStack(
      pages: (context) => [
        NaviPage.material(
          key: const ValueKey('Wishlists'),
          child: WishlistListScreen(
            wishlists: wishlists,
            onTapped: (wishlist) => setState(() {
              _selectedWishlist = wishlist;
            }),
            onCreate: (id) {
              context.navi.to(['wishlist', id]);
            },
          ),
        ),
        if (_selectedWishlist != null)
          NaviPage.material(
            key: ValueKey(_selectedWishlist),
            route: NaviRoute(path: ['wishlist', '${_selectedWishlist!.id}']),
            child: WishlistScreen(wishlist: _selectedWishlist!),
          ),
      ],
      onPopPage: (context, route, dynamic result) {
        if (_selectedWishlist != null) {
          setState(() {
            _selectedWishlist = null;
          });
        }
      },
    );
  }
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
