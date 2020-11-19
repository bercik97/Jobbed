import 'package:flutter/cupertino.dart';
import 'package:give_job/shared/model/user.dart';

class PieceworkPage extends StatefulWidget {
  final User _user;
  final int _todayWorkdayId;

  PieceworkPage(this._user, this._todayWorkdayId);

  @override
  _PieceworkPageState createState() => _PieceworkPageState();
}

class _PieceworkPageState extends State<PieceworkPage> {
  User _user;
  int _todayWorkdayId;

  @override
  Widget build(BuildContext context) {
    this._user = widget._user;
    this._todayWorkdayId = widget._todayWorkdayId;
    return Container();
  }
}
