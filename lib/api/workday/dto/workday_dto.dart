import 'package:flutter/cupertino.dart';
import 'package:give_job/api/vocation/dto/vocation_dto.dart';
import 'package:give_job/api/workplace/dto/workplace_dto.dart';

class WorkdayDto {
  final int id;
  final int number;
  final int hours;
  final int rating;
  final String plan;
  final String opinion;
  final double money;
  final List workplaces;
  final VocationDto vocation;

  WorkdayDto({
    @required this.id,
    @required this.number,
    @required this.hours,
    @required this.rating,
    @required this.plan,
    @required this.opinion,
    @required this.money,
    @required this.workplaces,
    @required this.vocation,
  });

  factory WorkdayDto.fromJson(Map<String, dynamic> json) {
    var workplacesAsJson = json['workplaces'];
    var vocationAsJson = json['vocation'];
    return WorkdayDto(
      id: json['id'] as int,
      number: json['number'] as int,
      hours: json['hours'] as int,
      rating: json['rating'] as int,
      plan: json['plan'] as String,
      opinion: json['opinion'] as String,
      money: json['money'] as double,
      workplaces: workplacesAsJson != null ? workplacesAsJson.map((data) => WorkplaceDto.fromJson(data)).toList() : null,
      vocation: vocationAsJson != null ? VocationDto.fromJson(vocationAsJson) : null,
    );
  }
}
