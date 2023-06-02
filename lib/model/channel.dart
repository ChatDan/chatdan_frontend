import 'package:json_annotation/json_annotation.dart';

part 'channel.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Channel {
  final int id;
  final int postId;
  String content;
  final bool isOwner;
  final bool isPostOwner;
  final bool isBoxOwner;

  Channel(
      {required this.id,
      required this.postId,
      this.content = '',
      required this.isOwner,
      this.isPostOwner = false,
      this.isBoxOwner = false});

  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelToJson(this);

  @override
  bool operator ==(Object other) =>
      (other is Channel) && id == other.id;

  @override
  int get hashCode => id;
}