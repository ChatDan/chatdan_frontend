import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'chat.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Chat {
  final int id;
  DateTime createdAt;
  DateTime updatedAt;
  final int oneUserId;
  final User oneUser;
  final int anotherUserId;
  final User anotherUser;
  final String lastMessageContent;
  int messageCount;

  Chat({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.oneUserId,
    required this.oneUser,
    required this.anotherUserId,
    required this.anotherUser,
    this.lastMessageContent = '',
    this.messageCount = 0,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);

  @override
  bool operator ==(Object other) => (other is Chat) && id == other.id;

  @override
  int get hashCode => id;
}
