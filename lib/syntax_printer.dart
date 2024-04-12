import 'dart:convert';
import 'package:meta/meta.dart';


class SyntaxPrinter {
  static const INDENT = "    ";
  static final instance = SyntaxPrinter._create();

  late final JsonEncoder _encoder = 
    JsonEncoder.withIndent(INDENT, (item) => item.toJson());

  SyntaxPrinter._create();

  String print(SyntaxElement syntax) {
    return _encoder.convert(syntax);
  }
}

abstract interface class JsonEncodable {
  Object? toJson();
}


sealed class SyntaxElement implements JsonEncodable {
  const SyntaxElement();
}


final class MainBody extends SyntaxElement {
  final List<String> fileTypes;
  final String scopeName;
  final List<Pattern> topLevelPatterns;
  final Map<String, Pattern> repository;

  const MainBody({
    required this.fileTypes,
    required this.scopeName,
    required this.topLevelPatterns,
    required this.repository,
  });

  @override
  Object? toJson() {
    return {
      "fileTypes": fileTypes,
      "scopeName": scopeName,
      "patterns": topLevelPatterns,
      "repository": repository,
    };
  }
}

sealed class Pattern extends SyntaxElement {
  final String debugName;
  final String styleName;

  const Pattern({
    required this.debugName,
    this.styleName = "",
  });

  @override
  @mustBeOverridden
  @mustCallSuper
  Map toJson() {
    return {
      'name': "${styleName.isNotEmpty ? "$styleName " : ""}$debugName",
    };
  }
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

  const IncludePattern({required this.identifier}): super(debugName: "");

  @override
  Map toJson() {
    return {
      ...super.toJson(),
      'include': identifier,
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
