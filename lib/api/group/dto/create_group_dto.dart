import 'package:flutter/cupertino.dart';

class CreateGroupDto {
  final String name;
  final String description;
  final String companyId;
  final int managerId;
  final List<String> employeeIds;

  CreateGroupDto({
    @required this.name,
    @required this.description,
    @required this.companyId,
    @required this.managerId,
    @required this.employeeIds,
  });

  static Map<String, dynamic> jsonEncode(CreateGroupDto dto) {
    Map<String, dynamic> map = new Map();
    map['name'] = dto.name;
    map['description'] = dto.description;
    map['companyId'] = dto.companyId;
    map['managerId'] = dto.managerId;
    map['employeeIds'] = dto.employeeIds;
    return map;
  }
}
