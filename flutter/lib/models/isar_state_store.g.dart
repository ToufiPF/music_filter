// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_state_store.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMusicStateCollection on Isar {
  IsarCollection<MusicState> get musicStates => this.collection();
}

const MusicStateSchema = CollectionSchema(
  name: r'MusicState',
  id: 8982773206380275642,
  properties: {
    r'state': PropertySchema(
      id: 0,
      name: r'state',
      type: IsarType.byte,
      enumMap: _MusicStatestateEnumValueMap,
    )
  },
  estimateSize: _musicStateEstimateSize,
  serialize: _musicStateSerialize,
  deserialize: _musicStateDeserialize,
  deserializeProp: _musicStateDeserializeProp,
  idName: r'musicId',
  indexes: {
    r'state': IndexSchema(
      id: 7917036384617311412,
      name: r'state',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'state',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _musicStateGetId,
  getLinks: _musicStateGetLinks,
  attach: _musicStateAttach,
  version: '3.1.0+1',
);

int _musicStateEstimateSize(
  MusicState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _musicStateSerialize(
  MusicState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.state.index);
}

MusicState _musicStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MusicState(
    id,
    _MusicStatestateValueEnumMap[reader.readByteOrNull(offsets[0])] ??
        KeepState.unspecified,
  );
  return object;
}

P _musicStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_MusicStatestateValueEnumMap[reader.readByteOrNull(offset)] ??
          KeepState.unspecified) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MusicStatestateEnumValueMap = {
  'unspecified': 0,
  'kept': 1,
  'deleted': 2,
};
const _MusicStatestateValueEnumMap = {
  0: KeepState.unspecified,
  1: KeepState.kept,
  2: KeepState.deleted,
};

Id _musicStateGetId(MusicState object) {
  return object.musicId;
}

List<IsarLinkBase<dynamic>> _musicStateGetLinks(MusicState object) {
  return [];
}

void _musicStateAttach(IsarCollection<dynamic> col, Id id, MusicState object) {}

extension MusicStateQueryWhereSort
    on QueryBuilder<MusicState, MusicState, QWhere> {
  QueryBuilder<MusicState, MusicState, QAfterWhere> anyMusicId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterWhere> anyState() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'state'),
      );
    });
  }
}

extension MusicStateQueryWhere
    on QueryBuilder<MusicState, MusicState, QWhereClause> {
  QueryBuilder<MusicState, MusicState, QAfterWhereClause> musicIdEqualTo(
      Id musicId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: musicId,
        upper: musicId,
      ));
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterWhereClause> musicIdNotEqualTo(
      Id musicId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: musicId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: musicId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: musicId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: musicId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterWhereClause> musicIdGreaterThan(
      Id musicId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: musicId, includeLower: include),
      );
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterWhereClause> musicIdLessThan(
      Id musicId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: musicId, includeUpper: include),
      );
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterWhereClause> musicIdBetween(
    Id lowerMusicId,
    Id upperMusicId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerMusicId,
        includeLower: includeLower,
        upper: upperMusicId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterWhereClause> stateEqualTo(
      KeepState state) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'state',
        value: [state],
      ));
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterWhereClause> stateNotEqualTo(
      KeepState state) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'state',
              lower: [],
              upper: [state],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'state',
              lower: [state],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'state',
              lower: [state],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'state',
              lower: [],
              upper: [state],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterWhereClause> stateGreaterThan(
    KeepState state, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'state',
        lower: [state],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterWhereClause> stateLessThan(
    KeepState state, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'state',
        lower: [],
        upper: [state],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterWhereClause> stateBetween(
    KeepState lowerState,
    KeepState upperState, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'state',
        lower: [lowerState],
        includeLower: includeLower,
        upper: [upperState],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MusicStateQueryFilter
    on QueryBuilder<MusicState, MusicState, QFilterCondition> {
  QueryBuilder<MusicState, MusicState, QAfterFilterCondition> musicIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'musicId',
        value: value,
      ));
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterFilterCondition>
      musicIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'musicId',
        value: value,
      ));
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterFilterCondition> musicIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'musicId',
        value: value,
      ));
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterFilterCondition> musicIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'musicId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterFilterCondition> stateEqualTo(
      KeepState value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'state',
        value: value,
      ));
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterFilterCondition> stateGreaterThan(
    KeepState value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'state',
        value: value,
      ));
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterFilterCondition> stateLessThan(
    KeepState value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'state',
        value: value,
      ));
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterFilterCondition> stateBetween(
    KeepState lower,
    KeepState upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'state',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MusicStateQueryObject
    on QueryBuilder<MusicState, MusicState, QFilterCondition> {}

extension MusicStateQueryLinks
    on QueryBuilder<MusicState, MusicState, QFilterCondition> {}

extension MusicStateQuerySortBy
    on QueryBuilder<MusicState, MusicState, QSortBy> {
  QueryBuilder<MusicState, MusicState, QAfterSortBy> sortByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterSortBy> sortByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }
}

extension MusicStateQuerySortThenBy
    on QueryBuilder<MusicState, MusicState, QSortThenBy> {
  QueryBuilder<MusicState, MusicState, QAfterSortBy> thenByMusicId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'musicId', Sort.asc);
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterSortBy> thenByMusicIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'musicId', Sort.desc);
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterSortBy> thenByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<MusicState, MusicState, QAfterSortBy> thenByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }
}

extension MusicStateQueryWhereDistinct
    on QueryBuilder<MusicState, MusicState, QDistinct> {
  QueryBuilder<MusicState, MusicState, QDistinct> distinctByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'state');
    });
  }
}

extension MusicStateQueryProperty
    on QueryBuilder<MusicState, MusicState, QQueryProperty> {
  QueryBuilder<MusicState, int, QQueryOperations> musicIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'musicId');
    });
  }

  QueryBuilder<MusicState, KeepState, QQueryOperations> stateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'state');
    });
  }
}
