import 'dart:async';
import 'package:flutter/material.dart';
import 'page4.dart'; // Import Page4

class Page3 extends StatefulWidget {
  final int remainingTime;

  const Page3({super.key, required this.remainingTime});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> with TickerProviderStateMixin {
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
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
                const SizedBox(height: 30),

                // Question + Code
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2541),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      width: 2,
                      color: Colors.cyanAccent.withOpacity(0.7),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            children: [
                              TextSpan(
                                  text:
                                      "Question:\nWhy might this link fail in some browsers?\n"),
                              TextSpan(
                                text: "Link: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: "<a href=\"www.google.com\">Open Google</a>",
                                style: TextStyle(
                                    color: Colors.cyanAccent,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: cyanPurpleGradient,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
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
                  child: ListView(
                    children: [
                      ...[
                        "A. Missing title",
                        "B. Missing https://",
                        "C. Needs target=\"_blank\"",
                        "D. Needs button tag"
                      ].asMap().entries.map((entry) {
                        int index = entry.key;
                        String option = entry.value;
                        final selected = _selectedAnswerIndex == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: GestureDetector(
                            onTap: _isRoundActive
                                ? () => _handleSelect(index)
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: selected ? cyanPurpleGradient : null,
                                color:
                                    selected ? null : const Color(0xFF0B132B),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: selected
                                      ? Colors.cyanAccent
                                      : Colors.grey.shade700,
                                  width: 2,
                                ),
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
                                  option,
                                  style: TextStyle(
                                    color:
                                        selected ? Colors.white : Colors.white70,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

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
                                  Page4(remainingTime: _remainingTime),
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
