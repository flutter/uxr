import 'package:flutter/material.dart';

import 'api/inherited_animation_controller.dart';

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

class RepeatScenario extends StatefulWidget {
  const RepeatScenario({super.key});

  @override
  RepeatScenarioState createState() => RepeatScenarioState();
}

class RepeatScenarioState extends State<RepeatScenario>
    with SingleTickerProviderStateMixin {
  bool _isRepeating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Repeat Scenario')),
      body: Center(
        child: InheritedAnimationController(
          child: FadeTransition(
            opacity: InheritedAnimationController.of(context).controller,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_isRepeating) {
                    InheritedAnimationController.of(context).controller.stop();
                    _isRepeating = false;
                  } else {
                    _isRepeating = true;
                    InheritedAnimationController.of(
                      context,
                    ).controller.repeat(reverse: true);
                  }
                });
              },
              child: Text('Fade in and out'),
            ),
          ),
        ),
      ),
    );
  }
}
