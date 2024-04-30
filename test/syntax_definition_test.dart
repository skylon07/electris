import 'package:test/test.dart';

import 'package:electris_generator/syntax_definitions/syntax_definition.dart';


void main() {
  group("capture index tracking, like", () {
    test("a single capture group", () {
      var ref = GroupRef();
      var recipe = TestBuilder().singleCaptureTest1(ref);
      expect(recipe.compile(), equals("(asdf)"));
      expect(recipe.positionOf(ref), equals(1));
    });

    test("nested capture groups", () {
      var ref1 = GroupRef();
      var ref2 = GroupRef();
      var ref3 = GroupRef();
      var recipe = TestBuilder().multiCaptureTest1(ref1, ref2, ref3);
      expect(recipe.compile(), equals("(((bfksn)))"));
      expect(recipe.positionOf(ref1), equals(1));
      expect(recipe.positionOf(ref2), equals(2));
      expect(recipe.positionOf(ref3), equals(3));
    });

    test("nested and concatenated capture groups", () {
      var ref1 = GroupRef();
      var ref2 = GroupRef();
      var ref3 = GroupRef();
      var ref4 = GroupRef();
      var recipe = TestBuilder().multiCaptureTest2(ref1, ref2, ref3, ref4);
      expect(recipe.compile(), equals("(abc1)abc2(((abc3))abc4)"));
      expect(recipe.positionOf(ref1), equals(1));
      expect(recipe.positionOf(ref2), equals(2));
      expect(recipe.positionOf(ref3), equals(3));
      expect(recipe.positionOf(ref4), equals(4));
    });
  });
}

final class TestBuilder extends RegExpBuilder {
  @override
  RegExpCollection createCollection() => throw UnimplementedError();

  RegExpRecipe singleCaptureTest1(GroupRef ref) {
    return capture(pattern("asdf"), ref);
  }

  RegExpRecipe multiCaptureTest1(GroupRef ref1, GroupRef ref2, GroupRef ref3) {
    return capture(capture(capture(pattern("bfksn"), ref3), ref2), ref1);
  }

  RegExpRecipe multiCaptureTest2(GroupRef ref1, GroupRef ref2, GroupRef ref3, GroupRef ref4) {
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


