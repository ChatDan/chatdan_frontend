import 'package:json_annotation/json_annotation.dart';

part 'division.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Division {
  final int id;
  String name;
  String description;

  Division(
      {required this.id,
      this.name = '',
      this.description = ''});

  factory Division.fromJson(Map<String, dynamic> json) => _$DivisionFromJson(json);

  Map<String, dynamic> toJson() => _$DivisionToJson(this);

  @override
  bool operator ==(Object other) =>
      (other is Division) && id == other.id;

  @override
  int get hashCode => id;
}