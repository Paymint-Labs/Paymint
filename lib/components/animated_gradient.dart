import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Returns an container with 
class AnimatedGradientBox extends HookWidget {
  final List<Gradient> gradients;
  final Curve curve;

  AnimatedGradientBox(this.gradients, [this.curve = Curves.linear]);

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(gradient: useAnimatedGradient(gradients: gradients, curve: curve)));
  }
}

Gradient useAnimatedGradient({
  Duration duration = const Duration(seconds: 5),
  List<Gradient> gradients,
  Curve curve = Curves.linear,
}) {
  return Hook.use(_AnimatedGradientHook(
    duration: duration,
    gradients: gradients,
    curve: curve,
  ));
}

class GradientTween extends Tween<Gradient> {
  GradientTween({
    Gradient begin,
    Gradient end,
  }) : super(begin: begin, end: end);

  @override
  Gradient lerp(double t) => Gradient.lerp(begin, end, t);
}

class _AnimatedGradientHook extends Hook<Gradient> {
  final List<Gradient> gradients;
  final Duration duration;
  final Curve curve;

  _AnimatedGradientHook({this.duration, this.gradients, this.curve});

  @override
  HookState<Gradient, Hook<Gradient>> createState() => _AnimatedGradientHookState();
}

class _AnimatedGradientHookState extends HookState<Gradient, _AnimatedGradientHook> {
  @override
  Gradient build(BuildContext context) {
    final controller = useAnimationController(duration: hook.duration);
    final index = useValueNotifier(0);

    useEffect(() {
      controller.repeat();
      final listener = () {
        final newIndex = (controller.value * hook.gradients.length).floor() % hook.gradients.length;
        if (newIndex != index.value) index.value = newIndex;
      };
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [hook.gradients, hook.duration, hook.curve]);

    return useAnimation(GradientTween(
            begin: hook.gradients[index.value], end: hook.gradients[(index.value + 1) % hook.gradients.length])
        .animate(CurvedAnimation(
            curve: Interval(
              index.value / hook.gradients.length,
              (index.value + 1) / hook.gradients.length,
              curve: hook.curve,
            ),
            parent: controller)));
  }
}
