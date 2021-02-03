import 'package:flutter/cupertino.dart';

class GroupDashboardDto {
  final int id;
  final String name;
  final String description;
  final String groupCreator;
  final int numberOfEmployees;

  GroupDashboardDto({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.groupCreator,
    @required this.numberOfEmployees,
  });

  factory GroupDashboardDto.fromJson(Map<String, dynamic> json) {
    return GroupDashboardDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      groupCreator: json['groupCreator'] as String,
      numberOfEmployees: json['numberOfEmployees'] as int,
    );
  }
}
