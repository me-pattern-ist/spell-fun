import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/word.dart';
import 'tracing_screen.dart';
import 'puzzle_screen.dart';

import '../constants.dart';

class LearningSessionScreen extends StatefulWidget {
  final List<Word> words;
  final bool isCursive;
  final int storyIndex;

  const LearningSessionScreen({
    super.key,
    required this.words,
    this.isCursive = false,
    required this.storyIndex,
  });

  @override
  State<LearningSessionScreen> createState() => _LearningSessionScreenState();
}

class _LearningSessionScreenState extends State<LearningSessionScreen> {
  int _currentIndex = 0;
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage(kTtsLanguage);
    await flutterTts.setSpeechRate(kTtsSpeechRate);
    await flutterTts.setVolume(kTtsVolume);
    await flutterTts.setPitch(kTtsPitch);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void _handleNext() async {
    if (!mounted) return;

    setState(() {
      if (_currentIndex < widget.words.length - 1) {
        _currentIndex++;
      } else {
        // Done with all words, go to puzzle
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PuzzleScreen(
              words: widget.words,
              storyIndex: widget.storyIndex,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = widget.words[_currentIndex];

    return TracingScreen(
      key: ValueKey(currentWord.id),
      word: currentWord,
      onNext: _handleNext,
      onPronounce: () => _speak(currentWord.text),
      onPronounceSentence: () => _speak(currentWord.sentence),
      isCursive: widget.isCursive,
    );
  }
}
