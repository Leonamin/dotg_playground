import 'package:flutter/material.dart';

class SpeedDialFAB extends StatefulWidget {
  final bool open;
  final Widget primaryChild;
  final List<Widget> children;
  final AnimationController? controller;
  final Duration duration;
  final Duration? reverseDuration;

  final EdgeInsets? primaryPadding;
  final EdgeInsets? childrenPadding;
  final double? childrenDistance;

  const SpeedDialFAB({
    super.key,
    required this.primaryChild,
    required this.children,
    this.controller,
    this.duration = const Duration(milliseconds: 450),
    this.reverseDuration,
    required this.open,
    this.primaryPadding,
    this.childrenPadding,
    this.childrenDistance,
  });

  @override
  State<StatefulWidget> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Animation<double>> _speedDialChildAnimations = [];

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _animationController = widget.controller ??
        AnimationController(
          value: widget.open ? 1 : 0,
          vsync: this,
          duration: widget.duration,
          reverseDuration: widget.reverseDuration,
        );

    _animationController.addListener(() {
      if (mounted) setState(() {});
    });

    _generateChildAnimations();
  }

  void _generateChildAnimations() {
    final double fraction = 1.0 / widget.children.length;
    for (int index = 0; index < widget.children.length; ++index) {
      var items = _createTweenSequenceItems(index, fraction);
      _speedDialChildAnimations.insert(
          0, TweenSequence<double>(items).animate(_animationController));
    }
  }

  List<TweenSequenceItem<double>> _createTweenSequenceItems(
      int index, double fraction) {
    var items = <TweenSequenceItem<double>>[];

    if (fraction * index > 0.0) {
      items.add(TweenSequenceItem(
          tween: ConstantTween(0.0), weight: fraction * index));
    }

    items.add(TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0), weight: fraction));

    final double lastWeight = fraction * (widget.children.length - 1 - index);
    if (lastWeight > 0.0) {
      items.add(
          TweenSequenceItem(tween: ConstantTween(1.0), weight: lastWeight));
    }

    return items;
  }

  @override
  void didUpdateWidget(covariant SpeedDialFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.open != widget.open) _animate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!_animationController.isDismissed) ..._buildChildrenWidgets(),
        _buildPrimaryWidget(),
      ],
    );
  }

  List<Widget> _buildChildrenWidgets() {
    return widget.children.asMap().entries.map<Widget>((entry) {
      int index = entry.key;
      Widget child = entry.value;

      return Padding(
        padding: widget.childrenPadding ?? const EdgeInsets.only(right: 4),
        child: Opacity(
          opacity: _speedDialChildAnimations[index].value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _speedDialChildAnimations[index],
                child: Padding(
                  padding:
                      EdgeInsets.only(bottom: widget.childrenDistance ?? 8),
                  child: child,
                ),
              )
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildPrimaryWidget() {
    return Padding(
      key: const ValueKey('primary'),
      padding: widget.primaryPadding ?? const EdgeInsets.only(right: 4),
      child: widget.primaryChild,
    );
  }

  void _animate() async {
    if (widget.open) {
      await _animationController.forward();
    } else {
      await _animationController.reverse();
    }
  }
}
