// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      topicId: json['topic_id'] as int,
      posterId: json['poster_id'] as int?,
      poster: json['poster'] == null
          ? null
          : User.fromJson(json['poster'] as Map<String, dynamic>),
      content: json['content'] as String? ?? '',
      isAnonymous: json['is_anonymous'] as bool,
      anonyname: json['anonyname'] as String?,
      ranking: json['ranking'] as int,
      isOwner: json['is_owner'] as bool,
      liked: json['liked'] as bool,
      disliked: json['disliked'] as bool,
      likeCount: json['like_count'] as int,
      dislikeCount: json['dislike_count'] as int,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'topic_id': instance.topicId,
      'poster_id': instance.posterId,
      'poster': instance.poster,
      'content': instance.content,
      'is_anonymous': instance.isAnonymous,
      'anonyname': instance.anonyname,
      'ranking': instance.ranking,
      'is_owner': instance.isOwner,
      'liked': instance.liked,
      'disliked': instance.disliked,
      'like_count': instance.likeCount,
      'dislike_count': instance.dislikeCount,
    };
