import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/api/itemplace/dto/itemplace_dashboard_dto.dart';
import 'package:give_job/api/itemplace/dto/itemplace_details_dto.dart';
import 'package:give_job/api/itemplace/service/itemplace_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/groups/group/itemplaces/details/itemplaces_details_page.dart';
import 'package:give_job/manager/groups/group/shared/group_model.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/texts.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

class ReturnItemsPage extends StatefulWidget {
  final GroupModel _model;
  final ItemplaceDashboardDto _itemplaceDto;
  final List<ItemplaceDetailsDto> _itemplaces;

  ReturnItemsPage(this._model, this._itemplaceDto, this._itemplaces);

  @override
  _ReturnItemsPageState createState() => _ReturnItemsPageState();
}

class _ReturnItemsPageState extends State<ReturnItemsPage> {
  GroupModel _model;
  User _user;
  ItemplaceDashboardDto _itemplaceDto;
  List<ItemplaceDetailsDto> _itemplaces;
  List<TextEditingController> _textEditingItemControllers = new List();

  ItemplaceService _itemPlaceService;

  bool _isAddButtonTapped = false;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    this._model = widget._model;
    this._user = _model.user;
    this._itemplaceDto = widget._itemplaceDto;
    this._itemplaces = widget._itemplaces;
    this._itemplaces.forEach((i) => _textEditingItemControllers.add(new TextEditingController()));
    this._itemPlaceService = ServiceInitializer.initialize(context, _user.authHeader, ItemplaceService);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xffFFFFFF, WHITE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: DARK,
          appBar: managerAppBar(context, _user, getTranslated(context, 'returnItems')),
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
                      itemCount: _itemplaces.length,
                      itemBuilder: (BuildContext context, int index) {
                        String itemName = _itemplaces[index].name;
                        String quantity = _itemplaces[index].quantity.toString();
                        String warehouseName = _itemplaces[index].warehouseName.toString();
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
                                  subtitle: Column(
                                    children: [
                                      Row(
                                        children: [
                                          text15White(getTranslated(this.context, 'quantity') + ': '),
                                          text15Green(quantity),
                                        ],
                                      ),
                                      SizedBox(height: 7.5),
                                      Column(
                                        children: [
                                          Align(
                                            child: textWhite(getTranslated(this.context, 'warehouse') + ': '),
                                            alignment: Alignment.topLeft,
                                          ),
                                          Align(
                                            child: textGreen(warehouseName),
                                            alignment: Alignment.topLeft,
                                          ),
                                        ],
                                      ),
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
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, ItemplacesDetailsPage(_model, _itemplaceDto)),
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
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ItemplacesDetailsPage(_model, _itemplaceDto)), (e) => false),
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
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}