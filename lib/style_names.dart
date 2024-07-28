import 'package:vscode_theming/vscode_theming.dart';


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
  sourceCode_punctuation("source-code.punctuation"),
  
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

  const ElectrisStyleName(String specificScope) :
    scope = "electris.$specificScope";
}
