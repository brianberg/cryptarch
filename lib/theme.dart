import "package:flutter/material.dart";

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.white,
    accentColor: Colors.black87,
    buttonColor: Colors.black12,
    cursorColor: Colors.black,
    focusColor: Colors.black,
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Colors.white,
      secondary: Colors.black87,
      surface: Colors.white,
      onPrimary: Colors.black87,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      primaryVariant: Colors.white38,
    ),
    appBarTheme: AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.black87,
      ),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: Colors.white,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.black12,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
    ),
    dialogTheme: DialogTheme(
      contentTextStyle: TextStyle(
        color: Colors.black,
      ),
      backgroundColor: Colors.white,
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      labelStyle: TextStyle(color: Colors.black),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    ),
    textTheme: TextTheme(
      bodyText1: TextStyle(
        color: Colors.black87,
      ),
      bodyText2: TextStyle(
        color: Colors.black87,
      ),
      button: TextStyle(
        color: Colors.black87,
      ),
      caption: TextStyle(
        color: Colors.black87,
      ),
      headline1: TextStyle(
        color: Colors.black87,
      ),
      headline2: TextStyle(
        color: Colors.black87,
      ),
      headline3: TextStyle(
        color: Colors.black87,
      ),
      headline4: TextStyle(
        color: Colors.black87,
      ),
      headline5: TextStyle(
        color: Colors.black87,
      ),
      headline6: TextStyle(
        color: Colors.black87,
      ),
      subtitle1: TextStyle(
        color: Colors.black54,
      ),
      subtitle2: TextStyle(
        color: Colors.black54,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.black,
    accentColor: Colors.white,
    scaffoldBackgroundColor: Colors.black,
    backgroundColor: Colors.black,
    buttonColor: Colors.grey[900],
    cursorColor: Colors.white,
    dividerColor: Colors.grey[700],
    colorScheme: ColorScheme.dark(
      primary: Colors.black,
      secondary: Colors.white,
      surface: Colors.grey[900],
      onPrimary: Colors.white,
      onSecondary: Colors.grey[900],
      onSurface: Colors.white,
      primaryVariant: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      color: Colors.black,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: Colors.black,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.grey[900],
    ),
    cardTheme: CardTheme(
      color: Colors.grey[900],
    ),
    dialogTheme: DialogTheme(
      contentTextStyle: TextStyle(
        color: Colors.white,
      ),
      backgroundColor: Colors.grey[900],
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[900],
      labelStyle: TextStyle(color: Colors.white),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    ),
    textTheme: TextTheme(
      bodyText1: TextStyle(
        color: Colors.white,
      ),
      bodyText2: TextStyle(
        color: Colors.white,
      ),
      button: TextStyle(
        color: Colors.white,
      ),
      caption: TextStyle(
        color: Colors.white,
      ),
      headline1: TextStyle(
        color: Colors.white,
      ),
      headline2: TextStyle(
        color: Colors.white,
      ),
      headline3: TextStyle(
        color: Colors.white,
      ),
      headline4: TextStyle(
        color: Colors.white,
      ),
      headline5: TextStyle(
        color: Colors.white,
      ),
      headline6: TextStyle(
        color: Colors.white,
      ),
      subtitle1: TextStyle(
        color: Colors.white70,
      ),
      subtitle2: TextStyle(
        color: Colors.white70,
      ),
    ),
  );
}
