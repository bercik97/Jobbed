import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/note_sub_workplace/dto/note_sub_workplace_dto.dart';
import 'package:jobbed/api/piecework_service_quantity/dto/piecework_service_quantity_dto.dart';

class NoteDto {
  final int id;
  final String managerNote;
  String employeeNote;
  final List noteSubWorkplaceDto;
  final List pieceworkServicesQuantities;

  NoteDto({
    @required this.id,
    @required this.managerNote,
    @required this.employeeNote,
    @required this.noteSubWorkplaceDto,
    @required this.pieceworkServicesQuantities,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) {
    return NoteDto(
      id: json['id'] as int,
      managerNote: json['managerNote'] as String,
      employeeNote: json['employeeNote'] as String,
      noteSubWorkplaceDto: json['noteSubWorkplaceDto'].map((data) => NoteSubWorkplaceDto.fromJson(data)).toList(),
      pieceworkServicesQuantities: json['pieceworkServicesQuantities'].map((data) => PieceworkServiceQuantityDto.fromJson(data)).toList(),
    );
  }
}
