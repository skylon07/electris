import 'package:vscode_theming/vscode_theming.dart';

import '../style_names.dart';


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
    typeAfterKeywordContext,
    typeAnnotationContext,
    typeParameterContext,
    defaultContext,
  ];

  
  // -- contexts and their units --

  late final typeAfterKeywordContext = createUnit(
    "typeAfterKeywordContext",
    matchPair: collection.typeAfterKeywordContext,
    innerUnits: () => typeContextUnits,
  );

  late final typeAnnotationContext = createUnit(
    "typeAnnotationContext",
    matchPair: collection.typeAnnotationContext,
    innerUnits: () => typeContextUnits,
  );

  late final typeParameterContext = createUnit(
    "typeParameterContext",
    matchPair: collection.typeParameterContext,
    innerUnits: () => typeContextUnits,
  );

  late final defaultContext = createUnit(
    "defaultContext",
    innerUnits: () => defaultContextUnits,
  );

  late final typeContextUnits = [
    typeParameterKeyword, // `extends` must be above `extends_var`
    genericList,
    nullableOperator,
    functionType, // `someType Function()` must be above `someType`
    recordListTop,
    typeIdentifier,
  ];

  late final defaultContextUnits = [
    comment,

    keyword, // `var` must be above `var_iable`

    literalNumber, // `10` must be above `someVar_10`
    literalString,
    literalKeyword, // `true` must be above `true_thy`
    variableConst, // `MY_CONST` must be above `MyConst` and `myConst`

    builtinType, // `int` must be above `int_eger`
    variableType, // `MyType` must be above `myType`

    simpleOperation, // `?` in `_?._` must be above `_ ? _ : _`
    conditionalOperation, // `:` in `_ ? _ : _` must be above `{_: _}`
    mapLiteralPunctuation, // `{}` must be above `{`, `}` (ie general punctuation)

    functionCall, // `myFunction()` must be above `myFunction_noCall`
    functionCallArgumentList, // not inner unit for `functionCall` since it also applies to anonymous functions

    annotation,
    organizationalPunctuation,
    variablePlain,
  ];


  // -- type context units --

  late final typeIdentifier = createUnit(
    "typeIdentifier",
    styleName: ElectrisStyleName.sourceCode_types_type,
    match: collection.typeIdentifier,
  );

  late final nullableOperator = createUnit(
    "nullableOperator",
    styleName: ElectrisStyleName.sourceCode_types_type,
    match: collection.nullableOperator,
  );

  late final ScopeUnit genericList = createUnit(
    "genericList",
    styleName: ElectrisStyleName.sourceCode_types_typeRecursive,
    matchPair: collection.genericList,
    innerUnits: () => [
      recordListNoStyle, // not recursive to avoid excessive shading
      recursiveTypeContextUnits,
    ],
  );

  ScopeUnit recordListFactory(String identifier, ElectrisStyleName? styleName) =>
    createUnit(
      identifier,
      styleName: styleName,
      matchPair: collection.recordList,
      innerUnits: () => [
        recursiveTypeContextUnits,
      ],
    );
  late final recordListNoStyle    = recordListFactory("recordListNoStyle",    null);
  late final recordListTop        = recordListFactory("recordListTop",        ElectrisStyleName.sourceCode_types_type);
  late final recordListRecursive  = recordListFactory("recordListRecursive",  ElectrisStyleName.sourceCode_types_typeRecursive);

  late final ScopeUnit functionType = createUnit(
    "functionType",
    styleName: ElectrisStyleName.sourceCode_types_type,
    matchPair: collection.functionType,
    innerUnits: () => typeContextUnits,
  );

  late final ScopeUnit recursiveTypeContextUnits = createUnit(
    "recursiveTypeParameter",
    innerUnits: () => [
      typeParameterKeyword,
      genericList,
      recordListRecursive,
      // not all type context units are included since they break the scopes that shade nested items
    ],
  );

  late final typeParameterKeyword = createUnit(
    "typeParameterKeyword",
    styleName: ElectrisStyleName.sourceCode_operator,
    match: collection.typeParameterKeyword,
  );


  // -- default context units --

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
      collection.keywordOperator_$valid: ElectrisStyleName.sourceCode_functionCall,
      collection.keywordOperator_$invalid: ElectrisStyleName.sourceCode_escape,
    },
  );

  late final annotation = createUnit(
    "annotation",
    styleName: ElectrisStyleName.sourceCode_operator,
    match: collection.annotation,
  );

  late final organizationalPunctuation = createUnit(
    "organizationalPunctuation",
    styleName: ElectrisStyleName.sourceCode_punctuation,
    match: collection.organizationalPunctuation,
  );

  late final mapLiteralPunctuation = createUnit(
    "mapLiteralPunctuation",
    beginCaptures: {
      entireRecipe: ElectrisStyleName.sourceCode_punctuation,
    },
    endCaptures: {
      entireRecipe: ElectrisStyleName.sourceCode_punctuation,
    },
    matchPair: collection.mapLiteralPunctuation,
    innerUnits: () => [
      organizationalPunctuation, // overrides "else" operator `:` in conditionals `_ ? _ : _`
      self,
    ],
  );

  late final simpleOperation = createUnit(
    "simpleOperation",
    styleName: ElectrisStyleName.sourceCode_operator,
    match: collection.simpleOperation,
  );
  
  late final conditionalOperation = createUnit(
    "conditionalOperation",
    matchPair: collection.conditionalOperation,
    beginCaptures: {
      collection.conditionalOperation_$test: ElectrisStyleName.sourceCode_operator
    },
    endCaptures: {
      collection.conditionalOperation_$else: ElectrisStyleName.sourceCode_operator
    },
    innerUnits: () => [self],
  );

  late final functionCall = createUnit(
    "functionCall",
    beginCaptures: {
      collection.functionCall_$name: ElectrisStyleName.sourceCode_functionCall,
    },
    matchPair: collection.functionCall,
    innerUnits: () => [self],
  );

  late final functionCallArgumentList = createUnit(
    "functionCallArgumentList",
    beginCaptures: {
      entireRecipe: ElectrisStyleName.sourceCode_punctuation,
    },
    endCaptures: {
      entireRecipe: ElectrisStyleName.sourceCode_punctuation,
    },
    matchPair: collection.recordList,
    innerUnits: () => [self],
  );

  late final literalNumber = createUnit(
    "literalNumber",
    styleName: ElectrisStyleName.sourceCode_primitiveLiteral,
    match: collection.literalNumber,
  );

  late final ScopeUnit literalString = createUnit(
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
          collection.literalStringInterpOperExpression_$brace: ElectrisStyleName.sourceCode_operator,
        },
        endCaptures: {
          collection.literalStringInterpOperExpression_$brace: ElectrisStyleName.sourceCode_operator,
        },
        innerUnits: () => defaultContextUnits,
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
  
  late final ScopeUnit comment = createUnit(
    "comments",
    innerUnits: () => [
      // this unit must be above singleLineComment, since it is a substring
      createUnitInline(
        styleName: ElectrisStyleName.sourceCode_documentation,
        match: collection.singleLineDocComment,
      ),
      createUnitInline(
        styleName: ElectrisStyleName.sourceCode_comment,
        match: collection.singleLineComment,
      ),
      createUnitInline(
        styleName: ElectrisStyleName.sourceCode_comment,
        matchPair: collection.multiLineComment,
        innerUnits: () => [comment],
      ),
    ]
  );

  late final builtinType = createUnit(
    "builtinType",
    styleName: ElectrisStyleName.sourceCode_types_type,
    match: collection.builtinType,
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
  late final RegExpPair   typeAfterKeywordContext;
  late final RegExpPair   typeAnnotationContext;
  late final RegExpPair   typeParameterContext;
  
  late final RegExpRecipe variablePlain;
  late final RegExpRecipe variablePlainNoDollar;
  late final RegExpRecipe variableType;
  late final RegExpRecipe variableConst;

  late final RegExpRecipe keyword;
  late final GroupRef     keywordOperator_$valid = GroupRef();
  late final GroupRef     keywordOperator_$invalid = GroupRef();

  late final RegExpRecipe annotation;
  late final RegExpRecipe organizationalPunctuation;
  late final RegExpPair   mapLiteralPunctuation;
  late final RegExpRecipe simpleOperation;
  late final RegExpPair   conditionalOperation;
  late final GroupRef     conditionalOperation_$test = GroupRef();
  late final GroupRef     conditionalOperation_$else = GroupRef();

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
  late final GroupRef     literalStringInterpOperExpression_$brace = GroupRef();
  late final RegExpRecipe literalStringEscapeSequence;

  late final RegExpRecipe literalKeyword;

  late final RegExpRecipe singleLineComment;
  late final RegExpRecipe singleLineDocComment;
  late final RegExpPair   multiLineComment;

  late final RegExpRecipe builtinType;
  late final RegExpRecipe typeIdentifier;
  late final RegExpRecipe nullableOperator;
  late final RegExpPair   genericList;
  late final RegExpRecipe typeParameterKeyword;

  late final RegExpPair   recordList;

  late final RegExpPair   functionCall;
  late final GroupRef     functionCall_$name = GroupRef();
  late final RegExpPair   functionType;

  @override
  DartRegExpCollector createCollection() {
    var numberChar          = chars(r"0..9");
    var numberLowerHexChar  = chars(r"a..f");
    var numberUpperHexChar  = chars(r"A..F");
    var literalNumberDecimal = concat([
      exactly("."),
      oneOrMore(numberChar),
    ]);
    var literalNumberScientific = concat([
      chars("eE"),
      optional(chars("+-")),
      oneOrMore(numberChar),
    ]);
    var hexNumberChar = either([
      numberChar,
      numberLowerHexChar,
      numberUpperHexChar,
    ]);
    this.literalNumber = either([
      concat([
        exactly("0"),
        chars("xX"),
        zeroOrMore(hexNumberChar),
      ]),
      concat([
        oneOrMore(numberChar),
        optional(literalNumberDecimal),
        optional(literalNumberScientific),
      ]),
      concat([
        literalNumberDecimal,
        optional(literalNumberScientific)
      ]),
    ]);

    var identifierLowerChar     = chars(r"a..z");
    var identifierUpperChar     = chars(r"A..Z");
    var identifierSpacerChar    = chars(r"_");
    var identifierDollarChar    = chars(r"$");
    var identifierCharsSet      = [
      identifierLowerChar,
      identifierUpperChar,
      identifierSpacerChar,
      identifierDollarChar,
      numberChar,
    ];
    var identifierChar = either(identifierCharsSet);
    var identifierCharOrDot = either([
      identifierChar,
      chars("."),
    ]);

    this.variablePlain = oneOrMore(identifierChar);
    this.variablePlainNoDollar = oneOrMore(either([
      for (var char in identifierCharsSet)
        if (char != identifierDollarChar) char
    ]));
    this.nullableOperator = exactly("?");
    this.variableType = concat([
      zeroOrMore(either([
        for (var char in identifierCharsSet)
          if (char != identifierUpperChar && char != identifierLowerChar) char
      ])),
      identifierUpperChar,
      zeroOrMore(identifierChar),
    ]);
    this.variableConst = concat([
      // must be at least two letters long; single uppercase should be type color
      // (to avoid flashing const color when typing out type names)
      repeatAtLeast(2, concat([
        zeroOrMore(either([
          for (var char in identifierCharsSet)
            if (char != identifierUpperChar && char != identifierLowerChar) char
        ])),
        identifierUpperChar,
      ])),
      zeroOrMore(either([
        for (var char in identifierCharsSet)
          if (char != identifierLowerChar) char
      ])),
      aheadIsNot(identifierChar),
    ]);

    this.builtinType = either([
      phrase("num"), phrase("int"), phrase("double"), phrase("bool"), phrase("void"),
    ]);
    var validGenericChars = notChars(r"+-*/^|&~=");
    this.genericList = pair(
      begin: concat([
        exactly("<"),
        aheadIs(either([
          concat([
            zeroOrMore(validGenericChars),
            exactly(">"),
          ]),
          concat([
            oneOrMore(validGenericChars),
            endsWith(space(req: false)),
          ]),
        ])),
      ]),
      end: exactly(">"),
    );
    this.typeIdentifier = oneOrMore(identifierCharOrDot);
    this.typeParameterKeyword = either([
      phrase("dynamic"), phrase("extends"),
    ]);

    // fixes recognizing record related stuff inside strings, ex `{ (0, false): "(match) yes", }`
    var knownInvalidRecordChars = zeroOrMore(notChars("\"'"));
    // any `recordList.asSingleRecipe()` should instead be this
    var recordListAsSingleRecipe = recordList.asSingleRecipe(knownInvalidRecordChars);
    this.recordList = pair(
      begin: exactly("("),
      end: exactly(")"),
    );

    var functionCallParametersStart = concat([
      space(req: false),
      optional(exactly("!")),
      space(req: false),
      optional(genericList.asSingleRecipe()),
      space(req: false),
      recordList.begin,
    ]);
    var multilineGenericListStart = concat([
      genericList.begin,
      endsWith(space(req: false)),
    ]);
    this.functionCall = pair(
      begin: concat([
        capture(variablePlain, functionCall_$name),
        aheadIs(either([
          functionCallParametersStart,
          multilineGenericListStart,
          genericList.begin,
        ])),
      ]),
      end: behindIs(recordList.end),
    );

    this.functionType = pair(
      begin: concat([
        phrase("Function"),
        aheadIs(functionCallParametersStart),
      ]),
      end: behindIs(recordList.end),
    );

    var keywordHardWord = either([
      phrase("class"),    phrase("extends"),  phrase("with"),   phrase("super"),
      phrase("is"),       phrase("as"),       phrase("enum"),   phrase("var"),
      phrase("const"),    phrase("final"),    phrase("if"),     phrase("else"),
      phrase("for"),      phrase("in"),       phrase("while"),  phrase("continue"),
      phrase("break"),    phrase("do"),       phrase("switch"), phrase("case"),
      phrase("default"),  phrase("try"),      phrase("catch"),  phrase("finally"),
      phrase("throw"),    phrase("rethrow"),  phrase("assert"), phrase("this"),
      phrase("new"),      phrase("return"),
    ]);
    var keywordHard = keywordHardWord;
    
    var keywordSoftWord = either([
      phrase("import"),     phrase("export"),     phrase("library"),    phrase("hide"),
      phrase("show"),       phrase("deferred"),   phrase("part of"),    phrase("part"),
      phrase("abstract"),   phrase("interface"),  phrase("implements"), phrase("mixin"),
      phrase("base"),       phrase("sealed"),     phrase("typedef"),    phrase("dynamic"),
      phrase("static"),     phrase("covariant"),  phrase("late"),       phrase("extension type"),
      phrase("extension"),  phrase("when"),       phrase("on"),         phrase("async"),
      phrase("await"),      phrase("sync"),       phrase("get"),        phrase("set"),
      phrase("yield"),      phrase("external"),   phrase("required"),   phrase("factory"),
      phrase("macro"),
    ]);
    var keywordSoft = concat([
      keywordSoftWord,
      aheadIsNot(concat([
        functionCallParametersStart,
        // don't treat "static" as a function in `static (int, int) myFn() {}`
        aheadIsNot(concat([
          zeroOrMore(anything),
          recordList.end,
          space(req: false),
          variablePlain,
        ])),
      ])),
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
        functionCallParametersStart,
        endsWith(space(req: false)),
      ])),
    ]);
    var invalidOperator = either([
      zeroOrMore(notChars(r"(\s")),
      endsWith(nothing),
    ]);
    var keywordOperatorWord = phrase("operator");
    var keywordOperator = concat([
      keywordOperatorWord,
      space(req: false),
      either([
        capture(validOperator, this.keywordOperator_$valid),
        capture(invalidOperator, this.keywordOperator_$invalid),
      ]),
    ]);

    var keywordWord = either([keywordHardWord, keywordSoftWord, keywordOperatorWord]);
    this.keyword = either([keywordHard, keywordSoft, keywordOperator]);

    this.annotation = concat([
      exactly("@"),
      zeroOrMore(identifierCharOrDot),
    ]);

    var propertyAccess = exactly(".");
    this.organizationalPunctuation = either([
      // breaks records when included here; handled in function call grammar instead
      // exactly("("), 
      exactly(")"),
      exactly("["), exactly("]"),
      exactly("{"), exactly("}"),
      exactly(":"), exactly(","),
      exactly(";"), propertyAccess,
    ]);
    this.mapLiteralPunctuation = pair(
      begin: exactly("{"),
      end: exactly("}"),
    );

    this.simpleOperation = either([
      // arithmetic operations
      exactly("++"),  exactly("--"),
      exactly("+"),   exactly("-"),
      exactly("*"),   exactly("/"),
      exactly("~/"),  exactly("%"),
      exactly("!"),
      exactly("<<"),  exactly(">>"),
      exactly(">>>"),
      exactly("&"),   exactly("|"),
      exactly("^"),   exactly("~"),

      // assignment operations
      exactly("="),   exactly("??="),
      exactly("+="),  exactly("-="),
      exactly("*="),  exactly("/="),
      exactly("~/="), exactly("%="),
      exactly("<<="), exactly(">>="),
      exactly(">>>="),
      exactly("&="),  exactly("|="),
      exactly("^="),  exactly("~="),

      // comparative operations
      exactly(">"),   exactly(">="),
      exactly("<"),   exactly("<="),
      exactly("=="),  exactly("!="),
      exactly("??"),
      concat([exactly("?"), aheadIs(propertyAccess)]),

      // symbol operator
      exactly("#"),

      // spread operator
      exactly("..."),

      // lambda operator
      exactly("=>"),
    ]);
    this.conditionalOperation = pair(
      begin:  capture(exactly("?"), this.conditionalOperation_$test),
      end:    capture(exactly(":"), this.conditionalOperation_$else),
    );

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
      end: aheadIsNot(variablePlainNoDollar),
    );
    this.literalStringInterpOperExpression = pair(
      begin: capture(
        exactly(r"${"),
        this.literalStringInterpOperExpression_$brace,
      ),
      end: capture(
        exactly(r"}"),
        this.literalStringInterpOperExpression_$brace,
      ),
    );
    this.literalStringEscapeSequence = either([
      concat([
        exactly(r"\x"),
        repeatAtMost(2, hexNumberChar),
      ]),
      // \u{...} case must be above general \u... case
      concat([
        exactly(r"\u{"),
        zeroOrMore(hexNumberChar),
        exactly(r"}"),
      ]),
      concat([
        exactly(r"\u"),
        repeatAtMost(4, hexNumberChar),
      ]),
      // general/usual case has to be last
      concat([
        exactly(r"\"),
        optional(anything),
      ]),
    ]);

    this.literalKeyword = either([
      phrase("true"), phrase("false"), phrase("null"),
    ]);

    this.singleLineComment = concat([
      exactly("//"),
      zeroOrMore(anything),
    ]);
    this.singleLineDocComment = concat([
      exactly("///"),
      zeroOrMore(anything),
    ]);
    this.multiLineComment = pair(
      begin: exactly("/*"),
      end: exactly("*/"),
    );

    var typeAfterKeywordPrefixKeyword = either([
      phrase("class"),    phrase("mixin"),      phrase("extension type"),
      phrase("extends"),  phrase("implements"), phrase("with"),
      phrase("typedef"),  phrase("is"),         phrase("as"),
    ]);
    this.typeAfterKeywordContext = pair(
      begin: either([
        behindIs(typeAfterKeywordPrefixKeyword),
        behindIs(concat([
          phrase("typedef"),
          zeroOrMore(anything),
          exactly("="),
        ])),
      ]),
      end: behindIsNot(either([
        space(req: true),
        // ensure we haven't just started at `begin`
        typeAfterKeywordPrefixKeyword,
        exactly("="),
      ])),
    );

    var variablePrefixKeyword = either([
      phrase("var"),      phrase("final"),      phrase("const"),
      phrase("dynamic"),  phrase("covariant"),  phrase("static"),
    ]);
    this.typeAnnotationContext = pair(
      begin: concat([
        either([
          concat([
            startsWith(nothing),
            // fixes recognizing anonymous functions like `(void Function() callback) {...}` as records
            aheadIsNot(concat([
              recordListAsSingleRecipe,
              zeroOrMore(anything),
              either([
                exactly("=>"),
                exactly("{"),
              ]),
            ])),
          ]),
          behindIs(either([
            variablePrefixKeyword,
            recordList.begin, exactly(","),
          ])),
        ]),
        aheadIs(concat([
          space(req: false),
          either([
            concat([
              typeIdentifier,
              optional(genericList.asSingleRecipe()),
            ]),
            concat([
              recordListAsSingleRecipe,
            ]),
          ]),
          optional(nullableOperator),
          space(req: true),
          identifierChar,
        ])),
        // don't match `final` in `late final myVar`
        aheadIsNot(spaceBefore(keywordWord)),
      ]),
      end: concat([
        aheadIs(space(req: true)),
        behindIs(either([
          typeIdentifier,
          genericList.end,
          nullableOperator,
          recordList.end,
        ])),
        aheadIsNot(concat([
          space(req: false),
          functionType.begin,
        ])),
      ]),
    );
    
    this.typeParameterContext = pair(
      begin: either([
        concat([
          behindIs(concat([
            typeIdentifier,
            space(req: false),
            optional(exactly("!")),
          ])),
          aheadIs(either([
            genericList.asSingleRecipe(),
            multilineGenericListStart,
          ])),
        ]),
        aheadIs(
          concat([
            genericList.asSingleRecipe(), // because there is no way to tell if `<` in `<\n...\n>[]` is for type params
            either([
              exactly("["),
              exactly("{"),
            ]),
          ])
        ),
      ]),
      end: behindIs(genericList.end),
    );

    return this;
  }
}
