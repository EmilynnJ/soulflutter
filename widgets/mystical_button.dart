import 'package:flutter/material.dart';
import '../theme.dart';

class MysticalButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;
  final double? width;
  final double? height;
  final Color? color;
  final Color? textColor;

  const MysticalButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.width,
    this.height,
    this.color,
    this.textColor,
  });

  @override
  State<MysticalButton> createState() => _MysticalButtonState();
}

class _MysticalButtonState extends State<MysticalButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _scaleController.forward();
  }

  void _onTapUp() {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    Color backgroundColor;
    Color foregroundColor;
    
    if (widget.isSecondary) {
      backgroundColor = Colors.transparent;
      foregroundColor = widget.color ?? theme.colorScheme.primary;
    } else {
      backgroundColor = widget.color ?? theme.colorScheme.primary;
      foregroundColor = widget.textColor ?? theme.colorScheme.onPrimary;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: isEnabled ? (_) => _onTapDown() : null,
            onTapUp: isEnabled ? (_) => _onTapUp() : null,
            onTapCancel: isEnabled ? _onTapCancel : null,
            child: Container(
              width: widget.width,
              height: widget.height ?? 50,
              decoration: BoxDecoration(
                gradient: widget.isSecondary 
                  ? null 
                  : LinearGradient(
                      colors: [
                        backgroundColor,
                        backgroundColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                border: widget.isSecondary 
                  ? Border.all(color: foregroundColor, width: 2)
                  : null,
                borderRadius: BorderRadius.circular(25),
                boxShadow: isEnabled && !widget.isSecondary ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3 + 0.2 * _glowAnimation.value),
                    blurRadius: 8 + 4 * _glowAnimation.value,
                    spreadRadius: 2 + 2 * _glowAnimation.value,
                  ),
                ] : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? widget.onPressed : null,
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: foregroundColor,
                            ),
                          )
                        else ...[
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: foregroundColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: foregroundColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MysticalIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const MysticalIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 24,
    this.tooltip,
  });

  @override
  State<MysticalIconButton> createState() => _MysticalIconButtonState();
}

class _MysticalIconButtonState extends State<MysticalIconButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _scaleController.forward();
  }

  void _onTapUp() {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null;
    final iconColor = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: isEnabled ? (_) => _onTapDown() : null,
            onTapUp: isEnabled ? (_) => _onTapUp() : null,
            onTapCancel: isEnabled ? _onTapCancel : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: isEnabled ? [
                  BoxShadow(
                    color: iconColor.withOpacity(0.2 + 0.1 * _glowAnimation.value),
                    blurRadius: 4 + 2 * _glowAnimation.value,
                    spreadRadius: 1 + 1 * _glowAnimation.value,
                  ),
                ] : null,
              ),
              child: IconButton(
                icon: Icon(
                  widget.icon,
                  color: iconColor,
                  size: widget.size,
                ),
                onPressed: widget.onPressed,
                tooltip: widget.tooltip,
              ),
            ),
          ),
        );
      },
    );
  }
}

class MysticalFloatingActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;

  const MysticalFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  });

  @override
  State<MysticalFloatingActionButton> createState() => _MysticalFloatingActionButtonState();
}

class _MysticalFloatingActionButtonState extends State<MysticalFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 20000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotateController);

    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final fgColor = widget.foregroundColor ?? theme.colorScheme.onPrimary;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _rotateAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value * 0.1, // Subtle rotation
            child: FloatingActionButton(
              onPressed: widget.onPressed,
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              tooltip: widget.tooltip,
              child: Icon(widget.icon),
            ),
          ),
        );
      },
    );
  }
}