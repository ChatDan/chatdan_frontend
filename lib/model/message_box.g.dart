// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_box.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageBox _$MessageBoxFromJson(Map<String, dynamic> json) => MessageBox(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      title: json['title'] as String,
      ownerId: json['owner_id'] as int,
      owner: json['owner'] == null
          ? null
          : User.fromJson(json['owner'] as Map<String, dynamic>),
      postCount: json['post_count'] as int,
      viewCount: json['view_count'] as int,
      posts:
          (json['posts'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$MessageBoxToJson(MessageBox instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'title': instance.title,
      'owner_id': instance.ownerId,
      'owner': instance.owner,
      'post_count': instance.postCount,
      'view_count': instance.viewCount,
      'posts': instance.posts,
    };

MessageBoxList _$MessageBoxListFromJson(Map<String, dynamic> json) =>
    MessageBoxList(
      list: (json['list'] as List<dynamic>)
          .map((e) => MessageBox.fromJson(e as Map<String, dynamic>))
          .toList(),
      version: json['version'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );

Map<String, dynamic> _$MessageBoxListToJson(MessageBoxList instance) =>
    <String, dynamic>{
      'list': instance.list,
      'version': instance.version,
      'total': instance.total,
    };
