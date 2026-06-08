import 'package:pub_semver/pub_semver.dart';

void main() {
  final v1 = Version.parse('2.2.9');
  final v2 = Version.parse('2.2.9+29');
  print('v1: $v1');
  print('v2: $v2');
  print('v1 < v2: ${v1 < v2}');
  print('v1 == v2: ${v1 == v2}');
  print('v1.compareTo(v2): ${v1.compareTo(v2)}');
}
