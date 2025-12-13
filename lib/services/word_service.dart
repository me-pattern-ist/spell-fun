import 'package:flutter/services.dart' show rootBundle;
import '../models/word.dart';

class WordService {
  Future<List<Word>> loadAllWords() async {
    final words = await _loadWordsFromAsset('assets/all_words.csv');
    return words.reversed.toList(); // Bottom-Up: Reverse the list
  }

  Future<List<Word>> _loadWordsFromAsset(String assetPath) async {
    try {
      final String content = await rootBundle.loadString(assetPath);
      final List<String> lines = content.split('\n');
      
      List<Word> words = [];
      for (int i = 0; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isNotEmpty) {
          words.add(Word(
            id: '${i + 1}',
            text: line,
            meaning: 'A word: $line', // Placeholder
            imageUrl: 'assets/${line.toLowerCase()}.png', // Placeholder
            difficulty: 1,
          ));
        }
      }
      return words;
    } catch (e) {
      print('Error loading words from $assetPath: $e');
      return [];
    }
  }
}
