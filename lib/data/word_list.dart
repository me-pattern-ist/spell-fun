import '../models/word.dart';

const String _rawWords = "PYRAMID,CORNER,BETTER,CHECK,SPLIT,TOUGH,SURPRISE,AWFUL,HORRID,GRIT,MERRILY,CROAK,AROUND";

final List<Word> wordList = _rawWords.split(',').asMap().entries.map((entry) {
  final index = entry.key;
  final text = entry.value.trim();
  return Word(
    id: '${index + 1}',
    text: text,
    meaning: 'A word: $text', // Placeholder
    imageUrl: 'assets/${text.toLowerCase()}.png', // Placeholder
    difficulty: 1,
  );
}).toList();
