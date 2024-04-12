import 'package:test/test.dart';

import '../lib/syntax_definitions/syntax_definition.dart';
import '../lib/syntax_printer.dart';


void main() {
  group("capture index tracking, like", () {
    test("a single capture group", () {
      var id = GroupId();
      var (expr, tracker) = TestDefinition().singleCaptureTest1(id);
      expect(expr, equals("(asdf)"));
      expect(tracker.getPosition(id), equals(1));
    });

    test("nested capture groups", () {
      var id1 = GroupId();
      var id2 = GroupId();
      var id3 = GroupId();
      var (expr, tracker) = TestDefinition().multiCaptureTest1(id1, id2, id3);
      expect(expr, equals("(((bfksn)))"));
      expect(tracker.getPosition(id1), equals(1));
      expect(tracker.getPosition(id2), equals(2));
      expect(tracker.getPosition(id3), equals(3));
    });

    test("nested and concatenated capture groups", () {
      var id1 = GroupId();
      var id2 = GroupId();
      var id3 = GroupId();
      var id4 = GroupId();
      var (expr, tracker) = TestDefinition().multiCaptureTest2(id1, id2, id3, id4);
      expect(expr, equals("(abc1)abc2(((abc3))abc4)"));
      expect(tracker.getPosition(id1), equals(1));
      expect(tracker.getPosition(id2), equals(2));
      expect(tracker.getPosition(id3), equals(3));
      expect(tracker.getPosition(id4), equals(4));
    });
  });
}

class TestDefinition extends SyntaxDefinition {
  @override
  get body => throw UnimplementedError();

  SyntaxResult singleCaptureTest1(GroupId id) {
    return capture(pattern("asdf"), id);
  }

  SyntaxResult multiCaptureTest1(GroupId id1, GroupId id2, GroupId id3) {
    return capture(capture(capture(pattern("bfksn"), id3), id2), id1);
  }

  SyntaxResult multiCaptureTest2(GroupId id1, GroupId id2, GroupId id3, GroupId id4) {
    return concat([
      capture(pattern("abc1"), id1),
      pattern("abc2"),
      capture(concat([
        capture(capture(pattern("abc3"), id4), id3),
        pattern("abc4")
      ]), id2)
    ]);
  }
}


