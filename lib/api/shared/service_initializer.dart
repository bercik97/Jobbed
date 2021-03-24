import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:jobbed/api/company/service/company_service.dart';
import 'package:jobbed/api/employee/service/employee_service.dart';
import 'package:jobbed/api/employee/service/employee_unauthenticated_service.dart';
import 'package:jobbed/api/excel/service/excel_service.dart';
import 'package:jobbed/api/group/service/group_service.dart';
import 'package:jobbed/api/item/service/item_service.dart';
import 'package:jobbed/api/item_place/service/item_place_service.dart';
import 'package:jobbed/api/manager/service/manager_service.dart';
import 'package:jobbed/api/manager/service/manager_unauthenticated_service.dart';
import 'package:jobbed/api/note/service/note_service.dart';
import 'package:jobbed/api/piecework/service/piecework_service.dart';
import 'package:jobbed/api/price_list/service/price_list_service.dart';
import 'package:jobbed/api/sub_workplace/service/sub_workplace_service.dart';
import 'package:jobbed/api/timesheet/service/timesheet_service.dart';
import 'package:jobbed/api/token/service/token_service.dart';
import 'package:jobbed/api/user/service/user_service.dart';
import 'package:jobbed/api/warehouse/service/warehouse_service.dart';
import 'package:jobbed/api/work_time/service/work_time_service.dart';
import 'package:jobbed/api/workday/service/workday_service.dart';
import 'package:jobbed/api/workplace/service/workplace_service.dart';

class ServiceInitializer {
  static initialize(BuildContext context, String authHeader, Object obj) {
    Map<String, String> headers = {HttpHeaders.authorizationHeader: authHeader, 'content-type': 'application/json; charset=utf-8'};
    switch (obj.toString()) {
      case 'CompanyService': return new CompanyService(context, headers);
      case 'EmployeeService': return new EmployeeService(context, headers);
      case 'EmployeeUnauthenticatedService': return new EmployeeUnauthenticatedService();
      case 'ExcelService': return new ExcelService(context, headers);
      case 'GroupService': return new GroupService(context, headers);
      case 'ItemService': return new ItemService(context, headers);
      case 'ItemPlaceService': return new ItemPlaceService(context, headers);
      case 'ManagerService': return new ManagerService(context, headers);
      case 'ManagerUnauthenticatedService': return new ManagerUnauthenticatedService();
      case 'NoteService': return new NoteService(context, headers);
      case 'PieceworkService': return new PieceworkService(context, headers);
      case 'PriceListService': return new PriceListService(context, headers);
      case 'SubWorkplaceService': return new SubWorkplaceService(context, headers);
      case 'TimesheetService': return new TimesheetService(context, headers);
      case 'TokenService': return new TokenService();
      case 'UserService': return new UserService(context, headers);
      case 'WorkdayService': return new WorkdayService(context, headers);
      case 'WarehouseService': return new WarehouseService(context, headers);
      case 'WorkTimeService': return new WorkTimeService(context, headers);
      case 'WorkplaceService': return new WorkplaceService(context, headers);
      default: throw 'Wrong (class as String) to translate!';
    }
  }
}