import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/extensions/color_extensions.dart';
import 'home_view.dart';

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
                      color: Colors.white.withAlphaFromOpacity(
                        (_isHovered || _isDragging) ? widget.opacity * 2 : widget.opacity,
                      ),
                      boxShadow: (_isHovered || _isDragging)
                          ? [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withAlphaFromOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ]
                          : null,
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withAlphaFromOpacity(0.3),
                        width: _isHovered ? 2 : 0,
                      ),
                    ),
                    child: _isHovered
                        ? Icon(
                            Icons.touch_app,
                            color: Theme.of(context).primaryColor.withAlphaFromOpacity(0.7),
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

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  bool _isLogoHovered = false;
  bool _isButtonHovered = false;
  final List<Map<String, double>> _bubblePositions = [];
  int _tappedBubbles = 0;
  bool _showEasterEgg = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateBubblePositions();
    _startAnimations();
  }

  void _generateBubblePositions() {
    final random = math.Random();
    for (int i = 0; i < 8; i++) {
      _bubblePositions.add({
        'size': random.nextDouble() * 80 + 40,
        'x': random.nextDouble() * 300,
        'y': random.nextDouble() * 600,
        'opacity': random.nextDouble() * 0.3,
      });
    }
  }

  void _onBubbleTap() {
    setState(() {
      _tappedBubbles++;
      if (_tappedBubbles >= 5 && !_showEasterEgg) {
        _showEasterEgg = true;
        _showEasterEggDialog();
      }
    });
  }

  void _showEasterEggDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Easter Egg Found!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You found the secret! Keep exploring...'),
            const SizedBox(height: 20),
            Image.asset('assets/images/logo.png', height: 100),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cool!'),
          ),
        ],
      ),
    );
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (!mounted) return;
    final currentContext = context;
    Navigator.of(currentContext).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withAlphaFromOpacity(0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Interactive draggable bubbles
                      for (final bubble in _bubblePositions)
                        DraggableBubble(
                          size: bubble['size']!,
                          initialX: bubble['x']!,
                          initialY: bubble['y']!,
                          opacity: bubble['opacity']!,
                          rotationController: _rotationController,
                          onTap: _onBubbleTap,
                        ),              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Interactive Logo
                  Center(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isLogoHovered = true),
                      onExit: (_) => setState(() => _isLogoHovered = false),
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_mainController, _pulseController]),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value * 
                                  (_isLogoHovered ? 1.1 : 1.0) * 
                                  _pulseAnimation.value,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(90),
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme.of(context).primaryColor.withAlphaFromOpacity(_isLogoHovered ? 0.5 : 0.3),
                                    blurRadius: _isLogoHovered ? 30 : 20,
                                    spreadRadius: _isLogoHovered ? 8 : 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(90),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Theme.of(context).primaryColor.withAlphaFromOpacity(0.1),
                                      child: Icon(
                                        Icons.local_hospital,
                                        size: 80,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Interactive App Name
                  MouseRegion(
                    onEnter: (_) => setState(() => _isLogoHovered = true),
                    onExit: (_) => setState(() => _isLogoHovered = false),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                              color: _isLogoHovered 
                                ? Colors.white.withAlphaFromOpacity(0.1) 
                                : Colors.transparent,
                          ),
                          child: Text(
                            'Doctor App',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withAlphaFromOpacity(_isLogoHovered ? 0.4 : 0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: _isLogoHovered ? 8 : 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_showEasterEgg) ...[
                    const SizedBox(height: 20),
                    Text(
                      '🎉 Easter Egg Found! ($_tappedBubbles bubbles)',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                  const Spacer(),
                  // Interactive Developer Info
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isLogoHovered = true),
                      onExit: (_) => setState(() => _isLogoHovered = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                              color: _isLogoHovered 
                              ? Colors.white.withAlphaFromOpacity(0.1) 
                              : Colors.transparent,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Hamza Saif',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withAlphaFromOpacity(0.2),
                                    offset: const Offset(1, 1),
                                    blurRadius: _isLogoHovered ? 5 : 3,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'FA23-BCS-153',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withAlphaFromOpacity(0.9),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Interactive Next Button with particles
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: MouseRegion(
                          onEnter: (_) => setState(() => _isButtonHovered = true),
                          onExit: (_) => setState(() => _isButtonHovered = false),
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + 
                                      (_isButtonHovered ? 0.1 : 0.0) + 
                                      (0.05 * _pulseAnimation.value),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withAlphaFromOpacity(
                                          _isButtonHovered ? 0.5 : 0.3
                                        ),
                                        blurRadius: _isButtonHovered ? 15 : 10,
                                        spreadRadius: _isButtonHovered ? 4 : 2,
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _navigateToHome,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 48, 
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Next',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (_isButtonHovered) ...[
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}