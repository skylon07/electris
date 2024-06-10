import 'package:meta/meta.dart';

import './regexp_normalization.dart';


sealed class RegExpRecipe {
  final List<RegExpRecipe> sources;
  final GroupTracker _tracker;
  final RegExpTag? tag;

  RegExpRecipe(this.sources, this._tracker, {this.tag});

  String compile() => _expr;
  late final _expr = _createExpr();

  int positionOf(GroupRef ref) => _tracker.getPosition(ref);

  @mustBeOverridden
  RegExpRecipe copy();
  String _createExpr();

  Iterable<RegExpRecipe> get sourcesFlattened sync* {
    for (var source in sources) {
      yield source;
      yield* source.sourcesFlattened;
    }
  }
}

enum RegExpTag {
  capture, either, chars,
  aheadIs, aheadIsNot,
  behindIs, behindIsNot,
}


final class BaseRegExpRecipe extends RegExpRecipe {
  final String expr;

  BaseRegExpRecipe(this.expr, {super.tag}) : super(const [], GroupTracker());

  @override
  BaseRegExpRecipe copy({
    String? expr,
  }) => BaseRegExpRecipe(
    expr ?? this.expr,
  );
  
  @override
  String _createExpr() => expr;
}

final class AugmentedRegExpRecipe extends RegExpRecipe {
  final RegExpRecipe source;
  final Augmenter augment;

  AugmentedRegExpRecipe(this.source, this.augment, {super.tag}) : super([source], source._tracker);

  @override
  AugmentedRegExpRecipe copy({
    RegExpRecipe? source,
    Augmenter? augment
  }) => AugmentedRegExpRecipe(
    source ?? this.source,
    augment ?? this.augment,
  );

  @override
  String _createExpr() => augment(source.compile());
}
typedef Augmenter = String Function(String expr);

final class JoinedRegExpRecipe extends RegExpRecipe {
  final String joinBy;

  JoinedRegExpRecipe(List<RegExpRecipe> sources, this.joinBy, {super.tag}) : 
    super(
      sources,
      GroupTracker.combine(
        sources.map((source) => source._tracker)
      ),
    );

  @override
  JoinedRegExpRecipe copy({
    List<RegExpRecipe>? sources,
    String? joinBy,
  }) => JoinedRegExpRecipe(
    sources ?? this.sources,
    joinBy ?? this.joinBy,
  );

  @override
  String _createExpr() {
    return sources
      .map((source) => source.compile())
      .join(joinBy);
  }
}


final class InvertibleRegExpRecipe extends AugmentedRegExpRecipe {
  final bool inverted;

  InvertibleRegExpRecipe(super.source, super.augment, {required this.inverted, super.tag});

  @override
  InvertibleRegExpRecipe copy({
    RegExpRecipe? source,
    Augmenter? augment,
    bool? inverted,
  }) => InvertibleRegExpRecipe(
    source ?? this.source,
    augment ?? this.augment,
    inverted: inverted ?? this.inverted,
  );
}

final class TrackedRegExpRecipe extends AugmentedRegExpRecipe {
  @override
  late final GroupTracker _tracker;

  TrackedRegExpRecipe(super.source, super.augment, {GroupRef? ref, super.tag}) {
    var newTracker = source._tracker.increment();
    if (ref != null) {
      newTracker = newTracker.startTracking(ref);
    }
    _tracker = newTracker;
  }

  @override
  TrackedRegExpRecipe copy({
    RegExpRecipe? source,
    Augmenter? augment,
    GroupRef? ref,
  }) => TrackedRegExpRecipe(
    source ?? this.source,
    augment ?? this.augment,
    ref: ref,
  );
}


class GroupRef {}

// TODO: document operation meanings
final class GroupTracker {
  final Map<GroupRef, int> _positions;
  final int _groupCount;

  const GroupTracker._create(this._positions, this._groupCount);
  const GroupTracker(): this._create(const {}, 0);

  GroupTracker startTracking(GroupRef newRef, [int position = 1]) {
    assert (!_positions.containsKey(newRef));
    return GroupTracker._create(
      {
        ..._positions,
        newRef: position,
      },
      _groupCount,
    );
  }

  int getPosition(GroupRef ref) {
    if (!_positions.containsKey(ref)) throw ArgumentError("Position not tracked for ref!", "ref");
    return _positions[ref]!;
  }

  int get groupCount => _groupCount;

  GroupTracker increment([int by = 1]) => GroupTracker._create(
    {
      for (var MapEntry(key: groupRef, value: position) in _positions.entries)
        groupRef: position + by,
    },
    _groupCount + by,
  );

  static GroupTracker combine(Iterable<GroupTracker> trackers) {
    var combinedPositions = <GroupRef, int>{};
    var totalGroupCount = 0;

    for (var tracker in trackers) {
      for (var MapEntry(key: groupRef, value: position) in tracker._positions.entries) {
        assert (!combinedPositions.containsKey(groupRef));
        combinedPositions[groupRef] = position + totalGroupCount;
      }
      totalGroupCount += tracker._groupCount;
    }

    return GroupTracker._create(combinedPositions, totalGroupCount);
  }
}
