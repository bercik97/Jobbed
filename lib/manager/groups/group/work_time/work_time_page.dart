import 'package:flutter/cupertino.dart';
import 'package:give_job/manager/shared/group_model.dart';

class WorkTimePage extends StatefulWidget {
  final GroupModel _model;

  WorkTimePage(this._model);

  @override
  _WorkTimePageState createState() => _WorkTimePageState();
}

class _WorkTimePageState extends State<WorkTimePage> {
  GroupModel _model;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    return Container();
  }
}
