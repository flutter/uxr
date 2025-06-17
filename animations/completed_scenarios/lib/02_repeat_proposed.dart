import 'package:flutter/material.dart';

import 'api/02_inherited_animation_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repeat Scenario Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RepeatScenario(),
    );
  }
}

class RepeatScenario extends StatelessWidget {
  const RepeatScenario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Repeat Scenario')),
      body: Center(
        child: InheritedAnimationController(child: RepeatFadeButton()),
      ),
    );
  }
}

class RepeatFadeButton extends StatefulWidget {
  const RepeatFadeButton({super.key});

  @override
  State<RepeatFadeButton> createState() => _RepeatFadeButtonState();
}

class _RepeatFadeButtonState extends State<RepeatFadeButton> {
  bool _isRepeating = false;

  @override
  Widget build(BuildContext context) {
    var controller = InheritedAnimationController.of(context).controller;
    return FadeTransition(
      opacity: controller,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            if (_isRepeating) {
              controller.stop();
              _isRepeating = false;
            } else {
              _isRepeating = true;
              controller.repeat(reverse: true);
            }
          });
        },
        child: Text('Fade in and out'),
      ),
    );
  }
}
