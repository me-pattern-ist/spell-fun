import 'dart:math';
import '../models/math_model.dart';
import '../constants.dart';

class MathService {
  final Random _random = Random();

  MathProblem generateProblem(MathOperation operation) {
    int val1, val2, answer;

    switch (operation) {
      case MathOperation.addition:
        // Max sum controlled by constant
        val1 = _random.nextInt(kMathMaxSum + 1); // 0 to Max
        val2 = _random.nextInt(kMathMaxSum - val1 + 1); // Ensure val1 + val2 <= Max
        answer = val1 + val2;
        break;
      case MathOperation.subtraction:
        // Max number controlled by constant
        val1 = _random.nextInt(kMathMaxSum + 1); // 0 to Max
        val2 = _random.nextInt(val1 + 1); // 0 to val1 (ensure non-negative)
        answer = val1 - val2;
        break;
      case MathOperation.multiplication:
        val1 = _random.nextInt(10);
        val2 = _random.nextInt(10);
        answer = val1 * val2;
        break;
      case MathOperation.division:
        // Simple division (integer result)
        val2 = _random.nextInt(9) + 1; // 1-9 (no div by zero)
        answer = _random.nextInt(10); // 0-9
        val1 = answer * val2;
        break;
    }

    return MathProblem(
      val1: val1,
      val2: val2,
      operation: operation,
      answer: answer,
    );
  }
}
