import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(WishlistApp());
}

class Wishlist {
  final String id;

  Wishlist(this.id);
}

class AppState {
  final List<Wishlist> wishlists = <Wishlist>[];
  Wishlist? selectedWishlist;
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
    if (uri.pathSegments.length == 0) {
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
  final GlobalKey<NavigatorState> navigatorKey;

  AppState appState = AppState();

  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  AppRoutePath get currentConfiguration {
    final selected = appState.selectedWishlist;
    if (selected == null) {
      return AppRoutePath();
    } else {
      return AppRoutePath(id: selected.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedWishlist = appState.selectedWishlist;
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: ValueKey('WishlistListPage'),
          child: WishlistListScreen(
            wishlists: appState.wishlists,
            onTapped: _handleTapped,
            onCreate: (newId) {
              var wishlist = Wishlist(newId);
              appState.wishlists.add(wishlist);
              appState.selectedWishlist = wishlist;
              notifyListeners();
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

        // Update the list of pages by setting _selectedBook to null
        appState.selectedWishlist = null;
        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath path) async {
    var pathId = path.id;
    if (pathId == null) {
      appState.selectedWishlist = null;
      return;
    }

    // Create a wishlist with the given ID if none exists
    // var hasWishlist = appState.wishlists.firstWhere((e) => e.id == path.id, orElse: () => null);
    Wishlist? wishlist;
    for (var w in appState.wishlists) {
      if (w.id == path.id) {
        wishlist = w;
      }
    }
    if (wishlist == null) {
      appState.wishlists.add(Wishlist(pathId));
    } else {
      appState.selectedWishlist = wishlist;
    }
    notifyListeners();
  }

  void _handleTapped(Wishlist wishlist) {
    appState.selectedWishlist = wishlist;
    notifyListeners();
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
            child: Text('Navigate to /wishlist/<ID> to create a new wishlist.'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                var randomInt = Random().nextInt(10000);
                this.onCreate('$randomInt');
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
