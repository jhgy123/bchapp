///
/// author: jhgy
/// data: ON 2023-04-27
///
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'my_predict_plugin_method_channel.dart';

abstract class MyPredictPluginPlatform extends PlatformInterface {
  /// Constructs a MyPredictPluginPlatform.
  MyPredictPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static MyPredictPluginPlatform _instance = MethodChannelMyPredictPlugin();

  /// The default instance of [MyPredictPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelMyPredictPlugin].
  static MyPredictPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MyPredictPluginPlatform] when
  /// they register themselves.
  static set instance(MyPredictPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// 病害预测抽象方法
  Future<String?> getBHid(String imagePath) {
    throw UnimplementedError('getBHid() has not been implemented.');
  }

  /// 虫害预测抽象方法
  Future<String?> getCHid(String imagePath) {
    throw UnimplementedError('getCHid() has not been implemented.');
  }
}
