import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scenario 1 - Flutter Animate Scale & Rotate',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Scenario 1 - Flutter Animate Scale & Rotate'),
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

  late AnimationController _controller;

  static const double initialSize = 128.0;
  static const double finalSize = 256.0;
  static const double scaleFactor = finalSize / initialSize;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: duration, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleExpanded() {
    setState(() {
      selected = !selected;
    });

    if (selected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(context) {
    return GestureDetector(
      onTap: toggleExpanded,
      child: Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: initialSize,
                height: initialSize,
                child: Image.asset(
                  'assets/eat_cape_town_sm.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
          .animate(controller: _controller)
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(scaleFactor, scaleFactor),
            alignment: Alignment.center,
            curve: Curves.ease,
          )
          .rotate(
            begin: 0.0,
            end: 0.5,
            alignment: Alignment.center,
            curve: Curves.ease,
          ),
    );
  }
}
