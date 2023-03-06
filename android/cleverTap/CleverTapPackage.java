package com.yourcompany.yourapp.clevertap;

import android.app.Application;
import android.content.Context;

import com.clevertap.android.sdk.ActivityLifecycleCallback;
import com.clevertap.android.sdk.CleverTapAPI;
import com.clevertap.android.sdk.CleverTapInstanceConfig;
import com.clevertap.android.sdk.InAppNotificationButtonListener;
import com.clevertap.android.sdk.InAppNotificationListener;
import com.clevertap.android.sdk.PushNotificationListener;
import com.clevertap.android.sdk.PushType;
import com.clevertap.android.sdk.SyncListener;
import com.clevertap.android.sdk.events.EventDetail;
import com.clevertap.android.sdk.product_config.CTProductConfigListener;

import java.util.ArrayList;
import java.util.HashMap;

import io.flutter.app.FlutterApplication;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class CleverTapPackage implements MethodCallHandler
{

    private final Context context;
    private MethodChannel channel;
    private CleverTapAPI cleverTapAPI;
    private String cleverTapAccountId;
    private String cleverTapToken;
    private Boolean disableAppLaunchedEvent;
    private Boolean useCustomCleverTapId;

    public CleverTapPackage(Context context) {
        this.context = context;
    }

    public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "clevertap_plugin");
        channel.setMethodCallHandler(new CleverTapPackage(registrar.context()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result)
    {
        switch (call.method) {
            case "setDebugLevel":
                setDebugLevel(call, result);
                break;
            case "setCredentials":
                setCredentials(call, result);
                break;
            case "onUserLogin":
                onUserLogin(call, result);
                break;
            case "profileSet":
                profileSet(call, result);
                break;
            case "profileSetGraphUser":
                profileSetGraphUser(call, result);
                break;
            case "profileSetGooglePlusUser":
                profileSetGooglePlusUser(call, result);
                break;
            case "profileSetTwitterUser":
                profileSetTwitterUser(call, result);
                break;
            case "profileGetProperty":
                profileGetProperty(call, result);
                break;
            case "profileGetCleverTapAttributionIdentifier":
                profileGetCleverTapAttributionIdentifier(call, result);
                break;
            case "pushProfile":
                pushProfile(call, result);
                break;
            case "recordEvent":
                recordEvent(call, result);
                break;
            case "recordChargedEvent":
                recordChargedEvent(call, result);
                break;
            case "recordError":
                recordError(call, result);
                break
        }
    }
}