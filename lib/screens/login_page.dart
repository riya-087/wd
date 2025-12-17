import 'package:flutter/material.dart';
import 'quiz_page1.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _startQuiz() {
    if (_formKey.currentState!.validate()) {
      final studentName = _nameController.text.trim();
      final studentEmail = _emailController.text.trim();
      final startTime = DateTime.now();

     Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => QuizPage1(
      studentName: studentName,
      studentEmail: studentEmail,
      startTime: startTime,
    ),
  ),
);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "WebArena TagMode",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v!.trim().isEmpty ? "Enter your name" : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v!.trim().isEmpty) return "Enter your email";
                        if (!v.contains("@") || !v.contains(".")) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _startQuiz,
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            "Start",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
