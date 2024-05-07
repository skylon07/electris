import 'dart:convert';
import 'dart:io';
import 'package:meta/meta.dart';


// TODO: document all classes here; include a code block showing a "template"
//  that illustrates the kind of pattern the class is emulating

class SyntaxPrinter {
  static const INDENT = "    ";
  static final instance = SyntaxPrinter._create();

  late final JsonEncoder _encoder = 
    JsonEncoder.withIndent(INDENT, (item) => item.toJson());

  SyntaxPrinter._create();

  String print(SyntaxElement syntax) {
    return _encoder.convert(syntax) + "\n";
  }

  Future<void> printToFile(SyntaxElement syntax, String path) {
    var file = File(path);
    var contents = print(syntax);
    return file.writeAsString(contents);
  }
}

abstract interface class JsonEncodable {
  Map toJson();
}


sealed class SyntaxElement implements JsonEncodable {
  const SyntaxElement();
}


final class MainBody extends SyntaxElement {
  final List<String> fileTypes;
  final String langName;
  final List<Pattern> topLevelPatterns;
  final List<RepositoryItem> repository;

  const MainBody({
    required this.fileTypes,
    required this.langName,
    required this.topLevelPatterns,
    required this.repository,
  });

  @override
  Map toJson() {
    return {
      "fileTypes": fileTypes,
      "scopeName": "electris.source.$langName",
      "patterns": topLevelPatterns,
      "repository": {
        for (var item in repository)
          item.identifier: item,
      },
    };
  }
}

final class RepositoryItem extends SyntaxElement {
  final String identifier;
  final Pattern body;

  const RepositoryItem({
    required this.identifier,
    required this.body,
  });

  @override
  Map toJson() {
    // it is the containing object's resposibility to
    // assign the correct identifier
    return body.toJson();
  }

  IncludePattern asInclude() => IncludePattern(identifier: identifier);
}

sealed class Pattern extends SyntaxElement {
  final String debugName;
  final StyleName? styleName;

  const Pattern({
    required this.debugName,
    this.styleName,
  });

  @override
  @mustBeOverridden
  @mustCallSuper
  Map toJson() {
    final styleName = this.styleName;
    var name =
      "${styleName != null ? "electris.${styleName.scope} " : ""}"
      "${debugName.isNotEmpty ? "electris.syntax.$debugName" : ""}";
    return {
      if (name.isNotEmpty)
        'name': name,
    };
  }
}

enum StyleName {
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

  
  final String scope;

  const StyleName(this.scope);
}

final class MatchPattern extends Pattern {
  final String match;
  final List<CapturePattern> captures;

  const MatchPattern({
    required super.debugName,
    super.styleName,
    required this.match,
    this.captures = const [],
  });

  @override
  Map toJson() {
    return {
      ...super.toJson(),
      'match': match,
      if (captures.isNotEmpty)
        'captures': captures.toIndexedMap(),
    };
  }
}

final class CapturePattern extends Pattern {
  CapturePattern({
    required super.debugName,
    super.styleName,
  });

  @override
  Map toJson() {
    return super.toJson();
  }
}

final class GroupingPattern extends Pattern {
  final List<Pattern> innerPatterns;

  const GroupingPattern({
    required super.debugName,
    super.styleName,
    required this.innerPatterns,
  });

  @override
  Map toJson() {
    return {  
      ...super.toJson(),
      if (innerPatterns.isNotEmpty)
        'patterns': innerPatterns,
    };
  }
}

final class EnclosurePattern extends GroupingPattern {
  final String begin;
  final String end;
  final List<CapturePattern> beginCaptures;
  final List<CapturePattern> endCaptures;

  const EnclosurePattern({
    required super.debugName,
    super.styleName,
    super.innerPatterns = const [],
    required this.begin,
    required this.end,
    this.beginCaptures = const [],
    this.endCaptures = const [],
  });

  @override
  Map toJson() {
    return {
      ...super.toJson(),
      'begin': begin,
      'end': end,
      if (beginCaptures.isNotEmpty)
        'beginCaptures': beginCaptures.toIndexedMap(),
      if (endCaptures.isNotEmpty)
        'endCaptures': endCaptures.toIndexedMap(),
    };
  }
}

final class IncludePattern extends Pattern {
  final String identifier;

  const IncludePattern({required this.identifier, super.debugName = ""});

  @override
  Map toJson() {
    var shouldTreatAsReference = identifier.isNotEmpty && identifier[0] != "%";
    return {
      ...super.toJson(),
      'include': shouldTreatAsReference ? "#$identifier" : identifier.substring(1),
    };
  }
}


extension _IndexMapping<ItemT> on List<ItemT> {
  Map<String, ItemT> toIndexedMap() =>
    {
      for (var idx = 0; idx < length; ++idx)
        '${idx + 1}': this[idx]
    };
}
