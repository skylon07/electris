import './regexp_recipes.dart';


RegExpRecipe normalize(RegExpRecipe recipe) =>
  switch (recipe) {
    EitherRegExpRecipe() => _normalizeEither(recipe),
    
    AugmentedRegExpRecipe(:var source) => _replaceSource(recipe, source),
    JoinedRegExpRecipe(:var sources) => _replaceSources(recipe, sources),
    _ => recipe,
  };


RecipeT _replaceSources<RecipeT extends JoinedRegExpRecipe>(RecipeT recipe, List<RegExpRecipe> newSources) {
  return recipe.copy(
    sources: [
      for (var source in newSources)
      normalize(source),
    ],
  ) as RecipeT;
}

RecipeT _replaceSource<RecipeT extends AugmentedRegExpRecipe>(RecipeT recipe, RegExpRecipe newSource) {
  return recipe.copy(
    source: normalize(newSource),
  ) as RecipeT;
}


EitherRegExpRecipe _normalizeEither(EitherRegExpRecipe recipe) {
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
