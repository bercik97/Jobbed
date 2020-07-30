import 'package:flutter/cupertino.dart';

class ManagerGroupDto {
  final int id;
  final String name;
  final String countryOfWork;
  final String description;
  final int numberOfEmployees;

  ManagerGroupDto({
    @required this.id,
    @required this.name,
    @required this.countryOfWork,
    @required this.description,
    @required this.numberOfEmployees,
  });

  factory ManagerGroupDto.fromJson(Map<String, dynamic> json) {
    return ManagerGroupDto(
      id: json['id'] as int,
      name: json['name'] as String,
      countryOfWork: json['countryOfWork'] as String,
      description: json['description'] as String,
      numberOfEmployees: json['numberOfEmployees'] as int,
    );
  }
}
