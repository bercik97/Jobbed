import 'package:give_job/shared/model/user.dart';

class GroupModel {
  User user;
  int groupId;
  String groupName;
  String groupDescription;
  String numberOfEmployees;
  String countryOfWork;

  GroupModel(
    this.user,
    this.groupId,
    this.groupName,
    this.groupDescription,
    this.numberOfEmployees,
    this.countryOfWork,
  );
}
