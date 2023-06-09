import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Message {
  final int id;
  final DateTime createdAt;
  final int fromUserId;
  final int toUserId;
  String content;
  bool isMe;

  Message({
    required this.id,
    required this.createdAt,
    required this.fromUserId,
    required this.toUserId,
    this.content = '',
    required this.isMe,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  @override
  bool operator ==(Object other) => (other is Message) && id == other.id;

  @override
  int get hashCode => id;
}
