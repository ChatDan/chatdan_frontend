import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Message {
  final int id;
  final DateTime createdAt;
  DateTime updatedAt;
  final int fromUserId;
  final int toUserId;
  String content;
  bool isOwner;

  Message(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.fromUserId,
      required this.toUserId,
      this.content = '',
      required this.isOwner});

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  @override
  bool operator ==(Object other) =>
      (other is Message) && id == other.id;

  @override
  int get hashCode => id;
}