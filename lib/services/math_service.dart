import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/math_model.dart';
import '../constants.dart';

class MathService {
  final Random _random = Random();
  List<MathProblem> _fractionProblems = [];
  List<MathProblem> _multiplicationProblems = [];

  Future<void> loadMultiplication() async {
    if (_multiplicationProblems.isNotEmpty) return;

    try {
      final String csvData = await rootBundle.loadString('assets/math_multiplication.csv');
      final List<String> lines = csvData.split('\n');
      
      for (String line in lines) {
        if (line.trim().isEmpty) continue;
        
        final parts = line.split('|');
        if (parts.length >= 2) {
          final question = parts[0].trim();
          final answer = parts[1].trim();
          
          _multiplicationProblems.add(MathProblem(
            val1: 0, // Dummy
            val2: 0, // Dummy
            operation: MathOperation.multiplication,
            answer: 0, // Dummy
            customQuestion: question,
            answerString: answer,
          ));
        }
      }
      print("Loaded ${_multiplicationProblems.length} multiplication problems.");
    } catch (e) {
      print("Error loading multiplication: $e");
    }
  }

  Future<void> loadFractions() async {
    if (_fractionProblems.isNotEmpty) return;

    try {
      final String csvData = await rootBundle.loadString('assets/math_fractions.csv');
      final List<String> lines = csvData.split('\n');
      
      for (String line in lines) {
        if (line.trim().isEmpty) continue;
        
        final parts = line.split('|');
        if (parts.length >= 2) {
          final question = parts[0].trim();
          final answer = parts[1].trim();
          
          _fractionProblems.add(MathProblem(
            val1: 0, // Dummy
            val2: 0, // Dummy
            operation: MathOperation.fractions,
            answer: 0, // Dummy
            customQuestion: question,
            answerString: answer,
          ));
        }
      }
      print("Loaded ${_fractionProblems.length} fraction problems.");
    } catch (e) {
      print("Error loading fractions: $e");
    }
  }

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
        // Max number controlled by specific subtraction constant
        val1 = _random.nextInt(kMaxSubtractionSum + 1); // 0 to Max
        val2 = _random.nextInt(val1 + 1); // 0 to val1 (ensure non-negative)
        answer = val1 - val2;
        break;
      case MathOperation.multiplication:
        if (_multiplicationProblems.isNotEmpty) {
          return _multiplicationProblems[_random.nextInt(_multiplicationProblems.length)];
        }
        val1 = _random.nextInt(kMaxMultiplicationTable) + 1; // 1 to table limit
        val2 = _random.nextInt(10);
        answer = val1 * val2;
        break;
      case MathOperation.division:
        // Simple division (integer result)
        val2 = _random.nextInt(9) + 1; // 1-9 (no div by zero)
        answer = _random.nextInt(10); // 0-9
        val1 = answer * val2;
        break;
      case MathOperation.fractions:
        if (_fractionProblems.isNotEmpty) {
          return _fractionProblems[_random.nextInt(_fractionProblems.length)];
        }
        
        // Fallback if CSV not loaded or empty
        int denominator = _random.nextInt(9) + 2; // 2-10
        int num1 = _random.nextInt(denominator) + 1; // 1 to d
        int num2 = _random.nextInt(denominator) + 1; // 1 to d
        
        val1 = num1;
        val2 = num2;
        answer = num1 + num2; 
        
        String question = "$num1/$denominator + $num2/$denominator";
        String ansStr = "${num1 + num2}/$denominator";
        
        return MathProblem(
          val1: val1,
          val2: val2,
          operation: operation,
          answer: answer,
          customQuestion: question,
          answerString: ansStr,
        );
    }

    return MathProblem(
      val1: val1,
      val2: val2,
      operation: operation,
      answer: answer,
    );
  }
}
