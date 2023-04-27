# my_predict_plugin

pytorch 模型在flutter项目中推理运行插件.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## my_predict_plugin文件目录介绍
```
my_predict_plugin
 ├── android               # 安卓的原生代码，包括pytroch的java推理代码
 │    ├── src/main/java/com/example/my_predict_plugin/BHClasses.java        # 病害类别ID值 
 │    ├── src/main/java/com/example/my_predict_plugin/CHClasses.java        # 虫害类别ID值
 │    ├── src/main/java/com/example/my_predict_plugin/MyPredictPlugin.java  # pytorch_android_lite 原生Android代码推理实现
 │    └── build.gradle     # 安卓原生代码的配置文件          
 ├── assets                # 资源文件夹，安卓原生代码所需要的资源文件夹，这里放模型pt文件
 ├── example               # my_predict_plugin插件使用的简单flutter例子
 │    ├── lib              #里面是dart文件
 │    │    ├── my_isolate_interface.dart  #flutter-Isolate方式调用推理方法(使用时my_predict_plugin插件需要次文件)
 │    │    ├── image_selection_page.dart  #可根据需求修改
 │    │    └── main.dart   #可根据需求修改
 │    │── pubspec.yaml     #example项目配置文件
 │    └── ...              #其他文件
 ├── lib                   # my_predict_plugin的flutter插件的method channel调用原生Android代码的dart封装
 │    ├── my_predict_plugin.dart
 │    └── my_predict_plugin_method_channel.dart
 ├── pubspec.yaml          # my_predict_plugin插件所需要的配置文件
 └── ...                   # 其他文件    
```

## 项目技术方法
### 1. pythorch-mobile
- 使用pytroch进行害模型训练，并将保存模型转换为PyTorch Mobile所需要的模型格式(.pt格式)。
- 使用Android原生java代码对模型进行加载、推理。

### 2. flutter-Platform Channel(平台通道)
- 平台通道介绍：Platform Channel 是一个异步消息通道，消息在发送之前会编码成二进制消息，接收到的二进制消息会解码成 Dart 值，其传递的消息类型只能是对应的解编码器支持的值，所有的解编码器都支持空消息。
- 使用Platform Channel(平台通道)实现flutter的dart代码调用Android原生模型推理的java代码，实现Android原生代码与flutter代码的交互。

### 3. flutter-Isolate
- 使用 isolate 创建新线程，用于进行消耗较多资源的模型推理，避开主线程，不干扰UI刷新，避免主进程执行任务过多导致程序崩溃。

## my_predict_plugin插件使用版本要求
### 1. Flutter 3.7.11 • channel stable (其他版本未测试)
### 2. Android minSdkVersion 21
### 3. pytorch-mobile后的模型版本(model_bytecode_version)需要为-5(>=5时，需要降低其版本，否则无法进行模型推理)


## my_predict_plugin插件使用步骤
### 1. 在要使用my_predict_plugin插件的flutter项目中配置my_predict_plugin依赖。
```
dependencies:
  flutter:
    sdk: flutter
  my_predict_plugin:
    path: ./my_predict_plugin   #my_predict_plugin插件文件相对于当前pubspec.yaml文件的相对位置，此处需要根据具体项目结构进行更改
```

### 2. 在要使用的flutter项目的lib文件中创建`my_isolate_interface.dart`文件，文件内容如下。
```
import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:my_predict_plugin/my_predict_plugin.dart';
import 'dart:isolate';

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
```

### 3. 在要使用插件的dart文件中import刚刚创建的`my_isolate_interface.dart`文件，使用如下函数调用模型推理函数。
```
import 'my_isolate_interface.dart';
```
```
//_imagepath:要处理的图片相对于手机设备的绝对路径
//runInference(_imagepath)返回推理处理后对应类别的ID值
resultId=await runInference(_imagepath);
```

### 4.修改项目文件中的`/android/app/build.gradle`文件中的`minSdkVersion flutter.minSdkVersion`为`minSdkVersion 21`，因为。
(如果编译运行时报错`uses-sdk:minSdkVersion 16 cannot be smaller than version 21 declared in library [:my_predict_plugin]`时，修改`minSdkVersion flutter.minSdkVersion`为`minSdkVersion 21`。
因为`my_predict_plugin`使用到了`org.pytorch:pytorch_android_lite:1.10.0`，而`org.pytorch:pytorch_android_lite:1.10.0`的依赖要求为`minSdkVersion 21`。
```
    defaultConfig {
        applicationId "com.example.bchapp"
//        minSdkVersion flutter.minSdkVersion  //修改前
        minSdkVersion 21  //修改后
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
```


