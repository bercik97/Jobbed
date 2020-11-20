import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:give_job/api/piecework/dto/create_piecework_dto.dart';
import 'package:give_job/api/piecework/service/piecework_service.dart';
import 'package:give_job/api/price_list/dto/price_list_dto.dart';
import 'package:give_job/api/price_list/service/pricelist_service.dart';
import 'package:give_job/api/shared/service_initializer.dart';
import 'package:give_job/employee/employee_profile_page.dart';
import 'package:give_job/internationalization/localization/localization_constants.dart';
import 'package:give_job/manager/shared/manager_app_bar.dart';
import 'package:give_job/manager/shared/manager_side_bar.dart';
import 'package:give_job/shared/libraries/colors.dart';
import 'package:give_job/shared/libraries/constants.dart';
import 'package:give_job/shared/model/user.dart';
import 'package:give_job/shared/service/toastr_service.dart';
import 'package:give_job/shared/service/validator_service.dart';
import 'package:give_job/shared/util/navigator_util.dart';
import 'package:give_job/shared/widget/icons.dart';
import 'package:give_job/shared/widget/loader.dart';
import 'package:give_job/shared/widget/texts.dart';

import '../piecework_page.dart';

class AddPieceworkPage extends StatefulWidget {
  final User _user;
  final String _todayDate;
  final int _todayWorkdayId;

  AddPieceworkPage(this._user, this._todayDate, this._todayWorkdayId);

  @override
  _AddPieceworkPageState createState() => _AddPieceworkPageState();
}

class _AddPieceworkPageState extends State<AddPieceworkPage> {
  User _user;
  String _todayDate;
  int _todayWorkdayId;

  PricelistService _pricelistService;
  PieceworkService _pieceworkService;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ScrollController _scrollController = new ScrollController();

  final TextEditingController _workplaceNameController = new TextEditingController();

  List<PricelistDto> _pricelists = new List();
  List<PricelistDto> _filteredPricelists = new List();

  Map<String, int> serviceWithQuantity = new LinkedHashMap();

  bool _loading = false;
  bool _isAddButtonTapped = false;

  @override
  void initState() {
    this._user = widget._user;
    this._todayDate = widget._todayDate;
    this._todayWorkdayId = widget._todayWorkdayId;
    this._pricelistService = ServiceInitializer.initialize(context, _user.authHeader, PricelistService);
    this._pieceworkService = ServiceInitializer.initialize(context, _user.authHeader, PieceworkService);
    super.initState();
    _loading = true;
    _pricelistService.findAllByCompanyId(int.parse(_user.companyId)).then((res) {
      setState(() {
        _pricelists = res;
        _filteredPricelists = _pricelists;
        _loading = false;
      });
    }).catchError((onError) {
      _showFailureDialog();
    });
  }

  _showFailureDialog() {
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
                  textWhite(getTranslated(this.context, 'noPricelist')),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: textWhite(getTranslated(this.context, 'goToTheEmployeeProfilPage')),
                onPressed: () => _resetAndOpenPage(),
              ),
            ],
          ),
          onWillPop: _navigateToEmployeeProfilPage,
        );
      },
    );
  }

  Future<bool> _navigateToEmployeeProfilPage() async {
    _resetAndOpenPage();
    return true;
  }

  void _resetAndOpenPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => EmployeeProfilPage(_user)),
      ModalRoute.withName('/'),
    );
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
          appBar: managerAppBar(context, _user, getTranslated(context, 'createReport') + ' / ' + _todayDate),
          drawer: managerSideBar(context, _user),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              autovalidate: true,
              key: formKey,
              child: Column(
                children: [
                  SizedBox(height: 5),
                  _buildField(
                    _workplaceNameController,
                    getTranslated(context, 'writeWorkplaceName'),
                    getTranslated(context, 'workplaceName'),
                    26,
                    1,
                    getTranslated(context, 'workplaceNameIsRequired'),
                  ),
                  SizedBox(height: 10),
                  _buildAddedPriceList(),
                  SizedBox(height: 20),
                  _buildLoupe(),
                  SizedBox(height: 10),
                  _buildPricelist(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, PieceworkPage(_user, _todayDate, _todayWorkdayId)),
    );
  }

  bool _isValid() {
    return formKey.currentState.validate();
  }

  Widget _buildField(TextEditingController controller, String hintText, String labelText, int length, int lines, String errorText) {
    return TextFormField(
      autofocus: false,
      controller: controller,
      autocorrect: true,
      keyboardType: TextInputType.multiline,
      maxLength: length,
      maxLines: lines,
      cursorColor: WHITE,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(color: WHITE),
      validator: RequiredValidator(errorText: errorText),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
        counterStyle: TextStyle(color: WHITE),
        border: OutlineInputBorder(),
        hintText: hintText,
        labelText: labelText,
        labelStyle: TextStyle(color: WHITE),
      ),
    );
  }

  Widget _buildLoupe() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: TextFormField(
        autofocus: false,
        autocorrect: true,
        cursorColor: WHITE,
        style: TextStyle(color: WHITE),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: WHITE, width: 2)),
          counterStyle: TextStyle(color: WHITE),
          border: OutlineInputBorder(),
          labelText: getTranslated(this.context, 'search'),
          prefixIcon: iconWhite(Icons.search),
          labelStyle: TextStyle(color: WHITE),
        ),
        onChanged: (string) {
          setState(
            () {
              _filteredPricelists = _pricelists.where((e) => ((e.name + e.price.toString()).toLowerCase().contains(string.toLowerCase()))).toList();
            },
          );
        },
      ),
    );
  }

  Widget _buildAddedPriceList() {
    if (serviceWithQuantity.isEmpty) {
      return textCenter18Green(getTranslated(context, 'noAddedItemsFromPricelist'));
    }
    Iterable keys = serviceWithQuantity.keys;
    Iterable values = serviceWithQuantity.values;
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: MORE_BRIGHTER_DARK),
                child: DataTable(
                  columnSpacing: 10,
                  columns: [
                    DataColumn(label: textWhiteBold('No.')),
                    DataColumn(label: textWhiteBold(getTranslated(context, 'serviceName'))),
                    DataColumn(label: textWhiteBold(getTranslated(context, 'quantity'))),
                    DataColumn(label: textWhiteBold(getTranslated(context, 'remove'))),
                  ],
                  rows: [
                    for (int i = 0; i < keys.length; i++)
                      DataRow(
                        cells: [
                          DataCell(textWhite((i + 1).toString())),
                          DataCell(textWhite(keys.elementAt(i))),
                          DataCell(textWhite(values.elementAt(i).toString())),
                          DataCell(
                            MaterialButton(
                              child: iconWhite(Icons.close),
                              color: Colors.red,
                              onPressed: () => setState(() => serviceWithQuantity.remove(keys.elementAt(i))),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricelist() {
    return Expanded(
      flex: 2,
      child: Scrollbar(
        isAlwaysShown: true,
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _filteredPricelists.length,
          itemBuilder: (BuildContext context, int index) {
            PricelistDto pricelist = _filteredPricelists[index];
            String name = pricelist.name;
            String price = pricelist.price.toString();
            return Card(
              color: DARK,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    color: BRIGHTER_DARK,
                    child: ListTile(
                      trailing: InkWell(
                        child: IconButton(
                          icon: icon30Green(Icons.add),
                          onPressed: () {
                            if (serviceWithQuantity.containsKey(name)) {
                              ToastService.showErrorToast(getTranslated(this.context, 'youHaveAlreadyChosenThisPricelistService'));
                              return;
                            }
                            _setPricelistServiceQuantity(name);
                          },
                        ),
                      ),
                      title: text20WhiteBold(utf8.decode(name.runes.toList())),
                      subtitle: Row(
                        children: [
                          textWhite(getTranslated(this.context, 'price') + ': '),
                          textGreen(price),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _setPricelistServiceQuantity(String pricelistService) {
    TextEditingController _quantityController = new TextEditingController();
    showGeneralDialog(
      context: context,
      barrierColor: DARK.withOpacity(0.95),
      barrierDismissible: false,
      barrierLabel: getTranslated(context, 'quantity'),
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return SizedBox.expand(
          child: Scaffold(
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
                          text20GreenBold(pricelistService),
                        ],
                      ),
                    ),
                    SizedBox(height: 7.5),
                    textGreen(getTranslated(context, 'typeQuantityOfServicePerformed')),
                    SizedBox(height: 2.5),
                    Container(
                      width: 150,
                      child: TextFormField(
                        autofocus: true,
                        controller: _quantityController,
                        keyboardType: TextInputType.numberWithOptions(decimal: false),
                        maxLength: 3,
                        cursorColor: WHITE,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(color: WHITE),
                        decoration: InputDecoration(
                          counterStyle: TextStyle(color: WHITE),
                          labelStyle: TextStyle(color: WHITE),
                          labelText: '(1-999)',
                        ),
                      ),
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
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 25),
                        MaterialButton(
                          elevation: 0,
                          height: 50,
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              iconWhite(Icons.check),
                            ],
                          ),
                          color: GREEN,
                          onPressed: () {
                            int quantity;
                            try {
                              quantity = int.parse(_quantityController.text);
                            } catch (FormatException) {
                              ToastService.showErrorToast(getTranslated(context, 'quantityIsRequired'));
                              return;
                            }
                            String invalidMessage = ValidatorService.validatePricelistServiceQuantity(quantity, context);
                            if (invalidMessage != null) {
                              ToastService.showErrorToast(invalidMessage);
                              return;
                            }
                            setState(() => serviceWithQuantity[pricelistService] = quantity);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
            onPressed: () => {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => PieceworkPage(_user, _todayDate, _todayWorkdayId)), (e) => false),
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
            color: GREEN,
            onPressed: () => _isAddButtonTapped ? null : _createNote(),
          ),
        ],
      ),
    );
  }

  void _createNote() {
    setState(() => _isAddButtonTapped = true);
    if (!_isValid()) {
      _errorDialog(getTranslated(context, 'workplaceNameIsRequired'));
      setState(() => _isAddButtonTapped = false);
      return;
    }
    if (serviceWithQuantity.isEmpty) {
      _errorDialog(getTranslated(context, 'noAddedItemsFromPricelist'));
      setState(() => _isAddButtonTapped = false);
      return;
    }
    CreatePieceworkDto dto = new CreatePieceworkDto(
      workdayId: _todayWorkdayId,
      workplaceName: _workplaceNameController.text,
      serviceWithQuantity: serviceWithQuantity,
    );
    _pieceworkService.create(dto).then((res) {
      ToastService.showSuccessToast(getTranslated(context, 'successfullyAddedNewReportAboutPiecework'));
      Navigator.push(
        this.context,
        MaterialPageRoute(builder: (context) => PieceworkPage(_user, _todayDate, _todayWorkdayId)),
      );
    }).catchError((onError) {
      ToastService.showErrorToast(getTranslated(context, 'smthWentWrong'));
      setState(() => _isAddButtonTapped = false);
    });
  }

  _errorDialog(String content) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: DARK,
          title: textGreen(getTranslated(context, 'error')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                textWhite(content),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: textWhite(getTranslated(context, 'close')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
