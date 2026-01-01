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

  final Map<String, String> correctAnswersMap = {
    'Q1': 'GET',
    'Q2': 'POST',
    'Q3': 'PUT',
    'Q4': 'D. Because it needs a name attribute',
    'Q5': 'Option B',
  };

  @override
  void initState() {
    super.initState();

    QuizTimer().stop();
    QuizTimer().totalTime = 5 * 60;
    QuizTimer().start(
      onTick: () {
        if (mounted) setState(() {});
      },
      onFinish: () => _submit(),
    );

    if (widget.answersSoFar.containsKey('sectionB')) {
      codeController.text = widget.answersSoFar['sectionB'];
    }
  }

  @override
  void dispose() {
    QuizTimer().stop();
    codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!mounted || _submitted) return;
    _submitted = true;
    QuizTimer().stop();

    final sectionBCode = codeController.text;
    final sectionBMarks = EvaluationService.evaluateSectionB(sectionBCode);
    final sectionAMarks =
        EvaluationService.evaluateSectionA(widget.answersSoFar);

    widget.answersSoFar['sectionAMarks'] = sectionAMarks;
    widget.answersSoFar['sectionB'] = sectionBCode;
    widget.answersSoFar['sectionBMarks'] = sectionBMarks;

    await DatabaseHelper.instance.insertResult(
      name: widget.studentName,
      email: widget.studentEmail,
      sectionAScore: sectionAMarks,
      sectionAAnswers: widget.answersSoFar['sectionAAnswers'] ?? {},
      sectionBScore: sectionBMarks,
      sectionBAnswer: sectionBCode,
    );

    await PdfService.generateFullResult(
      name: widget.studentName,
      email: widget.studentEmail,
      timestamp: DateTime.now(),
      sectionA: {
        'correctAnswers': correctAnswersMap,
        'userAnswers': widget.answersSoFar['sectionAAnswers'] ?? {},
        'marks': sectionAMarks,
      },
      sectionB: {
        'correctAnswer': '<body style="background-color: lightblue">',
        'userAnswer': sectionBCode,
        'marks': sectionBMarks,
      },
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B132B),
        content: const Text(
          "Your quiz has been submitted.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = QuizTimer().remainingTime;

    return Scaffold(
      body: Stack(
        children: [
          // ===== BACKGROUND SAME AS sectionBPart1 =====
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
                        label: Text("Section B",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: cyanPurpleGradient,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          _format(remaining),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Mini Coding Task (CSS)",
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
                      border:
                          Border.all(color: Colors.cyanAccent, width: 2),
                    ),
                    child: const Text(
                      "TASK:\nUse INLINE CSS to set the background color of the page to LIGHT BLUE.",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        // LEFT: Preview code box (just like Part1)
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
<head></head>
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
                        // RIGHT: Code input
                        Expanded(
                          child: TextField(
                            controller: codeController,
                            expands: true,
                            maxLines: null,
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace'),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF060B1E),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
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
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.zero),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: cyanPurpleGradient,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            "SUBMIT SECTION B",
                            style: TextStyle(
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

// Background painter (same as Part1)
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
