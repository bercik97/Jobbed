import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class PieceworkDto {
  final String service;
  final int quantity;
  final double priceForEmployee;
  final double priceForCompany;

  PieceworkDto({
    @required this.service,
    @required this.quantity,
    @required this.priceForEmployee,
    @required this.priceForCompany,
  });

  factory PieceworkDto.fromJson(Map<String, dynamic> json) {
    return PieceworkDto(
      service: UTFDecoderUtil.decode(json['service']),
      quantity: json['quantity'] as int,
      priceForEmployee: json['priceForEmployee'] as double,
      priceForCompany: json['priceForCompany'] as double,
    );
  }
}
