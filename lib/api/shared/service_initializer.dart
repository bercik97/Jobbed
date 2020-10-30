import 'dart:io';

import 'package:give_job/api/employee/service/employee_service.dart';
import 'package:give_job/api/group/service/group_service.dart';
import 'package:give_job/api/manager/service/manager_service.dart';
import 'package:give_job/api/token/service/token_service.dart';
import 'package:give_job/api/user/service/user_service.dart';
import 'package:give_job/api/vocation/service/vocation_service.dart';
import 'package:give_job/api/workday/service/workday_service.dart';
import 'package:give_job/api/workplace/service/workplace_service.dart';

class ServiceInitializer {
  static initialize(String authHeader, Object obj) {
    Map<String, String> header = {HttpHeaders.authorizationHeader: authHeader};
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: authHeader,
      "content-type": "application/json"
    };
    switch (obj.toString()) {
      case 'EmployeeService': return new EmployeeService(header, headers);
      case 'GroupService': return new GroupService(header, headers);
      case 'ManagerService': return new ManagerService(header, headers);
      case 'TokenService': return new TokenService();
      case 'UserService': return new UserService(header, headers);
      case 'VocationService': return new VocationService(header, headers);
      case 'WorkdayService': return new WorkdayService(header, headers);
      case 'WorkplaceService': return new WorkplaceService(header, headers);
      default: throw 'Wrong (class as String) to translate!';
    }
  }
}