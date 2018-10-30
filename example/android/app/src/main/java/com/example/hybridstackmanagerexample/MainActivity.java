package com.example.hybridstackmanagerexample;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.taobao.hybridstackmanager.*;

import java.util.HashMap;

public class MainActivity extends FlutterWrapperActivity implements XURLRouterHandler {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    XURLRouter.sharedInstance().setAppContext(getApplicationContext());
    setupNativeOpenUrlHandler();
    super.onCreate(savedInstanceState);
    //This delay is added to make sure that it works fine even when launching from flutter.
    new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
      @Override
      public void run() {
        //Do something here
        Intent intent = new Intent();
        intent.setData(Uri.parse("hrd://fdemo"));
        checkIfOpenFlutter(intent);
      }
    }, 30);
  }

  void setupNativeOpenUrlHandler(){
    XURLRouter.sharedInstance().setNativeRouterHandler(this);
  }
  public Class openUrlWithQueryAndParams(String url, HashMap query, HashMap params){
    Uri tmpUri = Uri.parse(url);
    if("ndemo".equals(tmpUri.getHost())){
      return XDemoActivity.class;
    }
    return null;
  }
}
