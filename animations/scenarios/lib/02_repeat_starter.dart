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


    // Please edit `RepeatScenarioState` code to implement the following
    // animation behavior:
    // 1. When the animation is not currently running, a tap on the
    // 'Fade in and out' button should initiate a repeating animation
    // that causes the 'Fading Button' button to fade in and out.
    // 2. When the animation is currently running, a tap on the
    // 'Fade in and out' button should terminate the animation.

    // Hint: You may use `FadeTransition`, `AnimationController`,
    // `InheritedAnimationController` or other APIs in this test.
class RepeatScenarioState extends State<RepeatScenario>
    with SingleTickerProviderStateMixin {


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Repeat Scenario')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text('Fading Button'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Please implement this call method.
              },
              child: Text('Fade in and out'),
            ),
          ],
        ),
      ),
    );
  }
}
