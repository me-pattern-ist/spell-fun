import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants.dart';

class StoryScreen extends StatefulWidget {
  final int storyIndex;

  const StoryScreen({super.key, required this.storyIndex});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late int _currentStoryIndex;
  String _storyText = '';
  bool _isLoading = true;
  late FlutterTts flutterTts;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _currentStoryIndex = widget.storyIndex;
    flutterTts = FlutterTts();
    _initTts();
    _loadStory();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage(kTtsLanguage);
    await flutterTts.setSpeechRate(kTtsSpeechRate);
    await flutterTts.setVolume(kTtsVolume);
    await flutterTts.setPitch(kTtsPitch);

    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  Future<void> _loadStory() async {
    setState(() {
      _isLoading = true;
      _isPlaying = false;
    });
    await flutterTts.stop();

    try {
      final text = await rootBundle.loadString('assets/stories/story_${_currentStoryIndex}.txt');
      if (mounted) {
        setState(() {
          _storyText = text;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading story: $e');
      if (mounted) {
        setState(() {
          // If we tried to go next and failed, we might want to revert or handle differently.
          // For now, just show error but if it was a navigation attempt, maybe we should have checked first?
          // Since we can't easily check existence without loading, we'll handle it here.
          _storyText = "End of stories!";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateStory(int delta) async {
    int newIndex = _currentStoryIndex + delta;
    if (newIndex < 0) return;

    // Optimistically try to load
    try {
      await rootBundle.loadString('assets/stories/story_$newIndex.txt');
      // If successful, update index and reload fully
      setState(() {
        _currentStoryIndex = newIndex;
      });
      _loadStory();
    } catch (e) {
      // Failed to load next story
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No more stories!')),
        );
      }
    }
  }

  Future<void> _toggleSpeech() async {
    if (_isPlaying) {
      await flutterTts.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _isPlaying = true;
      });
      await flutterTts.speak(_storyText);
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Time!'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE1BEE7), Colors.white],
                ),
              ),
              child: Column(
                children: [
                  // Main Content Area (Images + Story)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Image
                          Expanded(
                            flex: 1,
                            child: _buildStoryImage(1),
                          ),
                          
                          const SizedBox(width: 10),

                          // Center Story Text
                          Expanded(
                            flex: 2,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              color: Colors.white.withValues(alpha: 0.9),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _storyText,
                                      style: GoogleFonts.comicNeue(
                                        fontSize: 24, // Slightly larger for better readability
                                        height: 1.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.deepPurple.shade900,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    IconButton(
                                      icon: Icon(
                                        _isPlaying ? Icons.stop_circle : Icons.volume_up,
                                        size: 48,
                                        color: Colors.deepPurple,
                                      ),
                                      onPressed: _toggleSpeech,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Right Image
                          Expanded(
                            flex: 1,
                            child: _buildStoryImage(2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Controls Area
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.white.withValues(alpha: 0.5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Navigation Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _currentStoryIndex > 0 ? () => _navigateStory(-1) : null,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Previous'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton.icon(
                              onPressed: () => _navigateStory(1),
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Next'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Finish Button
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          icon: const Icon(Icons.home, size: 30),
                          label: const Text('Back to Home'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStoryImage(int imgNum) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: AssetImage('assets/stories/story_${_currentStoryIndex}_img_$imgNum.png'),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            // Fallback if image not found
          },
        ),
      ),
      child: Image.asset(
        'assets/stories/story_${_currentStoryIndex}_img_$imgNum.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
