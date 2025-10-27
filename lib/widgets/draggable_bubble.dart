import 'dart:math' as math;
import 'package:flutter/material.dart';

class DraggableBubble extends StatefulWidget {
  final double size;
  final double initialX;
  final double initialY;
  final double opacity;
  final AnimationController rotationController;
  final VoidCallback? onTap;

  const DraggableBubble({
    required this.size,
    required this.initialX,
    required this.initialY,
    required this.opacity,
    required this.rotationController,
    this.onTap,
    super.key,
  });

  @override
  State<DraggableBubble> createState() => _DraggableBubbleState();
}

class _DraggableBubbleState extends State<DraggableBubble> with SingleTickerProviderStateMixin {
  late double _x;
  late double _y;
  bool _isDragging = false;
  bool _isHovered = false;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _x = widget.initialX;
    _y = widget.initialY;
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(widget.rotationController);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _x += details.delta.dx;
      _y += details.delta.dy;
      if (!_isDragging) _isDragging = true;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() => _isDragging = false);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _x,
      top: _y,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          onPanUpdate: _onDragUpdate,
          onPanEnd: _onDragEnd,
          child: AnimatedBuilder(
            animation: widget.rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha((widget.opacity * 255).clamp(0, 255).toInt()),
                    boxShadow: _isHovered
                        ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withAlpha(50), blurRadius: 12, spreadRadius: 4)]
                        : null,
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(40), width: _isHovered ? 2 : 0),
                  ),
                  child: _isHovered
                      ? Icon(Icons.touch_app, color: Theme.of(context).colorScheme.primary.withAlpha(160), size: widget.size * 0.36)
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
