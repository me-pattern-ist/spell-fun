import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/word.dart';

class DrawingPoint {
  final Offset offset;
  final double pressure;

  DrawingPoint(this.offset, this.pressure);
}

class TracingScreen extends StatefulWidget {
  final Word word;
  final VoidCallback onNext;
  final VoidCallback? onPronounce;
  final VoidCallback? onPronounceSentence;
  final bool isCursive;

  const TracingScreen({
    super.key,
    required this.word,
    required this.onNext,
    this.onPronounce,
    this.onPronounceSentence,
    this.isCursive = false,
  });

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  List<DrawingPoint?> points = [];

  @override
  void initState() {
    super.initState();
    _pronounceTwice();
  }

  void _pronounceTwice() async {
    if (widget.onPronounce != null) {
      widget.onPronounce!();
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) widget.onPronounce!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.isCursive
        ? GoogleFonts.cookie(
            fontSize: 120,
            fontWeight: FontWeight.normal,
            textStyle: TextStyle(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2.0
                ..color = Colors.purple.withOpacity(0.3),
            ),
            letterSpacing: 2,
          )
        : GoogleFonts.comicNeue(
            fontSize: 120,
            fontWeight: FontWeight.bold,
            textStyle: TextStyle(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2.0
                ..color = Colors.purple.withOpacity(0.3),
            ),
            letterSpacing: 10,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text('Trace: ${widget.word.text}'),
        backgroundColor: Colors.white,
        actions: [
          if (widget.onPronounce != null)
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: widget.onPronounce,
              tooltip: 'Pronounce',
            ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E5F5), Colors.white], // Soft Lavender to White
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Guide Text
                    Text(
                      widget.word.text,
                      style: textStyle,
                    ),
                    // Drawing Area
                    Listener(
                      onPointerDown: (details) {
                        setState(() {
                          points.add(DrawingPoint(
                            details.localPosition,
                            details.pressureMin > 0 ? details.pressure : 0.5,
                          ));
                        });
                      },
                      onPointerMove: (details) {
                        setState(() {
                          points.add(DrawingPoint(
                            details.localPosition,
                            details.pressureMin > 0 ? details.pressure : 0.5,
                          ));
                        });
                      },
                      onPointerUp: (details) {
                        setState(() {
                          points.add(null);
                        });
                      },
                      child: CustomPaint(
                        painter: TracingPainter(points),
                        size: Size.infinite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.word.sentence.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        widget.word.sentence,
                        style: GoogleFonts.comicNeue(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (widget.onPronounceSentence != null)
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.purple),
                        onPressed: widget.onPronounceSentence,
                        tooltip: 'Listen to sentence',
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        points.clear();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                  ElevatedButton.icon(
                    onPressed: widget.onNext,
                    icon: const Icon(Icons.check),
                    label: const Text('Done!'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 20),
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
}

class TracingPainter extends CustomPainter {
  final List<DrawingPoint?> points;

  TracingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    // Rainbow Gradient Shader
    final shader = const LinearGradient(
      colors: [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.purple,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Paint paint = Paint()
      ..shader = shader
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      if (p1 != null && p2 != null) {
        // Vary stroke width based on pressure
        // Base width 5, pressure adds up to 15 more.
        paint.strokeWidth = 5.0 + (p1.pressure * 15.0);
        
        canvas.drawLine(p1.offset, p2.offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(TracingPainter oldDelegate) => true;
}
