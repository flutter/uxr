import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scenario 1 - Expand Card with Rotation and Scale',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Scenario 1 - Expand Card with Rotation and Scale'),
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
  static const Duration duration = Duration(milliseconds: 300);
  bool selected = false;

  double get turns => selected ? 0.5 : 0.0;
  static const double initialSize = 128.0;
  static const double finalSize = 256.0;
  static const double scaleFactor = finalSize / initialSize;
  double get currentScale => selected ? scaleFactor : 1.0;

  void toggleExpanded() {
    setState(() {
      selected = !selected;
    });
  }

  @override
  Widget build(context) {
    return GestureDetector(
      onTap: () => toggleExpanded(),
      child: AnimatedRotation(
        turns: turns,
        duration: duration,
        curve: Curves.ease,
        child: AnimatedScale(
          scale: currentScale,
          duration: duration,
          curve: Curves.ease,
          child: SizedBox(
            width: initialSize,
            height: initialSize,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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