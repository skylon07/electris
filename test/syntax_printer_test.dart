import 'package:test/test.dart';

import '../lib/syntax_printer.dart';


String syntaxPrint(SyntaxElement syntax) =>
  SyntaxPrinter.instance.print(syntax);

void main() {
  group("pattern syntaxes, such as", () {
    group("'capture' patterns, like", () {
      test("those with a name", () {
        var result = SyntaxPrinter.instance.print(
          CapturePattern(debugName: "electris.capture.name")
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.capture.name"
}"""
          ),
        );
      });
    });


    group("'match' patterns, like", () {
      test("those without a name", () {
        var result = SyntaxPrinter.instance.print(
          MatchPattern(debugName: "", match: "abcdef")
        );
        expect(
          result,
          equals(
"""
{
    "match": "abcdef"
}"""
          ),
        );
      });

      test("those with a name", () {
        var result = SyntaxPrinter.instance.print(
          MatchPattern(debugName: "electris.some.scope", match: "abcdef")
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.some.scope",
    "match": "abcdef"
}"""
          ),
        );
      });

      test("those with captures", () {
        var result = SyntaxPrinter.instance.print(
          MatchPattern(debugName: "", match: "abcdef", captures: [
            CapturePattern(debugName: "electris.some.name"),
            CapturePattern(debugName: "electris.some.othername"),
            CapturePattern(debugName: "electris.some.anothername"),
          ])
        );
        expect(
          result,
          equals(
"""
{
    "match": "abcdef",
    "captures": {
        "1": {
            "name": "electris.some.name"
        },
        "2": {
            "name": "electris.some.othername"
        },
        "3": {
            "name": "electris.some.anothername"
        }
    }
}"""
          ),
        );
      });
    });


    group("'group' patterns, like", () {
      test("those without a name", () {
        var result = SyntaxPrinter.instance.print(
          GroupingPattern(debugName: "", innerPatterns: [
            CapturePattern(debugName: "electris.some.name"),
            CapturePattern(debugName: "electris.some.othername"),
            CapturePattern(debugName: "electris.some.anothername"),
          ])
        );
        expect(
          result,
          equals(
"""
{
    "patterns": [
        {
            "name": "electris.some.name"
        },
        {
            "name": "electris.some.othername"
        },
        {
            "name": "electris.some.anothername"
        }
    ]
}"""
          ),
        );
      });

      test("those with a name", () {
        var result = SyntaxPrinter.instance.print(
          GroupingPattern(debugName: "electris.pattern.name", innerPatterns: [
            CapturePattern(debugName: "electris.some.name"),
            CapturePattern(debugName: "electris.some.othername"),
            CapturePattern(debugName: "electris.some.anothername"),
          ])
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.pattern.name",
    "patterns": [
        {
            "name": "electris.some.name"
        },
        {
            "name": "electris.some.othername"
        },
        {
            "name": "electris.some.anothername"
        }
    ]
}"""
          ),
        );
      });
    });


    group("'enclosure' patterns, like", () {
      test("those without a name", () {
        var result = SyntaxPrinter.instance.print(
          EnclosurePattern(debugName: "", begin: "abc", end: "def")
        );
        expect(
          result,
          equals(
"""
{
    "begin": "abc",
    "end": "def"
}"""
          ),
        );
      });

      test("those with a name", () {
        var result = SyntaxPrinter.instance.print(
          EnclosurePattern(debugName: "electris.enclosure.name", begin: "abc", end: "def")
        );
        expect(
          result,
          equals(
"""
{
    "name": "electris.enclosure.name",
    "begin": "abc",
    "end": "def"
}"""
          ),
        );
      });

      test("those with begin-captures", () {
        var result = SyntaxPrinter.instance.print(
          EnclosurePattern(debugName: "", begin: "abc", end: "def", beginCaptures: [
            CapturePattern(debugName: "electris.some.name"),
            CapturePattern(debugName: "electris.some.othername"),
            CapturePattern(debugName: "electris.some.anothername"),
          ])
        );
        expect(
          result,
          equals(
"""
{
    "begin": "abc",
    "end": "def",
    "beginCaptures": {
        "1": {
            "name": "electris.some.name"
        },
        "2": {
            "name": "electris.some.othername"
        },
        "3": {
            "name": "electris.some.anothername"
        }
    }
}"""
          ),
        );
      });

      test("those with end-captures", () {
        var result = SyntaxPrinter.instance.print(
          EnclosurePattern(debugName: "", begin: "abc", end: "def", endCaptures: [
            CapturePattern(debugName: "electris.some.name"),
            CapturePattern(debugName: "electris.some.othername"),
            CapturePattern(debugName: "electris.some.anothername"),
          ])
        );
        expect(
          result,
          equals(
"""
{
    "begin": "abc",
    "end": "def",
    "endCaptures": {
        "1": {
            "name": "electris.some.name"
        },
        "2": {
            "name": "electris.some.othername"
        },
        "3": {
            "name": "electris.some.anothername"
        }
    }
}"""
          ),
        );
      });

      test("those with inner children patterns", () {
        var result = SyntaxPrinter.instance.print(
          EnclosurePattern(debugName: "", begin: "abc", end: "def", innerPatterns: [
            CapturePattern(debugName: "electris.some.name"),
            CapturePattern(debugName: "electris.some.othername"),
            CapturePattern(debugName: "electris.some.anothername"),
          ])
        );
        expect(
          result,
          equals(
"""
{
    "patterns": [
        {
            "name": "electris.some.name"
        },
        {
            "name": "electris.some.othername"
        },
        {
            "name": "electris.some.anothername"
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
      test("those with some identifier", () {
        var result = SyntaxPrinter.instance.print(
          IncludePattern(identifier: "#some-repository-identifier")
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
    });
  });


  group("repository items, like", () {
    test("that they should not include their identifier in their JSON encoding", () {
      var result = SyntaxPrinter.instance.print(
        RepositoryItem(
          identifier: "some-identifier",
          body: IncludePattern(identifier: "#some-other-identifier")
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
      expect(includeId, equals("#repository-identifier"));
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
          langName: "electris.source.dart",
          topLevelPatterns: [
            EnclosurePattern(
              debugName: "electris.scope.enclosure",
              begin: "enclosure-begin",
              end: "enclosure-end",
              innerPatterns: [
                IncludePattern(identifier: "#some-repo-thing")
              ]
            )
          ],
          repository: [
            RepositoryItem(
              identifier: "some-repo-thing",
              body: MatchPattern(
                debugName: "electris.scope.match",
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
            "name": "electris.scope.enclosure",
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
            "name": "electris.scope.match",
            "match": "match-me"
        }
    }
}"""
        ),
      );
    });
  });
}
