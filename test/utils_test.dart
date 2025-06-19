// Import the Flutter test package to enable writing and running tests
import 'package:flutter_test/flutter_test.dart';

// Example utility function to test: adds two integers and returns the result
int add(int a, int b) {
  return a + b;
}

// Entry point for the test suite
void main() {
  // Define a test case using the test() function
  test('add() should return the sum of two numbers', () {
    // Check that add(2, 3) returns 5
    expect(add(2, 3), 5);

    // Check that add(-1, 1) returns 0
    expect(add(-1, 1), 0);
  });
}

