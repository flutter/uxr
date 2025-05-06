import 'package:flutter/widgets.dart';

/// A widget that provides an [AnimationController] to its descendants.
///
/// [InheritedAnimationController] simplifies managing and accessing an
/// [AnimationController] within a subtree of widgets. It handles the creation,
/// lifecycle, and disposal of the [AnimationController], making it easily
/// available to any descendant widget via the [of] method.
///
/// This is particularly useful for coordinating animations across multiple
/// widgets or when a parent widget needs to control an animation used by
/// its children.
///
/// The [AnimationController] provided by this widget is automatically
/// initialized in the state's `initState` and disposed in `dispose`.
///
/// ```dart
/// // Example usage:
/// InheritedAnimationController(
///   duration: const Duration(seconds: 1),
///   child: MyAnimatedWidget(),
/// )
///
/// class MyAnimatedWidget extends StatelessWidget {
///   const MyAnimatedWidget({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     // Access the controller provided by InheritedAnimationController
///     final animationController = InheritedAnimationController.of(context).controller;
///
///     // You can now use animationController to create animations
///     final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
///
///     // Or trigger controller actions
///     // animationController.forward();
///
///     return FadeTransition(
///       opacity: opacityAnimation,
///       child: Container(
///         width: 100,
///         height: 100,
///         color: Colors.blue,
///       ),
///     );
///   }
/// }
/// ```
class InheritedAnimationController extends StatefulWidget {
  /// Creates an [InheritedAnimationController] widget.
  ///
  /// The [duration] is required for the internal [AnimationController].
  /// The [child] widget is the root of the subtree that will have access
  /// to the controller.
  const InheritedAnimationController({
    super.key,
    this.duration = defaultDuration,
    this.debugLabel,
    this.lowerBound = 0.0,
    this.upperBound = 1.0,
    this.animationBehavior = AnimationBehavior.normal,
    required this.child,
  });

  static const defaultDuration = Duration(milliseconds: 400);

  /// The length of time this animation should last.
  final Duration duration;

  /// A label that is used in the [toString] implementation of the controller.
  final String? debugLabel;

  /// The value the controller returns when the animation is at its start,
  /// by default 0.0.
  final double lowerBound;

  /// The value the controller returns when the animation is at its end,
  /// by default 1.0.
  final double upperBound;

  /// The behavior of the controller when it's driving an imperative animation.
  final AnimationBehavior animationBehavior;

  /// The widget below this widget in the tree.
  ///
  /// This widget will have access to the [AnimationController] provided
  /// by this [InheritedAnimationController].
  final Widget child;

  /// Returns the [AnimationController] nearest to the given [context].
  ///
  /// If no [InheritedAnimationController] ancestor is found, this method
  /// will throw an error.
  ///
  /// To obtain the controller, a widget must have an [InheritedAnimationController]
  /// as an ancestor.
  static _InheritedAnimationControllerState of(BuildContext context) {
    final _InheritedAnimationControllerState? result = context
        .dependOnInheritedWidgetOfExactType<_InheritedAnimationControllerScope>()
        ?.state;
    assert(result != null,
    'InheritedAnimationController.of() called with a context that does not have an InheritedAnimationController ancestor.');
    return result!;
  }

  /// Returns the [AnimationController] nearest to the given [context],
  /// or null if none is found.
  ///
  /// This method is similar to [of], but returns null instead of throwing
  /// if no [InheritedAnimationController] ancestor is found.
  static _InheritedAnimationControllerState? maybeOf(BuildContext context) {
    final _InheritedAnimationControllerState? result = context
        .dependOnInheritedWidgetOfExactType<_InheritedAnimationControllerScope>()
        ?.state;
    return result;
  }


  @override
  State<InheritedAnimationController> createState() =>
      _InheritedAnimationControllerState();
}

/// The State class for [InheritedAnimationController].
///
/// This state manages the lifecycle of the [AnimationController] and
/// provides access to it via its public [controller] property.
class _InheritedAnimationControllerState
    extends State<InheritedAnimationController>
    with SingleTickerProviderStateMixin {
  /// The [AnimationController] managed by this state.
  ///
  /// Descendant widgets can access this controller via
  /// `InheritedAnimationController.of(context).controller`.
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      debugLabel: widget.debugLabel,
      lowerBound: widget.lowerBound,
      upperBound: widget.upperBound,
      animationBehavior: widget.animationBehavior,
    );
  }

  @override
  void didUpdateWidget(covariant InheritedAnimationController oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller properties if the parent widget rebuilds with new values.
    // This is a simplified update logic. A more robust implementation might
    // handle changes to lowerBound/upperBound or animationBehavior differently.
    if (widget.duration != oldWidget.duration) {
      controller.duration = widget.duration;
    }
    // Note: Changing debugLabel, lowerBound, upperBound, or animationBehavior
    // after creation might require more complex handling or recreating the controller
    // depending on desired behavior. Updating duration is the most common case.
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use an InheritedWidget to expose the state (and thus the controller)
    // to the subtree efficiently.
    return _InheritedAnimationControllerScope(
      state: this,
      child: widget.child,
    );
  }
}

/// An [InheritedWidget] that holds the state of the nearest
/// [InheritedAnimationController] ancestor.
///
/// This widget is internal to the implementation of [InheritedAnimationController]
/// and should not be used directly.
class _InheritedAnimationControllerScope extends InheritedWidget {
  const _InheritedAnimationControllerScope({
    required this.state,
    required super.child,
  });

  final _InheritedAnimationControllerState state;

  @override
  bool updateShouldNotify(
      covariant _InheritedAnimationControllerScope oldWidget) {
    // Notify descendants if the state object changes.
    // Changes within the controller (like value or status) are
    // observed by widgets listening to the controller directly.
    return state != oldWidget.state;
  }
}