class QuizAnswerStore {
  static final QuizAnswerStore _instance = QuizAnswerStore._internal();
  factory QuizAnswerStore() => _instance;
  QuizAnswerStore._internal();

  /// Section A answers (Q1–Q10)
  final Map<String, dynamic> sectionAAnswers = {};

  /// Section B code answers
  final Map<String, String> sectionBAnswers = {};

  void clear() {
    sectionAAnswers.clear();
    sectionBAnswers.clear();
  }
}
