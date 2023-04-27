# bchapp

病虫害检测APP，Android应用.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 项目文件目录介绍
```
├── android 
├── lib
├── my_predict_plugin     # 封装有pytroch进行模型推理的插件
│     ├── android         # 安卓的原生代码，包括pytroch的java推理代码
│     ├── assets          # 资源文件夹，安卓原生代码所需要的资源文件夹，这里放模型pt文件
│     ├── example         # my_predict_plugin插件使用的简单flutter例子
│     ├── lib             # my_predict_plugin的flutter插件的method channel调用原生Android代码的dart封装
│     │    ├── my_predict_plugin.dart
│     │    ├── my_predict_plugin_method_channel.dart
│     │    └── my_predict_plugin_platform_interface.dart   
│     ├── pubspec.yaml    # my_predict_plugin插件所需要的配置文件
│     └── ...             # 其他文件  
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


## [my_predict_plugin插件使用步骤请点击此处查看](./my_predict_plugin/README.md)





