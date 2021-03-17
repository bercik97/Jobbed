import 'package:flutter/cupertino.dart';

class UpdateNoteSubWorkplaceDto {
  final String managerNote;
  final String employeeNote;
  final List doneWorkplaceNoteIds;
  final List undoneWorkplaceNoteIds;

  UpdateNoteSubWorkplaceDto({
    @required this.managerNote,
    @required this.employeeNote,
    @required this.doneWorkplaceNoteIds,
    @required this.undoneWorkplaceNoteIds,
  });

  static Map<String, dynamic> jsonEncode(UpdateNoteSubWorkplaceDto dto) {
    Map<String, dynamic> map = new Map();
    map['managerNote'] = dto.managerNote;
    map['employeeNote'] = dto.employeeNote;
    map['doneWorkplaceNoteIds'] = dto.doneWorkplaceNoteIds;
    map['undoneWorkplaceNoteIds'] = dto.undoneWorkplaceNoteIds;
    return map;
  }
}
