///
/// author: jhgy
/// data: ON 2023-04-27
///
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'my_isolate_interface.dart';

class ImageSelectionPage extends StatefulWidget {
  @override
  _ImageSelectionPageState createState() => _ImageSelectionPageState();
}

class _ImageSelectionPageState extends State<ImageSelectionPage> {
  ///**注意**： File 图片文件，初始时不能为空值，否则报错，因此将其初始化为一个固定文件，后期需要优化处理
  File _imageFile=File("");
  String _imagepath="";
  String _resultId="";

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        // print("###################");
        print(_imageFile.path);
        _imagepath=_imageFile.path.toString();
      } else {
        print('没有选择图片');
      }
    });
  }

  Future<String> _predictImage() async {
    if (_imageFile != null) {
      String resultId="";
      /********  该处是调用推理函数runInference才UI进程中获取结果   ******/
      resultId=await runInference(_imagepath);
      /********  *****************************************   ******/
      return resultId;
    } else {
      throw Exception('No image selected.');
      return "No image selected.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选择并推理图片'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile == null
                ? Text('没有图片')
                : Image.file(_imageFile),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _pickImage(ImageSource.gallery);
              },
              child: Text('相册'),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                _pickImage(ImageSource.camera);
              },
              child: Text('拍照'),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () async {
                  String result = await _predictImage();
                  setState(() {
                    _resultId = result;
                  });
              },
              child: Text('推理预测'),
            ),
            Text(_resultId),
          ],
        ),
      ),
    );
  }
}
