import 'package:chatdan_frontend/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

import 'tag.dart';
import 'comment.dart';

part 'topic.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Topic {
  final int id;
  DateTime createdAt;
  DateTime updatedAt;
  String title;
  String content;
  final int? posterId;
  final User? poster;
  final bool isAnonymous;
  final String? anonyname;

  int divisionId;
  final List<Tag>? tags;
  final Comment? lastComment;

  int viewCount;
  int likeCount;
  int dislikeCount;
  int commentCount;
  int favoriteCount;

  final bool isOwner;
  bool liked;
  bool disliked;
  bool favored;

  Topic(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.title,
      required this.content,
      required this.posterId,
        required this.poster,
      required this.isAnonymous,
      this.anonyname,
      this.tags,
      required this.divisionId,
      this.lastComment,
      required this.viewCount,
      required this.likeCount,
      required this.dislikeCount,
      required this.commentCount,
      required this.favoriteCount,
      required this.isOwner,
      required this.liked,
      required this.disliked,
      required this.favored});

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

  Map<String, dynamic> toJson() => _$TopicToJson(this);

  @override
  bool operator ==(Object other) =>
      (other is Topic) && id == other.id;

  @override
  int get hashCode => id;
}