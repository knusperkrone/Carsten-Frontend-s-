// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerializableSearchResult _$SerializableSearchResultFromJson(
    Map<String, dynamic> json) {
  return SerializableSearchResult(
    json['url'] as String,
    json['name'] as String,
    json['parent'] as String,
    json['serialized'] as String,
    _$enumDecode(_$SearchTypeEnumMap, json['type']),
  );
}

Map<String, dynamic> _$SerializableSearchResultToJson(
        SerializableSearchResult instance) =>
    <String, dynamic>{
      'url': instance.url,
      'name': instance.name,
      'parent': instance.parent,
      'serialized': instance.serialized,
      'type': _$SearchTypeEnumMap[instance.type],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

const _$SearchTypeEnumMap = {
  SearchType.TRACK: 'TRACK',
  SearchType.PLAYLIST: 'PLAYLIST',
  SearchType.ALBUM: 'ALBUM',
};
