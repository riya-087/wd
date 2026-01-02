import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wd/backend/services/timer_service.dart';
import 'package:wd/screens/section_b/section%20B_part1.dart';
import 'package:wd/screens/section_b/section%20B_part2.dart';

class sectionBPart1 extends StatefulWidget {
  final String studentName;
  final String studentEmail;
  final DateTime startTime;
  final Map<String, dynamic> answersSoFar;

  const sectionBPart1({
    super.key,
    required this.studentName,
    required this.studentEmail,
    required this.startTime,
    required this.answersSoFar,
  });

  @override
  State<sectionBPart1> createState() => _sectionBPart1State();
}

class _sectionBPart1State extends State<sectionBPart1> {
  final TextEditingController codeController = TextEditingController();
  bool _hasNavigated = false;
  Timer? uiTimer; // ✅ Added UI timer

  final Gradient cyanPurpleGradient = const LinearGradient(
    colors: [Colors.cyanAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();

    // ✅ Stop any existing timer and start Section B timer
    QuizTimer().stop();
    QuizTimer().totalTime = 5 * 60;
    QuizTimer().start(
      onTick: () {
        if (mounted) setState(() {});
      },
      onFinish: () {
        if (!_hasNavigated) {
          _autoNavigateToNextQuestion();
        }
      },
    );

    // ✅ Load previously saved answer if exists
    if (widget.answersSoFar.containsKey('sectionBPreview')) {
      codeController.text = widget.answersSoFar['sectionBPreview'];
    }

    // ✅ Check if already timeout on init
    if (QuizTimer().remainingTime <= 0 && !_hasNavigated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoNavigateToNextQuestion();
      });
    }
  }

  @override
  void dispose() {
    QuizTimer().stop();
    codeController.dispose();
    super.dispose();
  }

  void _autoNavigateToNextQuestion() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    // ✅ Save current answer before moving
    widget.answersSoFar['sectionBPreview'] = codeController.text;

    // ✅ Show timeout dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B132B),
        title: const Text(
          'Time Up!',
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Section B Q1 time has expired. Moving to next question.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate to Q2
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => sectionB(
                    studentName: widget.studentName,
                    studentEmail: widget.studentEmail,
                    startTime: widget.startTime,
                    answersSoFar: widget.answersSoFar,
                  ),
                ),
              );
            },
            child: const Text(
              'Continue to Q2',
              style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = QuizTimer().remainingTime;

    // ✅ Check for timeout during rebuild
    if (remaining <= 0 && !_hasNavigated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoNavigateToNextQuestion();
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
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

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Chip(
                        backgroundColor: Colors.cyanAccent,
                        label: Text("Section B - Q1",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: remaining <= 60
                              ? const LinearGradient(
                                  colors: [Colors.redAccent, Colors.orangeAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : cyanPurpleGradient,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          remaining > 0 ? _format(remaining) : "TIME UP",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Mini Coding Task - Table Creation",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Time Limit: 5 minutes",
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B132B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.cyanAccent, width: 2),
                    ),
                    child: const Text(
                      "TASK: Write HTML code to create a table as shown in the image.",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Code and preview row
                  Expanded(
                    child: Row(
                      children: [
                        // LEFT: Cropped table image preview
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.cyanAccent, width: 1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                alignment: Alignment.topLeft,
                                child: SizedBox(
                                  width: 300,
                                  height: 100,
                                  child: Image.asset(
                                      'assets/images/table1.jpeg'),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // RIGHT: Code input
                        Expanded(
                          child: TextField(
                            controller: codeController,
                            expands: true,
                            maxLines: null,
                            enabled: remaining > 0, // ✅ Disable when time up
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace'),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF060B1E),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              hintText: remaining <= 0 ? 'Time Up' : 'Write your HTML code here...',
                              hintStyle: TextStyle(
                                color: Colors.white38,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // NEXT button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: remaining > 0 // ✅ Disable when time up
                          ? () {
                              // ✅ Save answer before navigation
                              widget.answersSoFar['sectionBPreview'] =
                                  codeController.text;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => sectionB(
                                    studentName: widget.studentName,
                                    studentEmail: widget.studentEmail,
                                    startTime: widget.startTime,
                                    answersSoFar: widget.answersSoFar,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        disabledBackgroundColor: Colors.grey.shade800, // ✅ Visual feedback
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: remaining > 0 
                              ? cyanPurpleGradient 
                              : LinearGradient(colors: [Colors.grey, Colors.grey]),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            remaining > 0 ? "NEXT" : "TIME UP",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _format(int t) {
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final s = (t % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}

// Circuit background painter
class _CircuitBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.05)
      ..strokeWidth = 1.2;

    const step = 100.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}