import 'package:avatar_letter/avatar_letter.dart';
import 'package:flutter/material.dart';

class AvatarsUtil {
  static AvatarLetter buildAvatar(String gender, double avatarSize, double fontSize, String nameLetter, String surnameLetter) {
    Color backgroundColor;
    if (gender == 'male') {
      backgroundColor = Color(0xff9dc4e5);
    } else {
      backgroundColor = Color(0xffffc0cb);
    }
    return AvatarLetter(
      size: avatarSize,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: fontSize,
      upperCase: true,
      numberLetters: 2,
      letterType: LetterType.Circular,
      text: nameLetter + ' ' + surnameLetter,
      backgroundColorHex: null,
      textColorHex: null,
    );
  }
}
