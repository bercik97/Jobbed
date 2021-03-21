import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/note_sub_workplace/dto/update_note_sub_workplace_dto.dart';
import 'package:jobbed/api/piecework_details/dto/piecework_details_dto.dart';

class UpdateNoteDto {
  final num workdayId;
  final UpdateNoteSubWorkplaceDto noteSubWorkplaceDto;
  final List pieceworksDetailsDto;

  UpdateNoteDto({
    @required this.workdayId,
    @required this.noteSubWorkplaceDto,
    @required this.pieceworksDetailsDto,
  });

  static Map<String, dynamic> jsonEncode(UpdateNoteDto dto) {
    Map<String, dynamic> map = new Map();
    map['workdayId'] = dto.workdayId;
    map['noteSubWorkplaceDto'] = UpdateNoteSubWorkplaceDto.jsonEncode(dto.noteSubWorkplaceDto);
    map['pieceworksDetailsDto'] = dto.pieceworksDetailsDto.map((e) => PieceworkDetails.jsonEncode(e)).toList();
    return map;
  }
}
