import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/note_sub_workplace/dto/note_sub_workplace_dto.dart';
import 'package:jobbed/api/piecework_details/dto/piecework_details_dto.dart';

class NoteDto {
  final int id;
  final int workdayId;
  String managerNote;
  String employeeNote;
  List noteSubWorkplaceDto;
  List pieceworksDetails;

  NoteDto({
    @required this.id,
    @required this.workdayId,
    @required this.managerNote,
    @required this.employeeNote,
    @required this.noteSubWorkplaceDto,
    @required this.pieceworksDetails,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) {
    var noteSubWorkplaceDtoJson = json['noteSubWorkplaceDto'];
    var pieceworksDetailsJson = json['pieceworksDetails'];
    return NoteDto(
      id: json['id'] as int,
      workdayId: json['workdayId'] as int,
      managerNote: json['managerNote'] as String,
      employeeNote: json['employeeNote'] as String,
      noteSubWorkplaceDto: noteSubWorkplaceDtoJson != null ? noteSubWorkplaceDtoJson.map((data) => NoteSubWorkplaceDto.fromJson(data)).toList() : null,
      pieceworksDetails: pieceworksDetailsJson != null ? pieceworksDetailsJson.map((data) => PieceworkDetails.fromJson(data)).toList() : null,
    );
  }
}
