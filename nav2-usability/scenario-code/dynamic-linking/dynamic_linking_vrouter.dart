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

class AppState {
  final List<Wishlist> wishlists = <Wishlist>[];

  void addWishlist(Wishlist wishlist) {
    wishlists.add(wishlist);
  }
}

class WishlistApp extends StatelessWidget {
  final AppState _appState = AppState();

  void createIfNotExist(String value) {
    if (_appState.wishlists.indexWhere((element) => element.id == value) == -1) {
      _appState.addWishlist(Wishlist(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return VRouter(
      routes: [
        VWidget(
          path: '/',
          widget: WishlistListScreen(wishlists: _appState.wishlists),
          stackedRoutes: [
            VGuard(
              beforeEnter: (vRedirector) async =>
                  createIfNotExist(vRedirector.newVRouterData!.pathParameters['id']!),
              beforeUpdate: (vRedirector) async =>
                  createIfNotExist(vRedirector.newVRouterData!.pathParameters['id']!),
              stackedRoutes: [
                VWidget(
                  path: r'wishlist/:id(\d+)',
                  widget: Builder(
                    builder: (context) => WishlistScreen(
                        wishlist: _appState.wishlists.firstWhere(
                                (element) => element.id == context.vRouter.pathParameters['id'])),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class WishlistListScreen extends StatelessWidget {
  final List<Wishlist> wishlists;

  WishlistListScreen({required this.wishlists});

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
                context.vRouter.push('/wishlist/$randomInt');
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
