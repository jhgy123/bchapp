///
/// author: jhgy
/// data: ON 2023-04-27
///
import 'my_predict_plugin_platform_interface.dart';

class MyPredictPlugin {
  static Future<String?> getPlatformVersion() {
    return MyPredictPluginPlatform.instance.getPlatformVersion();
  }
  //静态方法
  static Future<String?>  getBHid(String imagePath) {
    return MyPredictPluginPlatform.instance.getBHid(imagePath);
  }
  //静态方法
  static Future<String?> getCHid(String imagePath) {
    return MyPredictPluginPlatform.instance.getCHid(imagePath);
  }
}
