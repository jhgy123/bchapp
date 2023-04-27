///
/// author: jhgy
/// data: ON 2023-04-27
///
import 'package:flutter/material.dart';
import 'image_selection_page.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:my_predict_plugin/my_predict_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'my example 中文文本',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageSelectionPage(),
    );
  }
}