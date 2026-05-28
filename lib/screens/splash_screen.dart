import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget next;
  final Duration minDuration;

  const SplashScreen({
    super.key,
    required this.next,
    this.minDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _logo;
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _logo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: 1.0,
    );
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(widget.minDuration);
    if (!mounted) return;
    await _fade.reverse();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.next,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  void dispose() {
    _logo.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fade,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [
                      cs.surface,
                      cs.surfaceContainerHighest,
                      cs.primary.withOpacity(.35),
                    ]
                  : [
                      cs.primaryContainer,
                      cs.primary,
                      cs.tertiary,
                    ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _logo,
                    curve: Curves.elasticOut,
                  ),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _logo,
                      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: dark ? cs.surface : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.25),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🎯',
                          style: TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _logo,
                    curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                  )),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _logo,
                      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'LingoCode',
                          style: TextStyle(
                            color: dark ? cs.onSurface : Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'English · Python',
                          style: TextStyle(
                            color: (dark ? cs.onSurfaceVariant : Colors.white).withOpacity(.85),
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 64),
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _logo,
                    curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
                  ),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                          dark ? cs.primary : Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
