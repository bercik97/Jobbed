import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/sub_workplace/dto/sub_workplace_dto.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class WorkplaceForAddNoteDto {
  String id;
  String name;
  String description;
  List subWorkplacesDto;

  WorkplaceForAddNoteDto({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.subWorkplacesDto,
  });

  factory WorkplaceForAddNoteDto.fromJson(Map<String, dynamic> json) {
    var subWorkplacesDtoAsJson = json['subWorkplacesDto'];
    return WorkplaceForAddNoteDto(
      id: json['id'] as String,
      name: UTFDecoderUtil.decode(json['name']),
      description: UTFDecoderUtil.decode(json['description']),
      subWorkplacesDto: subWorkplacesDtoAsJson != null ? subWorkplacesDtoAsJson.map((data) => SubWorkplaceDto.fromJson(data)).toList() : null,
    );
  }
}
