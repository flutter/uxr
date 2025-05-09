import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import the package

// Make sure you have an image asset named 'assets/eat_cape_town_sm.jpg'

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scenario 1 - Flutter Animate Scale & Rotate',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Scenario 1 - Flutter Animate Scale & Rotate'),
        ),
        body: Center(child: ExpandCard()),
      ),
    );
  }
}

class ExpandCard extends StatefulWidget {
  const ExpandCard({super.key});
  @override
  State<ExpandCard> createState() => _ExpandCardState();
}

class _ExpandCardState extends State<ExpandCard>
    with SingleTickerProviderStateMixin {
  static const Duration duration = Duration(milliseconds: 300);
  bool selected = false; // Tracks the target state

  // We need an AnimationController to manually control the flutter_animate chain
  late AnimationController _controller;

  // Define the initial and final sizes to calculate the scale factor
  static const double initialSize = 128.0;
  static const double finalSize = 256.0;
  static const double scaleFactor =
      finalSize / initialSize; // Scale from 1.0 to 2.0

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController to drive the flutter_animate chain
    _controller = AnimationController(
      duration: duration, // Use the same duration for the animation
      vsync: this, // Use the SingleTickerProviderStateMixin
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }

  void toggleExpanded() {
    setState(() {
      selected = !selected; // Toggle the target state
    });

    // Control the animation chain based on the target state
    if (selected) {
      _controller.forward(); // Play the animation forward (scale up, rotate)
    } else {
      _controller
          .reverse(); // Play the animation in reverse (scale down, rotate back)
    }
  }

  @override
  Widget build(context) {


    return GestureDetector(
      onTap: toggleExpanded, // Call the toggle function on tap
      child:
          Card(
                clipBehavior: Clip.antiAlias,
                // Note: The Card's layout size will be based on its child (the Container's initial size)
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  // Use a regular Container with the initial size
                  child: Container(
                    width: initialSize,
                    height: initialSize,
                    child: Image.asset(
                      'assets/eat_cape_town_sm.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Apply the .animate() extension method to the Container
                ),
              )
              .animate(
                controller:
                    _controller, // Drive this animation chain with our controller
              )
              .scale(
                // Apply the scale effect from flutter_animate
                begin: const Offset(
                  1.0,
                  1.0,
                ), // Start scale (1.0 = original size)
                end: const Offset(
                  scaleFactor,
                  scaleFactor,
                ), // End scale (scaleFactor = 256/128)
                alignment: Alignment.center, // Scale from the center
                curve: Curves.ease, // Apply ease curve to scaling
              )
              .rotate(
                // Apply the rotate effect from flutter_animate
                begin: 0.0, // Start rotation (0 turns)
                end: 0.5, // End rotation (0.5 turns = 180 degrees)
                alignment: Alignment.center, // Rotate around the center
                curve: Curves.ease, // Apply ease curve to rotation
              ),
    );
  }
}
