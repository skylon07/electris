import './syntax_printer.dart';
import './regexp_builder_base.dart';


abstract base class SyntaxDefinition<BuilderT extends RegExpBuilder<CollectionT>, CollectionT> {
  final String langName;
  final bool isTextSyntax;
  final List<String> fileTypes;
  final List<DefinitionItem> _items = [];
  late final CollectionT collection;
  
  SyntaxDefinition({
    required this.langName,
    required this.isTextSyntax,
    required this.fileTypes,
    required BuilderT builder,
  }) {
    collection = builder.createCollection();
  }

  List<DefinitionItem> get rootItems;

  late final mainBody = MainBody(
    fileTypes: fileTypes,
    langName: langName,
    topLevelPatterns: [for (var item in rootItems) item.asIncludePattern()],
    repository: [for (var item in _items) item.asRepositoryItem()],
  );

  DefinitionItem createItemDirect(
    String identifier,
    {
      required Pattern Function(String debugName, List<Pattern> innerPatterns) createBody,
      List<DefinitionItem>? Function()? createInnerItems,
    }
  ) {
    var item = DefinitionItem(
      identifier,
      parent: this,
      createBody: createBody,
      createInnerItems: createInnerItems,
    );
    _items.add(item);
    return item;
  }

  // TODO: `captures` needs to be reworked to a map;
  //  this function should be supplied the capture patterns *and* their indexes
  //  (and the caller probably shouldn't have to create `CapturePattern`s directly...)
  DefinitionItem createItem(
    String identifier,
    {
      StyleName? styleName,
      String? match,
      String? begin,
      String? end,
      List<CapturePattern>? captures,
      List<CapturePattern>? beginCaptures,
      List<CapturePattern>? endCaptures,
      List<DefinitionItem>? Function()? createInnerItems,
    }
  ) {
    var argMap = {
      'debugName': null, // set later
      'styleName': styleName,
      'match': match,
      'begin': begin,
      'end': end,
      'captures': captures,
      'beginCaptures': beginCaptures,
      'endCaptures': endCaptures,
      'innerPatterns': null, // set later
    };
    return createItemDirect(
      identifier,
      createBody: (debugName, innerPatterns) {
        argMap['debugName'] = debugName;
        argMap['innerPatterns'] = innerPatterns;
        return _createItem_smartBody(argMap);
      },
      createInnerItems: createInnerItems,
    );
  }

  Pattern _createItem_smartBody(Map<String, dynamic> argMap) =>
    switch (argMap) {
      {
        'debugName': String debugName,
        'match': String match,

        'styleName': StyleName? styleName,
        'captures': List<CapturePattern>? captures,
        
        'begin': null,
        'end': null,
        'beginCaptures': null,
        'endCaptures': null,
        'innerPatterns': null || [],
      } => 
        MatchPattern(
          debugName: debugName,
          styleName: styleName,
          match: match,
          captures: captures ?? [],
        ),

      {
        'debugName': String debugName,
        'begin': String begin,
        'end': String end,

        'styleName': StyleName? styleName,
        'beginCaptures': List<CapturePattern>? beginCaptures,
        'endCaptures': List<CapturePattern>? endCaptures,
        'innerPatterns': List<Pattern>? innerPatterns,

        'match': null,
        'captures': null,
      } =>
        EnclosurePattern(
          debugName: debugName,
          styleName: styleName,
          innerPatterns: innerPatterns ?? [],
          begin: begin,
          end: end,
          beginCaptures: beginCaptures ?? [],
          endCaptures: endCaptures ?? [],
        ),

      {
        'debugName': String debugName,
        'innerPatterns': List<Pattern> innerPatterns,

        'styleName': StyleName? styleName,

        'match': null,
        'begin': null,
        'end': null,
        'captures': null,
        'beginCaptures': null,
        'endCaptures': null,
      } when innerPatterns.isNotEmpty =>
        GroupingPattern(
          debugName: debugName,
          styleName: styleName,
          innerPatterns: innerPatterns
        ),
      
      _ => throw ArgumentError("Invalid argument pattern."),
    };
}

// TODO: should this be private...? (Or it should at least control binding to its parent in the constructor)
final class DefinitionItem {
  final SyntaxDefinition parent;
  final String identifier;
  final Pattern Function(String debugName, List<Pattern> innerPatterns) createBody;
  final List<DefinitionItem>? Function()? createInnerItems;

  DefinitionItem(
    this.identifier,
    {
      required this.parent,
      required this.createBody,
      this.createInnerItems,
    }
  );

  late final innerItems = createInnerItems?.call() ?? [];

  RepositoryItem asRepositoryItem() => _repositoryItem;
  late final _repositoryItem = RepositoryItem(
    identifier: identifier,
    body: createBody(
      "${parent.langName}.$identifier",
      innerItems
        .map((item) => item.asIncludePattern())
        .toList(),
    )
  );

  IncludePattern asIncludePattern() => _includePattern;
  late final _includePattern = IncludePattern(identifier: identifier);
}
