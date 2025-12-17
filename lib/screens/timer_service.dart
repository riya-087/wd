import 'dart:async';

class QuizTimer {
  static final QuizTimer _instance = QuizTimer._internal();
  factory QuizTimer() => _instance;
  QuizTimer._internal();

  int totalTime = 10 * 60;
  int remainingTime = 10 * 60;
  Timer? _timer;

  void start({Function? onFinish, Function? onTick}) {
    _timer?.cancel();
    remainingTime = totalTime;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      remainingTime--;
      if (onTick != null) onTick();

      if (remainingTime <= 0) {
        t.cancel();
        if (onFinish != null) onFinish();
      }
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
