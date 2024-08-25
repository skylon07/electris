import 'dart:isolate';

import 'package:vscode_theming_tools/vscode_theming_tools.dart';

import './syntax_definitions/dart_definition.dart';


void main() async {
  var basePath = "syntaxes/";
  var definitions = [
    DartDefinition(),
  ];
  for (var definition in definitions) {
    // TODO: make sure second "$" is recognized as operator in new dart syntax
    // (old recognizes it as part of the variable `basePath$`)
    Isolate.run(() {
      var fullPath = "$basePath${definition.langName}-${definition.isTextSyntax ? "text":"source"}-generated.tmLanguage.json";
      // TODO: is this the best UX? maybe have the definition be able to print directly...?
      var syntax = definition.mainBody;
      return SyntaxPrinter.instance.printToFile(syntax, fullPath);
    });
  }
}
