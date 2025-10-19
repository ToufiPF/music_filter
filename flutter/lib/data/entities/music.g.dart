// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMusicCollection on Isar {
  IsarCollection<Music> get musics => this.collection();
}

const MusicSchema = CollectionSchema(
  name: r'Music',
  id: -9183130217566162288,
  properties: {
    r'album': PropertySchema(
      id: 0,
      name: r'album',
      type: IsarType.string,
    ),
    r'albumArtist': PropertySchema(
      id: 1,
      name: r'albumArtist',
      type: IsarType.string,
    ),
    r'artists': PropertySchema(
      id: 2,
      name: r'artists',
      type: IsarType.string,
    ),
    r'physicalPath': PropertySchema(
      id: 3,
      name: r'physicalPath',
      type: IsarType.string,
    ),
    r'state': PropertySchema(
      id: 4,
      name: r'state',
      type: IsarType.byte,
      enumMap: _MusicstateEnumValueMap,
    ),
    r'title': PropertySchema(
      id: 5,
      name: r'title',
      type: IsarType.string,
    ),
    r'virtualPath': PropertySchema(
      id: 6,
      name: r'virtualPath',
      type: IsarType.string,
    )
  },
  estimateSize: _musicEstimateSize,
  serialize: _musicSerialize,
  deserialize: _musicDeserialize,
  deserializeProp: _musicDeserializeProp,
  idName: r'id',
  indexes: {
    r'physicalPath': IndexSchema(
      id: -1913275958561836485,
      name: r'physicalPath',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'physicalPath',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'virtualPath': IndexSchema(
      id: -3357044703392709690,
      name: r'virtualPath',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'virtualPath',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    ),
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
  getId: _musicGetId,
  getLinks: _musicGetLinks,
  attach: _musicAttach,
  version: '3.1.0+1',
);

int _musicEstimateSize(
  Music object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.album;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.albumArtist;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.artists;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.physicalPath.length * 3;
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.virtualPath.length * 3;
  return bytesCount;
}

void _musicSerialize(
  Music object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.album);
  writer.writeString(offsets[1], object.albumArtist);
  writer.writeString(offsets[2], object.artists);
  writer.writeString(offsets[3], object.physicalPath);
  writer.writeByte(offsets[4], object.state.index);
  writer.writeString(offsets[5], object.title);
  writer.writeString(offsets[6], object.virtualPath);
}

Music _musicDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Music(
    album: reader.readStringOrNull(offsets[0]),
    albumArtist: reader.readStringOrNull(offsets[1]),
    artists: reader.readStringOrNull(offsets[2]),
    physicalPath: reader.readString(offsets[3]),
    title: reader.readStringOrNull(offsets[5]),
    virtualPath: reader.readString(offsets[6]),
  );
  object.id = id;
  object.state = _MusicstateValueEnumMap[reader.readByteOrNull(offsets[4])] ??
      KeepState.unspecified;
  return object;
}

P _musicDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (_MusicstateValueEnumMap[reader.readByteOrNull(offset)] ??
          KeepState.unspecified) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MusicstateEnumValueMap = {
  'unspecified': 0,
  'kept': 1,
  'deleted': 2,
};
const _MusicstateValueEnumMap = {
  0: KeepState.unspecified,
  1: KeepState.kept,
  2: KeepState.deleted,
};

Id _musicGetId(Music object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _musicGetLinks(Music object) {
  return [];
}

void _musicAttach(IsarCollection<dynamic> col, Id id, Music object) {
  object.id = id;
}

extension MusicByIndex on IsarCollection<Music> {
  Future<Music?> getByPhysicalPath(String physicalPath) {
    return getByIndex(r'physicalPath', [physicalPath]);
  }

  Music? getByPhysicalPathSync(String physicalPath) {
    return getByIndexSync(r'physicalPath', [physicalPath]);
  }

  Future<bool> deleteByPhysicalPath(String physicalPath) {
    return deleteByIndex(r'physicalPath', [physicalPath]);
  }

  bool deleteByPhysicalPathSync(String physicalPath) {
    return deleteByIndexSync(r'physicalPath', [physicalPath]);
  }

  Future<List<Music?>> getAllByPhysicalPath(List<String> physicalPathValues) {
    final values = physicalPathValues.map((e) => [e]).toList();
    return getAllByIndex(r'physicalPath', values);
  }

  List<Music?> getAllByPhysicalPathSync(List<String> physicalPathValues) {
    final values = physicalPathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'physicalPath', values);
  }

  Future<int> deleteAllByPhysicalPath(List<String> physicalPathValues) {
    final values = physicalPathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'physicalPath', values);
  }

  int deleteAllByPhysicalPathSync(List<String> physicalPathValues) {
    final values = physicalPathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'physicalPath', values);
  }

  Future<Id> putByPhysicalPath(Music object) {
    return putByIndex(r'physicalPath', object);
  }

  Id putByPhysicalPathSync(Music object, {bool saveLinks = true}) {
    return putByIndexSync(r'physicalPath', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPhysicalPath(List<Music> objects) {
    return putAllByIndex(r'physicalPath', objects);
  }

  List<Id> putAllByPhysicalPathSync(List<Music> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'physicalPath', objects, saveLinks: saveLinks);
  }

  Future<Music?> getByVirtualPath(String virtualPath) {
    return getByIndex(r'virtualPath', [virtualPath]);
  }

  Music? getByVirtualPathSync(String virtualPath) {
    return getByIndexSync(r'virtualPath', [virtualPath]);
  }

  Future<bool> deleteByVirtualPath(String virtualPath) {
    return deleteByIndex(r'virtualPath', [virtualPath]);
  }

  bool deleteByVirtualPathSync(String virtualPath) {
    return deleteByIndexSync(r'virtualPath', [virtualPath]);
  }

  Future<List<Music?>> getAllByVirtualPath(List<String> virtualPathValues) {
    final values = virtualPathValues.map((e) => [e]).toList();
    return getAllByIndex(r'virtualPath', values);
  }

  List<Music?> getAllByVirtualPathSync(List<String> virtualPathValues) {
    final values = virtualPathValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'virtualPath', values);
  }

  Future<int> deleteAllByVirtualPath(List<String> virtualPathValues) {
    final values = virtualPathValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'virtualPath', values);
  }

  int deleteAllByVirtualPathSync(List<String> virtualPathValues) {
    final values = virtualPathValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'virtualPath', values);
  }

  Future<Id> putByVirtualPath(Music object) {
    return putByIndex(r'virtualPath', object);
  }

  Id putByVirtualPathSync(Music object, {bool saveLinks = true}) {
    return putByIndexSync(r'virtualPath', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByVirtualPath(List<Music> objects) {
    return putAllByIndex(r'virtualPath', objects);
  }

  List<Id> putAllByVirtualPathSync(List<Music> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'virtualPath', objects, saveLinks: saveLinks);
  }
}

extension MusicQueryWhereSort on QueryBuilder<Music, Music, QWhere> {
  QueryBuilder<Music, Music, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Music, Music, QAfterWhere> anyState() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'state'),
      );
    });
  }
}

extension MusicQueryWhere on QueryBuilder<Music, Music, QWhereClause> {
  QueryBuilder<Music, Music, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Music, Music, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Music, Music, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Music, Music, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterWhereClause> physicalPathEqualTo(
      String physicalPath) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'physicalPath',
        value: [physicalPath],
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterWhereClause> physicalPathNotEqualTo(
      String physicalPath) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'physicalPath',
              lower: [],
              upper: [physicalPath],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'physicalPath',
              lower: [physicalPath],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'physicalPath',
              lower: [physicalPath],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'physicalPath',
              lower: [],
              upper: [physicalPath],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Music, Music, QAfterWhereClause> virtualPathEqualTo(
      String virtualPath) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'virtualPath',
        value: [virtualPath],
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterWhereClause> virtualPathNotEqualTo(
      String virtualPath) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'virtualPath',
              lower: [],
              upper: [virtualPath],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'virtualPath',
              lower: [virtualPath],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'virtualPath',
              lower: [virtualPath],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'virtualPath',
              lower: [],
              upper: [virtualPath],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Music, Music, QAfterWhereClause> stateEqualTo(KeepState state) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'state',
        value: [state],
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterWhereClause> stateNotEqualTo(
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

  QueryBuilder<Music, Music, QAfterWhereClause> stateGreaterThan(
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

  QueryBuilder<Music, Music, QAfterWhereClause> stateLessThan(
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

  QueryBuilder<Music, Music, QAfterWhereClause> stateBetween(
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

extension MusicQueryFilter on QueryBuilder<Music, Music, QFilterCondition> {
  QueryBuilder<Music, Music, QAfterFilterCondition> albumIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'album',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'album',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'album',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'album',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'album',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'album',
        value: '',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumArtistIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'albumArtist',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumArtistIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'albumArtist',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumArtistEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'albumArtist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumArtistGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'albumArtist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumArtistLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'albumArtist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumArtistBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'albumArtist',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumArtistStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'albumArtist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumArtistEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'albumArtist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumArtistContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'albumArtist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumArtistMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'albumArtist',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumArtistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'albumArtist',
        value: '',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> albumArtistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'albumArtist',
        value: '',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> artistsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'artists',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> artistsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'artists',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> artistsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> artistsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> artistsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> artistsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artists',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> artistsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> artistsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> artistsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artists',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> artistsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artists',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> artistsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artists',
        value: '',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> artistsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artists',
        value: '',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> physicalPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'physicalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> physicalPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'physicalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> physicalPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'physicalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> physicalPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'physicalPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> physicalPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'physicalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> physicalPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'physicalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> physicalPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'physicalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> physicalPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'physicalPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> physicalPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'physicalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> physicalPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'physicalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> stateEqualTo(
      KeepState value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'state',
        value: value,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> stateGreaterThan(
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

  QueryBuilder<Music, Music, QAfterFilterCondition> stateLessThan(
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

  QueryBuilder<Music, Music, QAfterFilterCondition> stateBetween(
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

  QueryBuilder<Music, Music, QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> titleContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> titleMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> virtualPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'virtualPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> virtualPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'virtualPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> virtualPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'virtualPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> virtualPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'virtualPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> virtualPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'virtualPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> virtualPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'virtualPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> virtualPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'virtualPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> virtualPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'virtualPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> virtualPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'virtualPath',
        value: '',
      ));
    });
  }

  QueryBuilder<Music, Music, QAfterFilterCondition> virtualPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'virtualPath',
        value: '',
      ));
    });
  }
}

extension MusicQueryObject on QueryBuilder<Music, Music, QFilterCondition> {}

extension MusicQueryLinks on QueryBuilder<Music, Music, QFilterCondition> {}

extension MusicQuerySortBy on QueryBuilder<Music, Music, QSortBy> {
  QueryBuilder<Music, Music, QAfterSortBy> sortByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> sortByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> sortByAlbumArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumArtist', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> sortByAlbumArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumArtist', Sort.desc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> sortByArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artists', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> sortByArtistsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artists', Sort.desc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> sortByPhysicalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'physicalPath', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> sortByPhysicalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'physicalPath', Sort.desc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> sortByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> sortByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> sortByVirtualPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'virtualPath', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> sortByVirtualPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'virtualPath', Sort.desc);
    });
  }
}

extension MusicQuerySortThenBy on QueryBuilder<Music, Music, QSortThenBy> {
  QueryBuilder<Music, Music, QAfterSortBy> thenByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenByAlbumArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumArtist', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenByAlbumArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'albumArtist', Sort.desc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenByArtists() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artists', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenByArtistsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artists', Sort.desc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenByPhysicalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'physicalPath', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenByPhysicalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'physicalPath', Sort.desc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenByStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'state', Sort.desc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenByVirtualPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'virtualPath', Sort.asc);
    });
  }

  QueryBuilder<Music, Music, QAfterSortBy> thenByVirtualPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'virtualPath', Sort.desc);
    });
  }
}

extension MusicQueryWhereDistinct on QueryBuilder<Music, Music, QDistinct> {
  QueryBuilder<Music, Music, QDistinct> distinctByAlbum(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'album', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Music, Music, QDistinct> distinctByAlbumArtist(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'albumArtist', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Music, Music, QDistinct> distinctByArtists(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artists', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Music, Music, QDistinct> distinctByPhysicalPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'physicalPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Music, Music, QDistinct> distinctByState() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'state');
    });
  }

  QueryBuilder<Music, Music, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Music, Music, QDistinct> distinctByVirtualPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'virtualPath', caseSensitive: caseSensitive);
    });
  }
}

extension MusicQueryProperty on QueryBuilder<Music, Music, QQueryProperty> {
  QueryBuilder<Music, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Music, String?, QQueryOperations> albumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'album');
    });
  }

  QueryBuilder<Music, String?, QQueryOperations> albumArtistProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'albumArtist');
    });
  }

  QueryBuilder<Music, String?, QQueryOperations> artistsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artists');
    });
  }

  QueryBuilder<Music, String, QQueryOperations> physicalPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'physicalPath');
    });
  }

  QueryBuilder<Music, KeepState, QQueryOperations> stateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'state');
    });
  }

  QueryBuilder<Music, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Music, String, QQueryOperations> virtualPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'virtualPath');
    });
  }
}
