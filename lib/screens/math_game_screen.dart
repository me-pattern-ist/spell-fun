import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/math_model.dart';
import '../services/math_service.dart';
import '../constants.dart';
import 'dart:math';

class MathGameScreen extends StatefulWidget {
  final MathOperation operation;

  const MathGameScreen({super.key, required this.operation});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  final MathService _mathService = MathService();
  late MathProblem _currentProblem;
  List<String> _options = [];
  int _problemsSolved = 0;
  final int _totalProblems = 5;
  late FlutterTts _flutterTts;
  bool _isCorrect = false;
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _initTts();
    _loadAndStart();
  }

  Future<void> _loadAndStart() async {
    if (widget.operation == MathOperation.fractions) {
      await _mathService.loadFractions();
    } else if (widget.operation == MathOperation.multiplication) {
      await _mathService.loadMultiplication();
    }
    if (mounted) {
      _nextProblem();
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(kTtsLanguage);
    await _flutterTts.setSpeechRate(kTtsSpeechRate);
  }

  void _nextProblem() {
    if (_problemsSolved >= _totalProblems) {
      _showCompletionDialog();
    } else {
      setState(() {
        _currentProblem = _mathService.generateProblem(widget.operation);
        _generateOptions();
        _isCorrect = false;
        _selectedOption = null;
      });
      _speakProblem();
    }
  }

  void _generateOptions() {
    _options = [];
    _options.add(_currentProblem.answerString);
    
    final random = Random();
    while (_options.length < 3) {
      if (widget.operation == MathOperation.fractions) {
        // Generate random fraction options
        // Parse current answer to get denominator
        // Format: "num/den"
        List<String> parts = _currentProblem.answerString.split('/');
        int currentNum = int.parse(parts[0]);
        int den = int.parse(parts[1]);
        
        int offset = random.nextInt(5) - 2; // -2 to 2
        if (offset == 0) offset = 1;
        
        int newNum = currentNum + offset;
        if (newNum < 1) newNum = 1; // Ensure positive
        
        String option = "$newNum/$den";
        if (!_options.contains(option)) {
          _options.add(option);
        }
      } else {
        // Normal integer options
        int offset = random.nextInt(10) - 5; 
        if (offset == 0) offset = 1;
        
        int optionVal = _currentProblem.answer + offset;
        
        // Ensure option is non-negative and unique
        if (optionVal >= 0 && !_options.contains(optionVal.toString())) {
          _options.add(optionVal.toString());
        }
      }
    }
    
    _options.shuffle();
  }

  Future<void> _speakProblem() async {
    if (_currentProblem.customQuestion != null) {
      if (widget.operation == MathOperation.fractions) {
        String spoken = _currentProblem.customQuestion!
           .replaceAll('/', ' over ')
           .replaceAll('+', ' plus ');
        await _flutterTts.speak("$spoken equals?");
      } else {
        await _flutterTts.speak(_currentProblem.customQuestion!);
      }
    } else {
      String opText = widget.operation == MathOperation.addition ? "plus" : 
                      widget.operation == MathOperation.subtraction ? "minus" : 
                      widget.operation == MathOperation.multiplication ? "times" : "divided by";
      await _flutterTts.speak("${_currentProblem.val1} $opText ${_currentProblem.val2} equals?");
    }
  }

  void _checkAnswer(String selectedOption) {
    setState(() {
      _selectedOption = selectedOption;
    });

    if (selectedOption == _currentProblem.answerString) {
      _handleCorrect();
    } else {
      _flutterTts.speak("Try again!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect, try again!'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 500),
        ),
      );
      // Clear selection after short delay to allow retry
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _selectedOption = null;
          });
        }
      });
    }
  }

  void _handleCorrect() {
    setState(() {
      _isCorrect = true;
      _problemsSolved++;
    });
    
    if (_currentProblem.customQuestion != null) {
       String spokenAns = _currentProblem.answerString.replaceAll('/', ' over ');
       _flutterTts.speak("Correct! The answer is $spokenAns");
    } else {
       _flutterTts.speak("Correct! The answer is ${_currentProblem.answer}");
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _nextProblem();
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Math Master!'),
        content: const Text('You solved all the problems!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog
              Navigator.pop(context); // Screen
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Problem ${_problemsSolved + 1}/$_totalProblems'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: _speakProblem,
          ),
        ],
      ),
      body: Column(
        children: [
          // Problem Display
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentProblem.customQuestion != null 
                          ? '${_currentProblem.customQuestion}'
                          : '${_currentProblem.val1} ${_currentProblem.operatorSymbol} ${_currentProblem.val2} = ',
                      style: GoogleFonts.comicNeue(
                        fontSize: _currentProblem.customQuestion != null ? 32 : 60, 
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_currentProblem.customQuestion == null) ...[
                      if (_isCorrect)
                        Text(
                          _currentProblem.answerString,
                          style: GoogleFonts.comicNeue(fontSize: 60, color: Colors.green, fontWeight: FontWeight.bold),
                        )
                      else
                        const Text(
                          '?',
                          style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                    ] else ...[
                       // For word problems, show answer below or inline if space permits
                       if (_isCorrect)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            "Answer: ${_currentProblem.answerString}",
                            style: GoogleFonts.comicNeue(fontSize: 40, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        )
                    ]
                  ],
                ),
              ),
            ),
          ),

          // Options
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _options.map((option) {
                  bool isSelected = _selectedOption == option;
                  bool isCorrect = option == _currentProblem.answerString;
                  
                  Color btnColor = Colors.blue.shade100;
                  if (isSelected) {
                    btnColor = isCorrect ? Colors.green.shade300 : Colors.red.shade300;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 80,
                      child: ElevatedButton(
                        onPressed: _isCorrect ? null : () => _checkAnswer(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 5,
                        ),
                        child: Text(
                          option,
                          style: GoogleFonts.comicNeue(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
