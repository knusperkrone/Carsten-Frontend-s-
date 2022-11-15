// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerializableSearchResult _$SerializableSearchResultFromJson(
        Map<String, dynamic> json) =>
    SerializableSearchResult(
      json['url'] as String,
      json['name'] as String,
      json['parent'] as String,
      json['serialized'] as String,
      $enumDecode(_$SearchTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$SerializableSearchResultToJson(
        SerializableSearchResult instance) =>
    <String, dynamic>{
      'url': instance.url,
      'name': instance.name,
      'parent': instance.parent,
      'serialized': instance.serialized,
      'type': _$SearchTypeEnumMap[instance.type],
    };

const _$SearchTypeEnumMap = {
  SearchType.TRACK: 'TRACK',
  SearchType.PLAYLIST: 'PLAYLIST',
  SearchType.ALBUM: 'ALBUM',
};
