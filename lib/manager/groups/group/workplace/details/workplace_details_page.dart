import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/workplace/dto/workplace_dto.dart';
import 'package:give_job/api/workplace/service/workplace_service.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/workplace/workplaces_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';

import 'edit/workplace_edit_page.dart';

class WorkplaceDetailsPage extends StatefulWidget {
  final GroupModel _model;
  final WorkplaceDto _workplaceDto;

  WorkplaceDetailsPage(this._model, this._workplaceDto);

  @override
  _WorkplaceDetailsPageState createState() => _WorkplaceDetailsPageState();
}

class _WorkplaceDetailsPageState extends State<WorkplaceDetailsPage> {
  GroupModel _model;
  User _user;
  WorkplaceDto _workplaceDto;

  WorkplaceService _workplaceService;

  bool _loading = false;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._workplaceDto = widget._workplaceDto;
    this._workplaceService = ServiceInitializer.initialize(context, _user.authHeader, WorkplaceService);
    super.initState();
    _loading = true;
    // _itemService.findAllByWarehouseId(_workplaceDto.id).then((res) {
    //   setState(() {
    //     _items = res;
    //     _items.forEach((e) => _checked.add(false));
    //     _filteredItems = _items;
    //     _loading = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    // if (_loading) {
    //   return loader(managerAppBar(context, _user, getTranslated(context, 'loading'), () => NavigatorUtil.navigate(context, WorkplacesPage(_model))));
    // }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(context, _user, getTranslated(context, 'workplaceDetails'), () => NavigatorUtil.navigate(context, WorkplacesPage(_model))),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Tab(
                    icon: Container(
                      child: Container(
                        child: Image(
                          width: 60,
                          image: AssetImage(
                            'images/workplace-icon.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  title: textWhiteBold(utf8.decode(_workplaceDto.name.runes.toList())),
                  subtitle: Column(
                    children: <Widget>[
                      Align(
                        child: _workplaceDto.location != null
                            ? textWhite(utf8.decode(_workplaceDto.location.runes.toList()))
                            : Row(
                                children: [
                                  textWhite(getTranslated(context, 'location') + ': '),
                                  textRed(getTranslated(context, 'empty')),
                                ],
                              ),
                        alignment: Alignment.topLeft,
                      ),
                      Align(
                        child: Row(
                          children: [
                            textWhite(getTranslated(context, 'workplaceCode') + ': '),
                            textGreen(_workplaceDto.id),
                          ],
                        ),
                        alignment: Alignment.topLeft,
                      ),
                    ],
                  ),
                  trailing: Ink(
                    decoration: ShapeDecoration(color: GREEN, shape: CircleBorder()),
                    child: IconButton(
                      icon: iconDark(Icons.border_color),
                      onPressed: () => NavigatorUtil.navigate(this.context, WorkplaceEditPage(_model, _workplaceDto)),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
                  child: TextFormField(
                    autofocus: false,
                    autocorrect: true,
                    cursorColor: WHITE,
                    style: TextStyle(color: WHITE),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
                      counterStyle: TextStyle(color: WHITE),
                      border: OutlineInputBorder(),
                      labelText: getTranslated(context, 'search'),
                      prefixIcon: iconWhite(Icons.search),
                      labelStyle: TextStyle(color: WHITE),
                    ),
                    onChanged: (string) {
                      setState(
                        () {},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, WorkplacesPage(_model)),
    );
  }
}
