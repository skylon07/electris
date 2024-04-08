import 'package:test/test.dart';

import '../lib/syntax_printer.dart';


String syntaxPrint(SyntaxElement syntax) =>
  SyntaxPrinter.instance.print(syntax);

void main() {
  group("top level little syntaxes, such as", () {
    group("file type lists, like", () {
      test("an empty list", () {
        var result = SyntaxPrinter.instance.print(
          FileTypesList(names: [])
        );
        expect(result, '[]');
      });

      test("a list with one element", () {
        var result = SyntaxPrinter.instance.print(
          FileTypesList(names: ["dart"])
        );
        expect(
          result,
          equals(
"""
[
    "dart"
]"""
          ),
        );
      });

      test("a list with a few elements", () {
        var result = SyntaxPrinter.instance.print(
          FileTypesList(names: ["dart1", "dart2", "dart3"])
        );
        expect(
          result,
          equals(
"""
[
    "dart1",
    "dart2",
    "dart3"
]"""
          ),
        );
      });
    });


    group("scope names, like", () {
      test("electris' dart scope", () {
        var result = SyntaxPrinter.instance.print(
          ScopeName(scope: "electris.source.dart")
        );
        expect(
          result,
          equals('"electris.source.dart"'),
        );
      });
    });
  });


  group("pattern syntaxes, such as", () {
    group("'capture' patterns, like", () {
      test("those with a name", () {
        var result = SyntaxPrinter.instance.print(
          CapturePattern(name: "electris.capture.name")
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
          MatchPattern(name: "", match: "abcdef")
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
          MatchPattern(name: "electris.some.scope", match: "abcdef")
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
          MatchPattern(name: "", match: "abcdef", captures: [
            CapturePattern(name: "electris.some.name"),
            CapturePattern(name: "electris.some.othername"),
            CapturePattern(name: "electris.some.anothername"),
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
          GroupingPattern(name: "", innerPatterns: [
            CapturePattern(name: "electris.some.name"),
            CapturePattern(name: "electris.some.othername"),
            CapturePattern(name: "electris.some.anothername"),
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
          GroupingPattern(name: "electris.pattern.name", innerPatterns: [
            CapturePattern(name: "electris.some.name"),
            CapturePattern(name: "electris.some.othername"),
            CapturePattern(name: "electris.some.anothername"),
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
          EnclosurePattern(name: "", begin: "abc", end: "def")
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
          EnclosurePattern(name: "electris.enclosure.name", begin: "abc", end: "def")
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
          EnclosurePattern(name: "", begin: "abc", end: "def", beginCaptures: [
            CapturePattern(name: "electris.some.name"),
            CapturePattern(name: "electris.some.othername"),
            CapturePattern(name: "electris.some.anothername"),
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
          EnclosurePattern(name: "", begin: "abc", end: "def", endCaptures: [
            CapturePattern(name: "electris.some.name"),
            CapturePattern(name: "electris.some.othername"),
            CapturePattern(name: "electris.some.anothername"),
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
          EnclosurePattern(name: "", begin: "abc", end: "def", innerPatterns: [
            CapturePattern(name: "electris.some.name"),
            CapturePattern(name: "electris.some.othername"),
            CapturePattern(name: "electris.some.anothername"),
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
    test("those with identifiers, which should not be present in their encodings (only in parents when they encode it)", () {
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
  });


  group("entire syntax bodies/files, like", () {
    test("those with all their attributes defined", () {
      var result = SyntaxPrinter.instance.print(
        MainBody(
          fileTypes: FileTypesList(names: [
            "dart1",
            "dart2",
          ]),
          scopeName: ScopeName(scope: "electris.source.dart"),
          topLevelPatterns: [
            EnclosurePattern(
              name: "electris.scope.enclosure",
              begin: "enclosure-begin",
              end: "enclosure-end",
              innerPatterns: [
                IncludePattern(identifier: "#some-repo-thing")
              ],
            ),
          ],
          repository: [
            RepositoryItem(
              identifier: "some-repo-thing",
              body: MatchPattern(
                name: "electris.scope.match",
                match: "match-me",
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
