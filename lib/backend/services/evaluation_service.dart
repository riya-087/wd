class EvaluationService {
  // Centralized correct answers for Section A
  static const Map<String, String> correctAnswers = {
    'Q1': 'GET',
    'Q2': 'Required',
    'Q3': 'For',
    'Q4': 'id',
    'Q6': 'iframe',
    'Q7': 'password',
    'Q8': '<section>',
    'Q9': '<hr>',
    'Q10': 'action',
  };

  // Correct matches for Q5 (drag-drop)
  static const Map<String, String> correctQ5Matches = {
    '<a>': 'defines a hyperlink',
    'href': 'Attribute used in <a> to link',
    '<option>': 'Drop-down option in list',
    '<div>': 'Container element for sections',
  };

  // EXACT correct answer for Section B Question 1 (Table)
  static const String correctTableCode = '''<table border="1">
  <tr>
    <th>Item</th>
    <th>Quantity</th>
    <th>Status</th>
  </tr>
  <tr>
    <td>Module A</td>
    <td>12</td>
    <td>Ready</td>
  </tr>
  <tr>
    <td>Module B</td>
    <td>05</td>
    <td>Wait</td>
  </tr>
  <tr>
    <td>Module B</td>
    <td></td>
    <td></td>
  </tr>
</table>''';

  // EXACT correct answer for Section B Question 2 (Inline CSS)
  static const String correctCSSCode = '''<!DOCTYPE html>
<html>
<head></head>
<body style="background-color: lightblue;">
  <h1>Hello</h1>
</body>
</html>''';

  /// Evaluates Section A answers
  /// Returns total score out of 14 (10 MCQs + 4 matching pairs)
  static int evaluateSectionA(Map<String, dynamic> answersSoFar) {
    int score = 0;
    
    final sectionAAnswers = answersSoFar['sectionAAnswers'] as Map<String, dynamic>?;
    if (sectionAAnswers == null) return 0;

    // Evaluate Q1-Q4, Q6-Q10 (10 questions, 1 mark each)
    correctAnswers.forEach((questionKey, correctAnswer) {
      final userAnswer = sectionAAnswers[questionKey] as String?;
      if (userAnswer != null && userAnswer == correctAnswer) {
        score++;
      }
    });

    // Evaluate Q5 matching (4 pairs, 1 mark each)
    final q5Matches = sectionAAnswers['Q5Matches'] as Map<String, dynamic>?;
    if (q5Matches != null) {
      correctQ5Matches.forEach((tag, correctMeaning) {
        final userMeaning = q5Matches[tag] as String?;
        if (userMeaning != null && userMeaning == correctMeaning) {
          score++;
        }
      });
    }

    return score;
  }

  /// Evaluates Section B Question 1 (Table Creation) - STRICT CHECKING
  /// Returns 5 if structure matches, 0 otherwise
  static int evaluateSectionBQ1(String code) {
    final lowerCode = code.trim().toLowerCase();
    
    // Check for essential table elements
    final hasTable = lowerCode.contains('<table');
    final hasTr = lowerCode.contains('<tr');
    final hasTh = lowerCode.contains('<th');
    final hasTd = lowerCode.contains('<td');
    
    // Check for at least 4 rows (1 header + 3 data rows)
    final trCount = '<tr'.allMatches(lowerCode).length;
    final hasCorrectRows = trCount >= 4;
    
    // Check for 3 columns (Item, Quantity, Status)
    final thCount = '<th'.allMatches(lowerCode).length;
    final hasThreeColumns = thCount >= 3;
    
    // Check if the content includes key data
    final hasItem = lowerCode.contains('item');
    final hasQuantity = lowerCode.contains('quantity');
    final hasStatus = lowerCode.contains('status');
    final hasModuleA = lowerCode.contains('module a');
    final hasModuleB = lowerCode.contains('module b');
    
    // Award full marks if structure and content are correct
    return (hasTable && 
            hasTr && 
            hasTh && 
            hasTd && 
            hasCorrectRows && 
            hasThreeColumns &&
            hasItem &&
            hasQuantity &&
            hasStatus &&
            hasModuleA &&
            hasModuleB) ? 5 : 0;
  }

  /// Evaluates Section B Question 2 (Inline CSS Background)
  /// Returns 5 if correct, 0 otherwise
  static int evaluateSectionBQ2(String code) {
    final lowerCode = code.trim().toLowerCase();
    
    // Check for inline CSS with background-color: lightblue
    final hasBackgroundColor = lowerCode.contains('background-color') || 
                                lowerCode.contains('background');
    final hasLightBlue = lowerCode.contains('lightblue') || 
                          lowerCode.contains('light blue') ||
                          lowerCode.contains('#add8e6') ||
                          lowerCode.contains('rgb(173, 216, 230)');
    final isInlineStyle = lowerCode.contains('style=');
    final hasBodyTag = lowerCode.contains('<body');
    
    return (hasBackgroundColor && hasLightBlue && isInlineStyle && hasBodyTag) ? 5 : 0;
  }

  /// Evaluates complete Section B (both questions)
  /// Returns total score out of 10 (5 marks each)
  static Map<String, int> evaluateSectionB(Map<String, dynamic> answersSoFar) {
    final sectionBQ1Code = answersSoFar['sectionBPreview'] as String? ?? '';
    final sectionBQ2Code = answersSoFar['sectionB'] as String? ?? '';
    
    final q1Score = evaluateSectionBQ1(sectionBQ1Code);
    final q2Score = evaluateSectionBQ2(sectionBQ2Code);
    
    return {
      'q1Score': q1Score,
      'q2Score': q2Score,
      'totalScore': q1Score + q2Score,
    };
  }

  /// Gets a detailed breakdown of Section A answers
  static Map<String, dynamic> getDetailedSectionAResults(Map<String, dynamic> answersSoFar) {
    final sectionAAnswers = answersSoFar['sectionAAnswers'] as Map<String, dynamic>?;
    if (sectionAAnswers == null) {
      return {
        'totalScore': 0,
        'maxScore': 14,
        'breakdown': {},
      };
    }

    Map<String, Map<String, dynamic>> breakdown = {};

    // MCQ questions
    correctAnswers.forEach((questionKey, correctAnswer) {
      final userAnswer = sectionAAnswers[questionKey] as String?;
      final isCorrect = userAnswer == correctAnswer;
      
      breakdown[questionKey] = {
        'userAnswer': userAnswer ?? 'Not Answered',
        'correctAnswer': correctAnswer,
        'isCorrect': isCorrect,
        'points': isCorrect ? 1 : 0,
      };
    });

    // Q5 matching
    final q5Matches = sectionAAnswers['Q5Matches'] as Map<String, dynamic>?;
    Map<String, dynamic> q5Breakdown = {};
    int q5Score = 0;

    correctQ5Matches.forEach((tag, correctMeaning) {
      final userMeaning = q5Matches?[tag] as String?;
      final isCorrect = userMeaning == correctMeaning;
      if (isCorrect) q5Score++;

      q5Breakdown[tag] = {
        'userAnswer': userMeaning ?? 'Not Matched',
        'correctAnswer': correctMeaning,
        'isCorrect': isCorrect,
      };
    });

    breakdown['Q5'] = {
      'matches': q5Breakdown,
      'points': q5Score,
      'maxPoints': 4,
    };

    final totalScore = evaluateSectionA(answersSoFar);

    return {
      'totalScore': totalScore,
      'maxScore': 14,
      'breakdown': breakdown,
    };
  }

  /// Gets a detailed breakdown of Section B answers
  static Map<String, dynamic> getDetailedSectionBResults(Map<String, dynamic> answersSoFar) {
    final scores = evaluateSectionB(answersSoFar);
    final q1Code = answersSoFar['sectionBPreview'] as String? ?? '';
    final q2Code = answersSoFar['sectionB'] as String? ?? '';
    
    return {
      'totalScore': scores['totalScore'],
      'maxScore': 10,
      'breakdown': {
        'Q1_Table': {
          'question': 'Write code to create a table (Item, Quantity, Status)',
          'userAnswer': q1Code.isEmpty ? 'Not Answered' : 'Code Submitted',
          'correctAnswer': correctTableCode,
          'points': scores['q1Score'],
          'maxPoints': 5,
          'correctCriteria': 'Must include table with 3 columns (Item, Quantity, Status) and 4 rows including Module A, Module B data',
        },
        'Q2_InlineCSS': {
          'question': 'Use inline CSS to set background color to light blue',
          'userAnswer': q2Code.isEmpty ? 'Not Answered' : 'Code Submitted',
          'correctAnswer': correctCSSCode,
          'points': scores['q2Score'],
          'maxPoints': 5,
          'correctCriteria': 'Must use style attribute on <body> tag with background-color: lightblue',
        },
      },
    };
  }

  /// Gets complete quiz results
  static Map<String, dynamic> getCompleteResults(Map<String, dynamic> answersSoFar) {
    final sectionAResults = getDetailedSectionAResults(answersSoFar);
    final sectionBResults = getDetailedSectionBResults(answersSoFar);
    
    return {
      'sectionA': sectionAResults,
      'sectionB': sectionBResults,
      'totalScore': sectionAResults['totalScore'] + sectionBResults['totalScore'],
      'maxScore': sectionAResults['maxScore'] + sectionBResults['maxScore'],
      'percentage': ((sectionAResults['totalScore'] + sectionBResults['totalScore']) / 
                     (sectionAResults['maxScore'] + sectionBResults['maxScore']) * 100).toStringAsFixed(2),
    };
  }
}