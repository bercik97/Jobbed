import 'package:flutter/cupertino.dart';
import 'package:give_job/manager/groups/group/shared/group_model.dart';

class ManagerVocationsVerifyPage extends StatefulWidget {
  final GroupModel _model;

  ManagerVocationsVerifyPage(this._model);

  @override
  _ManagerVocationsVerifyPageState createState() =>
      _ManagerVocationsVerifyPageState();
}

class _ManagerVocationsVerifyPageState
    extends State<ManagerVocationsVerifyPage> {
  GroupModel _model;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    return Container();
  }
}
