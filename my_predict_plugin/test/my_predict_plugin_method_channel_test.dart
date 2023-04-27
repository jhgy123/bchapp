import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_predict_plugin/my_predict_plugin_method_channel.dart';

void main() {
  MethodChannelMyPredictPlugin platform = MethodChannelMyPredictPlugin();
  const MethodChannel channel = MethodChannel('my_predict_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
