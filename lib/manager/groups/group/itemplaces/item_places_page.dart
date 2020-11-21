import 'package:flutter/cupertino.dart';
import 'package:give_job/manager/groups/group/shared/group_model.dart';
import 'package:give_job/shared/model/user.dart';

class ItemPlacesPage extends StatefulWidget {
  final GroupModel _model;

  ItemPlacesPage(this._model);

  @override
  _ItemPlacesPageState createState() => _ItemPlacesPageState();
}

class _ItemPlacesPageState extends State<ItemPlacesPage> {
  GroupModel _model;
  User _user;

  @override
  Widget build(BuildContext context) {
    this._model = widget._model;
    this._user = _model.user;
    return Container();
  }
}
