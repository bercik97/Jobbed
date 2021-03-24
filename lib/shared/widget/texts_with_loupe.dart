import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/shared/util/dialog_util.dart';
import 'package:jobbed/shared/widget/texts.dart';

import 'icons.dart';

Widget textBlackWithLoupe(BuildContext context, String text) {
  return text != null && text != '' && text.length > 30
      ? Row(
          children: [
            textBlack(text.substring(0, 30) + '...'),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: iconBlack(Icons.search),
              onPressed: () => DialogUtil.showScrollableDialog(
                context,
                ' ',
                text,
              ),
            ),
          ],
        )
      : textBlack(text);
}
