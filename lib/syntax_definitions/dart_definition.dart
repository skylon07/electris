import 'package:vscode_theming/vscode_theming.dart';


final class DartDefinition extends SyntaxDefinition<DartRegExpCollector, DartRegExpCollector> {
  DartDefinition() : super(
    scopePrefix: "electris",
    langName: "dart",
    isTextSyntax: false,
    fileTypes: ["dart"],
    builder: DartRegExpCollector(),
  );

  @override
  late final rootUnits = [
    keyword,

    literalNumber,
    literalString,
    literalKeyword,

    annotation,
    variableConst,
    variableType,
    variablePlain,
  ];

  late final variablePlain = createUnit(
    "variablePlain",
    styleName: ElectrisStyleName.sourceCode_variable,
    match: collection.variablePlain,
  );

  late final variableType = createUnit(
    "variableType",
    styleName: ElectrisStyleName.sourceCode_types_type,
    match: collection.variableType,
  );

  late final variableConst = createUnit(
    "variableConst",
    styleName: ElectrisStyleName.sourceCode_primitiveLiteral,
    match: collection.variableConst,
  );

  late final keyword = createUnit(
    "keyword",
    styleName: ElectrisStyleName.sourceCode_operator,
    match: collection.keyword,
    captures: {
      collection.keywordOperator_valid: ElectrisStyleName.sourceCode_functionCall,
      collection.keywordOperator_invalid: ElectrisStyleName.sourceCode_escape,
    },
  );

  late final annotation = createUnit(
    "annotation",
    styleName: ElectrisStyleName.sourceCode_operator,
    match: collection.annotation,
  );

  late final literalNumber = createUnit(
    "literalNumber",
    styleName: ElectrisStyleName.sourceCode_primitiveLiteral,
    match: collection.literalNumber,
  );

  late final literalString = createUnit(
    "literalString",
    styleName: ElectrisStyleName.sourceCode_primitiveLiteral,
    innerUnits: () => [
      createUnitInline(
        matchPair: collection.literalStringDouble,
        innerUnits: () => literalStringInnerUnits,
      ),
      createUnitInline(
        matchPair: collection.literalStringSingle,
        innerUnits: () => literalStringInnerUnits,
      ),
      createUnitInline(
        matchPair: collection.literalStringTripleDouble,
        innerUnits: () => literalStringInnerUnits,
      ),
      createUnitInline(
        matchPair: collection.literalStringTripleSingle,
        innerUnits: () => literalStringInnerUnits,
      ),
      createUnitInline(matchPair: collection.rawStringDouble),
      createUnitInline(matchPair: collection.rawStringSingle),
      createUnitInline(matchPair: collection.rawStringTripleDouble),
      createUnitInline(matchPair: collection.rawStringTripleSingle),
    ]
  );

  late final literalStringInnerUnits = [
    literalStringInterpOper,
    literalStringEscapeSequence,
  ];

  late final literalStringInterpOper = createUnit(
    "literalStringInterpOper",
    innerUnits: () => [
      createUnitInline(
        matchPair: collection.literalStringInterpOperExpression,
        beginCaptures: {
          collection.literalStringInterpOperExpression_brace: ElectrisStyleName.sourceCode_operator,
        },
        endCaptures: {
          collection.literalStringInterpOperExpression_brace: ElectrisStyleName.sourceCode_operator,
        },
        innerUnits: () => [self],
      ),
      // this unit must be last; it handles the base `$` case
      createUnitInline(
        styleName: ElectrisStyleName.sourceCode_operator,
        matchPair: collection.literalStringInterpOperIdentifier,
        innerUnits: () => [
          createUnitInline(
            styleName: ElectrisStyleName.sourceCode_variable,
            match: collection.variablePlainNoDollar,
          ),
        ],
      ),
    ],
  );

  late final literalStringEscapeSequence = createUnit(
    "literalStringEscapeSequence",
    styleName: ElectrisStyleName.sourceCode_escape,
    match: collection.literalStringEscapeSequence,
  );

  late final literalKeyword = createUnit(
    "literalKeyword",
    styleName: ElectrisStyleName.sourceCode_primitiveLiteral,
    match: collection.literalKeyword,
  );
  

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


final class DartRegExpCollector extends RegExpBuilder<DartRegExpCollector> {
  late final RegExpRecipe variablePlain;
  late final RegExpRecipe variablePlainNoDollar;
  late final RegExpRecipe variableType;
  late final RegExpRecipe variableConst;

  late final RegExpRecipe keyword;
  late final GroupRef     keywordOperator_valid = GroupRef();
  late final GroupRef     keywordOperator_invalid = GroupRef();

  late final RegExpRecipe annotation;

  late final RegExpRecipe literalNumber;

  late final RegExpPair   literalStringDouble;
  late final RegExpPair   literalStringSingle;
  late final RegExpPair   literalStringTripleDouble;
  late final RegExpPair   literalStringTripleSingle;
  late final RegExpPair   rawStringDouble;
  late final RegExpPair   rawStringSingle;
  late final RegExpPair   rawStringTripleDouble;
  late final RegExpPair   rawStringTripleSingle;
  late final RegExpPair   literalStringInterpOperIdentifier;
  late final RegExpPair   literalStringInterpOperExpression;
  late final GroupRef     literalStringInterpOperExpression_brace = GroupRef();
  late final RegExpRecipe literalStringEscapeSequence;
  late final RegExpRecipe literalKeyword;

  @override
  DartRegExpCollector createCollection() {
    var identifierLowerChar     = chars(r"a-z");
    var identifierUpperChar     = chars(r"A-Z");
    var identifierLowerHexChar  = chars(r"a-f");
    var identifierUpperHexChar  = chars(r"A-F");
    var identifierNumberChar    = chars(r"0-9");
    var identifierSpacerChar    = chars(r"_");
    var identifierDollarChar    = chars(r"$");
    var identifierCharWithoutDollar = either([
      identifierLowerChar,
      identifierUpperChar,
      identifierNumberChar,
      identifierSpacerChar,
    ]);
    // TODO: this produces [$]|([a-z...]); it thinks capture(either(chars(...))) is a "rest";
    //  it should instead combine all of them
    var identifierChar = either([
      identifierCharWithoutDollar,
      identifierDollarChar,
    ]);
    var identifierCharOrDot = either([
      identifierChar,
      chars("."),
    ]);
    var identifierHexChar = either([
      identifierNumberChar,
      identifierLowerHexChar,
      identifierUpperHexChar,
    ]);

    this.variablePlain = oneOrMore(identifierChar);
    this.variablePlainNoDollar = oneOrMore(identifierCharWithoutDollar);
    this.variableType = concat([
      zeroOrMore(identifierSpacerChar),
      identifierUpperChar,
      zeroOrMore(identifierChar),
    ]);
    this.variableConst = concat([
      aheadIsNot(concat([
        zeroOrMore(identifierChar),
        identifierLowerChar,
        zeroOrMore(identifierChar),
      ])),
      variableType,
      // must be at least two letters long; single uppercase should be type color
      // (to avoid flashing const color when typing out type names)
      identifierChar,
    ]);

    var keywordHard = either([
      phrase("class"),    phrase("extends"),  phrase("with"),   phrase("super"),
      phrase("is"),       phrase("as"),       phrase("enum"),   phrase("var"),
      phrase("const"),    phrase("final"),    phrase("if"),     phrase("else"),
      phrase("for"),      phrase("in"),       phrase("while"),  phrase("continue"),
      phrase("break"),    phrase("do"),       phrase("switch"), phrase("case"),
      phrase("default"),  phrase("try"),      phrase("catch"),  phrase("finally"),
      phrase("throw"),    phrase("rethrow"),  phrase("assert"), phrase("this"),
      phrase("new"),      phrase("return"),
    ]);
    
    var keywordSoft = concat([
      either([
        phrase("import"),     phrase("export"),     phrase("library"),    phrase("hide"),
        phrase("show"),       phrase("deferred"),   phrase("part of"),    phrase("part"),
        phrase("abstract"),   phrase("interface"),  phrase("implements"), phrase("mixin"),
        phrase("base"),       phrase("sealed"),     phrase("typedef"),    phrase("dynamic"),
        phrase("static"),     phrase("covariant"),  phrase("late"),       phrase("extension type"),
        phrase("extension"),  phrase("when"),       phrase("on"),         phrase("async"),
        phrase("await"),      phrase("sync"),       phrase("get"),        phrase("set"),
        phrase("yield"),      phrase("external"),   phrase("required"),   phrase("factory"),
        phrase("macro"),
      ]),
      // TODO: this should probably be a variable or two... ("function params" and "function type params")
      aheadIsNot(spaceBefore(chars("(<"))),
    ]);

    var validOperator = concat([
      either([
        exactly(">"),   exactly(">="),  exactly("<"),   exactly("<="),  exactly("=="),
        exactly("+"),   exactly("-"),   exactly("*"),   exactly("/"),   exactly("~/"),  exactly("%"),
        exactly("<<"),  exactly(">>"),  exactly(">>>"),
        exactly("^"),   exactly("&"),   exactly("|"),   exactly("~"),
        exactly("[]"),  exactly("[]="),
      ]),
      aheadIs(either([
        // TODO: this should probably be a variable or two... ("function params" and "function type params")
        spaceBefore(chars("(<")),
        endsWith(space(req: false)),
      ])),
    ]);
    var invalidOperator = either([
      zeroOrMore(notChars(r"(\s")),
      endsWith(nothing),
    ]);
    var keywordOperator = concat([
      phrase("operator"),
      space(req: false),
      either([
        capture(validOperator, this.keywordOperator_valid),
        capture(invalidOperator, this.keywordOperator_invalid),
      ]),
    ]);

    this.keyword = either([keywordHard, keywordSoft, keywordOperator]);

    this.annotation = concat([
      exactly("@"),
      zeroOrMore(identifierCharOrDot),
    ]);

    var literalNumberDecimal = concat([
      exactly("."),
      oneOrMore(identifierNumberChar),
    ]);
    var literalNumberScientific = concat([
      chars("eE"),
      optional(chars("+-")),
      oneOrMore(identifierNumberChar),
    ]);
    this.literalNumber = either([
      concat([
        exactly("0"),
        chars("xX"),
        zeroOrMore(identifierHexChar),
      ]),
      concat([
        oneOrMore(identifierNumberChar),
        optional(literalNumberDecimal),
        optional(literalNumberScientific),
      ]),
      concat([
        literalNumberDecimal,
        optional(literalNumberScientific)
      ]),
    ]);

    RegExpPair stringPattern(RegExpRecipe pattern, {required bool eolTerminates, required bool isRaw}) {
      var patterns = pair(begin: pattern, end: pattern);
      if (eolTerminates) {
        patterns = pair(
          begin: patterns.begin,
          end: either([patterns.end, endsWith(nothing)]),
        );
      }
      if (isRaw) {
        patterns = pair(
          begin: concat([exactly("r"), patterns.begin]),
          end: patterns.end,
        );
      }
      return patterns;
    }
    RegExpPair stringPattern_singlePair(RegExpRecipe pattern, {required bool isRaw}) =>
      stringPattern(
        pattern,
        eolTerminates: true,
        isRaw: isRaw,
      );
    RegExpPair stringPattern_triplePair(RegExpRecipe pattern, {required bool isRaw}) =>
      stringPattern(
        pattern,
        eolTerminates: false,
        isRaw: isRaw,
      );
    var stringDQuote = exactly('"');
    var stringSQuote = exactly("'");
    var stringTDQuote = exactly('"""');
    var stringTSQuote = exactly("'''");
    this.literalStringDouble       = stringPattern_singlePair(stringDQuote,   isRaw: false);
    this.literalStringSingle       = stringPattern_singlePair(stringSQuote,   isRaw: false);
    this.literalStringTripleDouble = stringPattern_triplePair(stringTDQuote,  isRaw: false);
    this.literalStringTripleSingle = stringPattern_triplePair(stringTSQuote,  isRaw: false);
    this.rawStringDouble           = stringPattern_singlePair(stringDQuote,   isRaw: true);
    this.rawStringSingle           = stringPattern_singlePair(stringSQuote,   isRaw: true);
    this.rawStringTripleDouble     = stringPattern_triplePair(stringTDQuote,  isRaw: true);
    this.rawStringTripleSingle     = stringPattern_triplePair(stringTSQuote,  isRaw: true);

    this.literalStringInterpOperIdentifier = pair( 
      begin: exactly(r"$"),
      end: aheadIsNot(identifierCharWithoutDollar),
    );
    this.literalStringInterpOperExpression = pair(
      begin: capture(
        exactly(r"${"),
        this.literalStringInterpOperExpression_brace,
      ),
      end: capture(
        exactly(r"}"),
        this.literalStringInterpOperExpression_brace,
      ),
    );
    this.literalStringEscapeSequence = either([
      concat([
        exactly(r"\x"),
        repeatAtMost(identifierHexChar, 2),
      ]),
      // \u{...} case must be above general \u... case
      concat([
        exactly(r"\u{"),
        zeroOrMore(identifierHexChar),
        exactly(r"}"),
      ]),
      concat([
        exactly(r"\u"),
        repeatAtMost(identifierHexChar, 4),
      ]),
      // general/usual case has to be last
      concat([
        exactly(r"\"),
        optional(anything),
      ]),
    ]);

    this.literalKeyword = either([
      phrase("true"),
      phrase("false"),
      phrase("null"),
    ]);

    return this;
  }
}


// TODO: needs to be moved to a different file that is for more generalized things
enum ElectrisStyleName implements StyleName {
  sourceCode_variable("source-code.variable"),
  sourceCode_operator("source-code.operator"),
  sourceCode_primitiveLiteral("source-code.primitive-literal"),
  sourceCode_escape("source-code.escape"),
  sourceCode_comment("source-code.comment"),
  sourceCode_documentation("source-code.documentation"),
  sourceCode_types_type("source-code.types.type"),
  sourceCode_types_typeRecursive("source-code.types.type-recursive"),
  sourceCode_functionCall("source-code.function-call"),
  sourceCode_punctuation("source-code.types.punctuation"),
  
  text("text"),
  sourceText("source-text"),

  markdown_styleOperator("markdown.style-operator"),
  markdown_bold("markdown.bold"),
  markdown_emphasized("markdown.emphasized"),
  markdown_strikethrough("markdown.strikethrough"),
  markdown_heading("markdown.heading"),
  markdown_horizontalRule("markdown.horizontal-rule"),
  markdown_code("markdown.code"),
  markdown_codeLang("markdown.code-lang"),
  markdown_imageLink("markdown.image-link"),
  markdown_linkPath("markdown.link-path"),
  markdown_linkHoverTitle("markdown.link-hover-title"),
  markdown_escape("markdown.escape"),
  markdown_extended_styleOperator("markdown.extended.style-operator"),
  markdown_extended_highlighted("markdown.extended.highlighted"),
  markdown_extended_subscript("markdown.extended.subscript"),

  xml_tagBrace("xml.tag-brace"),
  xml_tagLabel("xml.tagLabel"),
  xml_property("xml.property"),
  xml_propertyPunctuation("xml.property-punctuation"),
  xml_propertyInvalid("xml.property-invalid"),
  xml_propertyValue("xml.property-value"),
  xml_propertyAssignment("xml.property-assignment"),
  xml_comment("xml.comment"),

  gitignore_comment("gitignore.comment"),
  gitignore_file("gitignore.file"),
  gitignore_punctuation("gitignore.punctuation"),
  gitignore_operator("gitignore.operator");

  
  final String _scope;
  String get scope => "electris.$_scope";

  const ElectrisStyleName(this._scope);
}
