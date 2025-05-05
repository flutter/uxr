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
        appBar: AppBar(
          title: const Text('Scenario 1 - Fade out'),
        ),
        body: Center(
          child: FadeInOutButton(),
        ),
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
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isVisible = !isVisible;
          });
        },
        child: Text('Fade in and out'),
      ),
    );
  }
}
