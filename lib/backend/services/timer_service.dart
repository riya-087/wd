import 'dart:async';

class QuizTimer {
  static final QuizTimer _instance = QuizTimer._internal();
  factory QuizTimer() => _instance;
  QuizTimer._internal();

  int totalTime = 10 * 60;
  int remainingTime = 10 * 60;
  Timer? _timer;
  Function? _onFinish;
  Function? _onTick;

  void start({Function? onFinish, Function? onTick}) {
    _timer?.cancel();
    remainingTime = totalTime;
    _onFinish = onFinish;
    _onTick = onTick;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      remainingTime--;
      if (_onTick != null) _onTick!();

      if (remainingTime <= 0) {
        t.cancel();
        if (_onFinish != null) _onFinish!();
      }
    });
  }

  // Better approach: Set timer for specific sections
  void startSectionA({Function? onFinish, Function? onTick}) {
    totalTime = 10 * 60;
    start(onFinish: onFinish, onTick: onTick);
  }

  void startSectionB({Function? onFinish, Function? onTick}) {
    totalTime = 5 * 60;
    start(onFinish: onFinish, onTick: onTick);
  }

  void stop() {
    _timer?.cancel();
  }

  void reset() {
    _timer?.cancel();
    remainingTime = totalTime;
  }
}