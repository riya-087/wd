import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wd/backend/services/timer_service.dart';
import 'package:wd/backend/services/evaluation_service.dart';
import 'package:wd/backend/services/pdf_service.dart';
import 'package:wd/backend/database_helper.dart';

class sectionB extends StatefulWidget {
  final String studentName;
  final String studentEmail;
  final DateTime startTime;
  final Map<String, dynamic> answersSoFar;

  const sectionB({
    super.key,
    required this.studentName,
    required this.studentEmail,
    required this.startTime,
    required this.answersSoFar,
  });

  @override
  State<sectionB> createState() => _sectionBState();
}

class _sectionBState extends State<sectionB> {
  final TextEditingController codeController = TextEditingController();
  bool _submitted = false;

  final Gradient cyanPurpleGradient = const LinearGradient(
    colors: [Colors.cyanAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();

    // ✅ Reset timer for Q2
    QuizTimer().stop();
    QuizTimer().totalTime = 5 * 60;
    QuizTimer().start(
      onTick: () {
        if (mounted) setState(() {});
      },
      onFinish: () {
        if (!_submitted) {
          _autoSubmit(); // ✅ Auto-submit when time expires
        }
      },
    );

    // ✅ Load previously saved answer if exists
    if (widget.answersSoFar.containsKey('sectionB')) {
      codeController.text = widget.answersSoFar['sectionB'];
    }

    // ✅ Check if already timeout on init
    if (QuizTimer().remainingTime <= 0 && !_submitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoSubmit();
      });
    }
  }

  @override
  void dispose() {
    QuizTimer().stop();
    codeController.dispose();
    super.dispose();
  }

  /// ✅ Auto-submit when timer expires
  Future<void> _autoSubmit() async {
    if (!mounted || _submitted) return;
    
    await _submit(isAutoSubmit: true);
  }

  /// ✅ Main submit function (handles both manual and auto-submit)
  Future<void> _submit({bool isAutoSubmit = false}) async {
    if (!mounted || _submitted) return;
    _submitted = true;
    QuizTimer().stop();

    final sectionBCode = codeController.text;

    // ✅ Store Section B Q2 answer
    widget.answersSoFar['sectionB'] = sectionBCode;

    // ✅ Evaluate Section A
    final sectionAMarks = EvaluationService.evaluateSectionA(widget.answersSoFar);

    // ✅ Evaluate Section B (both questions)
    final sectionBScores = EvaluationService.evaluateSectionB(widget.answersSoFar);
    final sectionBQ1Marks = sectionBScores['q1Score']!;
    final sectionBQ2Marks = sectionBScores['q2Score']!;
    final sectionBTotalMarks = sectionBScores['totalScore']!;

    // ✅ Store marks in answersSoFar (for internal use only)
    widget.answersSoFar['sectionAMarks'] = sectionAMarks;
    widget.answersSoFar['sectionBQ1Marks'] = sectionBQ1Marks;
    widget.answersSoFar['sectionBQ2Marks'] = sectionBQ2Marks;
    widget.answersSoFar['sectionBMarks'] = sectionBTotalMarks;

    // ✅ Save to database - Combine both Section B answers
    final combinedSectionBAnswer = '''
=== QUESTION 1: Table Creation (Item, Quantity, Status) ===
${widget.answersSoFar['sectionBPreview'] ?? 'Not answered'}

=== QUESTION 2: Inline CSS Background ===
$sectionBCode
''';

    await DatabaseHelper.instance.insertResult(
      name: widget.studentName,
      email: widget.studentEmail,
      sectionAScore: sectionAMarks,
      sectionAAnswers: widget.answersSoFar['sectionAAnswers'] ?? {},
      sectionBScore: sectionBTotalMarks,
      sectionBAnswer: combinedSectionBAnswer,
    );

    // ✅ Generate PDF with complete results
    await PdfService.generateFullResult(
      name: widget.studentName,
      email: widget.studentEmail,
      timestamp: DateTime.now(),
      answersSoFar: widget.answersSoFar,
    );

    if (!mounted) return;

    // ✅ Show submission dialog (different message for auto-submit)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B132B),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAutoSubmit ? Icons.timer_off : Icons.check_circle_outline,
              color: isAutoSubmit ? Colors.orangeAccent : Colors.cyanAccent,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              isAutoSubmit 
                  ? 'Time Up - Quiz Auto-Submitted!' 
                  : 'Quiz Submitted Successfully!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isAutoSubmit
                  ? 'Section B time has expired. Your answers have been automatically saved.'
                  : 'Your answers have been recorded.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Results will be evaluated and shared with you later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, color: Colors.cyanAccent, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        widget.studentName,
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.studentEmail,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thank you for participating!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text(
              "FINISH",
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
    if (remaining <= 0 && !_submitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoSubmit();
      });
    }

    return Scaffold(
      body: Stack(
        children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Chip(
                        backgroundColor: Colors.cyanAccent,
                        label: Text("Section B - Q2",
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
                    "Mini Coding Task - Inline CSS",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Time Limit: 5 minutes\nChange the page background using INLINE CSS.",
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
                      "TASK:\nUse INLINE CSS to set the background color of the page to LIGHT BLUE.",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.cyanAccent, width: 1),
                            ),
                            child: const SingleChildScrollView(
                              child: Text(
                                '''<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      background-color: yellow;
    }
  </style>
</head>
<body>
  <h1>Hello</h1>
</body>
</html>''',
                                style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontFamily: 'monospace'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                              hintText: remaining <= 0 ? 'Time Up - Auto-Submitted' : 'Write your HTML code here...',
                              hintStyle: const TextStyle(
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
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: remaining > 0 && !_submitted // ✅ Disable when time up or already submitted
                          ? () => _submit(isAutoSubmit: false)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        disabledBackgroundColor: Colors.grey.shade800,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: (remaining > 0 && !_submitted)
                              ? cyanPurpleGradient
                              : const LinearGradient(colors: [Colors.grey, Colors.grey]),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            remaining > 0 
                                ? (_submitted ? "SUBMITTING..." : "SUBMIT QUIZ")
                                : "TIME UP - AUTO-SUBMITTED",
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