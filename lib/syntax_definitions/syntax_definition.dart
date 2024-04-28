import 'package:collection/collection.dart';

import '../syntax_printer.dart';


abstract base class SyntaxDefinition {
  MainBody get body; // should implement as a `late final` value
  

  // basic/fundamental result manipulation

  SyntaxResult pattern(String expr) => (expr, GroupTracker());

  SyntaxResult mapExpr(SyntaxResult result, String Function(String innerExpr) convert) {
    var (expr, tracker) = result;
    var newExpr = convert(expr);
    return (newExpr, tracker);
  }

  SyntaxResult capture(SyntaxResult inner, [GroupRef? ref]) {
    var (innerExpr, tracker) = inner;
    tracker = tracker.increment();
    if (ref != null) {
      tracker = tracker.startTracking(ref);
    }
    return ("($innerExpr)", tracker);
  }

  SyntaxResult concat(List<SyntaxResult> results) {
    var zip = IterableZip([
      for (var (expr, tracker) in results)
        [expr, tracker]
    ]);
    var [
      exprs,
      trackers,
    ] = [...zip];
    return (
      exprs.cast<String>().join(""),
      GroupTracker.combine(trackers.cast<GroupTracker>()),
    );
  }


  // repitition and optionality
  
  SyntaxResult optional(SyntaxResult inner) =>
    mapExpr(capture(inner), (innerExpr) => "$innerExpr?");

  SyntaxResult zeroOrMore(SyntaxResult inner) =>
    mapExpr(capture(inner), (innerExpr) => "$innerExpr*");

  SyntaxResult oneOrMore(SyntaxResult inner) =>
    mapExpr(capture(inner), (innerExpr) => "$innerExpr+");

  SyntaxResult repeatEqual(SyntaxResult inner, int times) =>
    mapExpr(capture(inner), (innerExpr) => "$innerExpr{$times}");
    
  SyntaxResult repeatAtLeast(SyntaxResult inner, int times) =>
    mapExpr(capture(inner), (innerExpr) => "$innerExpr{$times,}");

  SyntaxResult repeatAtMost(SyntaxResult inner, int times) =>
    mapExpr(capture(inner), (innerExpr) => "$innerExpr{,$times}");

  SyntaxResult repeatBetween(SyntaxResult inner, int lowTimes, int highTimes) =>
    mapExpr(capture(inner), (innerExpr) => "$innerExpr{$lowTimes,$highTimes}");


  // "look around" operations

  SyntaxResult aheadIs(SyntaxResult inner) => 
    mapExpr(inner, (innerExpr) => "(?=$innerExpr)");

  SyntaxResult aheadIsNot(SyntaxResult inner) => 
    mapExpr(inner, (innerExpr) => "(?!$innerExpr)");

  SyntaxResult behindIs(SyntaxResult inner) => 
    mapExpr(inner, (innerExpr) => "(?<=$innerExpr)");

  SyntaxResult behindIsNot(SyntaxResult inner) => 
    mapExpr(inner, (innerExpr) => "(?<!$innerExpr)");


  // other helpful stuff

  List<IncludePattern> includes(List<String> repoIdentifiers) => 
    [
      for (var identifier in repoIdentifiers)
      IncludePattern(
        identifier: identifier.contains(RegExp(r"^[$#].*$")) ? 
          "#$identifier" : identifier
      )
    ];
}


typedef SyntaxResult = (String, GroupTracker);

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
