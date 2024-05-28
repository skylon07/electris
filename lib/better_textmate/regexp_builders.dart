import 'package:collection/collection.dart';


abstract base class RegExpBuilder<CollectionT extends Record> {
  CollectionT createCollection();

  // base/fundamental recipe creation functions

  RegExpRecipe exactly(String string) => 
    _escapedPattern(string, RegExp(r"[.?*+\-()\[\]{}\^$|]"));

  RegExpRecipe chars(String charSet) => _chars(charSet, invert: false);

  RegExpRecipe notChars(String charSet) => _chars(charSet, invert: true);

  RegExpRecipe _chars(String charSet, {bool invert = false}) {
    var recipe = _escapedPattern(charSet, RegExp(r"[\[\]\^\/]"), isInvertedCharClass: invert);
    return _mapExpr(recipe, (expr) => "[${invert? "^":""}$expr]");
  }

  RegExpRecipe _escapedPattern(String exprStr, RegExp? escapeExpr, {bool? isInvertedCharClass}) {
    String expr;
    if (escapeExpr != null) {
      expr = exprStr.replaceAllMapped(escapeExpr, (match) => "\\${match[0]}");
    } else {
      expr = exprStr;
    }
    return RegExpRecipe._from(GroupTracker(), () => expr, isInvertedCharClass: isInvertedCharClass);
  }

  
  // basic composition operations

  RegExpRecipe capture(RegExpRecipe inner, [GroupRef? ref]) {
    var _tracker = inner._tracker.increment();
    if (ref != null) {
      _tracker = _tracker.startTracking(ref);
    }
    var _transform = () => "(${inner._expr})";
    return RegExpRecipe._from(_tracker, _transform);
  }

  RegExpRecipe concat(List<RegExpRecipe> recipes) => _join(recipes, joinBy: "");

  RegExpRecipe _mapExpr(RegExpRecipe recipe, String Function(String expr) mapper) =>
    RegExpRecipe._from(
      recipe._tracker,
      () => mapper(recipe._expr),
      isInvertedCharClass: recipe.isInvertedCharClass,
    );

  RegExpRecipe _join(List<RegExpRecipe> recipes, {required String joinBy}) {
    if (recipes.isEmpty) throw ArgumentError("Cannot join an empty list."); 

    var zip = IterableZip([
      for (var RegExpRecipe(:_tracker, _createExpr:_transform) in recipes)
        [_tracker, _transform]
    ]);
    var zipList = [...zip];
    
    var trackers = zipList[0].cast<GroupTracker>();
    var transforms = zipList[1].cast<String Function()>();
    return capture(RegExpRecipe._from(
      GroupTracker.combine(trackers),
      () => 
        [
          for (var transform in transforms)
          transform()
        ].join(joinBy),
    ));
  }


  // repitition and optionality
  
  RegExpRecipe optional(RegExpRecipe inner) =>
    _mapExpr(inner, (innerExpr) => "$innerExpr?");

  RegExpRecipe zeroOrMore(RegExpRecipe inner) =>
    _mapExpr(inner, (innerExpr) => "$innerExpr*");

  RegExpRecipe oneOrMore(RegExpRecipe inner) =>
    _mapExpr(inner, (innerExpr) => "$innerExpr+");

  RegExpRecipe repeatEqual(RegExpRecipe inner, int times) =>
    _mapExpr(inner, (innerExpr) => "$innerExpr{$times}");
    
  RegExpRecipe repeatAtLeast(RegExpRecipe inner, int times) =>
    _mapExpr(inner, (innerExpr) => "$innerExpr{$times,}");

  RegExpRecipe repeatAtMost(RegExpRecipe inner, int times) =>
    _mapExpr(inner, (innerExpr) => "$innerExpr{,$times}");

  RegExpRecipe repeatBetween(RegExpRecipe inner, int lowTimes, int highTimes) =>
    _mapExpr(inner, (innerExpr) => "$innerExpr{$lowTimes,$highTimes}");

  RegExpRecipe either(List<RegExpRecipe> branches) {
    bool? allInverted = null;
    if (branches.isNotEmpty) {
      allInverted = branches.first.isInvertedCharClass;
      if (allInverted != null) {
        for (var recipe in branches) {
          if (allInverted != recipe.isInvertedCharClass) {
            allInverted = null;
            break;
          }
        }
      }
    }

    var allCharClassesOfSameType = allInverted != null;
    if (allCharClassesOfSameType) {
      var sliceStart = allInverted? "[^".length : "[".length;

      var sliceEnd = -"]".length;
      var combinedClass = "[${allInverted? "^":""}${
        branches
          .map((recipe) => 
            _mapExpr(
              recipe,
              (expr) => expr.substring(sliceStart, expr.length + sliceEnd)
            ).compile()
          )
          .join("")
      }]";
      return _escapedPattern(combinedClass, null, isInvertedCharClass: allInverted);
    } else {
      return _join(branches, joinBy: r"|");
    }
  }

  late final nothing = exactly("");


  // "look around" operations

  RegExpRecipe aheadIs(RegExpRecipe inner) => 
    _mapExpr(inner, (innerExpr) => "(?=$innerExpr)");

  RegExpRecipe aheadIsNot(RegExpRecipe inner) => 
    _mapExpr(inner, (innerExpr) => "(?!$innerExpr)");

  RegExpRecipe behindIs(RegExpRecipe inner) => 
    _mapExpr(inner, (innerExpr) => "(?<=$innerExpr)");

  RegExpRecipe behindIsNot(RegExpRecipe inner) => 
    _mapExpr(inner, (innerExpr) => "(?<!$innerExpr)");

  
  // anchors

  RegExpRecipe startsWith(RegExpRecipe inner) =>
    _mapExpr(inner, (innerExpr) => "^$innerExpr");

  RegExpRecipe endsWith(RegExpRecipe inner) =>
    _mapExpr(inner, (innerExpr) => "$innerExpr\$");

  RegExpRecipe startsAndEndsWith(RegExpRecipe inner) =>
    _mapExpr(inner, (innerExpr) => "^$innerExpr\$");


  // spacing

  late final _anySpace = _escapedPattern(r"\s*", null);
  late final _reqSpace = _escapedPattern(r"\s+", null);

  RegExpRecipe space({required bool req}) => req? _reqSpace : _anySpace;

  RegExpRecipe spaceBefore(RegExpRecipe inner) =>
    concat([_anySpace, inner]);
  
  RegExpRecipe spaceReqBefore(RegExpRecipe inner) =>
    concat([_reqSpace, inner]);

  RegExpRecipe spaceAfter(RegExpRecipe inner) =>
    concat([inner, _anySpace]);
  
  RegExpRecipe spaceReqAfter(RegExpRecipe inner) =>
    concat([inner, _reqSpace]);
    
  RegExpRecipe spaceAround(RegExpRecipe inner) =>
    concat([_anySpace, inner, _anySpace]);
  
  RegExpRecipe spaceReqAround(RegExpRecipe inner) =>
    concat([_reqSpace, inner, _reqSpace]);

  RegExpRecipe spaceAroundReqBefore(RegExpRecipe inner) =>
    concat([_reqSpace, inner, _anySpace]);
  
  RegExpRecipe spaceAroundReqAfter(RegExpRecipe inner) =>
    concat([_anySpace, inner, _reqSpace]);

  RegExpRecipe phrase(String string) {
    var inner = _mapExpr(
      exactly(string),
      (innerExpr) => innerExpr.replaceAll(r" ", r"\s+"),
    );
    return concat([
      behindIs(either([
        startsWith(nothing),
        space(req: true),
      ])),
      either([
        concat([inner, aheadIsNot(_wordChar)]),
        endsWith(inner),
      ]),
    ]);
  }

  late final _wordChar = chars(r"a-zA-Z0-9_$"); // dart chars -- should work for most languages
}


final class RegExpRecipe {
  final GroupTracker _tracker;
  final String Function() _createExpr;
  final bool? isInvertedCharClass;
  late final isCharClass = isInvertedCharClass != null;

  RegExpRecipe._from(this._tracker, this._createExpr, {this.isInvertedCharClass = null});

  String compile() => _expr;
  late final _expr = _createExpr();

  int positionOf(GroupRef ref) => _tracker.getPosition(ref);
}


class GroupRef {}

// TODO: document operation meanings
final class GroupTracker {
  final Map<GroupRef, int> _positions;
  final int _groupCount;

  const GroupTracker._create(this._positions, this._groupCount);
  const GroupTracker(): this._create(const {}, 0);

  GroupTracker startTracking(GroupRef newRef, [int position = 1]) {
    assert (!_positions.containsKey(newRef));
    return GroupTracker._create(
      {
        ..._positions,
        newRef: position,
      },
      _groupCount,
    );
  }

  int getPosition(GroupRef ref) {
    if (!_positions.containsKey(ref)) throw ArgumentError("Position not tracked for ref!");
    return _positions[ref]!;
  }

  int get groupCount => _groupCount;

  GroupTracker increment([int by = 1]) => GroupTracker._create(
    {
      for (var MapEntry(key: groupRef, value: position) in _positions.entries)
        groupRef: position + by,
    },
    _groupCount + by,
  );

  static GroupTracker combine(List<GroupTracker> trackers) {
    var combinedPositions = <GroupRef, int>{};
    var totalGroupCount = 0;

    for (var tracker in trackers) {
      for (var MapEntry(key: groupRef, value: position) in tracker._positions.entries) {
        assert (!combinedPositions.containsKey(groupRef));
        combinedPositions[groupRef] = position + totalGroupCount;
      }
      totalGroupCount += tracker._groupCount;
    }

    return GroupTracker._create(combinedPositions, totalGroupCount);
  }
}
