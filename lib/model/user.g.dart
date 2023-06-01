// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      introduction: json['introduction'] as String?,
      banned: json['banned'] as bool,
      topicCount: json['topic_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      favoriteTopicsCount: json['favorite_topics_count'] as int? ?? 0,
      followersCount: json['followers_count'] as int? ?? 0,
      followingUsersCount: json['following_users_count'] as int? ?? 0,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'avatar': instance.avatar,
      'introduction': instance.introduction,
      'banned': instance.banned,
      'topic_count': instance.topicCount,
      'comment_count': instance.commentCount,
      'favorite_topics_count': instance.favoriteTopicsCount,
      'followers_count': instance.followersCount,
      'following_users_count': instance.followingUsersCount,
    };
