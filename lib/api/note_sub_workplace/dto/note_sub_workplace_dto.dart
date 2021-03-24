import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class NoteSubWorkplaceDto {
  final num id;
  bool done;
  final String workplaceName;
  final String subWorkplaceName;
  final String subWorkplaceDescription;

  NoteSubWorkplaceDto({
    @required this.id,
    @required this.done,
    @required this.workplaceName,
    @required this.subWorkplaceName,
    @required this.subWorkplaceDescription,
  });

  factory NoteSubWorkplaceDto.fromJson(Map<String, dynamic> json) {
    return NoteSubWorkplaceDto(
      id: json['id'] as num,
      done: json['done'] as bool,
      workplaceName: UTFDecoderUtil.decode(json['workplaceName']),
      subWorkplaceName: UTFDecoderUtil.decode(json['subWorkplaceName']),
      subWorkplaceDescription: UTFDecoderUtil.decode(json['subWorkplaceDescription']),
    );
  }
}
