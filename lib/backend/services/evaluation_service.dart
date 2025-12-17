class EvaluationService {
  static int evaluateSectionA(Map<String, dynamic> answers) {
    int score = 0;

    if (answers['Q1'] == 'GET') score++;
    if (answers['Q2'] == 'Target= "Blank"') score++;
    if (answers['Q3'] == 'B. Missing https://') score++;
    if (answers['Q4'] == 'D. Because it needs a name attribute') score++;

    // Q5 (matching)
    final correctMatches = {
      '<html>': 'HyperText Markup Language',
      '<head>': 'Metadata Container',
      '<body>': 'Visible Page Content',
      '<title>': 'Browser Tab Name',
    };

    final userMatches = (answers['Q5Matches'] as Map<String, dynamic>?) ?? {};
    userMatches.forEach((k, v) {
      if (correctMatches[k] == v) score++;
    });

    return score;
  }

  static int evaluateSectionB(String code) {
    final lowerCode = code.toLowerCase();
    return lowerCode.contains('background-color') && lowerCode.contains('lightblue') ? 10 : 0;
  }
}
