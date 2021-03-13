import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/note_sub_workplace/dto/note_sub_workplace_dto.dart';

class NoteDto {
  final int id;
  final String managerNote;
  final String employeeNote;
  final List subWorkplaceDto;

  NoteDto({
    @required this.id,
    @required this.managerNote,
    @required this.employeeNote,
    @required this.subWorkplaceDto,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) {
    return NoteDto(
      id: json['id'] as int,
      managerNote: json['managerNote'] as String,
      employeeNote: json['employeeNote'] as String,
      subWorkplaceDto: json['noteSubWorkplaceDto'].map((data) => NoteSubWorkplaceDto.fromJson(data)).toList(),
    );
  }
}
