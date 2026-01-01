import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:wd/screens/section_a/quiz_page1.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;

  final Gradient cyanPurpleGradient = const LinearGradient(
    colors: [Colors.cyanAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  void _startQuiz() {
    if (_formKey.currentState!.validate()) {
      final studentName = _nameController.text.trim();
      final studentEmail = _emailController.text.trim();
      final startTime = DateTime.now();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizPage1(
            studentName: studentName,
            studentEmail: studentEmail,
            startTime: startTime,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated particle background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticleBackgroundPainter(_animationController.value),
                size: Size.infinite,
              );
            },
          ),

          // Glassmorphic overlay for depth
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0A0F23).withOpacity(0.7),
                  const Color(0xFF020617).withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Floating orbs
          ...List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final offset = _animationController.value * 2 * math.pi;
                final x = math.sin(offset + index * 1.2) * 50 + 
                         (index * MediaQuery.of(context).size.width / 6);
                final y = math.cos(offset + index * 0.8) * 80 + 
                         (index * MediaQuery.of(context).size.height / 6);
                
                return Positioned(
                  left: x,
                  top: y,
                  child: Container(
                    width: 120 + (index * 20),
                    height: 120 + (index * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (index % 2 == 0 ? Colors.cyanAccent : Colors.purpleAccent)
                              .withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Login form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1f3a).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => cyanPurpleGradient
                              .createShader(bounds),
                          child: const Text(
                            "WebArena TagMode",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Enter your details to begin",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.cyanAccent,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.redAccent,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.redAccent,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (v) =>
                              v!.trim().isEmpty ? "Enter your name" : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.cyanAccent,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.redAccent,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.redAccent,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (v) {
                            if (v!.trim().isEmpty) return "Enter your email";
                            if (!v.contains("@") || !v.contains(".")) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _startQuiz,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: cyanPurpleGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  "Start Quiz",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParticleBackgroundPainter extends CustomPainter {
  final double animationValue;
  final math.Random random = math.Random(42);

  ParticleBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Dark background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF020617),
    );

    // Draw particles
    for (int i = 0; i < 80; i++) {
      final seed = i * 0.123;
      final x = (random.nextDouble() * size.width + 
                animationValue * 50 * math.sin(seed)) % size.width;
      final y = (random.nextDouble() * size.height + 
                animationValue * 30 * math.cos(seed)) % size.height;
      
      final size1 = 1.5 + random.nextDouble() * 2.5;
      final opacity = 0.3 + random.nextDouble() * 0.4;
      
      final paint = Paint()
        ..color = (i % 3 == 0 
            ? Colors.cyanAccent 
            : i % 3 == 1 
              ? Colors.purpleAccent 
              : Colors.white)
            .withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), size1, paint);
    }

    // Draw connecting lines between nearby particles
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i < 30; i++) {
      final seed1 = i * 0.123;
      final seed2 = (i + 1) * 0.123;
      
      final x1 = (random.nextDouble() * size.width + 
                 animationValue * 50 * math.sin(seed1)) % size.width;
      final y1 = (random.nextDouble() * size.height + 
                 animationValue * 30 * math.cos(seed1)) % size.height;
      
      final x2 = (random.nextDouble() * size.width + 
                 animationValue * 50 * math.sin(seed2)) % size.width;
      final y2 = (random.nextDouble() * size.height + 
                 animationValue * 30 * math.cos(seed2)) % size.height;
      
      final distance = math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
      
      if (distance < 150) {
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(ParticleBackgroundPainter oldDelegate) => true;
}