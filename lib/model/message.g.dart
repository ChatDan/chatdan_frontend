// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      fromUserId: json['from_user_id'] as int,
      toUserId: json['to_user_id'] as int,
      content: json['content'] as String? ?? '',
      isMe: json['is_me'] as bool,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'from_user_id': instance.fromUserId,
      'to_user_id': instance.toUserId,
      'content': instance.content,
      'is_me': instance.isMe,
    };
