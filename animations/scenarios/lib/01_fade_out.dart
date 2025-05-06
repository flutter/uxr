import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scenario 1 - Fade out',
      home: Scaffold(
        appBar: AppBar(title: const Text('Scenario 1 - Fade out')),
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

// Please edit the `FadeInOutButtonState` code below to implement the following
// animation behavior:
//
// 1. When the `isVisible` state changes, the button should smoothly fade in or out
//    using an opacity animation.
// 2. When faded out (isVisible = false), the button should become fully transparent.
// 3. When faded in (isVisible = true), the button should be fully opaque.

// Hint: You may use `AnimatedOpacity`, `Opacity`, `Animate` or other APIs in this test.

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
    );
  }
}
