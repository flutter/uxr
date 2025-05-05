// Assuming 'Animate' watches for changes in 'animatable' properties like opacity
import 'package:flutter/material.dart';

import 'api/animate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fade Out Button Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('Fade Out Button Demo')),
        body: Center(child: const FadeOutButton()),
      ),
    );
  }
}

class FadeOutButton extends StatefulWidget {
  const FadeOutButton({super.key});

  @override
  FadeOutButtonState createState() => FadeOutButtonState();
}

class FadeOutButtonState extends State<FadeOutButton> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Animate(
      duration: const Duration(milliseconds: 300),
      child: Opacity(
        opacity: isVisible ? 1.0 : 0.0,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              isVisible = !isVisible;
            });
          },
          child: const Text('Toggle Opacity'),
        ),
      ),
    );
  }
}
