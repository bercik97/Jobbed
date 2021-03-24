import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class PieceworkForEmployeeDto {
  final String service;
  final int quantity;
  final double priceForEmployee;

  PieceworkForEmployeeDto({
    @required this.service,
    @required this.quantity,
    @required this.priceForEmployee,
  });

  factory PieceworkForEmployeeDto.fromJson(Map<String, dynamic> json) {
    return PieceworkForEmployeeDto(
      service: UTFDecoderUtil.decode(json['service']),
      quantity: json['quantity'] as int,
      priceForEmployee: json['priceForEmployee'] as double,
    );
  }
}
