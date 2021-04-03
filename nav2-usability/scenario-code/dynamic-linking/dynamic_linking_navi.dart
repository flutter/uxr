// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file is tested with Navi 0.1.0.
// If it doesn't work with newer version, please check live version at https://github.com/zenonine/navi/tree/master/examples/uxr

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
  final NaviRouterDelegate _routerDelegate =
      NaviRouterDelegate.material(rootPage: RootPage());
  final NaviInformationParser _routeInformationParser = NaviInformationParser();

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

class WishlistListScreen extends StatelessWidget {
  final List<Wishlist> wishlists;

  WishlistListScreen({
    required this.wishlists,
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
                context.navi.stack(WishlistStackMarker()).state =
                    Wishlist('$randomInt');
              },
              child: Text('Create a new Wishlist'),
            ),
          ),
          for (var i = 0; i < wishlists.length; i++)
            ListTile(
              title: Text('Wishlist ${i + 1}'),
              subtitle: Text(wishlists[i].id),
              onTap: () {
                context.navi.stack(WishlistStackMarker()).state = wishlists[i];
              },
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

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RouteStack<Wishlist?>(
      marker: WishlistStackMarker(),
      pages: (context, state) => [
        MaterialPage<dynamic>(
          key: const ValueKey('Home'),
          child: WishlistListScreen(wishlists: wishlists),
        ),
        if (state != null)
          MaterialPage<dynamic>(
            key: ValueKey(state.id),
            child: WishlistScreen(wishlist: state),
          ),
      ],
      updateStateOnNewRoute: (routeInfo) {
        if (routeInfo.hasPrefixes(['wishlist'])) {
          final id = routeInfo.pathSegmentAt(1);

          if (id?.trim().isNotEmpty == true) {
            return wishlists.firstWhere(
              (w) => w.id == id,
              orElse: () => Wishlist(id!),
            );
          }
        }
      },
      updateRouteOnNewState: (state) {
        if (state != null && !wishlists.contains(state)) {
          wishlists.add(state);
        }

        return RouteInfo(
            pathSegments: state == null ? [] : ['wishlist', state.id]);
      },
      updateStateBeforePop: (context, route, dynamic result, state) => null,
    );
  }
}

class WishlistStackMarker extends StackMarker<Wishlist?> {}
