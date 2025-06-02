class Difference {
  final double x;
  final double y;
  bool found;

  Difference({required this.x, required this.y, this.found = false});
}

class DifferenceGame {
  final String imageLeftPath;
  final String imageRightPath;
  final List<Difference> differences;

  DifferenceGame ({
    required this.imageLeftPath,
    required this.imageRightPath,
    required this.differences,
});
  int get foundCount => differences.where((d) => d.found).length;

  bool checkTap(double tapX, double tapY, double tolerance){
    for (var diff in differences) {
      if (!diff.found &&
          (tapX - diff.x).abs() <= tolerance &&
          (tapY - diff.y).abs() <= tolerance) {
        diff.found = true;
        return true;
      }
    }
    return false;
    }
      bool get isGameComplete => foundCount == differences.length;
  }
