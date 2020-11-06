import 'package:flutter/cupertino.dart';
import 'package:give_job/shared/model/user.dart';

class AddGroupEmployeesPage extends StatefulWidget {
  final User user;

  AddGroupEmployeesPage(this.user);

  @override
  _AddGroupEmployeesPageState createState() => _AddGroupEmployeesPageState();
}

class _AddGroupEmployeesPageState extends State<AddGroupEmployeesPage> {
  User _user;

  @override
  Widget build(BuildContext context) {
    this._user = widget.user;
    return Container();
  }
}
