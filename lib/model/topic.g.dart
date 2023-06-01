// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      posterId: json['poster_id'] as int?,
      poster: json['poster'] == null
          ? null
          : User.fromJson(json['poster'] as Map<String, dynamic>),
      isAnonymous: json['is_anonymous'] as bool,
      anonyname: json['anonyname'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList(),
      divisionId: json['division_id'] as int,
      lastComment: json['last_comment'] == null
          ? null
          : Comment.fromJson(json['last_comment'] as Map<String, dynamic>),
      viewCount: json['view_count'] as int,
      likeCount: json['like_count'] as int,
      dislikeCount: json['dislike_count'] as int,
      commentCount: json['comment_count'] as int,
      favoriteCount: json['favorite_count'] as int,
      isOwner: json['is_owner'] as bool,
      liked: json['liked'] as bool,
      disliked: json['disliked'] as bool,
      favored: json['favored'] as bool,
    );

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'title': instance.title,
      'content': instance.content,
      'poster_id': instance.posterId,
      'poster': instance.poster,
      'is_anonymous': instance.isAnonymous,
      'anonyname': instance.anonyname,
      'division_id': instance.divisionId,
      'tags': instance.tags,
      'last_comment': instance.lastComment,
      'view_count': instance.viewCount,
      'like_count': instance.likeCount,
      'dislike_count': instance.dislikeCount,
      'comment_count': instance.commentCount,
      'favorite_count': instance.favoriteCount,
      'is_owner': instance.isOwner,
      'liked': instance.liked,
      'disliked': instance.disliked,
      'favored': instance.favored,
    };
