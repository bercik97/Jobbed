import 'package:jobbed/shared/model/user.dart';

class GroupModel {
  User user;
  int groupId;
  String groupName;
  String groupDescription;
  String numberOfEmployees;

  GroupModel(this.user, this.groupId, this.groupName, this.groupDescription, this.numberOfEmployees);
}
