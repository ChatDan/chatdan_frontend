// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: json['id'] as int,
      posterId: json['poster_id'] as int,
      content: json['content'] as String? ?? '',
      visibility: json['visibility'] as String,
      isOwner: json['is_owner'] as bool,
      isAnonymous: json['is_anonymous'] as bool,
      anonyname: json['anonyname'] as String?,
      channelCount: json['channel_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      channels: (json['channels'] as List<dynamic>?)
          ?.map((e) => Channel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'poster_id': instance.posterId,
      'content': instance.content,
      'visibility': instance.visibility,
      'is_owner': instance.isOwner,
      'is_anonymous': instance.isAnonymous,
      'anonyname': instance.anonyname,
      'channel_count': instance.channelCount,
      'view_count': instance.viewCount,
      'channels': instance.channels,
    };
