// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) => Tag(
      id: json['id'] as int? ?? 0,
      temperature: json['temperature'] as int? ?? 0,
      name: json['name'] as String,
    );

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
      'id': instance.id,
      'temperature': instance.temperature,
      'name': instance.name,
    };
