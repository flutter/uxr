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

class ExpandCard extends StatefulWidget {
  const ExpandCard({super.key});
  @override
  State<ExpandCard> createState() => _ExpandCardState();
}

class _ExpandCardState extends State<ExpandCard>
    with SingleTickerProviderStateMixin {
  bool selected = false;

  // State variable for rotation, in turns (1.0 = 360 degrees)
  double get turns => selected ? 0.5 : 0.0;

  double get size => selected ? 256 : 128;

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
        clipBehavior:
            Clip.antiAlias, // Helps contain the rotated image within the card
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Animate(
            child: Container(
              width: size,
              height: size,
              child: Transform.rotate(
                angle: turns * pi,
                child: Image.asset(
                  'assets/eat_cape_town_sm.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
