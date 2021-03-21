import 'package:flutter/cupertino.dart';

class CreateNoteDto {
  final String managerNote;
  final List workplaceIds;
  final List subWorkplaceIds;
  final List pieceworksDetails;
  final List employeeIds;
  final List yearsWithMonths;
  final List dates;

  CreateNoteDto({
    @required this.managerNote,
    @required this.workplaceIds,
    @required this.subWorkplaceIds,
    @required this.pieceworksDetails,
    @required this.employeeIds,
    @required this.yearsWithMonths,
    @required this.dates,
  });

  static Map<String, dynamic> jsonEncode(CreateNoteDto dto) {
    Map<String, dynamic> map = new Map();
    map['managerNote'] = dto.managerNote;
    map['workplaceIds'] = dto.workplaceIds;
    map['subWorkplaceIds'] = dto.subWorkplaceIds;
    map['pieceworksDetails'] = dto.pieceworksDetails;
    map['employeeIds'] = dto.employeeIds;
    map['yearsWithMonths'] = dto.yearsWithMonths;
    map['dates'] = dto.dates;
    return map;
  }
}
