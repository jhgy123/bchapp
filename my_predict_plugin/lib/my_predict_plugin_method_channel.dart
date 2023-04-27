///
/// author: jhgy
/// data: ON 2023-04-27
///
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'my_predict_plugin_platform_interface.dart';

/// An implementation of [MyPredictPluginPlatform] that uses method channels.
class MethodChannelMyPredictPlugin extends MyPredictPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('my_predict_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
  //重写病害预测方法
  @override
  Future<String?> getBHid(String imagePath) async {
    final classId = await methodChannel.invokeMethod<String>('getBHid',{'imagePath':imagePath});
    return classId;
  }

  //重写虫害预测方法
  @override
  Future<String?> getCHid(String imagePath) async {
    final classId = await methodChannel.invokeMethod<String>('getCHid',{'imagePath':imagePath});
    return classId;
  }
}
