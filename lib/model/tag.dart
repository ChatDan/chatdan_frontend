import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Tag {
  final int id;
  final int temperature;
  final String name;

  Tag({
    this.id = 0,
    this.temperature = 0,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);

  @override
  bool operator ==(Object other) => (other is Tag) && id == other.id;

  @override
  int get hashCode => name.hashCode;
}
