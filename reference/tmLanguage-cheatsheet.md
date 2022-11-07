# TextMate Grammar/Language Cheatsheet
This document contains the processes to use when defining grammars to inject into languages. This cheatsheet was created by referencing [these docs](https://macromates.com/manual/en/language_grammars).

(If semantic tokens ever need to be added, [this example](https://github.com/microsoft/vscode-extension-samples/tree/main/semantic-tokens-sample) is great to copy!)


## New Language Files
Two things must happen when defining new grammars for a language. First, the file must be added to the `grammars` key in `package.json`. Second, we must configure the top-level attributes in the new file.

### Adding the grammar file
To add a new grammer in `package.json`, simply add an object with these properties:

``` json
"grammars": [
    {
        "path": "./syntaxes/{language}-injections.tmLanguage.json",
        "scopeName": "electris.injections.{language}",
        "injectTo": ["source.{language}"]
    }
]
```

(where `{language}` is the VSCode-recognized language being used)

### Configuring the grammar file
After `package.json` is updated, create the `syntaxes/{language}-injections.tmLanguage.json` file. This file should initially contain an object with these values:

``` json
{
    "fileTypes": [
        "{language file type}"
    ],
    // this MUST match `scopeName` in `package.json`
    "scopeName": "electris.injections.{language}",
    "injectionSelector": "source.{language}",
    "patterns": [
        // base rule definitions here
    ],
    "repository": {
        // named rule definitions here
    }
}
```

(where `{language}` is the VSCode-recognized language being used, and `{language file type}` is the file extension used for language source files)


## Adding Rules
When adding new rules to either `patterns` or `repository`, there are several properties that can be used. Below is a brief overview of the properties of a rule and their descriptions:

``` json
{
    "name": "the scope name to use for matches (includes `begin` and `end` tokens)",
    "contentName": "the scope name to use for the content of matches (does not include `begin` and `end` tokens)",

    "begin": "a regex for the start of the matching scope",
    "match": "a regex for the content of the matching scope",
    "end": "a regex for the end of the matching scope",

    "beginCaptures": "a capture descriptor for captures made in `begin`",
    "captures": "a capture descriptor for captures made in `match`",
    "endCaptures": "a capture descriptor for captures made in `end`",

    "patterns": "an array of rules (like this one) to match scopes between `begin` and `end`"
}
```

A "capture descriptor" is an object describing information about a capture made by a rule. A capture descriptor's keys are the capture indexes, and the values are an object describing the capture. An example:

``` json
{
    "1": { name: "scope.of.capture.one" }
}
```

According to [the docs](https://macromates.com/manual/en/language_grammars#rule_keys), currently "`name` is the only attribute supported" for capture descriptions.


## Reusing Rules
Any `patterns` array can recursively refer to rules already defined. Instead of including a regular rule, simply add an object with an `include` property pointing to the rule to reference, like so:

``` json
{
    "include": "{reference}"
}
```

(where `{reference}` is one of ["#repository-rule"](#creating-new-named-rules), "source.{language}", or "$self")

### Creating new named rules
The `repository` is a place to define named rules to use in [`include` statements](#including-rules-recursively). The `repository`'s sole purpose is to provide a dictionary of names to rules. An example repository with two rules might look like this:

``` json
{
    "repository": {
        "my-rule": {
            "name": "scope.for.my.rule",
            "match": "my[\s-]*rule"
        },
        "special-rule": {
            "name": "scope.for.special.rule",
            "begin": "<special",
            "end": ">"
        }
    }
}
```
