import 'package:flutter/cupertino.dart';

class CreateGroupDto {
  final String name;
  final String description;
  final String countryOfWork;
  final int companyId;
  final int managerId;
  final List<String> employeeIds;

  CreateGroupDto({
    @required this.name,
    @required this.description,
    @required this.countryOfWork,
    @required this.companyId,
    @required this.managerId,
    @required this.employeeIds,
  });

  static Map<String, dynamic> jsonEncode(CreateGroupDto dto) {
    Map<String, dynamic> map = new Map();
    map['name'] = dto.name;
    map['description'] = dto.description;
    map['countryOfWork'] = dto.countryOfWork;
    map['companyId'] = dto.companyId;
    map['managerId'] = dto.managerId;
    map['employeeIds'] = dto.employeeIds;
    return map;
  }
}
