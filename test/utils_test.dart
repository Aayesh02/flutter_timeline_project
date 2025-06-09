import 'package:flutter_test/flutter_test.dart';

// Example utility function to test
int add(int a, int b) {
  return a + b;
}

void main() {
  test('add() should return the sum of two numbers', () {
    expect(add(2, 3), 5);
    expect(add(-1, 1), 0);
  });
}
