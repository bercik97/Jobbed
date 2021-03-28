import 'package:flutter/cupertino.dart';

class UpdateNoteSubWorkplaceDto {
  final List doneWorkplaceNoteIds;
  final List undoneWorkplaceNoteIds;

  UpdateNoteSubWorkplaceDto({
    @required this.doneWorkplaceNoteIds,
    @required this.undoneWorkplaceNoteIds,
  });

  static Map<String, dynamic> jsonEncode(UpdateNoteSubWorkplaceDto dto) {
    Map<String, dynamic> map = new Map();
    map['doneWorkplaceNoteIds'] = dto.doneWorkplaceNoteIds;
    map['undoneWorkplaceNoteIds'] = dto.undoneWorkplaceNoteIds;
    return map;
  }
}
