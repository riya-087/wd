import 'dart:async';
import 'package:flutter/material.dart';
import 'timer_service.dart';
import 'quiz_page4.dart';

class Question {
  final String text;
  final List<String> options;
  Question({required this.text, required this.options});
}

final Question question3 = Question(
  text: "Why might this link fail in some browsers?\n<a href=\"www.google.com\">Open Google</a>",
  options: [
    "A. Missing title",
    "B. Missing https://",
    "C. Needs target=\"_blank\"",
    "D. Needs button tag",
  ],
);


class Page3 extends StatefulWidget {
  final String studentName;
  final String studentEmail;
  final DateTime startTime;
  final Map<String, dynamic> answersSoFar;

  const Page3({
    super.key,
    required this.studentName,
    required this.studentEmail,
    required this.startTime,
    required this.answersSoFar,
  });

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  Timer? uiTimer;
  int? _selectedAnswerIndex;

  final Gradient cyanPurpleGradient = const LinearGradient(
    colors: [Colors.cyanAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
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
    setState(() => _selectedAnswerIndex = index);
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Timer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: cyanPurpleGradient,
                  ),
                  child: Text(
                    remaining > 0 ? formatTime(remaining) : "TIME UP",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Question Box
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2541),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.cyanAccent.withAlpha((0.7 * 255).round()),
                      width: 2,
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Question:\n",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: question3.text,
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Options
                Expanded(
                  child: ListView.builder(
                    itemCount: question3.options.length,
                    itemBuilder: (context, index) {
                      final selected = _selectedAnswerIndex == index;
                      return GestureDetector(
                        onTap: () => _select(index),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: selected ? cyanPurpleGradient : null,
                            color: selected ? null : const Color(0xFF0B132B),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: selected ? Colors.cyanAccent : Colors.grey.shade700,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            question3.options[index],
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white70,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("PREVIOUS"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedAnswerIndex == null) return;

                        // Save answer in answersSoFar map
                       final updatedAnswers =
    Map<String, dynamic>.from(widget.answersSoFar);

// Get or create Section A answers map
final sectionAAnswers =
    Map<String, dynamic>.from(updatedAnswers['sectionAAnswers'] ?? {});

// Save Q3
sectionAAnswers['Q3'] =
    question3.options[_selectedAnswerIndex!];

// Put back into main map
updatedAnswers['sectionAAnswers'] = sectionAAnswers;


                        // Navigate to Page4
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Page4(
                              studentName: widget.studentName,
                              studentEmail: widget.studentEmail,
                              startTime: widget.startTime,
                              answersSoFar: updatedAnswers,
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
      ),
    );
  }
}
