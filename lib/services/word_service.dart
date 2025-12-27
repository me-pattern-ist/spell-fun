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
          final parts = line.split('|');
          final text = parts[0].trim();
          final sentence = parts.length > 1 ? parts[1].trim() : "This is a word.";
          // We can store theme if we add it to Word model, or just ignore it for now.
          // The important part is not to crash if there are 3 parts.
          
          words.add(Word(
            id: '${i + 1}',
            text: text,
            meaning: 'A word: $text', // Placeholder
            sentence: sentence,
            imageUrl: 'assets/${text.toLowerCase()}.png', // Placeholder
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
