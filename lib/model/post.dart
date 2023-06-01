import 'package:json_annotation/json_annotation.dart';

import 'channel.dart';

part 'post.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Post {
  final int id;
  final int posterId;
  String content;
  String visibility;
  final bool isOwner;
  final bool isAnonymous;
  final String? anonyname;
  int channelCount;
  int viewCount;
  List<Channel>? channels;

  Post(
      {required this.id,
      required this.posterId,
      this.content = '',
      required this.visibility,
      required this.isOwner,
      required this.isAnonymous,
      this.anonyname,
      this.channelCount = 0,
      this.viewCount = 0,
      this.channels});

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);

  @override
  bool operator ==(Object other) =>
      (other is Post) && id == other.id;

  @override
  int get hashCode => id;
}
