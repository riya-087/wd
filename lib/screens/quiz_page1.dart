import 'dart:async';
import 'package:flutter/material.dart';
import 'timer_service.dart';
import 'quiz_page2.dart';

class Question {
  final String text;
  final List<String> options;
  Question({required this.text, required this.options});
}

final Question question1 = Question(
  text: 'What is the default method of a form if not specified?',
  options: ['GET', 'POST', 'PUT', 'SEND'],
);

class QuizPage1 extends StatefulWidget {
  final String studentName;
  final String studentEmail;
  final DateTime startTime;

  const QuizPage1({
    super.key,
    required this.studentName,
    required this.studentEmail,
    required this.startTime,
  });

  @override
  State<QuizPage1> createState() => _QuizPage1State();
}

class _QuizPage1State extends State<QuizPage1> {
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
    uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    QuizTimer().start();
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2541),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      width: 2,
                      color: Colors.cyanAccent.withOpacity(0.7),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          question1.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: cyanPurpleGradient,
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: question1.options.length,
                    itemBuilder: (context, index) {
                      final selected = _selectedAnswer == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: GestureDetector(
                          onTap: () => _select(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: selected ? cyanPurpleGradient : null,
                              color: selected ? null : const Color(0xFF0B132B),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: selected
                                    ? Colors.cyanAccent
                                    : Colors.grey.shade700,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                question1.options[index],
                                style: TextStyle(
                                  color: selected ? Colors.white : Colors.white70,
                                  fontSize: 17,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("PREVIOUS"),
                    ),
                    ElevatedButton(
                    
                      onPressed: () {
 final Map<String, dynamic> answersSoFar = {
  'sectionAAnswers': <String, String>{},
};

if (_selectedAnswer != null) {
  answersSoFar['sectionAAnswers']['Q1'] =
      question1.options[_selectedAnswer!];
}

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => Page2(
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
