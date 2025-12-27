import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/word.dart';
import 'story_screen.dart';

class PuzzleScreen extends StatefulWidget {
  final List<Word> words;
  final int storyIndex;

  const PuzzleScreen({super.key, required this.words, required this.storyIndex});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  late List<List<String>> grid;
  late int gridSize;
  final List<String> _foundWords = [];
  final List<Point<int>> _selectedPoints = [];
  
  // Store word locations for validation: Word -> List of Points
  final Map<String, List<Point<int>>> _wordLocations = {};

  @override
  void initState() {
    super.initState();
    _generatePuzzle();
  }

  void _generatePuzzle() {
    // Determine grid size based on longest word + padding, min 8x8
    int longestWord = widget.words.fold(0, (prev, word) => max(prev, word.text.length));
    gridSize = max(8, longestWord + 2);
    
    // Initialize empty grid
    grid = List.generate(gridSize, (_) => List.filled(gridSize, ''));
    _wordLocations.clear();

    final random = Random();
    
    for (var wordObj in widget.words) {
      String word = wordObj.text.toUpperCase();
      bool placed = false;
      int attempts = 0;

      while (!placed && attempts < 100) {
        attempts++;
        
        // Directions: 
        // 0: Vertical Down (row++, col)
        // 1: Vertical Up (row--, col)
        // 2: Diagonal Down-Right (row++, col++)
        // 3: Diagonal Up-Right (row--, col++)
        // 4: Diagonal Down-Left (row++, col--)
        // 5: Diagonal Up-Left (row--, col--)
        
        int direction = random.nextInt(6); 
        int row = random.nextInt(gridSize);
        int col = random.nextInt(gridSize);

        int dRow = 0;
        int dCol = 0;

        switch (direction) {
          case 0: dRow = 1; dCol = 0; break; // Down
          case 1: dRow = -1; dCol = 0; break; // Up
          case 2: dRow = 1; dCol = 1; break; // Diag Down-Right
          case 3: dRow = -1; dCol = 1; break; // Diag Up-Right
          case 4: dRow = 1; dCol = -1; break; // Diag Down-Left
          case 5: dRow = -1; dCol = -1; break; // Diag Up-Left
        }

        // Check bounds
        bool fits = true;
        int endRow = row + (dRow * (word.length - 1));
        int endCol = col + (dCol * (word.length - 1));

        if (endRow < 0 || endRow >= gridSize || endCol < 0 || endCol >= gridSize) {
          fits = false;
        }

        // Check collisions
        if (fits) {
          for (int i = 0; i < word.length; i++) {
            int r = row + (dRow * i);
            int c = col + (dCol * i);
            if (grid[r][c] != '' && grid[r][c] != word[i]) {
              fits = false;
              break;
            }
          }
        }

        // Place word
        if (fits) {
          List<Point<int>> points = [];
          for (int i = 0; i < word.length; i++) {
            int r = row + (dRow * i);
            int c = col + (dCol * i);
            grid[r][c] = word[i];
            points.add(Point(r, c));
          }
          _wordLocations[word] = points;
          placed = true;
        }
      }
      
      if (!placed) {
        debugPrint("Could not place word: $word");
      }
    }

    // Fill remaining
    const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c] == '') {
          grid[r][c] = letters[random.nextInt(letters.length)];
        }
      }
    }
  }

  void _onTileTap(Point<int> point) {
    if (!_selectedPoints.contains(point)) {
      setState(() {
        _selectedPoints.add(point);
      });
      _checkSelection();
    }
  }

  void _onTileDoubleTap(Point<int> point) {
    if (_selectedPoints.contains(point)) {
      setState(() {
        _selectedPoints.remove(point);
      });
    }
  }

  void _checkSelection() {
    // Check if the currently selected points match any word exactly
    for (var entry in _wordLocations.entries) {
      String word = entry.key;
      List<Point<int>> wordPoints = entry.value;

      // Check if found already
      if (_foundWords.contains(word)) continue;

      // Check if match
      if (_selectedPoints.length == wordPoints.length &&
          _selectedPoints.toSet().containsAll(wordPoints)) {
        
        setState(() {
          _foundWords.add(word);
          _selectedPoints.clear();
        });

        if (_foundWords.length == widget.words.length) {
          _showWinDialog();
        }
        return;
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Puzzle Solved!'),
        content: const Text('You found all the words! Great job!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog
              // Navigate to Story Screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryScreen(storyIndex: widget.storyIndex),
                ),
              );
            },
            child: const Text('See Story!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Search'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Word List
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 10,
              children: widget.words.map((w) {
                bool found = _foundWords.contains(w.text.toUpperCase());
                return Chip(
                  label: Text(
                    w.text,
                    style: TextStyle(
                      decoration: found ? TextDecoration.underline : null,
                      color: found ? Colors.white : Colors.black,
                    ),
                  ),
                  backgroundColor: found ? Colors.green : Colors.grey.shade200,
                );
              }).toList(),
            ),
          ),
          
          // Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double size = min(constraints.maxWidth, constraints.maxHeight);
                  
                  return Center(
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridSize,
                        ),
                        itemCount: gridSize * gridSize,
                        itemBuilder: (context, index) {
                          int r = index ~/ gridSize;
                          int c = index % gridSize;
                          Point<int> p = Point(r, c);
                          
                          bool isSelected = _selectedPoints.contains(p);
                          
                          // Check if part of a found word
                          bool isFound = false;
                          for (var word in _foundWords) {
                            if (_wordLocations[word]!.contains(p)) {
                              isFound = true;
                              break;
                            }
                          }

                          return GestureDetector(
                            onTap: () => _onTileTap(p),
                            onDoubleTap: () => _onTileDoubleTap(p),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                color: isSelected 
                                    ? Colors.blue.withAlpha(100) 
                                    : (isFound ? Colors.green.withAlpha(100) : Colors.white),
                              ),
                              child: Center(
                                child: Text(
                                  grid[r][c],
                                  style: GoogleFonts.comicNeue(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    decoration: isFound ? TextDecoration.underline : null,
                                    decorationThickness: 3.0,
                                    decorationColor: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
