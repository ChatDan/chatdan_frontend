// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'division.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Division _$DivisionFromJson(Map<String, dynamic> json) => Division(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$DivisionToJson(Division instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };
