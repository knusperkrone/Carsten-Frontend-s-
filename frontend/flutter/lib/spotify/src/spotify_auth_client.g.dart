// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_auth_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerializableApiToken _$SerializableApiTokenFromJson(
        Map<String, dynamic> json) =>
    SerializableApiToken(
      json['access_token'] as String,
      json['refresh_token'] as String?,
      json['token_type'] as String,
      json['expires_in'] as int,
      json['createdOn'] == null
          ? null
          : DateTime.parse(json['createdOn'] as String),
    );

Map<String, dynamic> _$SerializableApiTokenToJson(
        SerializableApiToken instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'createdOn': instance.createdOn?.toIso8601String(),
    };
