// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      oneUserId: json['one_user_id'] as int,
      oneUser: json['one_user'] == null
          ? null
          : User.fromJson(json['one_user'] as Map<String, dynamic>),
      anotherUserId: json['another_user_id'] as int,
      anotherUser: json['another_user'] == null
          ? null
          : User.fromJson(json['another_user'] as Map<String, dynamic>),
      lastMessageContent: json['last_message_content'] as String? ?? '',
      messageCount: json['message_count'] as int? ?? 0,
    );

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'one_user_id': instance.oneUserId,
      'one_user': instance.oneUser,
      'another_user_id': instance.anotherUserId,
      'another_user': instance.anotherUser,
      'last_message_content': instance.lastMessageContent,
      'message_count': instance.messageCount,
    };
