import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ivf_patient_app/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000))
    ..forward();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.secondary,
              AppColors.accent
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with pulse animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              ).animate(controller: _controller)
                  .scale(
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                  )
                  .fadeIn(duration: 600.ms)
                  .then()
                  .shimmer(
                    duration: 1500.ms,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
              
              const SizedBox(height: 32),
              
              // App name with slide animation
              const Text(
                'Bloom',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Color(0x40000000),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ).animate(controller: _controller)
                  .fadeIn(duration: 800.ms, delay: 300.ms)
                  .slideY(begin: 0.3, end: 0, duration: 800.ms, curve: Curves.easeOut)
                  .then()
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .tint(color: Colors.white.withValues(alpha: 0.1), duration: 2000.ms),
              
              const SizedBox(height: 8),
              
              // Tagline with fade animation
              const Text(
                'FERTILITY CARE, THOUGHTFULLY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                  color: Color(0xFFE0E7FF),
                ),
              ).animate(controller: _controller)
                  .fadeIn(duration: 800.ms, delay: 500.ms)
                  .slideY(begin: 0.3, end: 0, duration: 800.ms, curve: Curves.easeOut),
              
              const SizedBox(height: 48),
              
              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                ),
              ).animate(controller: _controller)
                  .fadeIn(duration: 600.ms, delay: 700.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
              
              const SizedBox(height: 24),
              
              // Version info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ).animate(controller: _controller)
                  .fadeIn(duration: 600.ms, delay: 900.ms)
                  .slideY(begin: 0.2, end: 0, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
