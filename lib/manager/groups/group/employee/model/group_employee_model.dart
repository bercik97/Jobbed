import 'package:give_job/shared/model/user.dart';

class GroupEmployeeModel {
  User user;
  int groupId;
  String groupName;
  String groupDescription;
  String numberOfEmployees;
  String countryOfWork;

  GroupEmployeeModel(
    this.user,
    this.groupId,
    this.groupName,
    this.groupDescription,
    this.numberOfEmployees,
    this.countryOfWork,
  );
}
