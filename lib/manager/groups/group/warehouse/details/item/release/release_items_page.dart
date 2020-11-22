import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/item/dto/create_item_dto.dart';
import 'package:give_job/api/item/dto/item_dto.dart';
import 'package:give_job/api/itemplace/dto/assign_items_dto.dart';
import 'package:give_job/api/itemplace/dto/itemplace_dashboard_dto.dart';
import 'package:give_job/api/itemplace/service/itemplace_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/api/warehouse/dto/warehouse_dashboard_dto.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/shared/group_model.dart';
import 'package:give_job/manager/groups/group/warehouse/details/warehouse_details_page.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class ReleaseItemsPage extends StatefulWidget {
  final GroupModel _model;
  final WarehouseDashboardDto _warehouseDto;
  final List<ItemDto> _items;

  ReleaseItemsPage(this._model, this._warehouseDto, this._items);

  @override
  _ReleaseItemsPageState createState() => _ReleaseItemsPageState();
}

class _ReleaseItemsPageState extends State<ReleaseItemsPage> {
  GroupModel _model;
  User _user;
  WarehouseDashboardDto _warehouseDto;
  List<ItemDto> _items;
  List<TextEditingController> _textEditingItemControllers = new List();

  List<ItemplaceDashboardDto> _itemPlaces;
  List<int> _itemPlacesRadioValues = new List();
  int _choosenIndex = -1;

  ItemplaceService _itemPlaceService;

  bool _loading = false;

  bool _isAddButtonTapped = false;
  bool _isAddBtnDisabled = true;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._warehouseDto = widget._warehouseDto;
    this._items = widget._items;
    this._items.forEach((i) => _textEditingItemControllers.add(new TextEditingController()));
    this._itemPlaceService = ServiceInitializer.initialize(context, _user.authHeader, ItemplaceService);
    super.initState();
    _loading = true;
    _itemPlaceService.findAllByCompanyId(int.parse(_user.companyId)).then((res) {
      setState(() {
        _itemPlaces = res;
        _itemPlaces.forEach((element) => _itemPlacesRadioValues.add(-1));
        _loading = false;
        if (_itemPlaces.isEmpty) {
          _showFailureDialogWithNavigate(getTranslated(this.context, 'noItemplacesToReleaseItems'));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loader(managerAppBar(context, _user, getTranslated(context, 'loading')), managerSideBar(context, _user));
    }
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(context, _user, getTranslated(context, 'releaseItems')),
          drawer: managerSideBar(context, _user),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Scrollbar(
                    isAlwaysShown: false,
                    controller: _scrollController,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _items.length,
                      itemBuilder: (BuildContext context, int index) {
                        String itemName = _items[index].name;
                        String quantity = _items[index].quantity.toString();
                        return Card(
                          color: DARK,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Card(
                                color: BRIGHTER_DARK,
                                child: ListTile(
                                  title: textGreen(itemName),
                                  subtitle: Row(
                                    children: [
                                      textWhite(getTranslated(this.context, 'quantity') + ': '),
                                      textGreen(quantity),
                                    ],
                                  ),
                                  trailing: Container(
                                    width: 100,
                                    child: _buildNumberField(_textEditingItemControllers[index], int.parse(quantity)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, WarehouseDetailsPage(_model, _warehouseDto)),
    );
  }

  _buildNumberField(TextEditingController controller, int max) {
    return NumberInputWithIncrementDecrement(
      onIncrement: (value) {
        if (value > max) {
          setState(() => value = max);
        }
      },
      controller: controller,
      min: 0,
      max: max,
      style: TextStyle(color: GREEN),
      widgetContainerDecoration: BoxDecoration(border: Border.all(color: BRIGHTER_DARK)),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MaterialButton(
            elevation: 0,
            height: 50,
            minWidth: 40,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[iconWhite(Icons.close)],
            ),
            color: Colors.red,
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WarehouseDetailsPage(_model, _warehouseDto)), (e) => false),
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
            onPressed: () => _releaseItemsToItemplace(),
          ),
        ],
      ),
    );
  }

  void _releaseItemsToItemplace() {
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: StatefulBuilder(builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.black12,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            textCenter20GreenBold('Choose place where selected items with quantites will be placed'),
                          ],
                        ),
                      ),
                      SizedBox(height: 7.5),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < _itemPlaces.length; i++)
                            _buildRadioBtn(
                              color: GREEN,
                              title: _itemPlaces[i].location,
                              value: 0,
                              groupValue: _itemPlacesRadioValues[i],
                              onChanged: (newValue) => setState(
                                () {
                                  if (_choosenIndex != -1) {
                                    _itemPlacesRadioValues[_choosenIndex] = -1;
                                  }
                                  _itemPlacesRadioValues[i] = newValue;
                                  _choosenIndex = i;
                                  _isAddBtnDisabled = false;
                                },
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 20),
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
                              children: <Widget>[iconWhite(Icons.close)],
                            ),
                            color: Colors.red,
                            onPressed: () {
                              if (_choosenIndex != -1) {
                                _itemPlacesRadioValues[_choosenIndex] = -1;
                              }
                              _choosenIndex = -1;
                              _isAddBtnDisabled = true;
                              Navigator.pop(context);
                            },
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
                            color: !_isAddBtnDisabled ? GREEN : Colors.grey,
                            onPressed: () => _isAddBtnDisabled || _isAddButtonTapped ? null : _handleAddBtn(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  void _handleAddBtn() {
    setState(() => _isAddButtonTapped = true);
    Map<String, int> itemsWithQuantities = new Map();
    for (int i = 0; i < _items.length; i++) {
      itemsWithQuantities[_items[i].name] = int.parse(_textEditingItemControllers[i].text);
    }
    AssignItemsDto dto = new AssignItemsDto(
      warehouseId: _warehouseDto.id,
      itemPlaceId: _itemPlaces[_choosenIndex].id,
      itemsWithQuantities: itemsWithQuantities,
    );
    _itemPlaceService.assignNewItems(dto).then((value) {
      ToastService.showSuccessToast(getTranslated(context, 'successfullyReleaseItemsToSelectedItemplace'));
      Navigator.push(
        this.context,
        MaterialPageRoute(builder: (context) => WarehouseDetailsPage(_model, _warehouseDto)),
      );
      setState(() => _isAddButtonTapped = false);
    }).catchError((onError) {
      String errorMsg = onError.toString();
      if (errorMsg.contains("NOT_ENOUGH_QUANTITY")) {
        _showFailureDialogWithNavigate(getTranslated(context, 'someOfItemsDoNotHaveEnoughQuantity'));
      } else {
        ToastService.showErrorToast(getTranslated(context, 'smthWentWrong'));
      }
      setState(() => _isAddButtonTapped = false);
    });
  }

  Widget _buildRadioBtn({Color color, String title, int value, int groupValue, Function onChanged}) {
    return RadioListTile(
      activeColor: color,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: textWhite(title),
    );
  }

  _showFailureDialogWithNavigate(String content) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: DARK,
            title: textGreen(getTranslated(this.context, 'failure')),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  textWhite(content),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textWhite(getTranslated(this.context, 'goToWarehousesPage')),
                onPressed: () => _resetAndOpenPage(),
              ),
            ],
          ),
          onWillPop: _navigateToWarehouseDetailsPage,
        );
      },
    );
  }

  Future<bool> _navigateToWarehouseDetailsPage() async {
    _resetAndOpenPage();
    return true;
  }

  void _resetAndOpenPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => WarehouseDetailsPage(_model, _warehouseDto)),
      ModalRoute.withName('/'),
    );
  }
}