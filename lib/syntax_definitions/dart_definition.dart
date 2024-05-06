import './syntax_definition.dart';
import '../syntax_printer.dart';


final class DartDefinition extends SyntaxDefinition<DartRegExpBuilder, DartRegExpCollection> {
  DartDefinition() : super(
    langName: "dart",
    fileTypes: ["dart"],
    builder: DartRegExpBuilder(),
  );

  @override
  late final rootItems = [
    
  ];

  late final self ;

  /// Detects non-[Record] pairs of parentheses, like `(...) {...}`.
  /// 
  /// This "hack" expression is attempting to solve a contextual grammar problem
  /// with a single regular expression. This expression (coupled with the other
  /// record and function definitions) roughly emulates the behavior that a full
  /// grammar would be able to provide. It does so by making some assumptions
  /// about the structure and rules of the problem its trying to solve.
  /// 
  /// The problem is the collision between the (anonymous) function and record 
  /// patterns. More specifically, the problem is distinguishing the "(" in
  /// `(int, int)` from the "(" in `(int val1) { ... }`. This problem cannot truly
  /// be solved with regular expressions, as it requires (at least) a context-free
  /// grammar to define it completely. However, using this regular expression
  /// becomes the only alternative after recognizing some limitations with how
  /// grammars work in TextMate.
  /// 
  /// While defining matching patterns for grammars is possible (ie begin/end pairs),
  /// there is no backtracking mechanism to decide later what a previous match
  /// *should* have been. This means that when the first "(" is encountered, we
  /// must decide right then whether it is for a record or a function. Because of
  /// this limitation, all of the context that would need to be known to make this
  /// decision must be encoded as extra regex statements (like lookaheads or
  /// lookbehinds) within the match pattern itself. This is why the problem cannot
  /// be solved by defining a grammar.
  /// 
  /// However, this is still not the whole problem. Since there is no way to "count
  /// pairs" with regular expressions, there are many cases where it is impossible
  /// to determine whether a "(" is a part of a record or a function. For example,
  /// consider this anonymous callback example:
  /// ```dart
  /// runCallback(
  ///   (((String, int), int) myWeirdRecord) {
  ///     // ...
  ///   }
  /// );
  /// ```
  /// There is no way to define "record" and "function" regular expressions that
  /// will always consistently match their corresponding "(" characters. A naive
  /// approach for the "function" expression would be to look for the "{" character
  /// later. However, 
  late final nonRecordParens_hack;
}


final class DartRegExpBuilder extends RegExpBuilder<DartRegExpCollection> {
  @override
  DartRegExpCollection createCollection() {
    var identifierLowerChar   = chars(r"a-z");
    var identifierUpperChar   = chars(r"A-Z");
    var identifierNumberChar  = chars(r"0-9");
    var identifierSpecialChar = chars(r"_$");
    var identifierChar = either([
      identifierLowerChar,
      identifierUpperChar,
      identifierNumberChar,
      identifierSpecialChar,
    ]);

    var variablePlain = oneOrMore(identifierChar);
    var variableType = concat([
      zeroOrMore(identifierSpecialChar),
      identifierUpperChar,
      zeroOrMore(identifierChar),
    ]);
    var variableConst = concat([
      variableType,
      behindIsNot(either([
        zeroOrMore(identifierChar),
        identifierLowerChar,
        zeroOrMore(identifierChar),
      ])),
    ]);

    return (
      variablePlain: variablePlain, 
      variableType: variableType, 
      variableConst: variableConst,
    );
  }
}

typedef DartRegExpCollection = ({
  RegExpRecipe variablePlain,
  RegExpRecipe variableType,
  RegExpRecipe variableConst,
});
