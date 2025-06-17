import 'package:flutter/material.dart';

/// A widget that animates the animatable attributes of its child subtree
/// whenever their values change.
///
/// `Animate` simplifies the process of adding implicit animations to your
/// widgets by allowing you to wrap an existing widget tree and define a
/// common animation configuration (duration, curve, etc.). Instead of
/// replacing individual widgets with their `Animated` counterparts
/// (e.g., using `AnimatedContainer` instead of `Container`), you wrap the
/// parent widget with `Animate`.
///
/// Child widgets within the subtree wrapped by `Animate` can expose
/// "animatable attributes" (parameters whose changes can be smoothly
/// animated). When these attributes change (e.g., due to a `setState` call
/// changing a variable driving the widget's properties), `Animate`
/// automatically interpolates between the old and new values using the
/// specified [duration] and [curve].
///
/// For a widget to have its attributes animated by `Animate`, it needs to
/// be designed to register its animatable properties with an `Animate`
/// ancestor (details of this registration mechanism are beyond this stub
/// implementation, but conceptually involves the child communicating its
/// animatable state to the parent `Animate` widget).
///
/// This widget is an alternative to using explicit `ImplicitlyAnimatedWidget`
/// subclasses like `AnimatedOpacity`, `AnimatedScale`, etc., allowing a
/// single animation configuration to apply to multiple animatable properties
/// across different widgets in the wrapped subtree.
///
/// {@tool dartpad}
/// This example demonstrates how `Animate` can be used to animate the
/// color and scale of a button simultaneously when a state change occurs.
///
/// ** Note:** This is a conceptual example based on the proposed API.
/// The actual implementation details for how `Container` and `Transform.scale`
/// would register their animatable properties with `Animate` are not
/// included in this stub.
///
/// ```dart
/// class AnimatedDemo extends StatefulWidget {
///   const AnimatedDemo({super.key});
///
///   @override
///   State<AnimatedDemo> createState() => _AnimatedDemoState();
/// }
///
/// class _AnimatedDemoState extends State<AnimatedDemo> {
///   bool isEnabled = false;
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: const Text('Animated Demo')),
///       body: Center(
///         child: Animate( // Wrap the subtree with Animate
///           duration: const Duration(milliseconds: 500),
///           curve: Curves.easeOut,
///           child: Container( // Container color would be animated
///             color: isEnabled ? Colors.blue : Colors.grey,
///             child: Transform.scale( // Transform.scale scale would be animated
///               scale: isEnabled ? 2.0 : 1.0,
///               child: ElevatedButton(
///                 onPressed: () {
///                   setState(() {
///                     isEnabled = !isEnabled;
///                   });
///                 },
///                 child: Text(isEnabled ? 'Disable' : 'Enable'),
///               ),
///             ),
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
/// {@end-tool}
class Animate extends StatelessWidget {
  /// The default duration for the animation if none is specified.
  static const defaultDuration = Duration(milliseconds: 400);

  /// The widget subtree to be animated.
  ///
  /// `Animate` will look for animatable attributes on widgets within this
  /// subtree and animate them when their values change.
  final Widget child;

  /// The duration over which the animation should occur.
  ///
  /// Defaults to [defaultDuration].
  final Duration duration;

  /// The easing curve to use for this animation.
  ///
  /// This curve applies to any animatable attributes within this subtree.
  final Curve? curve;

  /// Creates a widget that animates animatable attributes in its subtree.
  const Animate({
    super.key,
    required this.child,
    this.duration = defaultDuration,
    this.curve,
  });

  @override
  Widget build(BuildContext context) {
    // This is a "stub" implementation for the purposes of this UX study
    return child;
  }
}
