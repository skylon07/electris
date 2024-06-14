import './regexp_recipes.dart';
import './regexp_builder_base.dart';


RegExpRecipe normalize(RegExpRecipe recipe) {
  return switch (recipe) {
    JoinedRegExpRecipe(tag: RegExpTag.either) => _normalizeEither(recipe),
    AugmentedRegExpRecipe(tag: RegExpTag.behindIsNot) => _normalizeBehindIsNot(recipe),
    AugmentedRegExpRecipe(tag: RegExpTag.behindIs) => _normalizeBehindIs(recipe),
    _ => recipe,
  };
}


typedef TransformFn = RegExpRecipe? Function(RegExpRecipe);
extension _RecipeTraversal on RegExpRecipe {
  RegExpRecipe traverseTransform(TransformFn transform) {
    RegExpRecipe? prevRecipe = null;
    RegExpRecipe newRecipe = this;
    while (newRecipe != prevRecipe) {
      var result = transform(this);
      if (result == null) return newRecipe;
      prevRecipe = newRecipe;
      newRecipe = result;
    }
    
    switch (newRecipe) {
      case AugmentedRegExpRecipe(:var source): {
        var newSource = source.traverseTransform(transform);
        newRecipe = newRecipe.copy(source: newSource);
      }

      case JoinedRegExpRecipe(:var sources): {
        var newSources = [
          for (var source in sources)
            source.traverseTransform(transform)
        ];
        newRecipe = newRecipe.copy(sources: newSources);
      }

      default: break;
    }
    
    return newRecipe;
  }
}

TransformFn _combineTransforms(List<TransformFn> functions) {
  return (RegExpRecipe source) {
    for (var function in functions) {
      var newSource = function(source);
      if (newSource != source) return newSource;
    }
    return source;
  };
}

TransformFn _transform_pruneAheadIs() {
  var toPrune = <RegExpRecipe>{};
  return (recipe) {
    switch (recipe) {
      case AugmentedRegExpRecipe(tag: RegExpTag.aheadIs, :var source): {
        return toPrune.contains(recipe)? 
          source : recipe;
      }

      case JoinedRegExpRecipe(tag: RegExpTag.concat, :var sources): {
        var lastSource = sources.last;
        if (lastSource.tag == RegExpTag.aheadIs) {
          toPrune.add(lastSource);
        }
      }

      default: break;
    }
    return recipe;
  };
}


final class RecipeConfigurationError extends Error {
  final RegExpRecipe topRecipe;
  final RegExpRecipe containedRecipe;
  final String? details;

  RecipeConfigurationError(this.topRecipe, this.containedRecipe, [this.details]);

  @override
  String toString() {
    var topRecipeRep = _prettyRepOf(topRecipe, "...");
    var containedRecipeRep = _prettyRepOf(containedRecipe, "...");
    var fullRep = _prettyRepOf(topRecipe, "...$containedRecipeRep...");
    var detailsStr = (details != null)? " ($details)" : "";
    return "Invalid regex configuration `$fullRep`: `$topRecipeRep` cannot contain `$containedRecipeRep$detailsStr";
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


RegExpRecipe _normalizeEither(JoinedRegExpRecipe recipe) {
  var (chars, notChars, rest) = _flattenEither(recipe);
  var charClass = _combineCharClasses(chars);
  var notCharClass = _combineCharClasses(notChars);
  return recipe.copy(
    sources: [
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

  recipe.traverseTransform((source) {
    switch (source) {
      case InvertibleRegExpRecipe(tag: RegExpTag.chars, inverted: false): {
        charsList.add(source);
        return null;
      }

      case InvertibleRegExpRecipe(tag: RegExpTag.chars, inverted: true): {
        notCharsList.add(source);
        return null;
      }

      case RegExpRecipe(:var tag): {
        if (tag == RegExpTag.either) return source;

        restList.add(source);
        return null;
      }
    }
  });
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


RegExpRecipe _normalizeBehindIsNot(AugmentedRegExpRecipe recipe) {
  var shouldTransform = false;
  recipe.traverseTransform(
    _combineTransforms([
      _transform_pruneAheadIs(),
      (source) {
        switch (source.tag) {
          case RegExpTag.capture:
          case RegExpTag.either: {
            shouldTransform = true;
            return null;
          }

          case RegExpTag.aheadIs: {
            throw RecipeConfigurationError(recipe, source, "only allowed at the end of a `concat()`");
          }

          case RegExpTag.aheadIsNot: {
            throw RecipeConfigurationError(recipe, source);
          }

          default: return source;
        }
      },
    ])
  );

  if (shouldTransform) {
    return normalize(
      regExpBuilder.aheadIsNot(
        regExpBuilder.behindIs(
          recipe.source,
        ),
      )
    );
  } else {
    return recipe;
  }
}


RegExpRecipe _normalizeBehindIs(AugmentedRegExpRecipe recipe) {
  return recipe.traverseTransform(
    _combineTransforms([
      _transform_pruneAheadIs(),
      (source) {
        switch (source.tag) {
          case RegExpTag.aheadIs: {
            throw RecipeConfigurationError(recipe, source, "only allowed at the end of a `concat()`");
          }

          case RegExpTag.aheadIsNot:
          case RegExpTag.behindIsNot: {
            throw RecipeConfigurationError(recipe, source);
          }

          default: return source;
        }
      }
    ])
  );
}
