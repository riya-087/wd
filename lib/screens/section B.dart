import 'package:flutter/material.dart';
import 'timer_service.dart';
import '../backend/services/evaluation_service.dart';
import '../backend/services/pdf_service.dart';
import '../backend/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Page6 extends StatefulWidget {
  final String studentName;
  final String studentEmail;
  final DateTime startTime;
  final Map<String, dynamic> answersSoFar; // Unified map containing all previous answers

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
  final TextEditingController codeController = TextEditingController();
  bool _submitted = false;

  final Gradient cyanPurpleGradient = const LinearGradient(
    colors: [Colors.cyanAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Correct answers for Section A (MCQs & Matching)
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
    QuizTimer().totalTime = 5 * 60; // 5 minutes for Section B
    QuizTimer().start(
      onTick: () {
        if (mounted) setState(() {});
      },
      onFinish: () => _submit(fromTimer: true),
    );

    // Restore previous Section B answer if exists
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

  Future<void> _submit({bool fromTimer = false}) async {
    if (!mounted || _submitted) return;
    _submitted = true;
    QuizTimer().stop();

    final sectionBCode = codeController.text;
    int sectionBMarks = 0;

    // ===== Evaluate Section B =====
    try {
      sectionBMarks = EvaluationService.evaluateSectionB(sectionBCode);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Evaluation failed: $e')),
      );
      _submitted = false;
      return;
    }
    // ===== Evaluate Section A =====
final sectionAMarks =
    EvaluationService.evaluateSectionA(widget.answersSoFar);

widget.answersSoFar['sectionAMarks'] = sectionAMarks;


    // Update unified answers map
    widget.answersSoFar['sectionB'] = sectionBCode;
    widget.answersSoFar['sectionBMarks'] = sectionBMarks;

    // ===== Insert into Database =====
      // ===== Insert into Database =====
try {
  await DatabaseHelper.instance.insertResult(
  name: widget.studentName,
  email: widget.studentEmail,
  sectionAScore: widget.answersSoFar['sectionAMarks'],
  sectionAAnswers: widget.answersSoFar['sectionAAnswers'] ?? {},
  sectionBScore: sectionBMarks,
  sectionBAnswer: sectionBCode,
);

} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Database insert failed: $e')),
  );
  _submitted = false;
  return;
}


    // ===== Generate PDF and save (no auto-open) =====
  try {
    final pdfPath = await PdfService.generateFullResult(
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

    if (pdfPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF saved at: $pdfPath")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF generation failed: $e')),
    );
  }

    // ===== Success Dialog =====
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Exam Submitted"),
        content: Text(
          fromTimer
              ? "Time up! Exam auto-submitted.\nMarks: $sectionBMarks / 10"
              : "Section B submitted successfully.\nMarks: $sectionBMarks / 10",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B132B), Color(0xFF1C2541)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // HEADER: Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Chip(
                      backgroundColor: Colors.cyanAccent,
                      label: Text("Section B", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: cyanPurpleGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _format(remaining),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  "Mini Coding Task (CSS)",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Time Limit: 5 minutes\nChange the page background using INLINE CSS.",
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // TASK CARD
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2541),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.cyanAccent, width: 2),
                  ),
                  child: const Text(
                    "TASK:\nUse INLINE CSS to set the background color of the page to LIGHT BLUE.",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // CODE AREA
                Expanded(
                  child: Row(
                    children: [
                      // LEFT: Example code (read-only)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.cyanAccent, width: 1),
                          ),
                          child: const SingleChildScrollView(
                            child: Text(
                              '''<!DOCTYPE html>
<html>
<head>
  <style>
    body { background-color: #F5F5F5; }
  </style>
</head>
<body>
  <h1>Hello</h1>
</body>
</html>''',
                              style: TextStyle(color: Colors.greenAccent, fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // RIGHT: Student input
                      Expanded(
                        child: TextField(
                          controller: codeController,
                          expands: true,
                          maxLines: null,
                          style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF0B132B),
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

                // SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _submit(fromTimer: false),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: cyanPurpleGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          "SUBMIT SECTION B",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
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

  String _format(int t) {
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final s = (t % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}
