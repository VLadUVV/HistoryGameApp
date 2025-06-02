class Difference {
  final double x;
  final double y;
  bool found;

  Difference({required this.x, required this.y, this.found = false});

  bool isTapped(double tapX, double tapY, double radius) {
    final dx = tapX - x;
    final dy = tapY - y;
    return dx * dx + dy * dy <= radius * radius;
  }
}

class DifferenceGameModel {
  final String imageLeftPath;
  final String imageRightPath;
  final List<Difference> differences;

  DifferenceGameModel({
    required this.imageLeftPath,
    required this.imageRightPath,
    required this.differences,
  });

  int get foundCount =>
      differences
          .where((d) => d.found)
          .length;

  bool get isGameComplete => foundCount == differences.length;

  void checkTap(double tapX, double tapY, double radius) {
    for(var diff in differences) {
      if(!diff.found && diff.isTapped(tapX, tapY, radius)) {
        diff.found = true;
        break;
      }
    }
  }
}