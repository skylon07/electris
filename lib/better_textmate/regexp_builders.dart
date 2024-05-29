abstract base class RegExpBuilder<CollectionT extends Record> {
  CollectionT createCollection();

  // base/fundamental recipe creation functions

  RegExpRecipe exactly(String string) => 
    _escapedPattern(string, RegExp(r"[.?*+\-()\[\]{}\^$|]"));

  BaseRegExpRecipe _escapedPattern(String exprStr, RegExp? escapeExpr) {
    String expr;
    if (escapeExpr != null) {
      expr = exprStr.replaceAllMapped(escapeExpr, (match) => "\\${match[0]}");
    } else {
      expr = exprStr;
    }
    return BaseRegExpRecipe._from(expr);
  }

  RegExpRecipe chars(String charSet) => _chars(charSet, invert: false);

  RegExpRecipe notChars(String charSet) => _chars(charSet, invert: true);

  CharClassRegExpRecipe _chars(String charSet, {bool invert = false}) {
    var baseRecipe = _escapedPattern(charSet, RegExp(r"[\[\]\^\/]"));
    var augment = (expr) => "[${invert? "^":""}$expr]";
    return CharClassRegExpRecipe._from(baseRecipe, augment, inverted: invert);
  }

  // basic composition operations

  RegExpRecipe capture(RegExpRecipe inner, [GroupRef? ref]) {
    var newTracker = inner._tracker.increment();
    if (ref != null) {
      newTracker = newTracker.startTracking(ref);
    }
    var augment = (expr) => "($expr)";
    return CaptureRegExpRecipe._from(inner, augment, newTracker);
  }

  RegExpRecipe concat(List<RegExpRecipe> recipes) => capture(_join(recipes, joinBy: ""));

  AugmentedRegExpRecipe _augment(RegExpRecipe recipe, String Function(String expr) mapExpr) =>
    AugmentedRegExpRecipe._from(recipe, mapExpr);

  JoinedRegExpRecipe _join(List<RegExpRecipe> recipes, {required String joinBy}) {
    if (recipes.isEmpty) throw ArgumentError("Joining list should not be empty.", "recipes"); 
    return JoinedRegExpRecipe._from(recipes, joinBy);
  }


  // repitition and optionality
  
  RegExpRecipe optional(RegExpRecipe inner) =>
    _augment(inner, (expr) => "$expr?");

  RegExpRecipe zeroOrMore(RegExpRecipe inner) =>
    _augment(inner, (expr) => "$expr*");

  RegExpRecipe oneOrMore(RegExpRecipe inner) =>
    _augment(inner, (expr) => "$expr+");

  RegExpRecipe repeatEqual(RegExpRecipe inner, int times) =>
    _augment(inner, (expr) => "$expr{$times}");
    
  RegExpRecipe repeatAtLeast(RegExpRecipe inner, int times) =>
    _augment(inner, (expr) => "$expr{$times,}");

  RegExpRecipe repeatAtMost(RegExpRecipe inner, int times) =>
    _augment(inner, (expr) => "$expr{,$times}");

  RegExpRecipe repeatBetween(RegExpRecipe inner, int lowTimes, int highTimes) =>
    _augment(inner, (expr) => "$expr{$lowTimes,$highTimes}");

  RegExpRecipe either(List<RegExpRecipe> branches) {
    var recipe = _join(branches, joinBy: r"|");
    return capture(EitherRegExpRecipe._from(recipe.sources, recipe.joinBy));
  }

  late final nothing = exactly("");


  // "look around" operations

  RegExpRecipe aheadIs(RegExpRecipe inner) => 
    _augment(inner, (expr) => "(?=$expr)");

  RegExpRecipe aheadIsNot(RegExpRecipe inner) => 
    _augment(inner, (expr) => "(?!$expr)");

  RegExpRecipe behindIs(RegExpRecipe inner) => 
    _augment(inner, (expr) => "(?<=$expr)");

  RegExpRecipe behindIsNot(RegExpRecipe inner) => 
    _augment(inner, (expr) => "(?<!$expr)");

  
  // anchors

  RegExpRecipe startsWith(RegExpRecipe inner) =>
    _augment(inner, (expr) => "^$expr");

  RegExpRecipe endsWith(RegExpRecipe inner) =>
    _augment(inner, (expr) => "$expr\$");

  RegExpRecipe startsAndEndsWith(RegExpRecipe inner) =>
    _augment(inner, (expr) => "^$expr\$");


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
    var inner = _augment(
      exactly(string),
      (expr) => expr.replaceAll(r" ", r"\s+"),
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


sealed class RegExpRecipe {
  final GroupTracker _tracker;

  RegExpRecipe._from(this._tracker);

  String compile() => _expr;
  late final _expr = _normalize()._createExpr();

  int positionOf(GroupRef ref) => _tracker.getPosition(ref);

  String _createExpr();
  RegExpRecipe _normalize() => this;
}

final class BaseRegExpRecipe extends RegExpRecipe {
  final String expr;

  BaseRegExpRecipe._from(this.expr) : super._from(GroupTracker());
  
  @override
  String _createExpr() => expr;
}

final class AugmentedRegExpRecipe extends RegExpRecipe {
  final RegExpRecipe source;
  final String Function(String) augment;

  AugmentedRegExpRecipe._from(this.source, this.augment) : super._from(source._tracker);

  @override
  String _createExpr() => augment(source.compile());
}

final class JoinedRegExpRecipe extends RegExpRecipe {
  final List<RegExpRecipe> sources;
  final String joinBy;

  JoinedRegExpRecipe._from(this.sources, this.joinBy) : 
    super._from(GroupTracker.combine(
      sources.map((source) => source._tracker)
    ));

  @override
  String _createExpr() {
    return sources
      .map((source) => source.compile())
      .join(joinBy);
  }
}


final class CharClassRegExpRecipe extends AugmentedRegExpRecipe {
  final bool inverted;

  CharClassRegExpRecipe._from(super.source, super.augment, {required this.inverted}) : super._from();
}

final class CaptureRegExpRecipe extends AugmentedRegExpRecipe {
  @override
  GroupTracker _tracker;

  CaptureRegExpRecipe._from(super.source, super.augment, this._tracker) : super._from();
}

final class EitherRegExpRecipe extends JoinedRegExpRecipe {
  EitherRegExpRecipe._from(super.sources, super.joinBy) : super._from();

  @override
  RegExpRecipe _normalize() {
    var (chars, notChars, rest) = _flatten();
    var charClass = _combineCharClasses(chars);
    var notCharClass = _combineCharClasses(notChars);
    return EitherRegExpRecipe._from(
      [
        if (charClass != null) charClass,
        if (notCharClass != null) notCharClass,
        ...rest,
      ],
      joinBy,
    );
  }

  EitherFlatClasses _flatten() {
    var charsList = <CharClassRegExpRecipe>[];
    var notCharsList = <CharClassRegExpRecipe>[];
    var restList = <RegExpRecipe>[];

    for (var source in sources) {
      if (source is EitherRegExpRecipe) {
        var (chars, notChars, rest) = source._flatten();
        charsList.addAll(chars);
        notCharsList.addAll(notChars);
        restList.addAll(rest);
      } else {
        var listForSource = switch(source) {
          CharClassRegExpRecipe(inverted: false) => charsList,
          CharClassRegExpRecipe(inverted: true) => notCharsList,
          RegExpRecipe() => restList,
        };
        listForSource.add(source);
      }
    }
    return (charsList, notCharsList, restList);
  }

  CharClassRegExpRecipe? _combineCharClasses(List<CharClassRegExpRecipe> recipes) {
    if (recipes.isEmpty) return null;

    var (combinedClasses, inverted) = recipes
      .map((recipe) => (recipe.source.compile(), recipe.inverted))
      .reduce((last, next) {
        var (lastSource, lastInverted) = last;
        var (nextSource, nextInverted) = next;
        assert (lastInverted == nextInverted);
        return (lastSource + nextSource, nextInverted);
      });
    return CharClassRegExpRecipe._from(
      BaseRegExpRecipe._from(combinedClasses),
      recipes.first.augment,
      inverted: inverted,
    );
  }
}
typedef EitherFlatClasses = (
  List<CharClassRegExpRecipe> charsList,
  List<CharClassRegExpRecipe> notCharsList,
  List<RegExpRecipe>          restList,
);

final class BehindIsNotRegExpRecipe extends AugmentedRegExpRecipe {
  BehindIsNotRegExpRecipe._from(super.source, super.augment) : super._from();

  @override
  RegExpRecipe _normalize() {
    return super._normalize(); // TODO
  }
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
    if (!_positions.containsKey(ref)) throw ArgumentError("Position not tracked for ref!", "ref");
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

  static GroupTracker combine(Iterable<GroupTracker> trackers) {
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
