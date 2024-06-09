import './regexp_recipes.dart';


abstract base class RegExpBuilder<CollectionT> {
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
    return BaseRegExpRecipe(expr);
  }

  RegExpRecipe chars(String charSet) => _chars(charSet, invert: false);

  RegExpRecipe notChars(String charSet) => _chars(charSet, invert: true);

  CharClassRegExpRecipe _chars(String charSet, {bool invert = false}) {
    var baseRecipe = _escapedPattern(charSet, RegExp(r"[\[\]\^\/]"));
    var augment = (expr) => "[${invert? "^":""}$expr]";
    return CharClassRegExpRecipe(baseRecipe, augment, inverted: invert);
  }

  // basic composition operations

  RegExpRecipe capture(RegExpRecipe inner, [GroupRef? ref]) {
    var augment = (expr) => "($expr)";
    return CaptureRegExpRecipe(inner, augment, ref: ref);
  }

  RegExpRecipe concat(List<RegExpRecipe> recipes) => capture(_join(recipes, joinBy: ""));

  AugmentedRegExpRecipe _augment(RegExpRecipe recipe, String Function(String expr) mapExpr) =>
    AugmentedRegExpRecipe(recipe, mapExpr);

  JoinedRegExpRecipe _join(List<RegExpRecipe> recipes, {required String joinBy}) {
    if (recipes.isEmpty) throw ArgumentError("Joining list should not be empty.", "recipes"); 
    return JoinedRegExpRecipe(recipes, joinBy);
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
    return capture(EitherRegExpRecipe(recipe.sources, recipe.joinBy));
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


final class BlankBuilder extends RegExpBuilder<()> {
  @override
  () createCollection() => ();
}
final regExpBuilder = BlankBuilder();
