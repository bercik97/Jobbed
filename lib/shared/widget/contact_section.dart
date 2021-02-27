import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/internationalization/localization/localization_constants.dart';
import 'package:jobbed/shared/libraries/colors.dart';
import 'package:jobbed/shared/util/url_util.dart';
import 'package:jobbed/shared/widget/texts.dart';

import 'icons.dart';

Widget buildContactSection(BuildContext context, String phone, String viber, String whatsApp) {
  return SingleChildScrollView(
    child: Column(
      children: <Widget>[
        phone != null && phone != '' ? _buildPhoneNumber(context, phone) : _buildEmptyListTile(context, 'phone'),
        viber != null && viber != '' ? _buildViber(context, viber) : _buildEmptyListTile(context, 'viber'),
        whatsApp != null && whatsApp != '' ? _buildWhatsApp(context, whatsApp) : _buildEmptyListTile(context, 'whatsApp'),
      ],
    ),
  );
}

Widget _buildPhoneNumber(BuildContext context, String phone) {
  return ListTile(
    title: text17BlueBold(getTranslated(context, 'phone')),
    subtitle: Row(
      children: <Widget>[
        SelectableText(phone, style: TextStyle(fontSize: 16, color: BLACK)),
        SizedBox(width: 5),
        IconButton(icon: icon30Black(Icons.phone), onPressed: () => _launchAction(context, 'tel', phone)),
        IconButton(icon: icon30Black(Icons.local_post_office), onPressed: () => _launchAction(context, 'sms', phone)),
      ],
    ),
  );
}

Widget _buildViber(BuildContext context, String viber) {
  return ListTile(
    title: text17BlueBold(getTranslated(context, 'viber')),
    subtitle: Row(
      children: <Widget>[
        SelectableText(viber, style: TextStyle(fontSize: 16, color: BLACK)),
        SizedBox(width: 5),
        SizedBox(width: 7.5),
        Padding(
          padding: EdgeInsets.all(4),
          child: Transform.scale(
            scale: 1.2,
            child: BouncingWidget(
              duration: Duration(milliseconds: 100),
              scaleFactor: 2,
              onPressed: () => _launchApp(context, 'viber', viber),
              child: Image(width: 40, height: 40, image: AssetImage('images/viber.png')),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildWhatsApp(BuildContext context, String whatsAppNumber) {
  return ListTile(
    title: text17BlueBold(getTranslated(context, 'whatsApp')),
    subtitle: Row(
      children: <Widget>[
        SelectableText(whatsAppNumber, style: TextStyle(fontSize: 16, color: BLACK)),
        SizedBox(width: 7.5),
        Padding(
          padding: EdgeInsets.all(4),
          child: Transform.scale(
            scale: 1.2,
            child: BouncingWidget(
              duration: Duration(milliseconds: 100),
              scaleFactor: 2,
              onPressed: () => _launchApp(context, 'whatsapp', whatsAppNumber),
              child: Image(
                width: 40,
                height: 40,
                image: AssetImage('images/whatsapp.png'),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

_launchAction(BuildContext context, String action, String number) async {
  String url = action + ':' + number;
  UrlUtil.launchURL(context, url);
}

_launchApp(BuildContext context, String app, String number) async {
  var url = '$app://send?phone=$number';
  UrlUtil.launchURL(context, url);
}

Widget _buildEmptyListTile(BuildContext context, String title) {
  return ListTile(
    title: text17BlueBold(getTranslated(context, title)),
    subtitle: text16Black(getTranslated(context, 'empty')),
  );
}
