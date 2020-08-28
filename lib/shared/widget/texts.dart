import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/shared/libraries/colors.dart';

/////////////////////
/*    TEXT WHITE   */
/////////////////////
Text textWhite(String text) { return Text(text, style: TextStyle(color: WHITE)); }
Text text13White(String text) { return Text(text, style: TextStyle(fontSize: 13, color: WHITE)); }
Text text16White(String text) { return Text(text, style: TextStyle(fontSize: 16, color: WHITE)); }
Text text17White(String text) { return Text(text, style: TextStyle(fontSize: 18, color: WHITE)); }
Text text18White(String text) { return Text(text, style: TextStyle(fontSize: 18, color: WHITE)); }
Text text20White(String text) { return Text(text, style: TextStyle(fontSize: 20, color: WHITE)); }


/////////////////////
/* TEXT WHITE BOLD */
/////////////////////
Text textWhiteBold(String text) { return Text(text, style: TextStyle(color: WHITE, fontWeight: FontWeight.bold)); }
Text text15WhiteBold(String text) { return Text(text, style: TextStyle(fontSize: 15, color: WHITE, fontWeight: FontWeight.bold)); }
Text text16WhiteBold(String text) { return Text(text, style: TextStyle(fontSize: 16, color: WHITE, fontWeight: FontWeight.bold)); }
Text text18WhiteBold(String text) { return Text(text, style: TextStyle(fontSize: 18, color: WHITE, fontWeight: FontWeight.bold)); }
Text text20WhiteBold(String text) { return Text(text, style: TextStyle(fontSize: 20, color: WHITE, fontWeight: FontWeight.bold)); }


/////////////////////
/*TEXT WHITE ITALIC*/
/////////////////////
Text text20WhiteItalic(String text) { return Text(text, style: TextStyle(fontSize: 20, color: WHITE, fontStyle: FontStyle.italic)); }


////////////////////////////////////
/*TEXT CENTER WHITE BOLD UNDERLINE*/
////////////////////////////////////
Text textCenter20WhiteBoldUnderline(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: WHITE, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)); }
Text textWhiteBoldUnderline(String text) { return Text(text, style: TextStyle(color: WHITE, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)); }


/////////////////////
/*TEXT CENTER WHITE*/
/////////////////////
Text textCenterWhite(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(color: WHITE)); }
Text textCenter14White(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: WHITE)); }
Text textCenter19White(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 19, color: WHITE)); }
Text textCenter28White(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 28, color: WHITE)); }
Text textCenter30White(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 30, color: WHITE)); }


/////////////////////
/*    TEXT DARK    */
/////////////////////
Text textDark(String text) { return Text(text, style: TextStyle(color: DARK)); }


/////////////////////
/* TEXT DARK BOLD  */
/////////////////////
Text textDarkBold(String text) { return Text(text, style: TextStyle(color: DARK, fontWeight: FontWeight.bold)); }
Text text14DarkBold(String text) { return Text(text, style: TextStyle(fontSize: 14, color: DARK, fontWeight: FontWeight.bold)); }
Text text18DarkBold(String text) { return Text(text, style: TextStyle(fontSize: 18, color: DARK, fontWeight: FontWeight.bold)); }
Text text20DarkBold(String text) { return Text(text, style: TextStyle(fontSize: 20, color: DARK, fontWeight: FontWeight.bold)); }
Text text22DarkBold(String text) { return Text(text, style: TextStyle(fontSize: 22, color: DARK, fontWeight: FontWeight.bold)); }


/////////////////////
/*    TEXT GREEN   */
/////////////////////
Text textGreen(String text) { return Text(text, style: TextStyle(color: GREEN)); }
Text text16Green(String text) { return Text(text, style: TextStyle(fontSize: 14, color: GREEN)); }


/////////////////////////////////
/* TEXT CENTER GREEN UNDERLINE */
/////////////////////////////////
Text text25GreenUnderline(String text) { return Text(text, style: TextStyle(fontSize: 20, color: GREEN, decoration: TextDecoration.underline)); }


////////////////////////////
/* TEXT CENTER GREEN BOLD */
////////////////////////////
Text textCenter28GreenBold(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 28, color: GREEN, fontWeight: FontWeight.bold)); }


/////////////////////
/* TEXT GREEN BOLD */
/////////////////////
Text textGreenBold(String text) { return Text(text, style: TextStyle(color: GREEN, fontWeight: FontWeight.bold)); }
Text text20GreenBold(String text) { return Text(text, style: TextStyle(fontSize: 20, color: GREEN, fontWeight: FontWeight.bold)); }


/////////////////////
/*     TEXT RED    */
/////////////////////
Text text13Red(String text) { return Text(text, style: TextStyle(fontSize: 13, color: Colors.red)); }


/////////////////////
/* TEXT ORANGE BOLD*/
/////////////////////
Text text20OrangeBold(String text) { return Text(text, style: TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold)); }
