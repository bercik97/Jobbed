import 'package:flutter/cupertino.dart';

class GroupDashboardDto {
  final num id;
  final String name;
  final String description;
  final String groupCreator;
  final num numberOfEmployees;

  GroupDashboardDto({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.groupCreator,
    @required this.numberOfEmployees,
  });

  factory GroupDashboardDto.fromJson(Map<String, dynamic> json) {
    return GroupDashboardDto(
      id: json['id'] as num,
      name: json['name'],
      description: json['description'],
      groupCreator: json['groupCreator'],
      numberOfEmployees: json['numberOfEmployees'] as num,
    );
  }
}
