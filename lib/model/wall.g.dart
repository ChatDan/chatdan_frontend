// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wall.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wall _$WallFromJson(Map<String, dynamic> json) => Wall(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      content: json['content'] as String? ?? '',
      posterId: json['poster_id'] as int,
      poster: json['poster'] == null
          ? null
          : User.fromJson(json['poster'] as Map<String, dynamic>),
      visibility: json['visibility'] as String,
      isAnonymous: json['is_anonymous'] as bool,
      isShown: json['is_shown'] as bool? ?? true,
    );

Map<String, dynamic> _$WallToJson(Wall instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'content': instance.content,
      'poster_id': instance.posterId,
      'poster': instance.poster,
      'visibility': instance.visibility,
      'is_anonymous': instance.isAnonymous,
      'is_shown': instance.isShown,
    };
