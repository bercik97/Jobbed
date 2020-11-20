import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/group/service/group_service.dart';
import 'package:give_job/api/item/service/item_service.dart';
import 'package:give_job/api/manager/service/manager_service.dart';
import 'package:give_job/api/piecework/service/piecework_service.dart';
import 'package:give_job/api/price_list/service/pricelist_service.dart';
import 'package:give_job/api/timesheet/service/timesheet_service.dart';
import 'package:give_job/api/token/service/token_service.dart';
import 'package:give_job/api/user/service/user_service.dart';
import 'package:give_job/api/vocation/service/vocation_service.dart';
import 'package:give_job/api/warehouse/service/warehouse_service.dart';
import 'package:give_job/api/work_time/service/worktime_service.dart';
import 'package:give_job/api/workday/service/workday_service.dart';
import 'package:give_job/api/workplace/service/workplace_service.dart';

class ServiceInitializer {
  static initialize(BuildContext context, String authHeader, Object obj) {
    Map<String, String> header = {HttpHeaders.authorizationHeader: authHeader};
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: authHeader,
      "content-type": "application/json"
    };
    switch (obj.toString()) {
      case 'EmployeeService': return new EmployeeService(context, header, headers);
      case 'GroupService': return new GroupService(context, header, headers);
      case 'ItemService': return new ItemService(context, header, headers);
      case 'ManagerService': return new ManagerService(context, header, headers);
      case 'PieceworkService': return new PieceworkService(context, header, headers);
      case 'PricelistService': return new PricelistService(context, header, headers);
      case 'TimesheetService': return new TimesheetService(context, header, headers);
      case 'TokenService': return new TokenService();
      case 'UserService': return new UserService(context, headers);
      case 'VocationService': return new VocationService(context, headers);
      case 'WorkdayService': return new WorkdayService(context, header, headers);
      case 'WarehouseService': return new WarehouseService(context, header, headers);
      case 'WorkTimeService': return new WorkTimeService(context, header, headers);
      case 'WorkplaceService': return new WorkplaceService(context, header, headers);
      default: throw 'Wrong (class as String) to translate!';
    }
  }
}