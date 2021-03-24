import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class PriceListDto {
  final int id;
  String name;
  final double priceForEmployee;
  final double priceForCompany;

  PriceListDto({
    @required this.id,
    @required this.name,
    @required this.priceForEmployee,
    @required this.priceForCompany,
  });

  factory PriceListDto.fromJson(Map<String, dynamic> json) {
    return PriceListDto(
      id: json['id'] as int,
      name: UTFDecoderUtil.decode(json['name']),
      priceForEmployee: json['priceForEmployee'] as double,
      priceForCompany: json['priceForCompany'] as double,
    );
  }
}
