import 'package:collection/collection.dart';

import '../syntax_printer.dart';


abstract base class SyntaxDefinition<BuilderT extends RegExpBuilder<CollectionT>, CollectionT extends Record> {
  final String langName;
  final List<String> fileTypes;
  final List<DefinitionItem> _items = [];
  late final CollectionT collection;
  
  SyntaxDefinition({
    required this.langName,
    required this.fileTypes,
    required BuilderT builder,
  }) {
    collection = builder.createCollection();
  }

  List<DefinitionItem> get rootItems;

  late final mainBody = MainBody(
    fileTypes: fileTypes,
    langName: langName,
    topLevelPatterns: [for (var item in rootItems) item.asIncludePattern()],
    repository: [for (var item in _items) item.asRepositoryItem()],
  );

  DefinitionItem createItemDirect(
    String identifier,
    {
      required Pattern Function(String debugName, List<Pattern> innerPatterns) createBody,
      List<DefinitionItem>? Function()? createInnerItems,
    }
  ) => DefinitionItem(
    identifier,
    parent: this,
    createBody: createBody,
    createInnerItems: createInnerItems,
  );

  DefinitionItem createItem(
    String identifier,
    {
      StyleName? styleName,
      String? match,
      String? begin,
      String? end,
      List<CapturePattern>? captures,
      List<CapturePattern>? beginCaptures,
      List<CapturePattern>? endCaptures,
      List<DefinitionItem>? Function()? createInnerItems,
    }
  ) {
    var argMap = {
      'debugName': null, // set later
      'styleName': styleName,
      'match': match,
      'begin': begin,
      'end': end,
      'captures': captures,
      'beginCaptures': beginCaptures,
      'endCaptures': endCaptures,
      'innerPatterns': null, // set later
    };
    return createItemDirect(
      identifier,
      createBody: (debugName, innerPatterns) {
        argMap['debugName'] = debugName;
        argMap['innerPatterns'] = innerPatterns;
        return _createItem_smartBody(argMap);
      },
      createInnerItems: createInnerItems,
    );
  }

  Pattern _createItem_smartBody(Map<String, dynamic> argMap) =>
    switch (argMap) {
      {
        'debugName': String debugName,
        'match': String match,

        'styleName': StyleName? styleName,
        'captures': List<CapturePattern>? captures,
        
        'begin': null,
        'end': null,
        'beginCaptures': null,
        'endCaptures': null,
        'innerPatterns': null || [],
      } => 
        MatchPattern(
          debugName: debugName,
          styleName: styleName,
          match: match,
          captures: captures ?? [],
        ),

      {
        'debugName': String debugName,
        'begin': String begin,
        'end': String end,

        'styleName': StyleName? styleName,
        'beginCaptures': List<CapturePattern>? beginCaptures,
        'endCaptures': List<CapturePattern>? endCaptures,
        'innerPatterns': List<Pattern>? innerPatterns,

        'match': null,
        'captures': null,
      } =>
        EnclosurePattern(
          debugName: debugName,
          styleName: styleName,
          innerPatterns: innerPatterns ?? [],
          begin: begin,
          end: end,
          beginCaptures: beginCaptures ?? [],
          endCaptures: endCaptures ?? [],
        ),

      {
        'debugName': String debugName,
        'innerPatterns': List<Pattern> innerPatterns,

        'styleName': StyleName? styleName,

        'match': null,
        'begin': null,
        'end': null,
        'captures': null,
        'beginCaptures': null,
        'endCaptures': null,
      } when innerPatterns.isNotEmpty =>
        GroupingPattern(
          debugName: debugName,
          styleName: styleName,
          innerPatterns: innerPatterns
        ),
      
      _ => throw ArgumentError("Invalid argument pattern"),
    };
}

final class DefinitionItem {
  final SyntaxDefinition parent;
  final String identifier;
  final Pattern Function(String debugName, List<Pattern> innerPatterns) createBody;
  final List<DefinitionItem>? Function()? createInnerItems;

  DefinitionItem(
    this.identifier,
    {
      required this.parent,
      required this.createBody,
      this.createInnerItems,
    }
  );

  late final innerItems = createInnerItems?.call() ?? [];

  RepositoryItem asRepositoryItem() => _repositoryItem;
  late final _repositoryItem = RepositoryItem(
    identifier: identifier,
    body: createBody(
      "${parent.langName}.$identifier",
      innerItems
        .map((item) => item.asIncludePattern())
        .toList(),
    )
  );

  IncludePattern asIncludePattern() => _includePattern;
  late final _includePattern = IncludePattern(identifier: identifier);
}


abstract base class RegExpBuilder<CollectionT extends Record> {
  CollectionT createCollection();

  // base/fundamental recipe creation functions

  RegExpRecipe exactly(String string) => 
    _escapedPattern(string, RegExp(r"[.?*+\-()\[\]{}\^$|]"));

  RegExpRecipe chars(String charSet, {bool invert = false}) {
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
    var zip = IterableZip([
      for (var RegExpRecipe(:_tracker, _createExpr:_transform) in recipes)
        [_tracker, _transform]
    ]);
    var zipList = [...zip];
    
    var trackers = zipList[0].cast<GroupTracker>();
    var transforms = zipList[1].cast<String Function()>();
    return RegExpRecipe._from(
      GroupTracker.combine(trackers),
      () => 
        [
          for (var transform in transforms)
          transform()
        ].join(joinBy),
    );
  }


  // repitition and optionality
  
  RegExpRecipe optional(RegExpRecipe inner) =>
    _mapExpr(capture(inner), (innerExpr) => "$innerExpr?");

  RegExpRecipe zeroOrMore(RegExpRecipe inner) =>
    _mapExpr(capture(inner), (innerExpr) => "$innerExpr*");

  RegExpRecipe oneOrMore(RegExpRecipe inner) =>
    _mapExpr(capture(inner), (innerExpr) => "$innerExpr+");

  RegExpRecipe repeatEqual(RegExpRecipe inner, int times) =>
    _mapExpr(capture(inner), (innerExpr) => "$innerExpr{$times}");
    
  RegExpRecipe repeatAtLeast(RegExpRecipe inner, int times) =>
    _mapExpr(capture(inner), (innerExpr) => "$innerExpr{$times,}");

  RegExpRecipe repeatAtMost(RegExpRecipe inner, int times) =>
    _mapExpr(capture(inner), (innerExpr) => "$innerExpr{,$times}");

  RegExpRecipe repeatBetween(RegExpRecipe inner, int lowTimes, int highTimes) =>
    _mapExpr(capture(inner), (innerExpr) => "$innerExpr{$lowTimes,$highTimes}");

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
      return capture(_join(branches, joinBy: r"|"));
    }
  }


  // "look around" operations

  RegExpRecipe aheadIs(RegExpRecipe inner) => 
    _mapExpr(inner, (innerExpr) => "(?=$innerExpr)");

  RegExpRecipe aheadIsNot(RegExpRecipe inner) => 
    _mapExpr(inner, (innerExpr) => "(?!$innerExpr)");

  RegExpRecipe behindIs(RegExpRecipe inner) => 
    _mapExpr(inner, (innerExpr) => "(?<=$innerExpr)");

  RegExpRecipe behindIsNot(RegExpRecipe inner) => 
    _mapExpr(inner, (innerExpr) => "(?<!$innerExpr)");
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
