import 'dart:math';

import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

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

class WishlistLocation extends BeamLocation {
  WishlistLocation(AppState appState, BeamState state)
      : _appState = appState,
        super(state) {
    _appState.addListener(
      () => update(
        (state) => (state.copyWith(
          pathBlueprintSegments: _appState.selectedWishlist != null
              ? ['wishlist', ':wishlistId']
              : ['wishlist'],
          pathParameters: _appState.selectedWishlist != null
              ? {'wishlistId': _appState.selectedWishlist!.id}
              : {},
        )),
      ),
    );
  }

  final AppState _appState;

  @override
  List<String> get pathBlueprints => ['/wishlist/:wishlistId'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('wishlist-${_appState.wishlists.length}'),
          child: WishlistListScreen(
            wishlists: _appState.wishlists,
            onCreate: (id) {
              _appState.selectedWishlist = null;
              _appState.addWishlist(Wishlist(id));
            },
            onTapped: (wishlist) => _appState.selectedWishlist = wishlist,
          ),
        ),
        if (state.pathParameters.containsKey('wishlistId'))
          BeamPage(
            key: ValueKey('wishlist-${state.pathParameters['wishlistId']}'),
            child: WishlistScreen(
              wishlist: _appState.wishlists.firstWhere(
                (wishlist) => wishlist.id == state.pathParameters['wishlistId'],
                orElse: () {
                  final wishlist =
                      Wishlist(state.pathParameters['wishlistId']!);
                  _appState.wishlists.add(wishlist);
                  return wishlist;
                },
              ),
            ),
          ),
      ];
}

class WishlistApp extends StatelessWidget {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wishlist App',
      routerDelegate: BeamerRouterDelegate(
        locationBuilder: (state) => WishlistLocation(_appState, state),
      ),
      routeInformationParser: BeamerRouteInformationParser(),
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
