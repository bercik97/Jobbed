import 'package:flutter/cupertino.dart';
import 'package:give_job/shared/model/user.dart';

class ItemPlacesPage extends StatefulWidget {
  final User _user;

  ItemPlacesPage(this._user);

  @override
  _ItemPlacesPageState createState() => _ItemPlacesPageState();
}

class _ItemPlacesPageState extends State<ItemPlacesPage> {
  User _user;

  @override
  Widget build(BuildContext context) {
    this._user = widget._user;
    return Container();
  }
}
