// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Channel _$ChannelFromJson(Map<String, dynamic> json) => Channel(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      content: json['content'] as String? ?? '',
      isOwner: json['is_owner'] as bool,
    );

Map<String, dynamic> _$ChannelToJson(Channel instance) => <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'content': instance.content,
      'is_owner': instance.isOwner,
    };
