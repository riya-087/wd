import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wd/backend/services/timer_service.dart';
import 'package:wd/screens/section_b/section%20B_part1.dart';

class Page5 extends StatefulWidget {
  final String studentName;
  final String studentEmail;
  final DateTime startTime;
  final Map<String, dynamic> answersSoFar;

  const Page5({
    super.key,
    required this.studentName,
    required this.studentEmail,
    required this.startTime,
    required this.answersSoFar,
  });

  @override
  State<Page5> createState() => _Page5State();
}

class _Page5State extends State<Page5> {
  Timer? uiTimer;

  final Gradient cyanPurpleGradient = const LinearGradient(
    colors: [Colors.cyanAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final Map<String, String> correctPairs = {
    '<a>': 'defines a hyperlink',
    'href': 'Attribute used in <a> to link',
    '<option>': 'Drop-down option in list',
    '<div>': 'Container element for sections',
  };

  late List<String> leftTags;
  late List<String> rightAnswers;
  final Map<String, String?> userMatches = {};

  @override
  void initState() {
    super.initState();

    leftTags = correctPairs.keys.toList();
    rightAnswers = correctPairs.values.toList()..shuffle();

    for (final k in correctPairs.keys) {
      userMatches[k] = null;
    }

    uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    uiTimer?.cancel();
    super.dispose();
  }

  String _formatTime(int t) {
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final s = (t % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _nextToSectionB() {
    final Map<String, String> q5Matches = {};

    userMatches.forEach((k, v) {
      if (v != null) q5Matches[k] = v;
    });

    final sectionA =
        Map<String, dynamic>.from(widget.answersSoFar['sectionAAnswers'] ?? {});
    sectionA['Q5Matches'] = q5Matches;
    widget.answersSoFar['sectionAAnswers'] = sectionA;

    QuizTimer().stop();
    QuizTimer().startSectionB(
      onTick: () {
        if (mounted) setState(() {});
      },
      onFinish: () {},
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => sectionBPart1(
          studentName: widget.studentName,
          studentEmail: widget.studentEmail,
          startTime: widget.startTime,
          answersSoFar: widget.answersSoFar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = QuizTimer().remainingTime;

    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND
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
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // TIMER
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: remaining <= 60
                          ? const LinearGradient(
                              colors: [Colors.redAccent, Colors.orangeAccent],
                            )
                          : cyanPurpleGradient,
                    ),
                    child: Text(
                      remaining > 0 ? _formatTime(remaining) : "TIME UP",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // QUESTION
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B132B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyanAccent, width: 2),
                    ),
                    child: const Text(
                      "Match the HTML tags with their correct meanings",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔹 INSTRUCTION LABEL
                  const Text(
                    "👉 Drag each tag from the left and drop it onto its correct meaning.\n"
                    "Matched tags will change color and cannot be reused.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // DRAG & DROP AREA
                  Expanded(
                    child: Row(
                      children: [
                        // LEFT TAGS
                        Expanded(
                          child: Column(
                            children: leftTags.map((tag) {
                              final bool isMatched =
                                  userMatches[tag] != null;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Draggable<String>(
                                  data: tag,
                                  maxSimultaneousDrags:
                                      (remaining <= 0 || isMatched) ? 0 : 1,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: _box(tag, active: true),
                                  ),
                                  childWhenDragging:
                                      _box(tag, disabled: true),
                                  child: _box(
                                    tag,
                                    active: isMatched,
                                    disabled: isMatched,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // RIGHT TARGETS
                        Expanded(
                          child: Column(
                            children: rightAnswers.map((answer) {
                              return DragTarget<String>(
                                onAccept: (tag) {
                                  setState(() {
                                    userMatches[tag] = answer;
                                  });
                                },
                                builder: (_, __, ___) {
                                  final used =
                                      userMatches.containsValue(answer);

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: _box(
                                      used
                                          ? userMatches.entries
                                              .firstWhere(
                                                  (e) => e.value == answer)
                                              .key
                                          : answer,
                                      isTarget: true,
                                      active: used,
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // NAVIGATION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("PREVIOUS"),
                      ),
                      ElevatedButton(
                        onPressed: remaining > 0 ? _nextToSectionB : null,
                        child: const Text("NEXT"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _box(
    String text, {
    bool disabled = false,
    bool active = false,
    bool isTarget = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 60,
      decoration: BoxDecoration(
        gradient: active ? cyanPurpleGradient : null,
        color: active
            ? null
            : disabled
                ? Colors.grey[900]
                : const Color(0xFF060B1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? Colors.cyanAccent
              : isTarget
                  ? Colors.cyanAccent.withOpacity(0.6)
                  : Colors.white24,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: disabled ? Colors.white54 : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// BACKGROUND
class _CircuitBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.05)
      ..strokeWidth = 1.2;

    final nodePaint = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.08);

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
  bool shouldRepaint(_) => false;
}
