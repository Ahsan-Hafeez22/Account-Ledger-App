import 'package:flutter/material.dart';

extension NumExtensions on num {
  SizedBox get verticalSpace =>
      SizedBox(height: toDouble().clamp(0, double.infinity));
  SizedBox get horizontalSpace => SizedBox(width: toDouble());

  EdgeInsets get allPadding => EdgeInsets.all(toDouble());

  EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: toDouble());

  EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: toDouble());

  BorderRadius get radius => BorderRadius.circular(toDouble());

  Duration get milliseconds => Duration(milliseconds: toInt());

  Duration get seconds => Duration(seconds: toInt());
}

/*
Padding(
  padding: 16.allPadding,
  child: Text("Hello"),
);

Padding(
  padding: 20.horizontalPadding,
  child: Text("Wide padding"),
);

Future.delayed(300.milliseconds, () {
  print("Done");
});

Future.delayed(2.seconds, () {
  print("After 2 seconds");
});

Container(
  decoration: BoxDecoration(
    borderRadius: 12.radius,
  ),
);
*/
