enum MathOperation {
  addition,
  subtraction,
  multiplication,
  division,
  fractions,
}

class MathProblem {
  final int val1;
  final int val2;
  final MathOperation operation;
  final int answer;
  final String? customQuestion; // For fractions or custom formats
  final String answerString;    // For displaying the answer (e.g., "3/5")

  MathProblem({
    required this.val1,
    required this.val2,
    required this.operation,
    required this.answer,
    this.customQuestion,
    String? answerString,
  }) : answerString = answerString ?? answer.toString();

  String get operatorSymbol {
    switch (operation) {
      case MathOperation.addition:
        return '+';
      case MathOperation.subtraction:
        return '-';
      case MathOperation.multiplication:
        return '×';
      case MathOperation.division:
        return '÷';
      case MathOperation.fractions:
        return '+'; // Default for simple fraction addition
    }
  }

  @override
  String toString() {
    if (customQuestion != null) {
      return '$customQuestion = ?';
    }
    return '$val1 $operatorSymbol $val2 = ?';
  }
}
