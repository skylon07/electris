import './regexp_recipes.dart';
import './regexp_builder_base.dart';


RegExpRecipe normalize(RegExpRecipe recipe) {
  _NormalizedRecipe normalized = switch (recipe) {
    EitherRegExpRecipe() => _normalizeEither(recipe),
    BehindIsNotRegExpRecipe() => _normalizeBehindIsNot(recipe),
    
    AugmentedRegExpRecipe(:var source) => _replaceSource(recipe, source),
    JoinedRegExpRecipe(:var sources) => _replaceSources(recipe, sources),
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


_NormalizedRecipe _normalizeEither(EitherRegExpRecipe recipe) {
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
  List<CharClassRegExpRecipe> charsList,
  List<CharClassRegExpRecipe> notCharsList,
  List<RegExpRecipe>          restList,
);
EitherFlatClasses _flattenEither(EitherRegExpRecipe recipe) {
  var charsList = <CharClassRegExpRecipe>[];
  var notCharsList = <CharClassRegExpRecipe>[];
  var restList = <RegExpRecipe>[];

  for (var source in recipe.sources) {
    if (source is EitherRegExpRecipe) {
      var (chars, notChars, rest) = _flattenEither(source);
      charsList.addAll(chars);
      notCharsList.addAll(notChars);
      restList.addAll(rest);
    } else {
      var listForSource = switch(source) {
        CharClassRegExpRecipe(inverted: false) => charsList,
        CharClassRegExpRecipe(inverted: true) => notCharsList,
        RegExpRecipe() => restList,
      };
      listForSource.add(source);
    }
  }
  return (charsList, notCharsList, restList);
}

CharClassRegExpRecipe? _combineCharClasses(List<CharClassRegExpRecipe> recipes) {
  if (recipes.isEmpty) return null;

  var (combinedClasses, inverted) = recipes
    .map((recipe) => (recipe.source.compile(), recipe.inverted))
    .reduce((last, next) {
      var (lastSource, lastInverted) = last;
      var (nextSource, nextInverted) = next;
      assert (lastInverted == nextInverted);
      return (lastSource + nextSource, nextInverted);
    });
  return CharClassRegExpRecipe(
    BaseRegExpRecipe(combinedClasses),
    recipes.first.augment,
    inverted: inverted,
  );
}


_NormalizedRecipe _normalizeBehindIsNot(BehindIsNotRegExpRecipe recipe) {
  return _replaceSubtreeSingle(
    recipe.source,
    (normalizedSource) => 
      regExpBuilder.aheadIsNot(
        regExpBuilder.behindIs(
          normalizedSource
        ),
      ),
  );
}
