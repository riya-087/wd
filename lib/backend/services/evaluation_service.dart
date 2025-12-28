class EvaluationService {
  static int evaluateSectionA(Map<String, dynamic> answers) {
    int score = 0;

    if (answers['Q1'] == 'GET') score++;
    if (answers['Q2'] == 'C. Required') score++;
    if (answers['Q3'] == 'A. For') score++;
    if (answers['Q4'] == 'C. id') score++;
    if (answers['Q6'] == 'C. iframe') score++;
    if (answers['Q7'] == 'A. src') score++;
    if (answers['Q8'] == 'D. <section>') score++;
    if (answers['Q9'] == 'B. <hr>') score++;
    if (answers['Q10'] == 'A. action') score++;
    // Q5 (matching)
    final correctMatches = {
  '<a>': 'defines a hyperlink',
    'href': 'Attribute used in <a> to link',
    '<option>': 'Drop-down option in list',
    '<div>': 'Container element for sections',
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
