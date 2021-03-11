import 'package:flutter/cupertino.dart';

class SubWorkplaceDto {
  final int id;
  final String name;
  final String description;

  SubWorkplaceDto({
    @required this.id,
    @required this.name,
    @required this.description,
  });

  factory SubWorkplaceDto.fromJson(Map<String, dynamic> json) {
    return SubWorkplaceDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}
