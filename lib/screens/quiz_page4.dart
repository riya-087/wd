import 'package:flutter/material.dart';
import 'timer_service.dart';
import 'quiz_page5.dart';

class Page4 extends StatefulWidget {
  final String studentName;
  final String studentEmail;
  final DateTime startTime;
  final Map<String, dynamic> answersSoFar;

  const Page4({
    super.key,
    required this.studentName,
    required this.studentEmail,
    required this.startTime,
    required this.answersSoFar,
  });

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  int? _selectedAnswer;

  final Gradient cyanPurpleGradient = const LinearGradient(
    colors: [Colors.cyanAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    // Restore previously selected answer if exists
    _selectedAnswer = widget.answersSoFar['Q4Index'];
  }

  String _formatTime(int t) {
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final s = (t % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _goNext() {
    if (_selectedAnswer == null) return;

    // Update answers map
    final updatedAnswers = Map<String, dynamic>.from(widget.answersSoFar);
    final sectionAAnswers =
    Map<String, dynamic>.from(updatedAnswers['sectionAAnswers'] ?? {});

sectionAAnswers['Q4'] = options[_selectedAnswer!];

updatedAnswers['sectionAAnswers'] = sectionAAnswers;
updatedAnswers['Q4Index'] = _selectedAnswer;


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Page5(
          studentName: widget.studentName,
          studentEmail: widget.studentEmail,
          startTime: widget.startTime,
          answersSoFar: updatedAnswers,
        ),
      ),
    );
  }

  void _goPrevious() {
    Navigator.pop(context);
  }

  final options = [
    "A. The type=\"password\" hides the text",
    "B. The disabled attribute blocks input",
    "C. Because it is a placeholder",
    "D. Because it needs a name attribute",
  ];

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
                // TIMER
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
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // QUESTION CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2541),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyanAccent, width: 2),
                  ),
                  child: const Text(
                    "Question:\nWhy can the user NOT type anything in the password field?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // OPTIONS
                ...options.asMap().entries.map((e) {
                  final index = e.key;
                  final text = e.value;
                  final selected = _selectedAnswer == index;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedAnswer = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: selected ? cyanPurpleGradient : null,
                          color: selected ? null : const Color(0xFF0B132B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? Colors.cyanAccent : Colors.grey.shade700,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            text,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const Spacer(),

                // PREVIOUS & NEXT BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _goPrevious,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.grey, Colors.black54],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Center(
                              child: Text(
                                "PREVIOUS",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _selectedAnswer == null ? null : _goNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: cyanPurpleGradient,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Center(
                              child: Text(
                                "NEXT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
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
}
