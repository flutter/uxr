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
      title: 'Scenario 1 - Fade in and out',
      home: Scaffold(
        appBar: AppBar(title: const Text('Scenario 1 - Fade in and out')),
        body: Center(child: FadeInOutButton()),
      ),
    );
  }
}

class FadeInOutButton extends StatefulWidget {
  const FadeInOutButton({super.key});

  @override
  FadeInOutButtonState createState() => FadeInOutButtonState();
}

class FadeInOutButtonState extends State<FadeInOutButton> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isVisible = !isVisible;
        });
      },
      child: Text('Toggle Opacity'),
    ).animate(target: isVisible ? 1.0 : 0.0).fade(duration: 300.ms);
  }
}
