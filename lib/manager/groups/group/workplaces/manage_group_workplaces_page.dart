import 'package:flutter/cupertino.dart';
import 'package:give_job/manager/groups/group/employee/model/group_employee_model.dart';

class ManageGroupWorkplacesPage extends StatefulWidget {
  final GroupEmployeeModel _model;

  ManageGroupWorkplacesPage(this._model);

  @override
  _ManageGroupWorkplacesPageState createState() =>
      _ManageGroupWorkplacesPageState();
}

class _ManageGroupWorkplacesPageState extends State<ManageGroupWorkplacesPage> {
  GroupEmployeeModel _model;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    return Container();
  }
}
