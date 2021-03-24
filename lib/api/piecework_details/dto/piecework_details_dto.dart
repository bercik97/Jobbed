import 'package:flutter/cupertino.dart';
import 'package:jobbed/shared/util/utf_decoder_util.dart';

class PieceworkDetails {
  num id;
  String service;
  num toBeDoneQuantity;
  num doneQuantity;
  bool done;

  PieceworkDetails({
    this.id,
    @required this.service,
    @required this.toBeDoneQuantity,
    @required this.doneQuantity,
    this.done,
  });

  static Map<String, dynamic> jsonEncode(PieceworkDetails dto) {
    Map<String, dynamic> map = new Map();
    map['service'] = dto.service;
    map['toBeDoneQuantity'] = dto.toBeDoneQuantity;
    map['doneQuantity'] = dto.doneQuantity;
    return map;
  }

  factory PieceworkDetails.fromJson(Map<String, dynamic> json) {
    return PieceworkDetails(
      id: json['id'] as num,
      service: UTFDecoderUtil.decode(json['service']),
      toBeDoneQuantity: json['toBeDoneQuantity'] as num,
      doneQuantity: json['doneQuantity'] as num,
      done: json['done'] as bool,
    );
  }
}
