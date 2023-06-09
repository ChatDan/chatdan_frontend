import 'package:chatdan_frontend/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wall.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Wall {
  final int id;
  final DateTime createdAt;
  DateTime updatedAt;
  String content;
  final int posterId;
  final User? poster;
  String visibility;
  final bool isAnonymous;
  bool isShown;

  Wall({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.content = '',
    required this.posterId,
    required this.poster,
    required this.visibility,
    required this.isAnonymous,
    this.isShown = true,
  });

  factory Wall.fromJson(Map<String, dynamic> json) => _$WallFromJson(json);

  Map<String, dynamic> toJson() => _$WallToJson(this);

  @override
  bool operator ==(Object other) => (other is Wall) && id == other.id;

  @override
  int get hashCode => id;
}
