import 'package:flutter/cupertino.dart';

class CreatePricelistDto {
  final String companyId;
  final String name;
  final double priceForEmployee;
  final double priceForCompany;

  CreatePricelistDto({
    @required this.companyId,
    @required this.name,
    @required this.priceForEmployee,
    @required this.priceForCompany,
  });

  static Map<String, dynamic> jsonEncode(CreatePricelistDto dto) {
    Map<String, dynamic> map = new Map();
    map['companyId'] = dto.companyId;
    map['name'] = dto.name;
    map['priceForEmployee'] = dto.priceForEmployee;
    map['priceForCompany'] = dto.priceForCompany;
    return map;
  }
}
