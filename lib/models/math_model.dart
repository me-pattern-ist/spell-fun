enum MathOperation {
  addition,
  subtraction,
  multiplication,
  division,
}

class MathProblem {
  final int val1;
  final int val2;
  final MathOperation operation;
  final int answer;

  MathProblem({
    required this.val1,
    required this.val2,
    required this.operation,
    required this.answer,
  });

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
    }
  }

  @override
  String toString() {
    return '$val1 $operatorSymbol $val2 = ?';
  }
}
