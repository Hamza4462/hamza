import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedBubble extends StatefulWidget {
  final double size;
  final double initialX;
  final double initialY;
  final double opacity;
  final AnimationController rotationController;
  final VoidCallback? onTap;

  const AnimatedBubble({
    required this.size,
    required this.initialX,
    required this.initialY,
    required this.opacity,
    required this.rotationController,
    this.onTap,
    super.key,
  });

  @override
  State<AnimatedBubble> createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<AnimatedBubble> with SingleTickerProviderStateMixin {
  late double _x;
  late double _y;
  bool _isDragging = false;
  bool _isHovered = false;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _x = widget.initialX;
    _y = widget.initialY;
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(widget.rotationController);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _x += details.delta.dx;
      _y += details.delta.dy;
      if (!_isDragging) {
        _isDragging = true;
        _scaleController.forward();
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _scaleController.reverse();
    });
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
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) => _scaleController.reverse(),
          onTapCancel: () => _scaleController.reverse(),
          onTap: widget.onTap,
          onPanUpdate: _onDragUpdate,
          onPanEnd: _onDragEnd,
          child: AnimatedBuilder(
            animation: Listenable.merge([widget.rotationController, _scaleController]),
            builder: (context, child) {
              final scale = 1.0 + (_scaleController.value * 0.2);
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: Transform.scale(
                  scale: scale,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(
                        ((_isHovered || _isDragging) ? widget.opacity * 2 : widget.opacity * 255).round(),
                      ),
                      boxShadow: (_isHovered || _isDragging)
                          ? [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withAlpha(77), // 0.3 * 255
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ]
                          : null,
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withAlpha(77), // 0.3 * 255
                        width: _isHovered ? 2 : 0,
                      ),
                    ),
                    child: _isHovered
                        ? Icon(
                            Icons.touch_app,
                            color: Theme.of(context).primaryColor.withAlpha(179), // 0.7 * 255
                            size: widget.size * 0.4,
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool enableInteraction;
  final int numberOfBubbles;
  final double maxBubbleSize;
  final bool darkMode;

  const AnimatedBackground({
    required this.child,
    this.enableInteraction = true,
    this.numberOfBubbles = 8,
    this.maxBubbleSize = 120,
    this.darkMode = false,
    super.key,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  final List<Map<String, double>> _bubblePositions = [];

  bool _positionsGenerated = false;

  @override
  void initState() {
    super.initState();
    try {
      _setupAnimations();
    } catch (e) {
      debugPrint('Animation setup error: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_positionsGenerated) {
      _generateBubblePositions();
      _positionsGenerated = true;
    }
  }

  void _generateBubblePositions() {
    final size = MediaQuery.of(context).size;
    final random = math.Random();
    for (int i = 0; i < widget.numberOfBubbles; i++) {
      _bubblePositions.add({
        'size': random.nextDouble() * (widget.maxBubbleSize - 40) + 40,
        'x': random.nextDouble() * size.width,
        'y': random.nextDouble() * size.height,
        'opacity': random.nextDouble() * 0.3,
      });
    }
  }

  void _setupAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: widget.darkMode
              ? [
                  Theme.of(context).primaryColor.withAlpha(204), // 0.8 * 255
                  Theme.of(context).primaryColor.withAlpha(153), // 0.6 * 255
                  Theme.of(context).primaryColor.withAlpha(102), // 0.4 * 255
                ]
              : [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withAlpha(204), // 0.8 * 255
                  Colors.white,
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          if (widget.enableInteraction)
              for (final bubble in _bubblePositions)
                AnimatedBubble(
                  size: bubble['size']!,
                  initialX: bubble['x']!,
                  initialY: bubble['y']!,
                  opacity: bubble['opacity']!,
                  rotationController: _rotationController,
                ),
          widget.child,
        ],
      ),
    );
  }
}