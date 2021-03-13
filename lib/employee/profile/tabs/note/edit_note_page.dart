import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/api/note/dto/note_dto.dart';
import 'package:jobbed/employee/shared/employee_app_bar.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/libraries/constants.dart';
import 'package:jobbed/shared/model/user.dart';
import 'package:jobbed/shared/util/navigator_util.dart';

import '../../../employee_profile_page.dart';

class EditNotePage extends StatefulWidget {
  final User _user;
  final String _todayDate;
  final NoteDto _noteDto;

  EditNotePage(this._user, this._todayDate, this._noteDto);

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  User _user;
  String _todayDate;
  NoteDto _noteDto;

  @override
  void initState() {
    this._user = widget._user;
    this._todayDate = widget._todayDate;
    this._noteDto = widget._noteDto;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(primarySwatch: MaterialColor(0xff2BADFF, BLUE_RGBO)),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: WHITE,
          appBar: employeeAppBar(context, _user, getTranslated(context, 'note') + ' / ' + _todayDate, () => NavigatorUtil.navigateReplacement(context, EmployeeProfilePage(_user))),
        ),
      ),
      onWillPop: () => NavigatorUtil.onWillPopNavigate(context, EmployeeProfilePage(_user)),
    );
  }
}
