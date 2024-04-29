import 'package:test/test.dart';

import '../lib/syntax_printer.dart';


String syntaxPrint(SyntaxElement syntax) =>
  SyntaxPrinter.instance.print(syntax);

void main() {
  group("pattern syntaxes, such as", () {
    group("'capture' patterns, like", () {
      test("those without a (style) name", () {
        var result = SyntaxPrinter.instance.print(
          CapturePattern(debugName: "debugName")
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.syntax.debugName"
}"""
          ),
        );
      });

      test("those with a (style) name", () {
        var result = SyntaxPrinter.instance.print(
          CapturePattern(debugName: "debugName", styleName: StyleName.sourceCode_escape)
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.source-code.escape electris.syntax.debugName"
}"""
          ),
        );
      });
    });


    group("'match' patterns, like", () {
      test("those without a (style) name", () {
        var result = SyntaxPrinter.instance.print(
          MatchPattern(debugName: "debugName", match: "abcdef")
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.syntax.debugName",
    "match": "abcdef"
}"""
          ),
        );
      });

      test("those with a (style) name", () {
        var result = SyntaxPrinter.instance.print(
          MatchPattern(
            debugName: "debugName",
            styleName: StyleName.sourceCode_escape,
            match: "abcdef"
          )
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.source-code.escape electris.syntax.debugName",
    "match": "abcdef"
}"""
          ),
        );
      });

      test("those with captures", () {
        var result = SyntaxPrinter.instance.print(
          MatchPattern(debugName: "debugName", match: "abcdef", captures: [
            CapturePattern(debugName: "debugName1"),
            CapturePattern(debugName: "debugName2"),
            CapturePattern(debugName: "debugName3"),
          ])
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.syntax.debugName",
    "match": "abcdef",
    "captures": {
        "1": {
            "name": "electris.syntax.debugName1"
        },
        "2": {
            "name": "electris.syntax.debugName2"
        },
        "3": {
            "name": "electris.syntax.debugName3"
        }
    }
}"""
          ),
        );
      });
    });


    group("'group' patterns, like", () {
      test("those without a (style) name", () {
        var result = SyntaxPrinter.instance.print(
          GroupingPattern(debugName: "debugName", innerPatterns: [
            CapturePattern(debugName: "debugName1"),
            CapturePattern(debugName: "debugName2"),
            CapturePattern(debugName: "debugName3"),
          ])
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.syntax.debugName",
    "patterns": [
        {
            "name": "electris.syntax.debugName1"
        },
        {
            "name": "electris.syntax.debugName2"
        },
        {
            "name": "electris.syntax.debugName3"
        }
    ]
}"""
          ),
        );
      });

      test("those with a (style) name", () {
        var result = SyntaxPrinter.instance.print(
          GroupingPattern(
            debugName: "debugName",
            styleName: StyleName.sourceCode_escape,
            innerPatterns: [
              CapturePattern(debugName: "debugName1"),
              CapturePattern(debugName: "debugName2"),
              CapturePattern(debugName: "debugName3"),
            ]
          )
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.source-code.escape electris.syntax.debugName",
    "patterns": [
        {
            "name": "electris.syntax.debugName1"
        },
        {
            "name": "electris.syntax.debugName2"
        },
        {
            "name": "electris.syntax.debugName3"
        }
    ]
}"""
          ),
        );
      });
    });


    group("'enclosure' patterns, like", () {
      test("those without a (style) name", () {
        var result = SyntaxPrinter.instance.print(
          EnclosurePattern(debugName: "debugName", begin: "abc", end: "def")
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.syntax.debugName",
    "begin": "abc",
    "end": "def"
}"""
          ),
        );
      });

      test("those with a (style) name", () {
        var result = SyntaxPrinter.instance.print(
          EnclosurePattern(
            debugName: "debugName",
            styleName: StyleName.sourceCode_escape,
            begin: "abc",
            end: "def"
          )
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.source-code.escape electris.syntax.debugName",
    "begin": "abc",
    "end": "def"
}"""
          ),
        );
      });

      test("those with begin-captures", () {
        var result = SyntaxPrinter.instance.print(
          EnclosurePattern(debugName: "debugName", begin: "abc", end: "def", beginCaptures: [
            CapturePattern(debugName: "debugName1"),
            CapturePattern(debugName: "debugName2"),
            CapturePattern(debugName: "debugName3"),
          ])
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.syntax.debugName",
    "begin": "abc",
    "end": "def",
    "beginCaptures": {
        "1": {
            "name": "electris.syntax.debugName1"
        },
        "2": {
            "name": "electris.syntax.debugName2"
        },
        "3": {
            "name": "electris.syntax.debugName3"
        }
    }
}"""
          ),
        );
      });

      test("those with end-captures", () {
        var result = SyntaxPrinter.instance.print(
          EnclosurePattern(debugName: "debugName", begin: "abc", end: "def", endCaptures: [
            CapturePattern(debugName: "debugName1"),
            CapturePattern(debugName: "debugName2"),
            CapturePattern(debugName: "debugName3"),
          ])
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.syntax.debugName",
    "begin": "abc",
    "end": "def",
    "endCaptures": {
        "1": {
            "name": "electris.syntax.debugName1"
        },
        "2": {
            "name": "electris.syntax.debugName2"
        },
        "3": {
            "name": "electris.syntax.debugName3"
        }
    }
}"""
          ),
        );
      });

      test("those with inner children patterns", () {
        var result = SyntaxPrinter.instance.print(
          EnclosurePattern(debugName: "debugName", begin: "abc", end: "def", innerPatterns: [
            CapturePattern(debugName: "debugName1"),
            CapturePattern(debugName: "debugName2"),
            CapturePattern(debugName: "debugName3"),
          ])
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.syntax.debugName",
    "patterns": [
        {
            "name": "electris.syntax.debugName1"
        },
        {
            "name": "electris.syntax.debugName2"
        },
        {
            "name": "electris.syntax.debugName3"
        }
    ],
    "begin": "abc",
    "end": "def"
}"""
          ),
        );
      });
    });


    group("'include' patterns, like", () {
      test("those with any (non-escaped) identifier", () {
        var result = SyntaxPrinter.instance.print(
          IncludePattern(identifier: "some-repository-identifier")
        );
        expect(
          result,
          equals(
"""
{
    "include": "#some-repository-identifier"
}"""
          ),
        );
      });

      test("those with an escaped identifier", () {
        var result = SyntaxPrinter.instance.print(
          IncludePattern(identifier: "%do-this-exactly")
        );
        expect(
          result,
          equals(
"""
{
    "include": "do-this-exactly"
}"""
          ),
        );
      });
    });
  });


  group("repository items, like", () {
    test("that they should not include their identifier in their JSON encoding", () {
      var result = SyntaxPrinter.instance.print(
        RepositoryItem(
          identifier: "some-identifier",
          body: IncludePattern(identifier: "some-other-identifier")
        )
      );
      expect(
        result,
        equals(
"""
{
    "include": "#some-other-identifier"
}"""
        ),
      );
    });

    test("that their identifiers match their corresponding include pattern", () {
      var includeId = RepositoryItem(
        identifier: "repository-identifier",
        body: MatchPattern(debugName: "whatever", match: "whatever"),
      ).asInclude().identifier;
      expect(includeId, equals("repository-identifier"));
    });
  });


  group("entire syntax bodies/files, like", () {
    test("those with all their attributes defined", () {
      var result = SyntaxPrinter.instance.print(
        MainBody(
          fileTypes: [
            "dart1",
            "dart2"
          ],
          langName: "dart",
          topLevelPatterns: [
            EnclosurePattern(
              debugName: "enclosureDebugName",
              begin: "enclosure-begin",
              end: "enclosure-end",
              innerPatterns: [
                IncludePattern(identifier: "some-repo-thing")
              ]
            )
          ],
          repository: [
            RepositoryItem(
              identifier: "some-repo-thing",
              body: MatchPattern(
                debugName: "matchDebugName",
                match: "match-me"
              ),
            ),
          ],
        )
      );
      expect(
        result,
        equals(
"""
{
    "fileTypes": [
        "dart1",
        "dart2"
    ],
    "scopeName": "electris.source.dart",
    "patterns": [
        {
            "name": "electris.syntax.enclosureDebugName",
            "patterns": [
                {
                    "include": "#some-repo-thing"
                }
            ],
            "begin": "enclosure-begin",
            "end": "enclosure-end"
        }
    ],
    "repository": {
        "some-repo-thing": {
            "name": "electris.syntax.matchDebugName",
            "match": "match-me"
        }
    }
}"""
        ),
      );
    });
  });
}
