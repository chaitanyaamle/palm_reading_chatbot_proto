///Wrapper class to implement slide and fade animations at the same time to
///a given element. Wrap the widget that you wish to appear with slide-fade
///transition in this class.
import 'dart:async';

import 'package:flutter/material.dart';

enum Direction { vertical, horizontal, none }

class SlideFadeTransition extends StatefulWidget {
  ///The child on which to apply the given [SlideFadeTransition]
  final Widget child;

  ///The offset by which to slide and [child] into view from [Direction].
  ///Defaults to 0.2
  final double offset;

  ///The curve used to animate the [child] into view.
  ///Defaults to [Curves.easeIn]
  final Curve curve;

  ///The direction from which to animate the [child] into view. [Direction.horizontal]
  ///will make the child slide on x-axis by [offset] and [Direction.vertical] on y-axis.
  ///Defaults to [Direction.vertical]
  final Direction direction;

  ///The delay with which to animate the [child]. Takes in a [Duration] and
  /// defaults to 0.0 seconds
  final Duration delayStart;

  ///The total duration in which the animation completes. Defaults to 800 milliseconds
  final Duration animationDuration;

  final userId;

  SlideFadeTransition({
    required this.child,
    this.offset = 0.2,
    this.curve = Curves.easeIn,
    this.direction = Direction.horizontal,
    this.delayStart = const Duration(seconds: 0),
    this.animationDuration = const Duration(milliseconds: 800),
    this.userId = 0
  });
  @override
  _SlideFadeTransitionState createState() => _SlideFadeTransitionState();
}

class _SlideFadeTransitionState extends State<SlideFadeTransition>
    with SingleTickerProviderStateMixin {
  late Animation<Offset> _animationSlide;

  late AnimationController _animationController;

  late Animation<double> _animationFade;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    //configure the animation controller as per the direction
    if(widget.userId == 0 || widget.userId == -1){
      if (widget.direction == Direction.horizontal) {
        _animationSlide =
            Tween<Offset>(begin: Offset(-widget.offset, 0), end: Offset(0, 0))
                .animate(CurvedAnimation(
              curve: widget.curve,
              parent: _animationController,
            ));
      } else {
        _animationSlide =
            Tween<Offset>(begin: Offset(0, -widget.offset), end: Offset(0, 0))
                .animate(CurvedAnimation(
              curve: widget.curve,
              parent: _animationController,
            ));
      }
    }
    else if(widget.userId == 1){
      if (widget.direction == Direction.horizontal) {
        _animationSlide =
            Tween<Offset>(begin: Offset(widget.offset, 0), end: Offset(0, 0))
                .animate(CurvedAnimation(
              curve: widget.curve,
              parent: _animationController,
            ));
      } else {
        _animationSlide =
            Tween<Offset>(begin: Offset(0, -widget.offset), end: Offset(0, 0))
                .animate(CurvedAnimation(
              curve: widget.curve,
              parent: _animationController,
            ));
      }
    }

    _animationFade =
        Tween<double>(begin: -1.0, end: 1.0).animate(CurvedAnimation(
          curve: widget.curve,
          parent: _animationController,
        ));

    Timer(widget.delayStart, () {
      if(mounted){
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.direction != Direction.none ? FadeTransition(
      opacity: _animationFade,
      child: SlideTransition(
        position: _animationSlide,
        child: widget.child,
      ),
    ) : widget.child;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}