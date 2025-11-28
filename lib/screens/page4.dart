import 'dart:async';
import 'package:flutter/material.dart';

class Page4 extends StatefulWidget {
  final int remainingTime;

  const Page4({super.key, required this.remainingTime});

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> with TickerProviderStateMixin {
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
    final screenHeight = MediaQuery.of(context).size.height;

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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Question + Image
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2541),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      width: 2,
                      color: Colors.cyanAccent.withOpacity(0.7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Question:\nWhy can the user NOT type anything in the password field?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/password_field.png',
                          fit: BoxFit.contain,
                          height: screenHeight * 0.18,
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Options
                ...[
                  "A. The type=\"password\" hides the text",
                  "B. The disabled attribute blocks input",
                  "C. Because it is a placeholder",
                  "D. Because it needs a name attribute",
                ].asMap().entries.map((entry) {
                  int index = entry.key;
                  String option = entry.value;
                  final selected = _selectedAnswerIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: GestureDetector(
                      onTap: _isRoundActive ? () => _handleSelect(index) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: selected ? cyanPurpleGradient : null,
                          color: selected ? null : const Color(0xFF0B132B),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: selected ? Colors.cyanAccent : Colors.grey.shade700,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            option,
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
                }).toList(),

                const Spacer(),

                // Bottom buttons
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
                                Icon(Icons.arrow_back, color: Colors.white, size: 20),
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
                          // TODO: navigate to next page
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
                                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
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
