import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobbed/shared/libraries/colors.dart';

/////////////////////
/*    TEXT BLACK   */
/////////////////////
Text textBlack(String text) { return Text(text, style: TextStyle(color: BLACK)); }
Text text12Black(String text) { return Text(text, style: TextStyle(fontSize: 12, color: BLACK)); }
Text text13Black(String text) { return Text(text, style: TextStyle(fontSize: 13, color: BLACK)); }
Text text16Black(String text) { return Text(text, style: TextStyle(fontSize: 16, color: BLACK)); }
Text text17Black(String text) { return Text(text, style: TextStyle(fontSize: 17, color: BLACK)); }
Text text18Black(String text) { return Text(text, style: TextStyle(fontSize: 18, color: BLACK)); }
Text text20Black(String text) { return Text(text, style: TextStyle(fontSize: 20, color: BLACK)); }


/////////////////////
/* TEXT BLACK BOLD */
/////////////////////
Text textBlackBold(String text) { return Text(text, style: TextStyle(color: BLACK, fontWeight: FontWeight.bold)); }
Text text17BlackBold(String text) { return Text(text, style: TextStyle(fontSize: 17, color: BLACK, fontWeight: FontWeight.bold)); }
Text text20BlackBold(String text) { return Text(text, style: TextStyle(fontSize: 20, color: BLACK, fontWeight: FontWeight.bold)); }


////////////////////////////////////
/*TEXT CENTER BLACK BOLD UNDERLINE*/
////////////////////////////////////
Text textCenter20BlackBoldUnderline(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: BLACK, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)); }
Text textBlackBoldUnderline(String text) { return Text(text, style: TextStyle(color: BLACK, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)); }


/////////////////////
/*TEXT CENTER BLACK*/
/////////////////////
Text textCenterBlack(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(color: BLACK)); }
Text textCenter13Black(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: BLACK)); }
Text textCenter14Black(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: BLACK)); }
Text textCenter15Black(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: BLACK)); }
Text textCenter19Black(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 19, color: BLACK)); }
Text textCenter20Black(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: BLACK)); }
Text textCenter28Black(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: BLACK)); }
Text textCenter30Black(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 30, color: BLACK)); }


//////////////////////////
/*TEXT CENTER BLACK BOLD*/
/////////////////////////
Text textCenter20BlackBold(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: BLACK, fontWeight: FontWeight.bold)); }


/////////////////////
/*    TEXT WHITE    */
/////////////////////
Text textWhite(String text) { return Text(text, style: TextStyle(color: WHITE)); }
Text text18White(String text) { return Text(text, style: TextStyle(fontSize: 18, color: WHITE)); }
Text text20White(String text) { return Text(text, style: TextStyle(fontSize: 20, color: WHITE)); }
Text text25White(String text) { return Text(text, style: TextStyle(fontSize: 25, color: WHITE)); }


/////////////////////
/*TEXT CENTER WHITE */
/////////////////////
Text textCenterWhite(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(color: WHITE)); }


/////////////////////
/* TEXT WHITE BOLD  */
/////////////////////
Text text35WhiteBold(String text) { return Text(text, style: TextStyle(color: WHITE, fontSize: 35, fontWeight: FontWeight.bold)); }


/////////////////////
/* TEXT GREEN BOLD */
/////////////////////
Text textGreenBold(String text) { return Text(text, style: TextStyle(color: GREEN, fontWeight: FontWeight.bold)); }
Text text17GreenBold(String text) { return Text(text, style: TextStyle(color: GREEN, fontSize: 17, fontWeight: FontWeight.bold)); }
Text text20GreenBold(String text) { return Text(text, style: TextStyle(color: GREEN, fontSize: 20, fontWeight: FontWeight.bold)); }


/////////////////////
/*  TEXT BLUE GREY */
/////////////////////
Text textBlueGrey(String text) { return Text(text, style: TextStyle(color: Colors.blueGrey)); }
Text text16BlueGrey(String text) { return Text(text, style: TextStyle(color: Colors.blueGrey, fontSize: 16)); }


/////////////////////
/*    TEXT BLUE   */
/////////////////////
Text textBlue(String text) { return Text(text, style: TextStyle(color: BLUE)); }
Text text20Blue(String text) { return Text(text, style: TextStyle(color: BLUE, fontSize: 20)); }


/////////////////////////////////
/* TEXT CENTER BLUE UNDERLINE */
/////////////////////////////////
Text text20BlueUnderline(String text) { return Text(text, style: TextStyle(fontSize: 20, color: BLUE, decoration: TextDecoration.underline)); }


////////////////////////////
/*    TEXT CENTER BLUE   */
////////////////////////////
Text textCenter18Blue(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: BLUE)); }
Text textCenter20Blue(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: BLUE)); }


////////////////////////////
/* TEXT CENTER BLUE BOLD */
////////////////////////////
Text textCenter12BlueBold(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: BLUE, fontWeight: FontWeight.bold)); }
Text textCenter15BlueBold(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: BLUE, fontWeight: FontWeight.bold)); }
Text textCenter16BlueBold(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: BLUE, fontWeight: FontWeight.bold)); }
Text textCenter17BlueBold(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: BLUE, fontWeight: FontWeight.bold)); }
Text textCenter20BlueBold(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: BLUE, fontWeight: FontWeight.bold)); }


/////////////////////
/* TEXT BLUE BOLD */
/////////////////////
Text text17BlueBold(String text) { return Text(text, style: TextStyle(fontSize: 17, color: BLUE, fontWeight: FontWeight.bold)); }
Text text20BlueBold(String text) { return Text(text, style: TextStyle(fontSize: 20, color: BLUE, fontWeight: FontWeight.bold)); }


/////////////////////
/*     TEXT RED    */
/////////////////////
Text textRed(String text) { return Text(text, style: TextStyle(color: Colors.red)); }
Text text13Red(String text) { return Text(text, style: TextStyle(fontSize: 13, color: Colors.red)); }


/////////////////////
/*  TEXT RED BOLD  */
/////////////////////
Text textRedBold(String text) { return Text(text, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)); }


/////////////////////
/* TEXT CENTER RED */
/////////////////////
Text textCenter15Red(String text) { return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.red)); }


/////////////////////
/*   TEXT ORANGE   */
/////////////////////
Text text50Orange(String text) { return Text(text, style: TextStyle(color: Colors.orange, fontSize: 50)); }


/////////////////////
/* TEXT ORANGE BOLD*/
/////////////////////
Text textOrangeBold(String text) { return Text(text, style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)); }
Text text17OrangeBold(String text) { return Text(text, style: TextStyle(fontSize: 17, color: Colors.orange, fontWeight: FontWeight.bold)); }
Text text20OrangeBold(String text) { return Text(text, style: TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold)); }
