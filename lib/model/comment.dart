import 'package:chatdan_frontend/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Comment {
  final int id;
  DateTime createdAt;
  DateTime updatedAt;
  final int topicId;
  final int? posterId;
  final User? poster;
  String content;
  final bool isAnonymous;
  final String? anonyname;
  final int ranking;

  final bool isOwner;
  bool liked;
  bool disliked;
  int likeCount;
  int dislikeCount;

  Comment({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.topicId,
    this.posterId,
    this.poster,
    this.content = '',
    required this.isAnonymous,
    this.anonyname,
    required this.ranking,
    required this.isOwner,
    required this.liked,
    required this.disliked,
    required this.likeCount,
    required this.dislikeCount,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);

  @override
  bool operator ==(Object other) => (other is Comment) && id == other.id;

  @override
  int get hashCode => id;
}
