import 'package:flutter/material.dart';
import 'package:wd/backend/services/timer_service.dart';
import 'section B_part1.dart';

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

  final Gradient cyanPurpleGradient = const LinearGradient(
    colors: [Colors.cyanAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();

    QuizTimer().stop();
    QuizTimer().totalTime = 5 * 60;
    QuizTimer().start(onTick: () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    QuizTimer().stop();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = QuizTimer().remainingTime;

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
                    "Mini Coding Task ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Time Limit: 5 minutes.",
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
                      "TASK: Write a code to create a table as shown below.",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
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
                                  width: 300, // actual image width
                                  height: 100, // actual image height
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

                  // NEXT button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
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
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: cyanPurpleGradient,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            "NEXT",
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
