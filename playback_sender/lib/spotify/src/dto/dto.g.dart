// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpotifyAlbum _$SpotifyAlbumFromJson(Map<String, dynamic> json) => SpotifyAlbum(
      json['id'] as String,
      json['name'] as String,
      (json['images'] as List<dynamic>)
          .map((dynamic e) => SpotifyImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['artists'] as List<dynamic>)
          .map((dynamic e) => SpotifyArtist.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SpotifyAlbumToJson(SpotifyAlbum instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'images': instance.images,
      'artists': instance.artists,
    };

SpotifyArtist _$SpotifyArtistFromJson(Map<String, dynamic> json) =>
    SpotifyArtist(
      json['name'] as String,
    );

Map<String, dynamic> _$SpotifyArtistToJson(SpotifyArtist instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

SpotifyImage _$SpotifyImageFromJson(Map<String, dynamic> json) => SpotifyImage(
      json['height'] as int?,
      json['width'] as int?,
      json['url'] as String,
    );

Map<String, dynamic> _$SpotifyImageToJson(SpotifyImage instance) =>
    <String, dynamic>{
      'height': instance.height,
      'width': instance.width,
      'url': instance.url,
    };

SpotifyPager _$SpotifyPagerFromJson(Map<String, dynamic> json) => SpotifyPager(
      json['next'] as String?,
      json['previous'] as String?,
      genericListFromJson(json['items'] as List),
    );

SpotifyPlaylist _$SpotifyPlaylistFromJson(Map<String, dynamic> json) =>
    SpotifyPlaylist(
      json['id'] as String,
      json['name'] as String,
      json['snapshot_id'] as String,
      (json['images'] as List<dynamic>?)
          ?.map((dynamic e) => SpotifyImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      SpotifyUser.fromJson(json['owner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SpotifyPlaylistToJson(SpotifyPlaylist instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'snapshot_id': instance.snapshotId,
      'images': instance.images,
      'owner': instance.owner,
    };

SpotifyTrack _$SpotifyTrackFromJson(Map<String, dynamic> json) => SpotifyTrack(
      json['href'] as String,
      json['name'] as String,
      SpotifyAlbum.fromJson(json['album'] as Map<String, dynamic>),
      (json['artists'] as List<dynamic>)
          .map((dynamic e) => SpotifyArtist.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SpotifyTrackToJson(SpotifyTrack instance) =>
    <String, dynamic>{
      'href': instance.href,
      'name': instance.name,
      'album': instance.album,
      'artists': instance.artists,
    };

SpotifyTracksLink _$SpotifyTracksLinkFromJson(Map<String, dynamic> json) =>
    SpotifyTracksLink(
      json['href'] as String,
      json['total'] as int,
    );

Map<String, dynamic> _$SpotifyTracksLinkToJson(SpotifyTracksLink instance) =>
    <String, dynamic>{
      'href': instance.href,
      'total': instance.total,
    };

SpotifyUser _$SpotifyUserFromJson(Map<String, dynamic> json) => SpotifyUser(
      json['display_name'] as String,
    );

Map<String, dynamic> _$SpotifyUserToJson(SpotifyUser instance) =>
    <String, dynamic>{
      'display_name': instance.name,
    };
