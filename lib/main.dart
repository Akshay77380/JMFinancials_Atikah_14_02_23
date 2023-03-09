import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:alice/alice.dart';
import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
//
// // import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:markets/database/watchlist_database.dart';
import 'package:markets/util/Utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// import '../../../screens/onboarding_page_one.dart';
// import '../screens/ssl_pinning.dart';
import 'package:path/path.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trust_fall/trust_fall.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'Connection/EOD/EODClient.dart';
import 'database/database_helper.dart';
import 'util/CommonFunctions.dart';
import 'Connection/IQS/IQSClient.dart';
import 'Connection/News/NewsClient.dart';
import 'Connection/structHelper/BufferForSock.dart';
import 'database/news_database.dart';
import 'screens/splash_screen.dart';
import 'style/theme.dart';
import 'util/BrokerInfo.dart';
import 'util/Dataconstants.dart';
import 'util/InAppSelections.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
// import 'package:ssl_pinning_plugin/ssl_pinning_plugin.dart';
// AndroidNotificationChannel channel;
/// Initialize the [FlutterLocalNotificationsPlugin] package.
// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
void main() async
{

  WidgetsFlutterBinding.ensureInitialized();
  // await CleverTapPlugin.initializeInbox();
  HttpOverrides.global = MyHttpOverrides();
  BrokerInfo.setClientInfo(Broker.icici);
  Dataconstants.iqsClient = IQSClient();
  IQSClient.iqsBuff = BufferForSock(1024);
  final databasePath = join(await getDatabasesPath(), "masters.mf");
  final masterExists = await File(databasePath).exists();
  Dataconstants.eodClient = EODClient(masterExists);
  Dataconstants.masterExists = masterExists;
  EODClient.eodBuff = BufferForSock(1024);
  Dataconstants.newsClient = NewsClient();
  NewsClient.newsBuff = BufferForSock(2048);

  InAppSelection.fetchSelections();
  initPlatformState();
  NewsDatabase.instance.initDB();

  // ConnectionStatusSingleton connectionStatus =
  //     ConnectionStatusSingleton.getInstance();
  // connectionStatus.initialize();

  // WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));

  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }
  // channel = const AndroidNotificationChannel(
  //   'high_importance_channel', // id
  //   'High Importance Notifications', // title
  //   importance: Importance.high,
  // );
  //
  // flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // Dataconstants.flutterLocalNotificationsPlugin =
  //     flutterLocalNotificationsPlugin;
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );

  // var initializationSettingsAndroid =
  //     AndroidInitializationSettings('mipmap/ic_launcher');
  // var initializationSettingsIOS = IOSInitializationSettings();
  // var initializationSettings = InitializationSettings(
  //     android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  void sendProgressResponse(double value) {
    // mResponseListener.onResponseReceieved((value).toString(), 999);
  }
  if (masterExists)
    var result = DatabaseHelper.getAllScripDetailFromMemory(
      sendProgressResponse,
      true,
    );
  // Dataconstants.alice = Alice(
  //   showNotification: true,
  //   showInspectorOnShake: true,
  //   darkTheme: false,
  //   maxCallsCount: 1000,
  // );
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    // print('runZonedGuarded: Caught error in my root zone. ');
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}
Future<void> initPlatformState() async {
  String deviceId;
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    Dataconstants.feUserDeviceID = await PlatformDeviceId.getDeviceId;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      Dataconstants.deviceName = iosInfo.name;
      Dataconstants.osName = iosInfo.systemVersion;
      Dataconstants.devicemodel = iosInfo.model;
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print("${androidInfo.brand}");
      Dataconstants.deviceName = androidInfo.brand.replaceAll(' ', '');
      Dataconstants.osName = 'Android${androidInfo.version.release}';
      Dataconstants.devicemodel = androidInfo.model;
    }
  } on PlatformException {
    deviceId = 'Failed to get deviceId.';
  }
  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  // setState to update our non-existent appearance.
  // if (!mounted) return;
}
Future<String> downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final Response response = await get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   Dataconstants.flutterLocalNotificationsPlugin =
//       flutterLocalNotificationsPlugin;
//
//   // print('Handling a background message $message');
//
//   var initializationSettingsAndroid =
//       AndroidInitializationSettings('mipmap/ic_launcher');
//   var initializationSettingsIOS = IOSInitializationSettings();
//   var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//
//   // print('Handling a background message ${message.messageId}');
//   RemoteNotification notification = message.notification;
//   AndroidNotification android = message.notification?.android;
//
//   if (notification != null && android != null) {
//     flutterLocalNotificationsPlugin.show(
//       notification.hashCode,
//       notification.title,
//       notification.body,
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           channel.id,
//           channel.name,
//           // channel.description,
//           // TODO add a proper drawable resource to android, for now using
//           //      one that already exists in example app.
//           icon: 'launch_background',
//         ),
//       ),
//     );
//   }
//   return;
// }
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var appId = '';
  String mysource, mymedium, mycampaign;
  CleverTapPlugin _clevertapPlugin;
  var inboxInitialized = false;
  var optOut = false;
  var offLine = false;
  var enableDeviceNetworkingInfo = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  AndroidInitializationSettings initializationSettingsAndroid;
  // IOSInitializationSettings initializationSettingsIOS =
  // IOSInitializationSettings();
  InitializationSettings initializationSettings;

  // CleverTapPlugin _clevertapPlugin;
  // var inboxInitialized = false;
  // var optOut = false;
  // var offLine = false;
  // var enableDeviceNetworkingInfo = false;


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        {
          Dataconstants.iqsClient.sendIqsReconnectWithCallback;
          Dataconstants.fToast.init(Dataconstants.navigatorKey.currentContext);
          // checkDeepLink();
          // CommonFunction.reconnect();
          // if (Dataconstants.lastClicked == "My Watchlist") {
          //   Dataconstants.iqsClient.sendBulkLTPRequest(Dataconstants.marketWatchListeners[InAppSelection.marketWatchID].watchList, true);
          // } else if (Dataconstants.lastClicked == "Predefined") {
          //   Dataconstants.iqsClient.sendBulkLTPRequest(Dataconstants.predefinedMarketWatchListener.watchList, true);
          // } else if (Dataconstants.lastClicked == "Indices") {
          //   Dataconstants.iqsClient.sendBulkLTPRequest(Dataconstants.indicesMarketWatchListener.watchList, true);
          // } else if (Dataconstants.lastClicked == "Summary") {
          //   Dataconstants.iqsClient.requestForMarketSummary(
          //     Dataconstants.exchData[Dataconstants.summaryMarketWatchListener.summaryExchPos].exch,
          //     Dataconstants.exchData[Dataconstants.summaryMarketWatchListener.summaryExchPos].exchTypeShort,
          //     Dataconstants.summaryMarketWatchListener.selectedFilter,
          //   );
          // }
          // CommonFunction.reconnect();
        }
        break;
      case AppLifecycleState.inactive:
        break;
        break;
      case AppLifecycleState.paused:
        if (Dataconstants.itsClient.isLoggedIn) {
          //   DataConstants.itsClient.stopHandshakeTimer();

          // Dataconstants.iqsClient.stopIqsTimer();
        }
        Dataconstants.fToast.removeCustomToast();
        Fluttertoast.cancel();
        InAppSelection.saveSelections();
        CommonFunction.saveRecentSearchData();
        break;
      case AppLifecycleState.detached:
        break;
      //   print("app in detached");
      //   break;
    }
  }

  // checkDeepLink() async {
  //   await initDynamicLinksn();
  // }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;
  }
  @override
  void initState()
  {
    super.initState();
    initPlatformState();
    activateCleverTapFlutterPluginHandlers();
    CleverTapPlugin.setDebugLevel(3);
    CleverTapPlugin.createNotificationChannel(
        "fluttertest", "Flutter Test", "Flutter Test", 3, true);
    CleverTapPlugin.initializeInbox();
    CleverTapPlugin.registerForPush();
    initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/notiicon');
    initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    WidgetsBinding.instance.addObserver(this);
    getMessage();
    // getuuid(); //TODO: 21/12
    // initDynamicLinksn();
    // // CommonFunction.checkInternet();
    // initReferrerDetails();
    // initAppsFlyer(); //TODO: 21/12

    // WatchlistDatabase.instance.initDB(); //TODO: 21/12

    // FirebaseMessaging.instance
    //     .getInitialMessage()
    //     .then((RemoteMessage message) {
    //   if (message != null) {}
    // });
    //
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification notification = message.notification;
    //   AndroidNotification android = message.notification?.android;
    //
    //   // print("Handling a background message 123: ${message.data}");
    //   //
    //   // if (message.data.containsKey('_App42CampaignName')) {
    //   //
    //   //   try {
    //   //     final mediaObj = jsonDecode(message.data['_app42RichPush']);
    //   //
    //   //     if (mediaObj['type'] == 'image') {
    //   //       CommonFunction.showBigPictureNotificationURL(message.data);
    //   //     } else {
    //   //       CommonFunction.sherptzShowNotification(message.data);
    //   //     }
    //   //   } catch (e, s) {
    //   //     // print(e);
    //   //     CommonFunction.sherptzShowNotification(message.data);
    //   //   }
    //   // }
    //   // else
    //   // {
    //   if (notification != null && android != null) {
    //     flutterLocalNotificationsPlugin.show(
    //       notification.hashCode,
    //       notification.title,
    //       notification.body,
    //       NotificationDetails(
    //         android: AndroidNotificationDetails(
    //           channel.id,
    //           channel.name,
    //           icon: 'launch_background',
    //         ),
    //       ),
    //     );
    //   }
    //   return;
    //   // }
    // });
    //
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    //   // print('A new onMessageOpenedApp event was published!');
    //   RemoteNotification notification = message.notification;
    //
    //   SharedPreferences sharedPreferences =
    //       await SharedPreferences.getInstance();
    //   var storeduuid = sharedPreferences.getString('uuid');
    //   var systemCustId = sharedPreferences.getString('systemCustId');
    //   var appInstanceId = sharedPreferences.getString('appInstanceId');
    //
    //   var parameters = {
    //     'message_title_manual': notification.title,
    //     'message_body_manual': notification.body,
    //     'tvc_client_id': storeduuid ?? "",
    //     'Cust_ID': systemCustId ?? '',
    //     'app_id': appInstanceId ?? ''
    //   };
    //   FirebaseAnalytics.instance
    //       .logEvent(name: 'manual_notification_open', parameters: parameters);
    // });


  }

  // initAppsFlyer() async {
  //   AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
  //       afDevKey: "Tsa4VgpsYjrxSCswsHZqvm",
  //       appId: Platform.isAndroid ? "com.icicidirect.markets" : "1570800408",
  //       showDebug: true,
  //       timeToWaitForATTUserAuthorization: 50,
  //       appInviteOneLink: "",
  //       disableAdvertisingIdentifier: false,
  //       disableCollectASA: false);
  //
  //   InAppSelection.appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
  //
  //   InAppSelection.appsflyerSdk.initSdk(registerConversionDataCallback: true, registerOnAppOpenAttributionCallback: true, registerOnDeepLinkingCallback: true);
  //
  //   InAppSelection.appsFlyerId = await InAppSelection.appsflyerSdk.getAppsFlyerUID();
  // }

  // void getuuid() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   var storeduuid = sharedPreferences.getString('uuid');
  //   if (storeduuid != null) {
  //     Dataconstants.uuid = storeduuid;
  //     return;
  //   }
  //   var uuid = Uuid();
  //   var tvcClientId = uuid.v4();
  //   Dataconstants.uuid = tvcClientId;
  //   sharedPreferences.setString('uuid', tvcClientId);
  // }

  // void initDynamicLinksn() async {
  //   //
  //   final PendingDynamicLinkData data =
  //       await FirebaseDynamicLinks.instance.getInitialLink();
  //   final Uri deepLink = data?.link;
  //   // FirebaseDynamicLinks.instance.onLink(onSuccess: (dynamicLink) async {
  //   //   final Uri deepLink = dynamicLink?.link;
  //   //   InAppSelection.deeplink = deepLink.path;
  //   //   print("deep link =>  ${InAppSelection.deeplink}");
  //   //
  //   //
  //   //   if (deepLink != null) {
  //   //     final Uri deepLink = dynamicLink?.link;
  //   //
  //   //     if (deepLink != null) {
  //   //       final queryParams = deepLink.queryParameters;
  //   //       mysource = queryParams['utm_source'];
  //   //       mymedium = queryParams['utm_medium'];
  //   //       mycampaign = queryParams['utm_campaign'];
  //   //     }
  //   //   }
  //   //   _handleDynamicLink(dynamicLink);
  //   // });
  // }
  //
  // // void initDynamicLinksn() async {
  // //   final PendingDynamicLinkData data =
  // //       await FirebaseDynamicLinks.instance.getInitialLink();
  // //   final Uri deepLink = data?.link;
  // //   FirebaseDynamicLinks.instance.onLink(onSuccess: (dynamicLink) async {
  // //     final Uri deepLink = dynamicLink?.link;
  // //
  // //     if (deepLink != null) {
  // //       final Uri deepLink = dynamicLink?.link;
  // //
  // //       if (deepLink != null) {
  // //         final queryParams = deepLink.queryParameters;
  // //         mysource = queryParams['utm_source'];
  // //         mymedium = queryParams['utm_medium'];
  // //         mycampaign = queryParams['utm_campaign'];
  // //       }
  // //     }
  // //     var link =
  // //         "https://secure.icicidirect.com/accountopening?utm_source=mktapp-$mysource&utm_medium=mktapp-$mymedium&cid=${Dataconstants.uuid}&av=${Dataconstants.fileVersion}&aid=com.icicidirect.markets&dimension%2017=MarketApp&app_id=${Dataconstants.appInstanceId}&rmcode=111111";
  // //
  // //     if (await canLaunchUrl(Uri.parse(link))) launchUrl(Uri.parse(link));
  // //     _handleDynamicLink(dynamicLink);
  // //   });
  // // }
  //
  // initReferrerDetails() async {
  //   String referrerDetailsString;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     String token = await FirebaseMessaging.instance.getToken();
  //
  //     Dataconstants.fcmToken = token;
  //
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     var utmTerm;
  //     var utmContent;
  //     var utmCampaign;
  //     ReferrerDetails referrerDetails =
  //         await AndroidPlayInstallReferrer.installReferrer;
  //     referrerDetailsString = referrerDetails.toString();
  //
  //     var utm = referrerDetails.installReferrer.split("&");
  //     Dataconstants.utmMedium = utm[1].split("=")[1];
  //     prefs.setString('utm_medium', Dataconstants.utmMedium);
  //     Dataconstants.utmSource = utm[0].split("=")[1];
  //     prefs.setString('utm_source', Dataconstants.utmSource);
  //     if (utm.length > 2) {
  //       Dataconstants.utmTerm = utm[2].split("=")[1];
  //       prefs.setString('utm_term', Dataconstants.utmTerm);
  //       Dataconstants.utmContent = utm[3].split("=")[1];
  //       prefs.setString('utm_content', Dataconstants.utmContent);
  //       Dataconstants.utmCampaign = utm[4].split("=")[1];
  //       prefs.setString('utm_campaign', Dataconstants.utmCampaign);
  //     }
  //     var parameters = {
  //       'eventCategory': 'campaign tracking',
  //       'eventAction': 'Install campaign tracking',
  //       'utm_source': Dataconstants.utmSource,
  //       'utm_medium': Dataconstants.utmMedium,
  //       'referrerDetails': referrerDetailsString,
  //       'app_id': appId
  //     };
  //     if (utm.length > 2) {
  //       parameters.addAll({
  //         'utm_term': Dataconstants.utmTerm,
  //         'utm_content': Dataconstants.utmContent,
  //         'utm_campaign': Dataconstants.utmCampaign,
  //       });
  //     }
  //     // print("this is utm parameters => $parameters");
  //     FirebaseAnalytics.instance
  //         .logEvent(name: 'tvc_campaign', parameters: parameters);
  //   } catch (e) {
  //     referrerDetailsString = 'Failed to get referrer details: $e';
  //     // print("error $referrerDetailsString");
  //     // print("tvc error encountered");
  //   }
  //   if (!mounted) return;
  //   setState(() {
  //     // _referrerDetails = referrerDetailsString;
  //   });
  // }

  // void initializeFlutterFire() async {
  //   try {
  //     // Wait for Firebase to initialize and set `_initialized` state to true
  //     await Firebase.initializeApp();
  //     if (_kTestingCrashlytics) {
  //       // Force enable crashlytics collection enabled if we're testing it.
  //       await FirebaseCrashlytics.instance
  //           .setCrashlyticsCollectionEnabled(true);
  //     } else {
  //       // Else only enable it in non-debug builds.
  //       // You could additionally extend this to allow users to opt-in.
  //       await FirebaseCrashlytics.instance
  //           .setCrashlyticsCollectionEnabled(!kDebugMode);
  //     }
  //
  //     FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  //     Isolate.current.addErrorListener(RawReceivePort((pair) async {
  //       final List<dynamic> errorAndStacktrace = pair;
  //       await FirebaseCrashlytics.instance.recordError(
  //         errorAndStacktrace.first,
  //         errorAndStacktrace.last,
  //       );
  //     }).sendPort);
  //     setState(() {
  //       _initialized = true;
  //     });
  //     DataConstants.firebaseMessaging.subscribeToTopic('Broadcast');
  //   } catch (e) {
  //     // Set `_error` state to true if Firebase initialization fails
  //     setState(() {
  //       _error = true;
  //     });
  //   }
  // }

  void activateCleverTapFlutterPluginHandlers()
  {
    _clevertapPlugin = new CleverTapPlugin();
    _clevertapPlugin
        .setCleverTapPushAmpPayloadReceivedHandler(pushAmpPayloadReceived);
    _clevertapPlugin.setCleverTapPushClickedPayloadReceivedHandler(
        pushClickedPayloadReceived);
    _clevertapPlugin.setCleverTapInAppNotificationDismissedHandler(
        inAppNotificationDismissed);
    _clevertapPlugin.setCleverTapInAppNotificationShowHandler(
        inAppNotificationShow);
    _clevertapPlugin
        .setCleverTapProfileDidInitializeHandler(profileDidInitialize);
    _clevertapPlugin.setCleverTapProfileSyncHandler(profileDidUpdate);
    _clevertapPlugin.setCleverTapInboxDidInitializeHandler(inboxDidInitialize);
    _clevertapPlugin
        .setCleverTapInboxMessagesDidUpdateHandler(inboxMessagesDidUpdate);
    _clevertapPlugin
        .setCleverTapDisplayUnitsLoadedHandler(onDisplayUnitsLoaded);
    _clevertapPlugin.setCleverTapInAppNotificationButtonClickedHandler(
        inAppNotificationButtonClicked);
    _clevertapPlugin.setCleverTapInboxNotificationButtonClickedHandler(
        inboxNotificationButtonClicked);
    _clevertapPlugin.setCleverTapInboxNotificationMessageClickedHandler(
        inboxNotificationMessageClicked);
    _clevertapPlugin.setCleverTapFeatureFlagUpdatedHandler(featureFlagsUpdated);
    _clevertapPlugin
        .setCleverTapProductConfigInitializedHandler(productConfigInitialized);
    _clevertapPlugin
        .setCleverTapProductConfigFetchedHandler(productConfigFetched);
    _clevertapPlugin
        .setCleverTapProductConfigActivatedHandler(productConfigActivated);
    _clevertapPlugin.setCleverTapPushPermissionResponseReceivedHandler(pushPermissionResponseReceived);
  }

  void inAppNotificationDismissed(Map<String, dynamic> map) {
    this.setState(() {
      print("inAppNotificationDismissed called");
    });
  }

  void inAppNotificationShow(Map<String, dynamic> map) {
    this.setState(() {
      print("inAppNotificationShow called = ${map.toString()}");
    });
  }

  void inAppNotificationButtonClicked(Map<String, dynamic> map) {
    this.setState(() {
      print("inAppNotificationButtonClicked called = ${map.toString()}");
    });
  }

  void inboxNotificationButtonClicked(Map<String, dynamic> map) {
    this.setState(() {
      print("inboxNotificationButtonClicked called = ${map.toString()}");
    });
  }

  void inboxNotificationMessageClicked(Map<String, dynamic> map) {
    this.setState(() {
      print("inboxNotificationMessageClicked called = ${map.toString()}");
    });
  }

  void profileDidInitialize() {
    this.setState(() {
      print("profileDidInitialize called");
    });
  }

  void profileDidUpdate(Map<String, dynamic> map) {
    this.setState(() {
      print("profileDidUpdate called");
    });
  }

  void inboxDidInitialize() {
    this.setState(() {
      print("inboxDidInitialize called");
      inboxInitialized = true;
    });
  }

  void inboxMessagesDidUpdate()
  {
    this.setState(() async {
      print("inboxMessagesDidUpdate called");
      int unread = await CleverTapPlugin.getInboxMessageUnreadCount();
      int total = await CleverTapPlugin.getInboxMessageCount();
      print("Unread count = " + unread.toString());
      print("Total count = " + total.toString());
    });
  }

  void onDisplayUnitsLoaded(List<dynamic> displayUnits) {
    this.setState(() async {
      List displayUnits = await CleverTapPlugin.getAllDisplayUnits();
      print("Display Units = " + displayUnits.toString());
    });
  }

  void featureFlagsUpdated() {
    print("Feature Flags Updated");
    this.setState(() async {
      bool booleanVar = await CleverTapPlugin.getFeatureFlag("BoolKey", false);
      print("Feature flag = " + booleanVar.toString());
    });
  }

  void productConfigInitialized() {
    print("Product Config Initialized");
    this.setState(() async {
      await CleverTapPlugin.fetch();
    });
  }

  void productConfigFetched() {
    print("Product Config Fetched");
    this.setState(() async {
      await CleverTapPlugin.activate();
    });
  }

  void productConfigActivated() {
    print("Product Config Activated");
    this.setState(() async {
      String stringvar =
      await CleverTapPlugin.getProductConfigString("StringKey");
      print("PC String = " + stringvar.toString());
      int intvar = await CleverTapPlugin.getProductConfigLong("IntKey");
      print("PC int = " + intvar.toString());
      double doublevar =
      await CleverTapPlugin.getProductConfigDouble("DoubleKey");
      print("PC double = " + doublevar.toString());
    });
  }

  void pushAmpPayloadReceived(Map<String, dynamic> map) {
    print("pushAmpPayloadReceived called");
    this.setState(() async {
      var data = jsonEncode(map);
      print("Push Amp Payload = " + data.toString());
      CleverTapPlugin.createNotification(data);
    });
  }

  void pushClickedPayloadReceived(Map<String, dynamic> map) {
    print("pushClickedPayloadReceived called");
    this.setState(() async {
      var data = jsonEncode(map);
      print("on Push Click Payload = " + data.toString());
    });
  }

  void pushPermissionResponseReceived(bool accepted) {
    print("Push Permission response called ---> accepted = " +
        (accepted ? "true" : "false"));
  }
  void getMessage() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // await flutterLocalNotificationsPlugin.show(
      //   messageId++,
      //   message.notification.title,
      //   message.notification.body,
      //   platformChannelSpecifics,
      // );
      flutterLocalNotificationsPlugin.show(
          message.hashCode,
          null,
          message.data[4],
          // NotificationDetails(
          //   android: AndroidNotificationDetails(
          //     channel.id,
          //     channel.name,
          //     enableLights: true,
          //     color: Colors.transparent,
          //     icon: 'mipmap/ic_launcher',
          //   ),
          // ),

          const NotificationDetails(
              android : AndroidNotificationDetails(
                  'high_importance_channel',
                  'High Importance Notifications',
                  channelDescription:  'This channel is used for important notifications.',
                  importance: Importance.max,
                  priority: Priority.high,
                  icon: '@mipmap/notiicon',
                  enableLights: true,
                  color: Color(0xffff5c34),
                  showWhen: false)
          )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => MaterialApp(
        builder: (BuildContext context, Widget child) {
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(textScaleFactor: 1.0),
            child: child,
          );
        },
        title: BrokerInfo.appName,
        navigatorKey: Dataconstants.navigatorKey,
        theme: ThemeData.light().copyWith(
            textTheme: GoogleFonts.beVietnamProTextTheme(
              Theme.of(context).textTheme,
            ),
            primaryColor: Utils.primaryColor,
            accentColor: Colors.white,
            indicatorColor: const Color(0xFF4A4A4A),
            scaffoldBackgroundColor: Colors.white,
            cardColor: const Color(0xFFF2F4F7),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFFF2F4F7),
              selectedItemColor: Utils.primaryColor,
            ),
            // cursorColor: Utils.primaryColor,
            // textSelectionColor: Utils.primaryColor.withOpacity(0.5),
            // textSelectionHandleColor: Utils.primaryColor,
            bottomAppBarTheme: const BottomAppBarTheme(
              color: Color(0xFFF2F4F7),
              elevation: 5,
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Utils.primaryColor,
              selectionColor: Utils.primaryColor.withOpacity(0.5),
              selectionHandleColor: Utils.primaryColor,
            ),
            // useTextSelectionTheme: true,
            toggleableActiveColor: Utils.primaryColor,
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: Utils.primaryColor,
            ),
            appBarTheme: const AppBarTheme(
              color: Color(0xFFF2F4F7),
              iconTheme: IconThemeData(
                color: Colors.black, //change your color here
              ),
            ),
            brightness: Brightness.light,
            colorScheme: const ColorScheme(
                primary: Color(0xFFd4d8dd),
                primaryVariant: Utils.primaryColor,
                secondary: Utils.primaryColor,
                secondaryVariant: Utils.primaryColor,
                surface: Utils.primaryColor,
                background: Utils.primaryColor,
                error: Utils.primaryColor,
                onPrimary: Utils.primaryColor,
                onSecondary: Color(0xFFF2F4F7),
                onSurface: Utils.primaryColor,
                onBackground: Utils.primaryColor,
                onError: Utils.primaryColor,
                brightness: Brightness.dark)),

        darkTheme: ThemeConstants.amoledThemeMode.value
            ? ThemeData.dark().copyWith(
                textTheme: GoogleFonts.beVietnamProTextTheme(
                  Theme.of(context).textTheme,
                ).apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                ),
                canvasColor: const Color(0xFF13161A),
                primaryColor: Utils.primaryColor,
                accentColor: const Color(0xFF13161A),
                indicatorColor: const Color(0xFFF1F1F1),
                scaffoldBackgroundColor: const Color(0xFF000000),
                cardColor: const Color(0xFF13161A),
                dialogBackgroundColor: const Color(0xFF13161A),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Color(0xFF000000),
                  selectedItemColor: Utils.primaryColor,
                ),
                // cursorColor: Utils.primaryColor,
                // textSelectionColor: Utils.primaryColor.withOpacity(0.5),
                // textSelectionHandleColor: Utils.primaryColor,
                toggleableActiveColor: Utils.primaryColor,
                bottomAppBarTheme: const BottomAppBarTheme(
                  color: Color(0xFF0C1011),
                  elevation: 5,
                ),
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: Utils.primaryColor,
                  selectionColor: Utils.primaryColor.withOpacity(0.5),
                  selectionHandleColor: Utils.primaryColor,
                ),
                // useTextSelectionTheme: true,
                appBarTheme: const AppBarTheme(
                  brightness: Brightness.dark,
                  color: Color(0xFF000000),
                  iconTheme: IconThemeData(
                    color: Colors.white, //change your color here
                  ),
                ),
                snackBarTheme: const SnackBarThemeData(
                  backgroundColor: Utils.primaryColor,
                ),
                brightness: Brightness.dark,
                colorScheme: const ColorScheme(
                    primary: Color(0xFF2E4052),
                    primaryVariant: Utils.primaryColor,
                    secondary: Utils.primaryColor,
                    secondaryVariant: Utils.primaryColor,
                    surface: Utils.primaryColor,
                    background: Utils.primaryColor,
                    error: Utils.primaryColor,
                    onPrimary: Utils.primaryColor,
                    onSecondary: Color(0xFF2E4052),
                    onSurface: Utils.primaryColor,
                    onBackground: Utils.primaryColor,
                    onError: Utils.primaryColor,
                    brightness: Brightness.dark),
              )
            : ThemeData.dark().copyWith(
                textTheme: GoogleFonts.beVietnamProTextTheme(
                  Theme.of(context).textTheme,
                ).apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                ),
                canvasColor: const Color(0xFF1E2230),
                primaryColor: Utils.primaryColor,
                accentColor: const Color(0xFF2E4052),
                indicatorColor: const Color(0xFFF1F1F1),
                scaffoldBackgroundColor: const Color(0xFF0B0F1C),
                cardColor: const Color(0xFF1E2230),
                dialogBackgroundColor: const Color(0xFF1E2230),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Color(0xFF1E2230),
                  selectedItemColor: Utils.primaryColor,
                ),
                // cursorColor: Utils.primaryColor,
                // textSelectionColor: Utils.primaryColor.withOpacity(0.5),
                // textSelectionHandleColor: Utils.primaryColor,
                bottomAppBarTheme: const BottomAppBarTheme(
                  color: Color(0xFF1E2230),
                  elevation: 5,
                ),
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: Utils.primaryColor,
                  selectionColor: Utils.primaryColor.withOpacity(0.5),
                  selectionHandleColor: Utils.primaryColor,
                ),
                // useTextSelectionTheme: true,
                toggleableActiveColor: Utils.primaryColor,
                appBarTheme: const AppBarTheme(
                  brightness: Brightness.dark,
                  color: Color(0xFF1E2230),
                  iconTheme: IconThemeData(
                    color: Colors.white, //change your color here
                  ),
                ),
                snackBarTheme: const SnackBarThemeData(
                  backgroundColor: Utils.primaryColor,
                ),
                brightness: Brightness.dark,
                colorScheme: const ColorScheme(
                    primary: Color(0xFF2E4052),
                    primaryVariant: Utils.primaryColor,
                    secondary: Utils.primaryColor,
                    secondaryVariant: Utils.primaryColor,
                    surface: Utils.primaryColor,
                    background: Utils.primaryColor,
                    error: Utils.primaryColor,
                    onPrimary: Utils.primaryColor,
                    onSecondary: Color(0xFF2E4052),
                    onSurface: Utils.primaryColor,
                    onBackground: Utils.primaryColor,
                    onError: Utils.primaryColor,
                    brightness: Brightness.dark),
              ),
        themeMode: ThemeConstants.themeMode.value,
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
  void sendBasicPush() {
    var eventData = {
      // Key:    Value
      'first': 'partridge',
      'second': 'turtledoves'
    };
    CleverTapPlugin.recordEvent("Send Basic Push", eventData);
  }

  void sendAutoCarouselPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Carousel Push", eventData);
  }

  void sendManualCarouselPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Manual Carousel Push", eventData);
  }

  void sendFilmStripCarouselPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Filmstrip Carousel Push", eventData);
  }

  void sendRatingCarouselPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Rating Push", eventData);
  }

  void sendProductDisplayPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Product Display Notification", eventData);
  }

  void sendLinearProductDisplayPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Linear Product Display Push", eventData);
  }

  void sendCTAPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send CTA Notification", eventData);
  }

  void sendZeroBezelPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Zero Bezel Notification", eventData);
  }

  void sendZeroBezelTextOnlyPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent(
        "Send Zero Bezel Text Only Notification", eventData);
  }

  void sendTimerPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Timer Notification", eventData);
  }

  void sendInputBoxPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Input Box Notification", eventData);
  }

  void sendInputBoxReplyEventPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent(
        "Send Input Box Reply with Event Notification", eventData);
  }

  void sendInputBoxReplyAutoOpenPush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent(
        "Send Input Box Reply with Auto Open Notification", eventData);
  }

  void sendInputBoxRemindDOCFalsePush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent(
        "Send Input Box Remind Notification DOC FALSE", eventData);
  }

  void sendInputBoxCTADOCTruePush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Input Box CTA DOC true", eventData);
  }

  void sendInputBoxCTADOCFalsePush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Input Box CTA DOC false", eventData);
  }

  void sendInputBoxReminderDOCTruePush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Input Box Reminder DOC true", eventData);
  }

  void sendInputBoxReminderDOCFalsePush() {
    var eventData = {
      // Key:    Value
      '': ''
    };
    CleverTapPlugin.recordEvent("Send Input Box Reminder DOC false", eventData);
  }

  void setPushTokenFCM() {
    CleverTapPlugin.setPushToken("token_fcm");
  }

  void setPushTokenXPS() {
    CleverTapPlugin.setXiaomiPushToken("token_xps", "Europe");
  }

  void setPushTokenHMS() {
    CleverTapPlugin.setHuaweiPushToken("token_fcm");
  }

  void recordEvent() {
    var now = new DateTime.now();
    var eventData = {
      // Key:    Value
      'first': 'partridge',
      'second': 'turtledoves',
      'date': CleverTapPlugin.getCleverTapDate(now),
      'number': 1
    };
    CleverTapPlugin.recordEvent("Flutter Event", eventData);
    showToast("Raised event - Flutter Event");
  }

  void recordNotificationClickedEvent() {
    var eventData = {
      /// Key:    Value
      'nm': 'Notification message',
      'nt': 'Notification title',
      'wzrk_id': '0_0',
      'wzrk_cid': 'Notification Channel ID'

      ///other CleverTap Push Payload Key Values found in Step 3 of
      ///https://developer.clevertap.com/docs/android#section-custom-android-push-notifications-handling
    };
    CleverTapPlugin.pushNotificationClickedEvent(eventData);
    showToast("Raised event - Notification Clicked");
  }

  void recordNotificationViewedEvent() {
    var eventData = {
      /// Key:    Value
      'nm': 'Notification message',
      'nt': 'Notification title',
      'wzrk_id': '0_0',
      'wzrk_cid': 'Notification Channel ID'

      ///other CleverTap Push Payload Key Values found in Step 3 of
      ///https://developer.clevertap.com/docs/android#section-custom-android-push-notifications-handling
    };
    CleverTapPlugin.pushNotificationViewedEvent(eventData);
    showToast("Raised event - Notification Viewed");
  }

  void recordChargedEvent() {
    var item1 = {
      // Key:    Value
      'name': 'thing1',
      'amount': '100'
    };
    var item2 = {
      // Key:    Value
      'name': 'thing2',
      'amount': '100'
    };
    var items = [item1, item2];
    var chargeDetails = {
      // Key:    Value
      'total': '200',
      'payment': 'cash'
    };
    CleverTapPlugin.recordChargedEvent(chargeDetails, items);
    showToast("Raised event - Charged");
  }

  void recordUser() {
    var stuff = ["bags", "shoes"];
    var profile = {
      'Name': 'sarvesh',
      'Identity': '100',
      'DOB': '22-04-2000',

      ///Key always has to be "DOB" and format should always be dd-MM-yyyy
      'Email': 'sarveshgk10@gmail.com',
      'Phone': '14155551234',
      'props': 'property1',
      'stuff': stuff
    };
    CleverTapPlugin.profileSet(profile);
    showToast("Pushed profile " + profile.toString());
  }

  void showInbox() {
    if (inboxInitialized) {
      showToast("Opening App Inbox", onDismiss: () {
        var styleConfig = {
          'noMessageTextColor': '#ff6600',
          'noMessageText': 'No message(s) to show.',
          'navBarTitle': 'App Inbox',
          'navBarTitleColor': '#101727',
          'navBarColor': '#EF4444'
        };
        CleverTapPlugin.showInbox(styleConfig);
      });
    }
  }

  void showInboxWithTabs() {
    if (inboxInitialized) {
      showToast("Opening App Inbox", onDismiss: () {
        var styleConfig = {
          'noMessageTextColor': '#ff6600',
          'noMessageText': 'No message(s) to show.',
          'navBarTitle': 'App Inbox',
          'navBarTitleColor': '#101727',
          'navBarColor': '#EF4444',
          'tabs': ["promos", "offers"]
        };
        CleverTapPlugin.showInbox(styleConfig);
      });
    }
  }

  void getAllInboxMessages() async {
    List messages = await CleverTapPlugin.getAllInboxMessages();
    showToast("See all inbox messages in console");
    print("Inbox Messages = " + messages.toString());
  }

  void getUnreadInboxMessages() async {
    List messages = await CleverTapPlugin.getUnreadInboxMessages();
    showToast("See unread inbox messages in console");
    print("Unread Inbox Messages = " + messages.toString());
  }

  void getInboxMessageForId() async {
    var messageId = await getFirstInboxMessageId();

    if (messageId == null) {
      setState((() {
        showToast("Inbox Message id is null");
        print("Inbox Message id is null");
      }));
      return;
    }

    var messageForId = await CleverTapPlugin.getInboxMessageForId(messageId);
    setState((() {
      showToast("Inbox Message for id =  ${messageForId.toString()}");
      print("Inbox Message for id =  ${messageForId.toString()}");
    }));
  }

  void deleteInboxMessageForId() async {
    var messageId = await getFirstInboxMessageId();

    if (messageId == null) {
      setState((() {
        showToast("Inbox Message id is null");
        print("Inbox Message id is null");
      }));
      return;
    }

    await CleverTapPlugin.deleteInboxMessageForId(messageId);

    setState((() {
      showToast("Deleted Inbox Message with id =  $messageId");
      print("Deleted Inbox Message with id =  $messageId");
    }));
  }

  void markReadInboxMessageForId() async {
    var messageList = await CleverTapPlugin.getUnreadInboxMessages();

    if (messageList == null || messageList.length == 0) return;
    Map<dynamic, dynamic> itemFirst = messageList[0];

    if (Platform.isAndroid) {
      await CleverTapPlugin.markReadInboxMessageForId(itemFirst["id"]);
      setState((() {
        showToast("Marked Inbox Message as read with id =  ${itemFirst["id"]}");
        print("Marked Inbox Message as read with id =  ${itemFirst["id"]}");
      }));
    } else if (Platform.isIOS) {
      await CleverTapPlugin.markReadInboxMessageForId(itemFirst["_id"]);
      setState((() {
        showToast(
            "Marked Inbox Message as read with id =  ${itemFirst["_id"]}");
        print("Marked Inbox Message as read with id =  ${itemFirst["_id"]}");
      }));
    }
  }

  void pushInboxNotificationClickedEventForId() async {
    var messageId = await getFirstInboxMessageId();

    if (messageId == null) {
      setState((() {
        showToast("Inbox Message id is null");
        print("Inbox Message id is null");
      }));
      return;
    }

    await CleverTapPlugin.pushInboxNotificationClickedEventForId(messageId);

    setState((() {
      showToast(
          "Pushed NotificationClickedEvent for Inbox Message with id =  $messageId");
      print(
          "Pushed NotificationClickedEvent for Inbox Message with id =  $messageId");
    }));
  }

  void pushInboxNotificationViewedEventForId() async {
    var messageId = await getFirstInboxMessageId();

    if (messageId == null) {
      setState((() {
        showToast("Inbox Message id is null");
        print("Inbox Message id is null");
      }));
      return;
    }

    await CleverTapPlugin.pushInboxNotificationViewedEventForId(messageId);

    setState((() {
      showToast(
          "Pushed NotificationViewedEvent for Inbox Message with id =  $messageId");
      print(
          "Pushed NotificationViewedEvent for Inbox Message with id =  $messageId");
    }));
  }

  Future<String> getFirstInboxMessageId() async {
    var messageList = await CleverTapPlugin.getAllInboxMessages();
    print("inside getFirstInboxMessageId");
    Map<dynamic, dynamic> itemFirst = messageList[0];
    print(itemFirst.toString());

    if (Platform.isAndroid) {
      return itemFirst["id"];
    } else if (Platform.isIOS) {
      return itemFirst["_id"];
    }
    return "";
  }

  void setOptOut() {
    if (optOut) {
      CleverTapPlugin.setOptOut(false);
      optOut = false;
      showToast("You have opted in");
    } else {
      CleverTapPlugin.setOptOut(true);
      optOut = true;
      showToast("You have opted out");
    }
  }

  void setOffline() {
    if (offLine) {
      CleverTapPlugin.setOffline(false);
      offLine = false;
      showToast("You are online");
    } else {
      CleverTapPlugin.setOffline(true);
      offLine = true;
      showToast("You are offline");
    }
  }

  void setEnableDeviceNetworkingInfo() {
    if (enableDeviceNetworkingInfo) {
      CleverTapPlugin.enableDeviceNetworkInfoReporting(false);
      enableDeviceNetworkingInfo = false;
      showToast("You have disabled device networking info");
    } else {
      CleverTapPlugin.enableDeviceNetworkInfoReporting(true);
      enableDeviceNetworkingInfo = true;
      showToast("You have enabled device networking info");
    }
  }

  void recordScreenView() {
    var screenName = "Home Screen";
    CleverTapPlugin.recordScreenView(screenName);
  }

  void eventGetFirstTime() {
    var eventName = "Flutter Event";
    CleverTapPlugin.eventGetFirstTime(eventName).then((eventFirstTime) {
      if (eventFirstTime == null) return;
      setState((() {
        showToast("Event First time CleverTap = " + eventFirstTime.toString());
        print("Event First time CleverTap = " + eventFirstTime.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void eventGetLastTime() {
    var eventName = "Flutter Event";
    CleverTapPlugin.eventGetLastTime(eventName).then((eventLastTime) {
      if (eventLastTime == null) return;
      setState((() {
        showToast("Event Last time CleverTap = " + eventLastTime.toString());
        print("Event Last time CleverTap = " + eventLastTime.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void eventGetOccurrences() {
    var eventName = "Flutter Event";
    CleverTapPlugin.eventGetOccurrences(eventName).then((eventOccurrences) {
      if (eventOccurrences == null) return;
      setState((() {
        showToast(
            "Event detail from CleverTap = " + eventOccurrences.toString());
        print("Event detail from CleverTap = " + eventOccurrences.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void getEventDetail() {
    var eventName = "Flutter Event";
    CleverTapPlugin.eventGetDetail(eventName).then((eventDetailMap) {
      if (eventDetailMap == null) return;
      setState((() {
        showToast("Event detail from CleverTap = " + eventDetailMap.toString());
        print("Event detail from CleverTap = " + eventDetailMap.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void getEventHistory() {
    var eventName = "Flutter Event";
    CleverTapPlugin.getEventHistory(eventName).then((eventDetailMap) {
      if (eventDetailMap == null) return;
      setState((() {
        showToast(
            "Event History from CleverTap = " + eventDetailMap.toString());
        print("Event History from CleverTap = " + eventDetailMap.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void setLocation() {
    var lat = 19.07;
    var long = 72.87;
    CleverTapPlugin.setLocation(lat, long);
    showToast("Location is set");
  }

  void getCTAttributionId() {
    CleverTapPlugin.profileGetCleverTapAttributionIdentifier()
        .then((attributionId) {
      if (attributionId == null) return;
      setState((() {
        showToast("Attribution Id = " + "$attributionId");
        print("Attribution Id = " + "$attributionId");
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void getCleverTapId() {
    CleverTapPlugin.getCleverTapID().then((clevertapId) {
      if (clevertapId == null) return;
      setState((() {
        showToast("$clevertapId");
        print("$clevertapId");
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void onUserLogin() {
    var stuff = ["bags", "shoes"];
    var profile = {
      'Name': 'Captain America',
      'Identity': '100',
      'Email': 'captain@america.com',
      'Phone': '+14155551234',
      'stuff': stuff
    };
    CleverTapPlugin.onUserLogin(profile);
    showToast("onUserLogin called, check console for details");
  }

  void removeProfileValue() {
    CleverTapPlugin.profileRemoveValueForKey("props");
    showToast("check console for details");
  }

  void setProfileMultiValue() {
    var values = ["value1", "value2"];
    CleverTapPlugin.profileSetMultiValues("props", values);
    showToast("check console for details");
  }

  void addMultiValue() {
    var value = "value1";
    CleverTapPlugin.profileAddMultiValue("props", value);
    showToast("check console for details");
  }

  void incrementValue() {
    var value = 15;
    CleverTapPlugin.profileIncrementValue("score", value);
    showToast("check console for details");
  }

  void decrementValue() {
    var value = 10;
    CleverTapPlugin.profileDecrementValue("score", value);
    showToast("check console for details");
  }

  void addMultiValues() {
    var values = ["value1", "value2"];
    CleverTapPlugin.profileAddMultiValues("props", values);
    showToast("check console for details");
  }

  void removeMultiValue() {
    var value = "value1";
    CleverTapPlugin.profileRemoveMultiValue("props", value);
    showToast("check console for details");
  }

  void removeMultiValues() {
    var values = ["value1", "value2"];
    CleverTapPlugin.profileRemoveMultiValues("props", values);
    showToast("check console for details");
  }

  void getTimeElapsed() {
    CleverTapPlugin.sessionGetTimeElapsed().then((timeElapsed) {
      if (timeElapsed == null) return;
      setState((() {
        showToast("Session Time Elapsed = " + timeElapsed.toString());
        print("Session Time Elapsed = " + timeElapsed.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void getTotalVisits() {
    CleverTapPlugin.sessionGetTotalVisits().then((totalVisits) {
      if (totalVisits == null) return;
      setState((() {
        showToast("Session Total Visits = " + totalVisits.toString());
        print("Session Total Visits = " + totalVisits.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void getScreenCount() {
    CleverTapPlugin.sessionGetScreenCount().then((screenCount) {
      if (screenCount == null) return;
      setState((() {
        showToast("Session Screen Count = " + screenCount.toString());
        print("Session Screen Count = " + screenCount.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void getPreviousVisitTime() {
    CleverTapPlugin.sessionGetPreviousVisitTime().then((previousTime) {
      if (previousTime == null) return;
      setState((() {
        showToast("Session Previous Visit Time = " + previousTime.toString());
        print("Session Previous Visit Time = " + previousTime.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void getUTMDetails() {
    CleverTapPlugin.sessionGetUTMDetails().then((utmDetails) {
      if (utmDetails == null) return;
      setState((() {
        showToast("Session UTM Details = " + utmDetails.toString());
        print("Session UTM Details = " + utmDetails.toString());
      }));
    }).catchError((error) {
      setState(() {
        print("$error");
      });
    });
  }

  void suspendInAppNotifications() {
    CleverTapPlugin.suspendInAppNotifications();
    showToast("InApp notification is suspended");
  }

  void discardInAppNotifications() {
    CleverTapPlugin.discardInAppNotifications();
    showToast("InApp notification is discarded");
  }

  void resumeInAppNotifications() {
    CleverTapPlugin.resumeInAppNotifications();
    showToast("InApp notification is resumed");
  }

  void enablePersonalization() {
    CleverTapPlugin.enablePersonalization();
    showToast("Personalization enabled");
    print("Personalization enabled");
  }

  void disablePersonalization() {
    CleverTapPlugin.disablePersonalization();
    showToast("Personalization disabled");
    print("Personalization disabled");
  }

  void getAdUnits() async {
    List displayUnits = await CleverTapPlugin.getAllDisplayUnits();
    showToast("check console for logs");
    print("Display Units Payload = " + displayUnits.toString());

    displayUnits?.forEach((element) {
      var customExtras = element["custom_kv"];
      if (customExtras != null) {
        print("Display Units CustomExtras: " +  customExtras.toString());
      }
    });
  }

  void fetch() {
    CleverTapPlugin.fetch();
    showToast("check console for logs");

    ///CleverTapPlugin.fetchWithMinimumIntervalInSeconds(0);
  }

  void activate() {
    CleverTapPlugin.activate();
    showToast("check console for logs");
  }

  void fetchAndActivate() {
    CleverTapPlugin.fetchAndActivate();
    showToast("check console for logs");
  }

  void promptForPushNotification() {
    var fallbackToSettings = true;
    CleverTapPlugin.promptForPushNotification(fallbackToSettings);
    showToast("Prompt Push Permission");
  }

  void localHalfInterstitialPushPrimer() {
    var pushPrimerJSON = {
      'inAppType': 'half-interstitial',
      'titleText': 'Get Notified',
      'messageText': 'Please enable notifications on your device to use Push Notifications.',
      'followDeviceOrientation': false,
      'positiveBtnText': 'Allow',
      'negativeBtnText': 'Cancel',
      'fallbackToSettings': true,
      'backgroundColor': '#FFFFFF',
      'btnBorderColor': '#000000',
      'titleTextColor': '#000000',
      'messageTextColor': '#000000',
      'btnTextColor': '#000000',
      'btnBackgroundColor': '#FFFFFF',
      'btnBorderRadius': '4',
      'imageUrl': 'https://icons.iconarchive.com/icons/treetog/junior/64/camera-icon.png'
    };
    CleverTapPlugin.promptPushPrimer(pushPrimerJSON);
    showToast("Half-Interstitial Push Primer");
  }

  void localAlertPushPrimer() {
    this.setState(() async {
      bool isPushPermissionEnabled = await CleverTapPlugin
          .getPushNotificationPermissionStatus();
      if (isPushPermissionEnabled == null) return;

      // Check Push Permission status and then call `promptPushPrimer` if not enabled.
      if (!isPushPermissionEnabled) {
        var pushPrimerJSON = {
          'inAppType': 'alert',
          'titleText': 'Get Notified',
          'messageText': 'Enable Notification permission',
          'followDeviceOrientation': true,
          'positiveBtnText': 'Allow',
          'negativeBtnText': 'Cancel',
          'fallbackToSettings': true
        };
        CleverTapPlugin.promptPushPrimer(pushPrimerJSON);
        showToast("Alert Push Primer");
      } else {
        print("Push Permission is already enabled.");
      }
    });
  }

}

class MyHttpOverrides extends HttpOverrides
{

  @override
  HttpClient createHttpClient(SecurityContext context)
  {

    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

  }
}
