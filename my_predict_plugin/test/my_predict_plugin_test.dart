import 'package:flutter_test/flutter_test.dart';
import 'package:my_predict_plugin/my_predict_plugin.dart';
import 'package:my_predict_plugin/my_predict_plugin_platform_interface.dart';
import 'package:my_predict_plugin/my_predict_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMyPredictPluginPlatform
    with MockPlatformInterfaceMixin
    implements MyPredictPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MyPredictPluginPlatform initialPlatform = MyPredictPluginPlatform.instance;

  test('$MethodChannelMyPredictPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMyPredictPlugin>());
  });

  test('getPlatformVersion', () async {
    MyPredictPlugin myPredictPlugin = MyPredictPlugin();
    MockMyPredictPluginPlatform fakePlatform = MockMyPredictPluginPlatform();
    MyPredictPluginPlatform.instance = fakePlatform;

    expect(await myPredictPlugin.getPlatformVersion(), '42');
  });
}
