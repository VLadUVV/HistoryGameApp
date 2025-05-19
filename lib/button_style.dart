import 'package:flutter/material.dart';

ButtonStyle buttonStyle(){
  return ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.orange.withOpacity(0.7)),
    foregroundColor: WidgetStatePropertyAll(Colors.black),
    textStyle: WidgetStatePropertyAll (
      TextStyle(
        fontSize : 16,
        fontWeight: FontWeight.bold,
      ),
  ),
  shape: WidgetStatePropertyAll(
  RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(6),
  ),
  ),
  );
}