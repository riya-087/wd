import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wd/backend/services/timer_service.dart';
import 'package:wd/screens/section_b/section%20B_part1.dart';
import 'quiz_page8.dart';

class Question {
  final String text;
  final List<String> options;
  Question({required this.text, required this.options});
}

final Question question7 = Question(
  text: 'Which input type hides the characters entered in the Password field?',
  options: ['text', 'hidden', 'secure', 'password'],
);

class Page7 extends StatefulWidget {
  final String studentName;
  final String studentEmail;
  final DateTime startTime;
  final Map<String, dynamic> answersSoFar;

  const Page7({
    super.key,
    required this.studentName,
    required this.studentEmail,
    required this.startTime,
    required this.answersSoFar,
  });

  @override
  State<Page7> createState() => _Page7State();
}

class _Page7State extends State<Page7> {
  Timer? uiTimer;
  int? _selectedAnswer;
  bool _hasNavigated = false;

  final Gradient cyanPurpleGradient = const LinearGradient(
    colors: [Colors.cyanAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    
    // UI Timer for updating display only
    uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    // Check if already timeout
    if (QuizTimer().remainingTime <= 0 && !_hasNavigated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoNavigateToSectionB();
      });
    }
  }

  @override
  void dispose() {
    uiTimer?.cancel();
    super.dispose();
  }

  void _autoNavigateToSectionB() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    
    final Map<String, dynamic> answersSoFar = widget.answersSoFar;
    if (_selectedAnswer != null) {
      answersSoFar['sectionAAnswers']['Q7'] = question7.options[_selectedAnswer!];
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B132B),
        title: const Text('Section A Time Up!', 
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: const Text('Section A time has expired. Moving to Section B.', 
          style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(
                  builder: (_) => sectionBPart1(
                    studentName: widget.studentName, 
                    studentEmail: widget.studentEmail, 
                    startTime: widget.startTime, 
                    answersSoFar: answersSoFar
                  ),
                ), 
                (route) => route.isFirst
              );
            },
            child: const Text('Continue to Section B', 
              style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _select(int index) {
    if (QuizTimer().remainingTime <= 0) return;
    setState(() => _selectedAnswer = index);
  }

  String formatTime(int t) {
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final s = (t % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final remaining = QuizTimer().remainingTime;

    // Check for timeout during rebuild
    if (remaining <= 0 && !_hasNavigated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoNavigateToSectionB();
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A0F23), Color(0xFF020617)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          CustomPaint(
            size: Size.infinite,
            painter: _CircuitBackgroundPainter(),
          ),

          // CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Timer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: remaining <= 60
                          ? const LinearGradient(
                              colors: [Colors.redAccent, Colors.orangeAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : cyanPurpleGradient,
                    ),
                    child: Text(
                      remaining > 0 ? formatTime(remaining) : "TIME UP",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // QUESTION CARD
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B132B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyanAccent, width: 2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question7.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 📸 IMAGE — LEFT ALIGNED, FULLY VISIBLE
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Image.asset(
                                  'assets/images/password_field.png',
                                  height: 150,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: cyanPurpleGradient,
                          ),
                          child: const Icon(Icons.flash_on, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // OPTIONS
                  Expanded(
                    child: ListView.builder(
                      itemCount: question7.options.length,
                      itemBuilder: (context, index) {
                        final selected = _selectedAnswer == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: GestureDetector(
                            onTap: () => _select(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: selected ? cyanPurpleGradient : null,
                                color: selected ? null : const Color(0xFF060B1E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? Colors.cyanAccent
                                      : Colors.white24,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  question7.options[index],
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // NAVIGATION - FIXED: Added timeout check
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("PREVIOUS"),
                      ),
                      ElevatedButton(
                        onPressed: remaining > 0  // ✅ CRITICAL FIX: Added timeout check
                            ? () {
                                final Map<String, dynamic> answersSoFar =
                                    widget.answersSoFar;

                                if (_selectedAnswer != null) {
                                  answersSoFar['sectionAAnswers']['Q7'] =
                                      question7.options[_selectedAnswer!];
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Page8(
                                      studentName: widget.studentName,
                                      studentEmail: widget.studentEmail,
                                      startTime: widget.startTime,
                                      answersSoFar: answersSoFar,
                                    ),
                                  ),
                                );
                              }
                            : null,  // ✅ Disable button when time is up
                        child: const Text("NEXT"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// BACKGROUND PAINTER
class _CircuitBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.05)
      ..strokeWidth = 1.2;

    final nodePaint = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    const step = 100.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    for (double x = step / 2; x < size.width; x += step) {
      for (double y = step / 2; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 3, nodePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}