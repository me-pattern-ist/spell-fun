class Word {
  final String id;
  final String text;
  final String meaning;
  final String imageUrl; // Asset path or URL
  final int difficulty;

  const Word({
    required this.id,
    required this.text,
    required this.meaning,
    required this.imageUrl,
    this.difficulty = 1,
  });
}
