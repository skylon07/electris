import './regexp_recipes.dart';
import './regexp_builder_base.dart';


RegExpRecipe normalize(RegExpRecipe recipe) {
  _NormalizedRecipe normalized = switch (recipe) {
    JoinedRegExpRecipe(tag: RegExpTag.either) => _normalizeEither(recipe),
    AugmentedRegExpRecipe(tag: RegExpTag.behindIsNot) => _normalizeBehindIsNot(recipe),
    AugmentedRegExpRecipe(tag: RegExpTag.behindIs) => _normalizeBehindIs(recipe),
    _ => _NormalizedRecipe(recipe),
  };
  return normalized.recipe;
}


// TODO: document how this class reminds normalizing functions to use `_replace...()` functions,
//  which handle normalizing subtrees, instead of just using `recipe.copy()`
extension type _NormalizedRecipe(RegExpRecipe recipe) {}
_NormalizedRecipe _replaceSubtree(List<RegExpRecipe> newSources, RegExpRecipe Function(List<RegExpRecipe> normalizedSources) createRecipe, {bool normalizeHead = true}) {
  var normalizedSources = [
    for (var source in newSources)
      normalize(source),
  ];
  var recipe = createRecipe(normalizedSources);
  if (normalizeHead) {
    recipe = normalize(recipe);
  }
  return _NormalizedRecipe(recipe);
}

_NormalizedRecipe _replaceSubtreeSingle(RegExpRecipe newSource, RegExpRecipe Function(RegExpRecipe normalizedSource) createRecipe, {bool normalizeHead = true}) =>
  _replaceSubtree([newSource], (normalizedSources) => createRecipe(normalizedSources.single), normalizeHead: normalizeHead);

_NormalizedRecipe _replaceSource(AugmentedRegExpRecipe recipe, RegExpRecipe newSource) =>
  _replaceSubtreeSingle(newSource, (normalizedSource) => recipe.copy(source: normalizedSource), normalizeHead: false);

_NormalizedRecipe _replaceSources(JoinedRegExpRecipe recipe, List<RegExpRecipe> newSources) =>
  _replaceSubtree(newSources, (normalizedSources) => recipe.copy(sources: normalizedSources), normalizeHead: false);


final class RecipeConfigurationError extends Error {
  final RegExpRecipe topRecipe;
  final RegExpRecipe containedRecipe;

  RecipeConfigurationError(this.topRecipe, this.containedRecipe);

  @override
  String toString() {
    var topRecipeRep = _prettyRepOf(topRecipe, "...");
    var containedRecipeRep = _prettyRepOf(containedRecipe, "...");
    var fullRep = _prettyRepOf(topRecipe, "...$containedRecipeRep...");
    return "Invalid regex configuration `$fullRep`: `$topRecipeRep` cannot contain `$containedRecipeRep";
  }

  static String _prettyRepOf(RegExpRecipe recipe, String innerRep) {
    return switch(recipe) {
      BaseRegExpRecipe(:var expr) => 
        expr,
      AugmentedRegExpRecipe(:var augment) => 
        augment(innerRep),
      JoinedRegExpRecipe(:var joinBy) => 
        "$innerRep$joinBy...",
    };
  }
}


_NormalizedRecipe _normalizeEither(JoinedRegExpRecipe recipe) {
  var (chars, notChars, rest) = _flattenEither(recipe);
  var charClass = _combineCharClasses(chars);
  var notCharClass = _combineCharClasses(notChars);
  return _replaceSources(
    recipe,
    [
      if (charClass != null) charClass,
      if (notCharClass != null) notCharClass,
      ...rest,
    ],
  );
}

typedef EitherFlatClasses = (
  List<InvertibleRegExpRecipe> charsList,
  List<InvertibleRegExpRecipe> notCharsList,
  List<RegExpRecipe>          restList,
);
EitherFlatClasses _flattenEither(JoinedRegExpRecipe recipe) {
  var charsList = <InvertibleRegExpRecipe>[];
  var notCharsList = <InvertibleRegExpRecipe>[];
  var restList = <RegExpRecipe>[];

  // TODO: replace with functions like `_traverse()` and `_map` once they are added
  for (var source in recipe.sources) {
    switch (source) {
      case JoinedRegExpRecipe(tag: RegExpTag.either): {
        var (chars, notChars, rest) = _flattenEither(source);
        charsList.addAll(chars);
        notCharsList.addAll(notChars);
        restList.addAll(rest);
      }

      case InvertibleRegExpRecipe(tag: RegExpTag.chars, inverted: false): {
        charsList.add(source);
      }

      case InvertibleRegExpRecipe(tag: RegExpTag.chars, inverted: true): {
        notCharsList.add(source);
      }

      case RegExpRecipe(): {
        restList.add(source);
      }
    }
  }
  return (charsList, notCharsList, restList);
}

InvertibleRegExpRecipe? _combineCharClasses(List<InvertibleRegExpRecipe> recipes) {
  if (recipes.isEmpty) return null;

  var (combinedClasses, inverted) = recipes
    .map((recipe) => (recipe.source.compile(), recipe.inverted))
    .reduce((last, next) {
      var (lastSource, lastInverted) = last;
      var (nextSource, nextInverted) = next;
      assert (lastInverted == nextInverted);
      return (lastSource + nextSource, nextInverted);
    });
  return InvertibleRegExpRecipe(
    BaseRegExpRecipe(combinedClasses),
    recipes.first.augment,
    inverted: inverted,
  );
}


_NormalizedRecipe _normalizeBehindIsNot(AugmentedRegExpRecipe recipe) {
  var shouldTransform = false;
  sourcesLoop: for (var source in recipe.sourcesFlattened) {
    switch (source.tag) {
      case RegExpTag.capture:
      case RegExpTag.either: {
        shouldTransform = true;
        break sourcesLoop;
      }

      // TODO: aheadIs nodes could just be clipped out/mapped to their children...
      case RegExpTag.aheadIs:
      case RegExpTag.aheadIsNot: {
        throw RecipeConfigurationError(recipe, source);
      }

      default: continue;
    }
  }

  if (shouldTransform) {
    return _replaceSubtreeSingle(
      recipe.source,
      (normalizedSource) => 
        regExpBuilder.aheadIsNot(
          regExpBuilder.behindIs(
            normalizedSource
          ),
        ),
    );
  } else {
    return _NormalizedRecipe(recipe);
  }
}


_NormalizedRecipe _normalizeBehindIs(AugmentedRegExpRecipe recipe) {
  for (var source in recipe.sourcesFlattened) {
    switch (source.tag) {
      // TODO: aheadIs nodes could just be clipped out/mapped to their children...
      case RegExpTag.aheadIs:
      case RegExpTag.aheadIsNot:
      case RegExpTag.behindIsNot: {
        throw RecipeConfigurationError(recipe, source);
      }

      default: continue;
    }
  }
  return _NormalizedRecipe(recipe);
}
