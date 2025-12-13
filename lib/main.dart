import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'models/word.dart';
import 'screens/tracing_screen.dart';
import 'screens/learning_session_screen.dart';
import 'services/word_service.dart';

void main() {
  runApp(const SpellLearningGame());
}

class SpellLearningGame extends StatelessWidget {
  const SpellLearningGame({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom primary color (rich violet)
    const MaterialColor primaryViolet = MaterialColor(
      0xFF6A1B9A,
      <int, Color>{
        50: Color(0xFFF3E5F5),
        100: Color(0xFFE1BEE7),
        200: Color(0xFFCE93D8),
        300: Color(0xFFBA68C8),
        400: Color(0xFFAB47BC),
        500: Color(0xFF9C27B0),
        600: Color(0xFF8E24AA),
        700: Color(0xFF7B1FA2),
        800: Color(0xFF6A1B9A),
        900: Color(0xFF4A148C),
      },
    );

    return MaterialApp(
      title: 'Magic Spells',
      theme: ThemeData(
        primarySwatch: primaryViolet,
        textTheme: GoogleFonts.comicNeueTextTheme(),
        useMaterial3: true,
      ),
      home: const SpellBookScreen(),
    );
  }
}

class SpellBookScreen extends StatefulWidget {
  const SpellBookScreen({super.key});

  @override
  State<SpellBookScreen> createState() => _SpellBookScreenState();
}

class _SpellBookScreenState extends State<SpellBookScreen> {
  final WordService _wordService = WordService();
  late FlutterTts flutterTts;
  
  List<Word> _allWords = [];
  bool _isLoading = true;
  int _currentWordIndex = 0;
  bool _isCursive = false; // Default to Print

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initTts();
    _loadWords();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.3);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _loadWords() async {
    try {
      final words = await _wordService.loadAllWords();
      setState(() {
        _allWords = words;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading words: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startChallenge() {
    if (_allWords.isEmpty) return;

    // Select 5 words sequentially starting from current index
    List<Word> challengeWords = [];
    for (int i = 0; i < 5; i++) {
      challengeWords.add(_allWords[(_currentWordIndex + i) % _allWords.length]);
    }

    // Update index for next time (looping back if needed)
    setState(() {
      _currentWordIndex = (_currentWordIndex + 5) % _allWords.length;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LearningSessionScreen(
          words: challengeWords,
          isCursive: _isCursive,
        ),
      ),
    );
  }

  void _startLevel(Word word) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TracingScreen(
          word: word,
          onNext: () {
            Navigator.pop(context);
          },
          onPronounce: () => _speak(word.text),
          onPronounceSentence: () => _speak(word.sentence),
          isCursive: _isCursive,
        ),
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Cursive Writing'),
                    subtitle: const Text('Enable cursive font for tracing'),
                    value: _isCursive,
                    onChanged: (value) {
                      setState(() {
                        _isCursive = value;
                      });
                      // Update the main state as well
                      this.setState(() {
                        _isCursive = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Spell Book'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _startChallenge,
              icon: const Icon(Icons.play_arrow, size: 32),
              label: const Text('Start Challenge (5 Words)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _allWords.length,
              itemBuilder: (context, index) {
                final word = _allWords[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => _startLevel(word),
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.image, // Placeholder for word image
                            size: 30,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          word.text,
                          style: _isCursive
                              ? GoogleFonts.cookie(
                                  fontSize: 30, // Slightly larger for cursive
                                  fontWeight: FontWeight.normal,
                                )
                              : GoogleFonts.comicNeue(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
