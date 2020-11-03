import 'package:flutter/cupertino.dart';

class VocationDto {
  final int id;
  final String reason;
  final bool verified;

  VocationDto({
    @required this.id,
    @required this.reason,
    @required this.verified,
  });

  factory VocationDto.fromJson(Map<String, dynamic> json) {
    return VocationDto(
      id: json['id'] as int,
      reason: json['reason'] as String,
      verified: json['verified'] as bool,
    );
  }
}
