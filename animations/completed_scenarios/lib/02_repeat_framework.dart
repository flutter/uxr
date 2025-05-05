import 'package:flutter/material.dart';

import 'api/inherited_animation_controller.dart';

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
      appBar: AppBar(title: Text('Repeat Scenario')),
      body: Center(
        child: InheritedAnimationController(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FadeTransition(
                opacity: _controller,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_isRepeating) {
                        _controller.stop();
                        _isRepeating = false;
                      } else {
                        _isRepeating = true;
                        _controller.repeat(reverse: true);
                      }
                    });
                  },
                  child: Text('Fade in and out '),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
