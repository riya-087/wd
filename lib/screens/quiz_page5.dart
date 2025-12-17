import 'package:flutter/material.dart';
import 'timer_service.dart';
import 'section B.dart';

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
  final Gradient cyanPurpleGradient = const LinearGradient(
    colors: [Colors.cyanAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final Map<String, String> correctPairs = {
    '<html>': 'HyperText Markup Language',
    '<head>': 'Metadata Container',
    '<body>': 'Visible Page Content',
    '<title>': 'Browser Tab Name',
  };

  late List<String> leftTags;
  late List<String> rightAnswers;
  final Map<String, String?> userMatches = {};

  @override
  void initState() {
    super.initState();
    leftTags = correctPairs.keys.toList();
    rightAnswers = correctPairs.values.toList()..shuffle();

    // Restore previous matches safely
    final prevMatches = widget.answersSoFar['Q5Matches'];
    if (prevMatches != null && prevMatches is Map) {
      prevMatches.forEach((k, v) {
        userMatches[k.toString()] = v?.toString();
      });
    } else {
      for (var k in correctPairs.keys) userMatches[k] = null;
    }
  }

  int get score {
    int s = 0;
    userMatches.forEach((k, v) {
      if (v != null && correctPairs[k] == v) s++;
    });
    return s;
  }

  void _nextToSectionB() {
    // 1️⃣ Ensure Q5Matches is a proper Map<String, String>
    final Map<String, String> q5Matches =
        Map<String, String>.from(widget.answersSoFar['Q5Matches'] ?? {});

    // 2️⃣ Save current drag & drop matches into Q5Matches
    userMatches.forEach((key, value) {
      if (value != null) q5Matches[key] = value;
    });

    // 3️⃣ Update Section A answers safely
    final sectionA = Map<String, dynamic>.from(widget.answersSoFar['sectionAAnswers'] ?? {});
    sectionA['Q5'] = q5Matches;
    widget.answersSoFar['sectionAAnswers'] = sectionA;

    // 4️⃣ Update Q5Matches in root map for reference
    widget.answersSoFar['Q5Matches'] = q5Matches;

    // 5️⃣ Stop current timer and start Section B timer
    QuizTimer().stop();
    QuizTimer().totalTime = 5 * 60; // 5 minutes for Section B
    QuizTimer().start();

    // 6️⃣ Navigate to Section B
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Page6(
          studentName: widget.studentName,
          studentEmail: widget.studentEmail,
          startTime: DateTime.now(),
          answersSoFar: widget.answersSoFar,
        ),
      ),
    );
  }

  void _previousPage() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final remaining = QuizTimer().remainingTime;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B132B), Color(0xFF1C2541)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Timer
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: cyanPurpleGradient,
                    ),
                    child: Text(
                      _formatTime(remaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Question card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2541),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyanAccent, width: 2),
                  ),
                  child: const Text(
                    "Question:\nMatch the HTML tags with their correct meanings.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Drag & Drop area
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: leftTags.map((tag) {
                            final locked = userMatches[tag] != null;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Draggable<String>(
                                data: tag,
                                maxSimultaneousDrags: locked ? 0 : 1,
                                feedback: _dragBox(tag, active: true),
                                childWhenDragging: _dragBox(tag, disabled: true),
                                child: _dragBox(tag, disabled: locked),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: rightAnswers.map((answer) {
                            final used = userMatches.containsValue(answer);
                            return DragTarget<String>(
                              onAccept: (tag) {
                                setState(() {
                                  userMatches[tag] = answer;
                                });
                              },
                              builder: (_, __, ___) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: used ? cyanPurpleGradient : null,
                                    color: used ? null : const Color(0xFF0B132B),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.cyanAccent, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      used
                                          ? userMatches.entries.firstWhere((e) => e.value == answer).key
                                          : answer,
                                      style: TextStyle(
                                        color: used ? Colors.white : Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
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

                const SizedBox(height: 16),

                // Previous & Next buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _previousPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text("PREVIOUS"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextToSectionB,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cyanPurpleGradient.colors.last,
                        ),
                        child: const Text("NEXT"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dragBox(String text, {bool disabled = false, bool active = false}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: active ? cyanPurpleGradient : null,
        color: disabled ? Colors.grey[800] : const Color(0xFF0B132B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.cyanAccent, width: 2),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: disabled ? Colors.white38 : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatTime(int t) {
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final s = (t % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}
