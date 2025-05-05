import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: Center(child: RepeatScenario())));
  }
}

class RepeatScenario extends StatefulWidget {
  const RepeatScenario({super.key});

  @override
  RepeatScenarioState createState() => RepeatScenarioState();
}

class RepeatScenarioState extends State<RepeatScenario> {
  AnimationController? _faController;
  bool _isRepeating = false;

  void _toggleRepeatAnimation() {
    setState(() {
      if (_isRepeating) {
        _faController?.stop();
        _isRepeating = false;
      } else {
        _isRepeating = true;
        _faController?.repeat(reverse: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: _toggleRepeatAnimation,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
          child: const Text('Fade in and out'),
        ).animate(
          autoPlay: false,
          onInit: (controller) {
            _faController = controller;
            _faController?.value = 1.0;
          },
          effects: [
            FadeEffect(
              duration: 700.ms,
              begin: 0.0,
              end: 1.0,
              curve: Curves.easeInOut,
            ),
          ],
        ),
      ],
    );
  }
}
