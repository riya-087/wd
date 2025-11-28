import 'dart:async';
import 'package:flutter/material.dart';
import 'page3.dart'; // Import Page3

class Question {
  final String text;
  final List<String> options;
  Question({required this.text, required this.options});
}

// Question for Page2
final Question question2 = Question(
  text: 'Which attribute is used to open a link in a new tab/window?',
  options: ['Open', 'Blank', 'Target= "Blank"', 'Newtab'],
);

class Page2 extends StatefulWidget {
  final int remainingTime; // Timer passed from Page1
  const Page2({super.key, required this.remainingTime});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> with TickerProviderStateMixin {
  late int _remainingTime;
  Timer? _timer;
  int? _selectedAnswerIndex;
  bool _isRoundActive = true;

  final Gradient cyanPurpleGradient = const LinearGradient(
    colors: [Colors.cyanAccent, Colors.purpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.remainingTime;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
        setState(() => _isRoundActive = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime() {
    final m = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingTime % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _handleSelect(int index) {
    if (!_isRoundActive) return;
    setState(() => _selectedAnswerIndex = index);
  }

  @override
  Widget build(BuildContext context) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: cyanPurpleGradient,
                      ),
                      child: Text(
                        _isRoundActive ? _formatTime() : "ROUND ENDED",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Question Card
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
                          question2.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: cyanPurpleGradient,
                        ),
                        child: const Icon(Icons.help_outline,
                            color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Options
                Expanded(
                  child: ListView.builder(
                    itemCount: question2.options.length,
                    itemBuilder: (context, index) {
                      final selected = _selectedAnswerIndex == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: GestureDetector(
                          onTap: () => _handleSelect(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: selected ? cyanPurpleGradient : null,
                              color: selected ? null : const Color(0xFF0B132B),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: selected
                                      ? Colors.cyanAccent
                                      : Colors.grey.shade700,
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: selected
                                      ? Colors.cyanAccent.withOpacity(0.4)
                                      : Colors.black26,
                                  blurRadius: selected ? 8 : 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                question2.options[index],
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

                // Bottom buttons: PREVIOUS + NEXT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // PREVIOUS
                    SizedBox(
                      width: 160,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _timer?.cancel();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.black,
                          elevation: 6,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: cyanPurpleGradient,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.arrow_back,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "PREVIOUS",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // NEXT
                    SizedBox(
                      width: 160,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _timer?.cancel();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Page3(remainingTime: _remainingTime),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.black,
                          elevation: 6,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: cyanPurpleGradient,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "NEXT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 20),
                              ],
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
