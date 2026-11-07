class Formatters {
  static String formatCount(int count) {
    if (count >= 1000000) {
      double result = count / 1000000;
      return '${result.toStringAsFixed(1).replaceAll('.0', '')} jt';
    } else if (count >= 1000) {
      double result = count / 1000;
      return '${result.toStringAsFixed(1).replaceAll('.0', '')} rb';
    }
    return count.toString();
  }

  static String formatThousands(int count) {
    String str = count.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }
}
