import 'package:test/test.dart';

import '../lib/syntax_definitions/syntax_definition.dart';


void main() {
  group("capture index tracking, like", () {
    test("a single capture group", () {
      var ref = GroupRef();
      var (expr, tracker) = TestDefinition().singleCaptureTest1(ref);
      expect(expr, equals("(asdf)"));
      expect(tracker.getPosition(ref), equals(1));
    });

    test("nested capture groups", () {
      var ref1 = GroupRef();
      var ref2 = GroupRef();
      var ref3 = GroupRef();
      var (expr, tracker) = TestDefinition().multiCaptureTest1(ref1, ref2, ref3);
      expect(expr, equals("(((bfksn)))"));
      expect(tracker.getPosition(ref1), equals(1));
      expect(tracker.getPosition(ref2), equals(2));
      expect(tracker.getPosition(ref3), equals(3));
    });

    test("nested and concatenated capture groups", () {
      var ref1 = GroupRef();
      var ref2 = GroupRef();
      var ref3 = GroupRef();
      var ref4 = GroupRef();
      var (expr, tracker) = TestDefinition().multiCaptureTest2(ref1, ref2, ref3, ref4);
      expect(expr, equals("(abc1)abc2(((abc3))abc4)"));
      expect(tracker.getPosition(ref1), equals(1));
      expect(tracker.getPosition(ref2), equals(2));
      expect(tracker.getPosition(ref3), equals(3));
      expect(tracker.getPosition(ref4), equals(4));
    });
  });
}

final class TestDefinition extends SyntaxDefinition {
  @override
  get body => throw UnimplementedError();

  SyntaxResult singleCaptureTest1(GroupRef ref) {
    return capture(pattern("asdf"), ref);
  }

  SyntaxResult multiCaptureTest1(GroupRef ref1, GroupRef ref2, GroupRef ref3) {
    return capture(capture(capture(pattern("bfksn"), ref3), ref2), ref1);
  }

  SyntaxResult multiCaptureTest2(GroupRef ref1, GroupRef ref2, GroupRef ref3, GroupRef ref4) {
    return concat([
      capture(pattern("abc1"), ref1),
      pattern("abc2"),
      capture(concat([
        capture(capture(pattern("abc3"), ref4), ref3),
        pattern("abc4")
      ]), ref2)
    ]);
  }
}


