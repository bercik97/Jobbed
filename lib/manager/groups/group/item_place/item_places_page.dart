import 'dart:collection';
import 'dart:convert';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:give_job/api/item_place/dto/item_place_dashboard_dto.dart';
import 'package:give_job/api/item_place/service/item_place_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/group_page.dart';
import 'package:give_job/manager/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toast_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/hint.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../shared/widget/loader.dart';
import 'details/item_place_details_page.dart';

class ItemPlacesPage extends StatefulWidget {
  final GroupModel _model;

  ItemPlacesPage(this._model);

  @override
  _ItemPlacesPageState createState() => _ItemPlacesPageState();
}

class _ItemPlacesPageState extends State<ItemPlacesPage> {
  GroupModel _model;
  User _user;

  ItemPlaceService _itemPlaceService;

  List<ItemPlaceDashboardDto> _itemPlaces = new List();
  List<ItemPlaceDashboardDto> _filteredItemPlaces = new List();

  bool _loading = false;
  bool _isChecked = false;
  List<bool> _checked = new List();

  LinkedHashSet<int> _selectedIds = new LinkedHashSet();
  LinkedHashSet<ItemPlaceDashboardDto> _selectedItemPlaces = new LinkedHashSet();

  bool _isAddButtonTapped = false;
  bool _isDeleteButtonTapped = false;

  TextEditingController _locationController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._itemPlaceService = ServiceInitializer.initialize(context, _user.authHeader, ItemPlaceService);
    super.initState();
    _loading = true;
    _itemPlaceService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _itemPlaces = res;
        _itemPlaces.forEach((e) => _checked.add(false));
        _filteredItemPlaces = _itemPlaces;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _user, getTranslated(context, 'loading'), () => NavigatorUtil.navigate(context, GroupPage(_model))));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(context, _user, getTranslated(context, 'itemPlaces'), () => NavigatorUtil.navigate(context, GroupPage(_model))),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
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
                        () {
                          _filteredItemPlaces = _itemPlaces.where((i) => ((i.location + i.numberOfTypeOfItems.toString() + i.totalNumberOfItems.toString()).toLowerCase().contains(string.toLowerCase()))).toList();
                        },
                      );
                    },
                  ),
                ),
                ListTileTheme(
                  contentPadding: EdgeInsets.only(left: 3),
                  child: CheckboxListTile(
                    title: textWhite(getTranslated(this.context, 'selectUnselectAll')),
                    value: _isChecked,
                    activeColor: GREEN,
                    checkColor: WHITE,
                    onChanged: (bool value) {
                      setState(() {
                        _isChecked = value;
                        List<bool> l = new List();
                        _checked.forEach((b) => l.add(value));
                        _checked = l;
                        if (value) {
                          _selectedIds.addAll(_filteredItemPlaces.map((e) => e.id));
                          _selectedItemPlaces.addAll(_filteredItemPlaces.map((e) => e));
                        } else {
                          _selectedIds.clear();
                          _selectedItemPlaces.clear();
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                _itemPlaces.isEmpty
                    ? _handleNoItemPlaces()
                    : Expanded(
                        flex: 2,
                        child: RefreshIndicator(
                          color: DARK,
                          backgroundColor: WHITE,
                          onRefresh: _refresh,
                          child: Scrollbar(
                            isAlwaysShown: true,
                            controller: _scrollController,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _filteredItemPlaces.length,
                              itemBuilder: (BuildContext context, int index) {
                                ItemPlaceDashboardDto itemPlace = _filteredItemPlaces[index];
                                int foundIndex = 0;
                                for (int i = 0; i < _itemPlaces.length; i++) {
                                  if (_itemPlaces[i].id == itemPlace.id) {
                                    foundIndex = i;
                                  }
                                }
                                String location = utf8.decode(itemPlace.location.runes.toList());
                                String numberOfTypeOfItems = itemPlace.numberOfTypeOfItems.toString();
                                String totalNumberOfItems = itemPlace.totalNumberOfItems.toString();
                                return Card(
                                  color: DARK,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        color: BRIGHTER_DARK,
                                        child: ListTileTheme(
                                          contentPadding: EdgeInsets.only(right: 10),
                                          child: CheckboxListTile(
                                            controlAffinity: ListTileControlAffinity.trailing,
                                            secondary: Padding(
                                              padding: EdgeInsets.only(left: 10),
                                              child: Shimmer.fromColors(
                                                baseColor: GREEN,
                                                highlightColor: WHITE,
                                                child: BouncingWidget(
                                                  duration: Duration(milliseconds: 100),
                                                  scaleFactor: 2,
                                                  onPressed: () => NavigatorUtil.navigate(this.context, ItemPlaceDetailsPage(_model, itemPlace)),
                                                  child: icon40Green(Icons.search),
                                                ),
                                              ),
                                            ),
                                            title: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: textGreen(location),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Row(
                                                    children: [
                                                      textWhite(getTranslated(this.context, 'numberOfTypeOfItems') + ': '),
                                                      textGreen(numberOfTypeOfItems.toString()),
                                                    ],
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Row(
                                                    children: [
                                                      textWhite(getTranslated(this.context, 'totalNumberOfItems') + ': '),
                                                      textGreen(totalNumberOfItems.toString()),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            activeColor: GREEN,
                                            checkColor: WHITE,
                                            value: _checked[foundIndex],
                                            onChanged: (bool value) {
                                              setState(() {
                                                _checked[foundIndex] = value;
                                                if (value) {
                                                  _selectedIds.add(_itemPlaces[foundIndex].id);
                                                  _selectedItemPlaces.add(_itemPlaces[foundIndex]);
                                                } else {
                                                  _selectedIds.remove(_itemPlaces[foundIndex].id);
                                                  _selectedItemPlaces.remove(_itemPlaces[foundIndex]);
                                                }
                                                int selectedIdsLength = _selectedIds.length;
                                                if (selectedIdsLength == _itemPlaces.length) {
                                                  _isChecked = true;
                                                } else if (selectedIdsLength == 0) {
                                                  _isChecked = false;
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "plusBtn",
                tooltip: getTranslated(context, 'createItemPlace'),
                backgroundColor: GREEN,
                onPressed: () => _addItemPlace(context),
                child: text25Dark('+'),
              ),
              SizedBox(height: 15),
              FloatingActionButton(
                heroTag: "deleteBtn",
                tooltip: getTranslated(context, 'deleteSelectedItemPlaces'),
                backgroundColor: Colors.red,
                onPressed: () => _isDeleteButtonTapped ? null : _handleDeleteByIdIn(_selectedIds, _selectedItemPlaces),
                child: Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, GroupPage(_model)),
    );
  }

  void _addItemPlace(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'itemPlace'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
            backgroundColor: Colors.black12,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 50), child: text20GreenBold(getTranslated(context, 'createItemPlace'))),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      autofocus: true,
                      controller: _locationController,
                      keyboardType: TextInputType.multiline,
                      maxLength: 100,
                      maxLines: 2,
                      cursorColor: WHITE,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(color: WHITE),
                      decoration: InputDecoration(
                        hintText: getTranslated(this.context, 'textSomeLocation') + ' ...',
                        hintStyle: TextStyle(color: MORE_BRIGHTER_DARK),
                        counterStyle: TextStyle(color: WHITE),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GREEN, width: 2.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GREEN, width: 2.5),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        minWidth: 40,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            iconWhite(Icons.close),
                          ],
                        ),
                        color: Colors.red,
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 25),
                      MaterialButton(
                        elevation: 0,
                        height: 50,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[iconWhite(Icons.check)],
                        ),
                        color: GREEN,
                        onPressed: () => _isAddButtonTapped ? null : _handleAddItemPlace(_locationController.text),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _handleAddItemPlace(String location) {
    setState(() => _isAddButtonTapped = true);
    if (location == null || location.isEmpty) {
      setState(() => _isAddButtonTapped = false);
      ToastService.showErrorToast(getTranslated(this.context, 'itemPlaceLocationIsRequired'));
      return;
    }
    showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
    _itemPlaceService.create(_user.companyId, location).then((res) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        ToastService.showSuccessToast(getTranslated(this.context, 'successfullyAddedNewItemPlace'));
        NavigatorUtil.navigateReplacement(this.context, ItemPlacesPage(_model));
      });
    }).catchError((onError) {
      Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
        setState(() => _isAddButtonTapped = false);
        String errorMsg = onError.toString();
        if (errorMsg.contains("ITEM_PLACE_LOCATION_EXISTS")) {
          ToastService.showErrorToast(getTranslated(this.context, 'itemPlaceLocationExists'));
        } else {
          ToastService.showErrorToast(getTranslated(this.context, 'somethingWentWrong'));
        }
      });
    });
  }

  _handleDeleteByIdIn(LinkedHashSet<int> ids, LinkedHashSet<ItemPlaceDashboardDto> selectedItemPlaces) {
    if (ids.isEmpty) {
      showHint(context, getTranslated(context, 'needToSelectItemPlaces') + ' ', getTranslated(context, 'whichYouWantToRemove'));
      return;
    }
    if (selectedItemPlaces.any((element) => element.numberOfTypeOfItems != 0)) {
      showHint(context, getTranslated(context, 'cannotRemovePlacesWithItems') + ' ', getTranslated(context, 'hintReturnItems'));
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textWhite(getTranslated(this.context, 'confirmation')),
          content: textWhite(getTranslated(this.context, 'areYouSureYouWantToDeleteSelectedItemPlaces')),
          actions: <Widget>[
            FlatButton(
              child: textWhite(getTranslated(this.context, 'yesDeleteThem')),
              onPressed: () {
                showProgressDialog(context: context, loadingText: getTranslated(context, 'loading'));
                _itemPlaceService.deleteByIdIn(ids.map((e) => e.toString()).toList()).then((res) {
                  Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                    Navigator.pop(context);
                    setState(() => _itemPlaces.removeWhere((element) => selectedItemPlaces.contains(element)));
                    setState(() => _isDeleteButtonTapped = false);
                    ToastService.showSuccessToast(getTranslated(this.context, 'selectedItemPlacesRemoved'));
                  });
                }).catchError((onError) {
                  Future.delayed(Duration(microseconds: 1), () => dismissProgressDialog()).whenComplete(() {
                    setState(() => _isDeleteButtonTapped = false);
                    ToastService.showErrorToast(getTranslated(this.context, 'somethingWentWrong'));
                  });
                });
              },
            ),
            FlatButton(
              child: textWhite(getTranslated(this.context, 'no')),
              onPressed: () => Navigator.of(this.context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _handleNoItemPlaces() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Align(alignment: Alignment.center, child: text20GreenBold(getTranslated(this.context, 'noItemPlaces'))),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30, left: 30, top: 10),
          child: Align(alignment: Alignment.center, child: textCenter19White(getTranslated(this.context, 'noItemPlacesHint'))),
        ),
      ],
    );
  }

  Future<Null> _refresh() {
    _loading = true;
    return _itemPlaceService.findAllByCompanyId(_user.companyId).then((res) {
      setState(() {
        _isAddButtonTapped = false;
        _isDeleteButtonTapped = false;
        _itemPlaces = res;
        _itemPlaces.forEach((e) => _checked.add(false));
        _filteredItemPlaces = _itemPlaces;
        _loading = false;
      });
    });
  }
}