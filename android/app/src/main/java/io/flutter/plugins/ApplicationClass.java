package com.example.ctintegration;

import com.clevertap.android.sdk.ActivityLifecycleCallback;
import com.clevertap.android.sdk.CleverTapAPI;

import io.flutter.app.FlutterApplication;


public class ApplicationClass extends FlutterApplication {
    @java.lang.Override
    public void onCreate() {
        ActivityLifecycleCallback.register(this); //<--- Must call this before super.onCreate()
        super.onCreate();
    }
}