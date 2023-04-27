/**
 * author: jhgy
 * data: ON 2023-04-27
 */
package com.example.my_predict_plugin;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.content.res.AssetManager;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Log;
import android.widget.ImageView;
import android.widget.TextView;

import org.pytorch.IValue;
import org.pytorch.LiteModuleLoader;
import org.pytorch.Module;
import org.pytorch.Tensor;
import org.pytorch.torchvision.TensorImageUtils;
import org.pytorch.MemoryFormat;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

//import android.content.res.AssetManager;

/** MyPredictPlugin */
public class MyPredictPlugin implements FlutterPlugin, MethodCallHandler{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  /** 上下文，资源管理器 **/
  private Context context;
  private AssetManager assetManager;


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "my_predict_plugin");
    channel.setMethodCallHandler(this);

    /** 获取assetManager资源管理器，用于加载模型文件和图片文件 **/
    context = flutterPluginBinding.getApplicationContext();
    assetManager = context.getAssets();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      System.out.println("-------my test code!-------");
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }
    else if(call.method.equals("getBHid")){  //获取病害方法
      /******* 病害模型文件 ******/
      String BHModelFlieName="squeezenet1_1_bh_38class_mobile.pt";

      System.out.println("BH Class number:"+BHClasses.BH_CLASSES_ID.length);
      String imagePath = call.argument("imagePath");
      System.out.println(context.getFilesDir());
      /** 调用java病害推理函数  **/
      String classId=predict(imagePath,BHModelFlieName,1);
      result.success(classId);
    }
    else if(call.method.equals("getCHid")){  //获取病害方法
      /******* 虫害害模型文件 ******/
//      String BHModelFlieName="vgg13_bh_38class_mobile.pt";
      String CHModelFlieName="";
      System.out.println("CH Class number:"+CHClasses.CH_CLASSES_ID.length);
      String imagePath = call.argument("imagePath");

      System.out.println(context.getFilesDir());
      /** 调用java虫害推理函数 **/
      String classId=predict(imagePath,CHModelFlieName,2);
      result.success(classId);
    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  /** 模型推理预测方法，
  // String imagePath 输入图片路径,
  // String modelPath 预测推理模型名称文件 .pt文件
  // Integer type 1:病害  2:虫害
   **/
  public String predict(String imagePath, String modelName, int type){
    Bitmap bitmap = null;
    Module module = null;
    try {
      /***获取imagePath文件的输入流 ***/
      InputStream inputstream = new FileInputStream(new File(imagePath));
      bitmap = BitmapFactory.decodeStream(inputstream);

      /** loading serialized torchscript module from packaged into app android asset model.pt,
      // app/src/model/assets/model.pt
       **/
      module = LiteModuleLoader.load(assetFilePath(context, modelName));
    } catch (IOException e) {
      Log.e("Pytorch", "Error reading assets", e);
    }

    /** preparing input tensor **/
    final Tensor inputTensor = TensorImageUtils.bitmapToFloat32Tensor(bitmap,
            TensorImageUtils.TORCHVISION_NORM_MEAN_RGB, TensorImageUtils.TORCHVISION_NORM_STD_RGB, MemoryFormat.CHANNELS_LAST);

    /** running the model **/
    final Tensor outputTensor = module.forward(IValue.from(inputTensor)).toTensor();

    /** getting tensor content as java array of floats **/
    final float[] scores = outputTensor.getDataAsFloatArray();

    /** searching for the index with maximum score **/
    float maxScore = -Float.MAX_VALUE;
    int maxScoreIdx = -1;
    for (int i = 0; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxScoreIdx = i;
      }
    }
    String class_id="";
    //    病害结果id值
    if(type==1){
      class_id = BHClasses.BH_CLASSES_ID[maxScoreIdx];
    }
    //    虫害结果id值
    else if(type==2){
      class_id = CHClasses.CH_CLASSES_ID[maxScoreIdx];
    }
    return class_id;
  }

  /** 获取 asset中的资源文件的绝对路径
   * @param context ：运行上下文
   * @param assetName asset中的资源文件的文件名
   * @return asset中的资源文件的绝对路径
   * @throws IOException
   */
  public static String assetFilePath(Context context, String assetName) throws IOException {
    File file = new File(context.getFilesDir(), assetName);
    if (file.exists() && file.length() > 0) {
      return file.getAbsolutePath();
    }

    try (InputStream is = context.getAssets().open(assetName)) {
      try (OutputStream os = new FileOutputStream(file)) {
        byte[] buffer = new byte[4 * 1024];
        int read;
        while ((read = is.read(buffer)) != -1) {
          os.write(buffer, 0, read);
        }
        os.flush();
      }
      return file.getAbsolutePath();
    }
  }
}
