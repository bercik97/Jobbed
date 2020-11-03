import 'package:flutter/cupertino.dart';

class WorkplaceDto {
  final int id;
  final String name;

  WorkplaceDto({@required this.id, @required this.name});

  factory WorkplaceDto.fromJson(Map<String, dynamic> json) {
    return WorkplaceDto(id: json['id'] as int, name: json['name'] as String);
  }
}
