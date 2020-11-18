import 'package:flutter/cupertino.dart';
import 'package:give_job/shared/model/user.dart';

class AddWarehousePage extends StatefulWidget {
  final User _user;

  AddWarehousePage(this._user);

  @override
  _AddWarehousePageState createState() => _AddWarehousePageState();
}

class _AddWarehousePageState extends State<AddWarehousePage> {
  User _user;

  @override
  void initState() {
    this._user = widget._user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
