import 'package:flutter/cupertino.dart';
import 'package:give_job/shared/model/user.dart';

class DeleteGroupEmployeesPage extends StatefulWidget {
  final User user;

  DeleteGroupEmployeesPage(this.user);

  @override
  _DeleteGroupEmployeesPageState createState() => _DeleteGroupEmployeesPageState();
}

class _DeleteGroupEmployeesPageState extends State<DeleteGroupEmployeesPage> {
  User _user;

  @override
  Widget build(BuildContext context) {
    this._user = widget.user;
    return Container();
  }
}
