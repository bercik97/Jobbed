import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:give_job/api/item/dto/item_dto.dart';
import 'package:give_job/shared/model/user.dart';

class ReleaseItemsPage extends StatefulWidget {
  final User _user;
  final LinkedHashSet<ItemDto> _items;

  ReleaseItemsPage(this._user, this._items);

  @override
  _ReleaseItemsPageState createState() => _ReleaseItemsPageState();
}

class _ReleaseItemsPageState extends State<ReleaseItemsPage> {
  User _user;
  LinkedHashSet<ItemDto> _items;

  @override
  Widget build(BuildContext context) {
    this._user = widget._user;
    this._items = widget._items;
    return Container();
  }
}
