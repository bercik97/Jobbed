import 'package:flutter/cupertino.dart';

class CreatePriceListDto {
  final String companyId;
  final String name;
  final double priceForEmployee;
  final double priceForCompany;

  CreatePriceListDto({
    @required this.companyId,
    @required this.name,
    @required this.priceForEmployee,
    @required this.priceForCompany,
  });

  static Map<String, dynamic> jsonEncode(CreatePriceListDto dto) {
    Map<String, dynamic> map = new Map();
    map['companyId'] = dto.companyId;
    map['name'] = dto.name;
    map['priceForEmployee'] = dto.priceForEmployee;
    map['priceForCompany'] = dto.priceForCompany;
    return map;
  }
}
