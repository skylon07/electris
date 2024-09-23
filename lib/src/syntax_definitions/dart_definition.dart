import 'package:vscode_theming_tools/vscode_theming_tools.dart';

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
    innerUnits: () => [
      libSeparator,
      ...typeContextUnits,
    ],
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

    ...defaultContextUnits, // default style for any unrecognized things so it doesn't look ugly
  ];

  late final defaultContextUnits = [
    comment,

    keyword, // `var` must be above `var_iable`

    literalNumber, // `10` must be above `someVar_10`
    literalString,
    literalKeyword, // `true` must be above `true_thy`
    variableConst, // `MY_CONST` must be above `MyConst` and `myConst`
    variableConstNoDollar,

    builtinType, // `int` must be above `int_eger`
    variableType, // `MyType` must be above `myType`
    variableTypeNoDollar,

    simpleOperation, // `?` in `_?._` must be above `_ ? _ : _`
    conditionalOperation, // `:` in `_ ? _ : _` must be above `{_: _}`
    chainOperation,
    mapLiteralPunctuation, // `{}` must be above `{`, `}` (ie general punctuation)

    functionCall, // `myFunction()` must be above `myFunction_noCall`
    functionCallArgumentList, // not inner unit for `functionCall` since it also applies to anonymous functions

    annotation,
    organizationalPunctuation,
    variablePlain,
    variablePlainNoDollar,
  ];


  // -- type context units --

  late final typeIdentifier = createUnit(
    "typeIdentifier",
    styleName: ElectrisStyleName.sourceCode_types_type,
    match: collection.typeIdentifier,
  );

  late final libSeparator = createUnit(
    "libSeparator",
    styleName: ElectrisStyleName.sourceCode_types_type,
    match: collection.libSeparator,
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
        recordVariable,
        recursiveTypeContextUnits,
      ],
    );
  late final recordListNoStyle    = recordListFactory("recordListNoStyle",    null);
  late final recordListTop        = recordListFactory("recordListTop",        ElectrisStyleName.sourceCode_types_type);
  late final recordListRecursive  = recordListFactory("recordListRecursive",  ElectrisStyleName.sourceCode_types_typeRecursive);

  late final recordVariable = createUnit(
    "recordVariable",
    styleName: ElectrisStyleName.sourceCode_variable,
    match: collection.recordVariable,
  );

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

  late final variablePlainNoDollar = createUnit(
    "variablePlainNoDollar",
    styleName: ElectrisStyleName.sourceCode_variable,
    match: collection.variablePlainNoDollar,
  );

  late final variableType = createUnit(
    "variableType",
    styleName: ElectrisStyleName.sourceCode_types_type,
    match: collection.variableType,
  );

  late final variableTypeNoDollar = createUnit(
    "variableTypeNoDollar",
    styleName: ElectrisStyleName.sourceCode_types_type,
    match: collection.variableTypeNoDollar,
  );

  late final variableConst = createUnit(
    "variableConst",
    styleName: ElectrisStyleName.sourceCode_primitiveLiteral,
    match: collection.variableConst,
  );

  late final variableConstNoDollar = createUnit(
    "variableConstNoDollar",
    styleName: ElectrisStyleName.sourceCode_primitiveLiteral,
    match: collection.variableConstNoDollar,
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

  late final chainOperation = createUnit(
    "chainOperation",
    styleName: ElectrisStyleName.sourceCode_variable, // not the normal operator style
    match: collection.chainOperation,
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
        matchPair: collection.literalStringTripleDouble,
        innerUnits: () => literalStringInnerUnits,
      ),
      createUnitInline(
        matchPair: collection.literalStringTripleSingle,
        innerUnits: () => literalStringInnerUnits,
      ),
      createUnitInline(
        matchPair: collection.literalStringDouble,
        innerUnits: () => literalStringInnerUnits,
      ),
      createUnitInline(
        matchPair: collection.literalStringSingle,
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
        innerUnits: () {
          var variableNoDollarUnits = {
            variablePlainNoDollar,
            variableTypeNoDollar,
            variableConstNoDollar,
          };
          // filtering the list guarantees the originally defined unit order is preserved
          return [
            for (var unit in defaultContextUnits)
              if (variableNoDollarUnits.contains(unit)) unit
          ];
        },
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
  late final RegExpRecipe variableTypeNoDollar;
  late final RegExpRecipe variableConst;
  late final RegExpRecipe variableConstNoDollar;

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
  late final RegExpRecipe chainOperation;

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
  late final RegExpRecipe libSeparator;
  late final RegExpRecipe nullableOperator;
  late final RegExpPair   genericList;
  late final RegExpRecipe typeParameterKeyword;

  late final RegExpPair   recordList;
  late final RegExpRecipe recordVariable;

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
    var identifierChars         = {
      identifierLowerChar,
      identifierUpperChar,
      identifierSpacerChar,
      identifierDollarChar,
      numberChar,
    };

    RegExpRecipe variablePlainPattern(Set<RegExpRecipe> charsSet) => 
      oneOrMore(either(charsSet.toList()));
    this.variablePlain          = variablePlainPattern(identifierChars);
    this.variablePlainNoDollar  = variablePlainPattern(identifierChars.difference({identifierDollarChar}));
    RegExpRecipe variableTypePattern(Set<RegExpRecipe> charsSet) => 
      concat([
        zeroOrMore(either(
          charsSet.difference({identifierUpperChar, identifierLowerChar}).toList()
        )),
        identifierUpperChar,
        zeroOrMore(either(charsSet.toList())),
      ]);
    this.variableType         = variableTypePattern(identifierChars);
    this.variableTypeNoDollar = variableTypePattern(identifierChars.difference({identifierDollarChar}));
    RegExpRecipe variableConstPattern(Set<RegExpRecipe> charsSet) =>
      concat([
        // must be at least two letters long; single uppercase should be type color
        // (to avoid flashing const color when typing out type names)
        repeatAtLeast(2, concat([
          zeroOrMore(either(
            charsSet.difference({identifierUpperChar, identifierLowerChar}).toList()
          )),
          identifierUpperChar,
        ])),
        zeroOrMore(either(
          charsSet.difference({identifierLowerChar}).toList()
        )),
        aheadIsNot(either(charsSet.toList())),
      ]);
    this.variableConst          = variableConstPattern(identifierChars);
    this.variableConstNoDollar  = variableConstPattern(identifierChars.difference({identifierDollarChar}));

    this.builtinType = either([
      phrase("num"), phrase("int"), phrase("double"), phrase("bool"), phrase("void"),
    ]);
    this.nullableOperator = exactly("?");
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
    this.typeIdentifier = oneOrMore(either(identifierChars.toList()));
    this.libSeparator = exactly(".");
    this.typeParameterKeyword = either([
      phrase("dynamic"), phrase("extends"),
    ]);

    // fixes recognizing record related stuff inside strings, ex `{ (0, false): "(match) yes", }`
    var knownInvalidRecordChars = zeroOrMore(notChars("\"'^&|="));
    this.recordList = pair(
      begin: exactly("("),
      end: exactly(")"),
    );
    // any `recordList.asSingleRecipe()` should instead be this
    var recordListAsSingleRecipe = recordList.asSingleRecipe(knownInvalidRecordChars);

    var functionCallParametersStart = concat([
      space(req: false),
      optional(exactly("!")),
      space(req: false),
      optional(genericList.asSingleRecipe()),
      space(req: false),
      recordList.begin,
    ]);

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
        // interpret `keyword()` as a function call, but `keyword ()` as a keyword
        // (ex. `static (int, int) myFn() {}` or `await (a ? b : c)`)
        aheadIsNot(space(req: true)),
        functionCallParametersStart,
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
      end: concat([
        behindIs(either([
          recordList.end,
          nullableOperator,
        ])),
        aheadIsNot(nullableOperator),
        // recognize recursively, like `void Function() Function()`
        aheadIsNot(spaceBefore(phrase("Function"))),
      ]),
    );

    var typeContextCommonBeginPiece = either([
      typeIdentifier,
      genericList.begin,
      recordList.begin,
      nullableOperator,
      spaceBefore(functionType.begin),
    ]);
    var typeContextCommonEndPiece = either([
      typeIdentifier,
      genericList.end,
      nullableOperator,
      recordList.end,
    ]);

    this.recordVariable = concat([
      behindIs(spaceReqAfter(typeContextCommonEndPiece)),
      aheadIsNot(functionType.begin),
      variablePlain,
    ]);

    this.annotation = concat([
      exactly("@"),
      zeroOrMore(either([
        ...identifierChars,
        libSeparator,
      ])),
    ]);

    var propertyAccess = concat([
      behindIsNot(exactly(".")),
      exactly("."),
      aheadIsNot(exactly(".")),
    ]);
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

    this.chainOperation = concat([
      behindIsNot(exactly(".")),
      exactly(".."),
      aheadIsNot(exactly(".")),
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
      end: either([
        aheadIsNot(variablePlain),
        aheadIs(exactly(r"$")),
      ]),
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
      phrase("on"),
    ]);
    this.typeAfterKeywordContext = pair(
      begin: concat([
        behindIs(either([
          concat([
            typeAfterKeywordPrefixKeyword,
            behindIs(spaceReqAfter(variablePlain)), // TODO: I don't like this... maybe keywords shouldn't be `phrase()`
          ]),
          concat([
            phrase("typedef"),
            zeroOrMore(anything),
            exactly("="),
          ]),
        ])),
        aheadIsNot(spaceBefore(keywordWord)),
        // restrict keyword maching to the same line
        // (in case the line above is, say, a comment ending with `class`)
        aheadIsNot(endsWith(space(req: false))),
      ]),
      end: concat([
        behindIs(typeContextCommonEndPiece),
        aheadIsNot(typeContextCommonBeginPiece),
      ]),
    );

    var variablePrefixKeyword = either([
      phrase("var"),      phrase("final"),      phrase("const"),
      phrase("dynamic"),  phrase("covariant"),  phrase("static"),
      phrase("abstract"), phrase("required"),
    ]);
    this.typeAnnotationContext = pair(
      begin: concat([
        // check behind to see if we are "in context"
        either([
          concat([
            startsWith(nothing),
            // fixes recognizing anonymous functions like `(void Function() callback) {...}` as records
            aheadIsNot(concat([
              space(req: false),
              // ...but recognizing `(rec, rec) fn() {...}` is still okay
              aheadIsNot(concat([
                recordListAsSingleRecipe,
                space(req: false),
                either([
                  functionCall.begin,
                  phrase("get"),
                  phrase("set"),
                ]),
              ])),
              recordListAsSingleRecipe,
              zeroOrMore(anything),
              either([
                exactly("=>"),
                exactly("{"),
              ]),
            ])),
          ]),
          behindIs(either([
            concat([
              variablePrefixKeyword,
              behindIs(spaceReqAfter(variablePlain)), // TODO: I don't like this... maybe keywords shouldn't be `phrase()`
            ]),
            // check if annotating function parameters...
            recordList.begin, exactly(","),
            // don't forget optional and named function parameters!
            exactly("["), exactly("{"),
          ])),
        ]),

        // check ahead to see if it's a valid type
        aheadIs(either([
          concat([
            space(req: false),
            either([
              concat([
                zeroOrMore(concat([
                  typeIdentifier,
                  libSeparator,
                ])),
                typeIdentifier,
                optional(genericList.asSingleRecipe()),
              ]),
              recordListAsSingleRecipe,
              functionType.asSingleRecipe(),
            ]),
            optional(nullableOperator),
            space(req: true),
            // don't allow keywords after matching, like `notAType in someList`
            aheadIsNot(concat([
              // ...except for a couple of keywords
              aheadIsNot(either([
                phrase("get"),
                phrase("set"),
              ])),
              keywordWord,
            ])),
            // two characters needed to prevent `thing` from being a type in `for (var thing i`
            either(identifierChars.toList()),
            either(identifierChars.toList()),
          ]),
        ])),
        // don't match `final` in `late final myVar`
        aheadIsNot(spaceBefore(keywordWord)),
      ]),
      end: concat([
        aheadIs(space(req: true)),
        behindIs(typeContextCommonEndPiece),
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
              exactly("("), // for anonymous functions
            ]),
          ])
        ),
      ]),
      end: behindIs(genericList.end),
    );

    return this;
  }
}
