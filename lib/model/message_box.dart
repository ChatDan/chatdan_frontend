import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'message_box.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MessageBox {
  final int id;
  final DateTime createdAt;
  DateTime updatedAt;
  String title;
  final int ownerId;
  final User? owner;
  int postCount;
  int viewCount;
  List<String>? posts;

  MessageBox({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.ownerId,
    this.owner,
    required this.postCount,
    required this.viewCount,
    this.posts,
  });

  factory MessageBox.fromJson(Map<String, dynamic> json) => _$MessageBoxFromJson(json);

  Map<String, dynamic> toJson() => _$MessageBoxToJson(this);

  @override
  bool operator ==(Object other) => (other is MessageBox) && id == other.id;

  @override
  int get hashCode => id;
}

@JsonSerializable()
class MessageBoxList {
  final List<MessageBox> list;
  final int version;
  final int total;

  MessageBoxList({
    required this.list,
    this.version = 0,
    this.total = 0,
  });

  factory MessageBoxList.fromJson(Map<String, dynamic> json) => _$MessageBoxListFromJson(json);

  Map<String, dynamic> toJson() => _$MessageBoxListToJson(this);
}
