import 'package:flutter/material.dart';

import 'api/02_inherited_animation_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repeat Scenario Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RepeatScenario(),
    );
  }
}

// The `RepeatScenarioState` code implements the following animation behavior 
// using AnimatedRotation and AnimatedScale:
// 1. When the animation is not currently running, a tap on the
// 'Fade in and out' button should initiate a repeating animation
// that causes the button to fade in and out.
// 2. When the animation is currently running, a tap on the
// 'Fade in and out' button should terminate the animation.
//
// Your task:
// Edit the current code to use the `InheritedAnimationController` API to
// replace `AnimationController`,
// achieving the same animation effect.

class RepeatScenario extends StatefulWidget {
  const RepeatScenario({super.key});

  @override
  RepeatScenarioState createState() => RepeatScenarioState();
}

class RepeatScenarioState extends State<RepeatScenario>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _isRepeating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Repeat Scenario')),
      body: Center(
        child: FadeTransition(
          opacity: _controller,
          child: ElevatedButton(
            onPressed: () {
              if (_isRepeating) {
                _controller.stop();
              } else {
                _controller.repeat(reverse: true);
              }
              setState(() {
                _isRepeating = !_isRepeating;
              });
            },
            child: const Text('Fade in and out'),
          ),
        ),
      ),
    );
  }
}
