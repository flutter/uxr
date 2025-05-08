import 'dart:math' show pi;
import 'api/animate.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scenario 1 - Expand Card with Rotation',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Scenario 1 - Expand Card with Rotation'),
        ),
        body: Center(child: ExpandCard()),
      ),
    );
  }
}
// Please edit `ExpandCard` code to implement the following
// animation behavior:
// 1. When tapped, the Card will be selected. Simultaneously, it will animate
//    from size 128 to 256 and rotate 180 degrees.
// 2. When deselected, the animation will reverse.

// Hint: You should use `Animate` API in this test.
class ExpandCard extends StatefulWidget {
  const ExpandCard({super.key});
  @override
  State<ExpandCard> createState() => _ExpandCardState();
}

class _ExpandCardState extends State<ExpandCard>
    with SingleTickerProviderStateMixin {
  bool selected = false;

  void toggleExpanded() {
    setState(() {
      selected = !selected;
    });
  }

  @override
  Widget build(context) {
    return GestureDetector(
      onTap: () => toggleExpanded(),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(8.0),

          child: Image.asset('assets/eat_cape_town_sm.jpg', fit: BoxFit.cover),
        ),
      ),
    );
  }
}
