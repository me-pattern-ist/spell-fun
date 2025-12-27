import 'dart:ui';

class NumberPaths {
  // Paths defined in a 100x100 coordinate system
  static List<List<Offset>> getPath(int number) {
    switch (number) {
      case 0:
        return [
          [
            const Offset(50, 10),
            const Offset(20, 30),
            const Offset(20, 70),
            const Offset(50, 90),
            const Offset(80, 70),
            const Offset(80, 30),
            const Offset(50, 10),
          ]
        ];
      case 1:
        return [
          [const Offset(50, 10), const Offset(50, 90)]
        ];
      case 2:
        return [
          [
            const Offset(20, 30),
            const Offset(50, 10),
            const Offset(80, 30),
            const Offset(20, 90),
            const Offset(80, 90)
          ]
        ];
      case 3:
        return [
          [
            const Offset(20, 20),
            const Offset(80, 20),
            const Offset(50, 50),
            const Offset(80, 80),
            const Offset(20, 80)
          ]
        ];
      case 4:
        return [
          [const Offset(70, 10), const Offset(20, 60), const Offset(90, 60)],
          [const Offset(70, 10), const Offset(70, 90)]
        ];
      case 5:
        return [
          [const Offset(80, 10), const Offset(30, 10), const Offset(30, 40), const Offset(80, 50), const Offset(80, 80), const Offset(30, 80)]
        ];
      case 6:
        return [
          [const Offset(70, 10), const Offset(30, 50), const Offset(30, 80), const Offset(50, 90), const Offset(80, 80), const Offset(80, 50), const Offset(30, 50)]
        ];
      case 7:
        return [
          [const Offset(20, 10), const Offset(80, 10), const Offset(40, 90)]
        ];
      case 8:
        return [
          [const Offset(50, 50), const Offset(20, 30), const Offset(50, 10), const Offset(80, 30), const Offset(50, 50), const Offset(20, 70), const Offset(50, 90), const Offset(80, 70), const Offset(50, 50)]
        ];
      case 9:
        return [
          [const Offset(50, 50), const Offset(20, 40), const Offset(20, 20), const Offset(50, 10), const Offset(80, 20), const Offset(80, 80), const Offset(50, 90)]
        ];
      default:
        return [];
    }
  }
}
