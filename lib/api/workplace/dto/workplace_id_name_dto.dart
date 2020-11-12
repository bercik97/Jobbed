import 'package:flutter/cupertino.dart';

class WorkplaceIdNameDto {
  final int id;
  final String name;

  WorkplaceIdNameDto({
    @required this.id,
    @required this.name,
  });

  factory WorkplaceIdNameDto.fromJson(Map<String, dynamic> json) {
    return WorkplaceIdNameDto(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
