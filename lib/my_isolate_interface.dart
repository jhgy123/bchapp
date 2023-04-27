///
/// auther: jhgy
/// data ON 2023/4/27 0027
///
///
import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:my_predict_plugin/my_predict_plugin.dart';
import 'dart:isolate';

/*******************************  该文件为使用my_predict_plugin的必要文件  ****************************************
 **/
/**
 * 必要方法，让推理处理在后台运行，避免在UI渲染进程由于处理量过多崩溃
 * 功能：不在UI渲染进程中推理模型，而是在后台进程进行推理模型
 * String input：处理图片在手机上的绝对路径
 */

Future<String> runInference(String ImageAbsolutePath) async {
  final receivePort = ReceivePort();
  RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
  String inferenceResult="";
  // print("1");
  Map<String, dynamic> message={'input':ImageAbsolutePath, 'sendPort':receivePort.sendPort,'rootIsolateToken':rootIsolateToken};
  //后台isolate通道
  await Isolate.spawn(_doInference,message);
  // print("3");
  final completer = Completer<void>();
  //获取isolate通道后台处理结果
  receivePort.listen((result) {
    inferenceResult=result;
    print('Isolate inference result: $result');
    completer.complete();
  });
  await completer.future;
  return inferenceResult;
}

/**
 * 注意：// isolate入口函数，该函数必须是静态的或顶级函数，不能是匿名内部函数。
 *  功能：调用 yPredictPlugin插件的推理方法，实现推理，并返回结果
 *  message={'input':ImageAbsolutePath, 'sendPort':receivePort.sendPort,'rootIsolateToken':rootIsolateToken}
 */
Future<void> _doInference(Map<String, dynamic> message) async {

  final input = message['input'];
  final sendPort = message['sendPort'];
  final rootIsolateToken = message['rootIsolateToken'];
  BackgroundIsolateBinaryMessenger
      .ensureInitialized(rootIsolateToken);
  // final _myPredictPlugin = MyPredictPlugin();
  // print(input);
  String result="";
  // print("2");
  try {
    result =
        await MyPredictPlugin.getBHid(input) ?? 'Unknown image';
  } on PlatformException {
    result = 'Failed to get class id.';
  }
  sendPort.send(result);
}

/********************************************************************************
 * **/





