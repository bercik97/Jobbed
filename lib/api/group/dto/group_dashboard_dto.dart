import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class GroupDashboardDto {
  final int id;
  final String name;
  final String description;
  final String groupCreator;
  final int numberOfEmployees;

  GroupDashboardDto({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.groupCreator,
    @required this.numberOfEmployees,
  });

  factory GroupDashboardDto.fromJson(Map<String, dynamic> json) {
    return GroupDashboardDto(
      id: json['id'] as int,
      name: UTFDecoderUtil.decode(json['name']),
      description: UTFDecoderUtil.decode(json['description']),
      groupCreator: UTFDecoderUtil.decode(json['groupCreator']),
      numberOfEmployees: json['numberOfEmployees'] as int,
    );
  }
}
