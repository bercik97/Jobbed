import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/sub_workplace/dto/sub_workplace_dto.dart';

class WorkplaceForAddNoteDto {
  String id;
  String name;
  List subWorkplacesDto;

  WorkplaceForAddNoteDto({
    @required this.id,
    @required this.name,
    @required this.subWorkplacesDto,
  });

  factory WorkplaceForAddNoteDto.fromJson(Map<String, dynamic> json) {
    var subWorkplacesDtoAsJson = json['subWorkplacesDto'];
    return WorkplaceForAddNoteDto(
      id: json['id'] as String,
      name: json['name'] as String,
      subWorkplacesDto: subWorkplacesDtoAsJson != null ? subWorkplacesDtoAsJson.map((data) => SubWorkplaceDto.fromJson(data)).toList() : null,
    );
  }
}
