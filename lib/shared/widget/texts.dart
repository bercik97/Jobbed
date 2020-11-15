import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:give_job/shared/libraries/colors.dart';

/////////////////////
/*    TEXT WHITE   */
/////////////////////
Text textWhite(String text) { return Text(text, style: TextStyle(color: WHITE)); }
Text text13White(String text) { return Text(text, style: TextStyle(fontSize: 13, color: WHITE)); }
Text text15White(String text) { return Text(text, style: TextStyle(fontSize: 15, color: WHITE)); }
Text text16White(String text) { return Text(text, style: TextStyle(fontSize: 16, color: WHITE)); }
Text text18White(String text) { return Text(text, style: TextStyle(fontSize: 18, color: WHITE)); }
Text text20White(String text) { return Text(text, style: TextStyle(fontSize: 20, color: WHITE)); }


/////////////////////
/* TEXT WHITE BOLD */
/////////////////////
Text textWhiteBold(String text) { return Text(text, style: TextStyle(color: WHITE, fontWeight: FontWeight.bold)); }
Text text16WhiteBold(String text) { return Text(text, style: TextStyle(fontSize: 16, color: WHITE, fontWeight: FontWeight.bold)); }
Text text18WhiteBold(String text) { return Text(text, style: TextStyle(fontSize: 18, color: WHITE, fontWeight: FontWeight.bold)); }
Text text20WhiteBold(String text) { return Text(text, style: TextStyle(fontSize: 20, color: WHITE, fontWeight: FontWeight.bold)); }
Text text25WhiteBold(String text) { return Text(text, style: TextStyle(fontSize: 25, color: WHITE, fontWeight: FontWeight.bold)); }


////////////////////////////////////
/*TEXT CENTER WHITE BOLD UNDERLINE*/
////////////////////////////////////
Text textCenter20WhiteBoldUnderline(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: WHITE, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)); }
Text textWhiteBoldUnderline(String text) { return Text(text, style: TextStyle(color: WHITE, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)); }


/////////////////////
/*TEXT CENTER WHITE*/
/////////////////////
Text textCenterWhite(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(color: WHITE)); }
Text textCenter13White(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: WHITE)); }
Text textCenter14White(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: WHITE)); }
Text textCenter16White(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: WHITE)); }
Text textCenter18White(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: WHITE)); }
Text textCenter19White(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 19, color: WHITE)); }
Text textCenter20White(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: WHITE)); }
Text textCenter28White(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 28, color: WHITE)); }
Text textCenter30White(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 30, color: WHITE)); }


//////////////////////////
/*TEXT CENTER WHITE BOLD*/
/////////////////////////
Text textCenter18WhiteBold(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: WHITE, fontWeight: FontWeight.bold)); }


/////////////////////
/*    TEXT DARK    */
/////////////////////
Text text18Dark(String text) { return Text(text, style: TextStyle(fontSize: 18, color: DARK)); }
Text text25Dark(String text) { return Text(text, style: TextStyle(fontSize: 25, color: DARK)); }


/////////////////////
/*TEXT CENTER WHITE*/
/////////////////////
Text textCenterDark(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(color: DARK)); }


/////////////////////
/* TEXT DARK BOLD  */
/////////////////////
Text textDarkBold(String text) { return Text(text, style: TextStyle(color: DARK, fontWeight: FontWeight.bold)); }


/////////////////////
/*    TEXT GREEN   */
/////////////////////
Text textGreen(String text) { return Text(text, style: TextStyle(color: GREEN)); }
Text text20Green(String text) { return Text(text, style: TextStyle(fontSize: 20, color: GREEN)); }
Text text25Green(String text) { return Text(text, style: TextStyle(fontSize: 25, color: GREEN)); }
Text text50Green(String text) { return Text(text, style: TextStyle(fontSize: 50, color: GREEN)); }


/////////////////////////////////
/* TEXT CENTER GREEN UNDERLINE */
/////////////////////////////////
Text text25GreenUnderline(String text) { return Text(text, style: TextStyle(fontSize: 20, color: GREEN, decoration: TextDecoration.underline)); }


////////////////////////////
/*    TEXT CENTER GREEN   */
////////////////////////////
Text textCenterGreen(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(color: GREEN)); }
Text textCenter14Green(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: GREEN)); }
Text textCenter18Green(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: GREEN)); }
Text textCenter20Green(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: GREEN)); }


////////////////////////////
/* TEXT CENTER GREEN BOLD */
////////////////////////////
Text textCenterGreenBold(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(color: GREEN, fontWeight: FontWeight.bold)); }
Text textCenter16GreenBold(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: GREEN, fontWeight: FontWeight.bold)); }
Text textCenter20GreenBold(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: GREEN, fontWeight: FontWeight.bold)); }


/////////////////////
/* TEXT GREEN BOLD */
/////////////////////
Text textGreenBold(String text) { return Text(text, style: TextStyle(color: GREEN, fontWeight: FontWeight.bold)); }
Text text15GreenBold(String text) { return Text(text, style: TextStyle(fontSize: 15, color: GREEN, fontWeight: FontWeight.bold)); }
Text text16GreenBold(String text) { return Text(text, style: TextStyle(fontSize: 16, color: GREEN, fontWeight: FontWeight.bold)); }
Text text20GreenBold(String text) { return Text(text, style: TextStyle(fontSize: 20, color: GREEN, fontWeight: FontWeight.bold)); }


/////////////////////
/*     TEXT RED    */
/////////////////////
Text textRed(String text) { return Text(text, style: TextStyle(color: Colors.red)); }
Text text13Red(String text) { return Text(text, style: TextStyle(fontSize: 13, color: Colors.red)); }
Text text20Red(String text) { return Text(text, style: TextStyle(fontSize: 20, color: Colors.red)); }


/////////////////////
/*  TEXT RED BOLD  */
/////////////////////
Text textRedBold(String text) { return Text(text, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)); }
Text text15RedBold(String text) { return Text(text, style: TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.bold)); }
Text text16RedBold(String text) { return Text(text, style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)); }
Text text20RedBold(String text) { return Text(text, style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)); }


/////////////////////
/* TEXT CENTER RED */
/////////////////////
Text textCenter15Red(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.red)); }


/////////////////////////////////
/* TEXT CENTER GREEN UNDERLINE */
/////////////////////////////////
Text textCenter15RedUnderline(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.red, decoration: TextDecoration.underline)); }


/////////////////////
/* TEXT ORANGE BOLD*/
/////////////////////
Text text20OrangeBold(String text) { return Text(text, style: TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold)); }


////////////////////////////
/* TEXT CENTER ORANGE BOLD*/
////////////////////////////
Text textCenter16OrangeBold(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.orange, fontWeight: FontWeight.bold)); }
Text textCenter20OrangeBold(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold)); }
