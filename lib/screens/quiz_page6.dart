import 'dart:async';
import 'package:flutter/material.dart';
import 'timer_service.dart';
import 'quiz_page7.dart';

class Question {
  final String text;
  final List<String> options;
  Question({required this.text, required this.options});
}

final Question question6 = Question(
  text: 'Which tag is used to embed a webpage inside another webpage?',
  options: ['<frame>', '<embed>', 'iframe', '<bject>'],
);

class Page6 extends StatefulWidget {
  final String studentName;
  final String studentEmail;
  final DateTime startTime;
  final Map<String, dynamic> answersSoFar;

  const Page6({
    super.key,
    required this.studentName,
    required this.studentEmail,
    required this.startTime,
    required this.answersSoFar,
  });

  @override
  State<Page6> createState() => _Page6State();
}

class _Page6State extends State<Page6> {
  Timer? uiTimer;
  int? _selectedAnswer;

  final Gradient cyanPurpleGradient = const LinearGradient(
    colors: [Colors.cyanAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();

    // UI Timer for updating display
    uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    uiTimer?.cancel();
    super.dispose();
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

    return Scaffold(
      body: Stack(
        children: [
          // Technical circuit background
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

          // Diagonal neon highlights
          Positioned(
            top: -160,
            left: -250,
            child: Transform.rotate(
              angle: -0.45,
              child: Container(
                height: 340,
                width: 900,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyanAccent.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -200,
            right: -260,
            child: Transform.rotate(
              angle: -0.45,
              child: Container(
                height: 380,
                width: 900,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purpleAccent.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Timer
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: cyanPurpleGradient,
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

                  // Question card
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B132B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyanAccent, width: 2),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            question6.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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

                  // Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: question6.options.length,
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
                                  question6.options[index],
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

                  // Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("PREVIOUS"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final Map<String, dynamic> answersSoFar =
                              widget.answersSoFar;

                          if (_selectedAnswer != null) {
                            answersSoFar['sectionAAnswers']['Q6'] =
                                question6.options[_selectedAnswer!];
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Page7(
                                studentName: widget.studentName,
                                studentEmail: widget.studentEmail,
                                startTime: widget.startTime,
                                answersSoFar: answersSoFar,
                              ),
                            ),
                          );
                        },
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

// Technical circuit pattern painter (same as QuizPage1)
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

    // Vertical and horizontal lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Nodes
    for (double x = step / 2; x < size.width; x += step) {
      for (double y = step / 2; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 3, nodePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
