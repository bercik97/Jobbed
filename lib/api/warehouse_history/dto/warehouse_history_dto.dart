import 'package:flutter/cupertino.dart';

class WarehouseHistoryDto {
  final int id;
  final String action;
  final String date;
  final String itemName;
  final String previousQuantity;
  final String newQuantity;

  WarehouseHistoryDto({
    @required this.id,
    @required this.action,
    @required this.date,
    @required this.itemName,
    @required this.previousQuantity,
    @required this.newQuantity,
  });

  factory WarehouseHistoryDto.fromJson(Map<String, dynamic> json) {
    return WarehouseHistoryDto(
      id: json['id'] as int,
      action: json['action'] as String,
      date: json['date'] as String,
      itemName: json['itemName'] as String,
      previousQuantity: json['previousQuantity'] as String,
      newQuantity: json['newQuantity'] as String,
    );
  }
}
