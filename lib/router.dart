import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'router_option.dart';
import 'hybrid_stack_manager.dart';
import 'utils.dart';
import 'dart:io';
import 'package:image/image.dart' as image;
import 'dart:math';

typedef Widget FlutterWidgetHandler({RouterOption routeOption, Key key});

class XMaterialPageRoute<T> extends MaterialPageRoute<T> {
  final WidgetBuilder builder;
  final bool animated;
  final GlobalKey boundaryKey;
  Duration get transitionDuration {
    if (animated == true) return const Duration(milliseconds: 300);
    return const Duration(milliseconds: 0);
  }

  XMaterialPageRoute({
    this.builder,
    this.animated,
    this.boundaryKey,
    RouteSettings settings: const RouteSettings(),
  }) : super(builder: builder, settings: settings);
}

class Router extends Object {
  static final Router singleton = new Router._internal();
  List<XMaterialPageRoute> flutterRootPageNameLst = new List();
  String currentPageUrl = null;
  FlutterWidgetHandler routerWidgetHandler;
  GlobalKey globalKeyForRouter;
  static Router sharedInstance() {
    return singleton;
  }

  Router._internal(){
    setupMethodChannel();
  }

  void setupMethodChannel(){
    HybridStackManagerPlugin.hybridStackManagerPlugin
        .setMethodCallHandler((MethodCall methodCall)async{
      String method = methodCall.method;
      if (method == "openURLFromFlutter") {
        Map args = methodCall.arguments;
        if (args != null) {
          bool animated = (args["animated"] == 1);
          Router.sharedInstance().pushPageWithOptionsFromFlutter(
              routeOption: new RouterOption(
                  url: args["url"],
                  query: args["query"],
                  params: args["params"]),
              animated: animated ?? false);
        }
      } else if (method == "popToRoot") {
        Router.sharedInstance().popToRoot();
      } else if (method == "popToRouteNamed") {
        Router.sharedInstance().popToRouteNamed(methodCall.arguments);
      } else if (method == "popRouteNamed") {
        Router.sharedInstance().popRouteNamed(methodCall.arguments);
      }
      else if(method == "fetchSnapshot"){
        NavigatorState navState = Navigator.of(globalKeyForRouter.currentContext);
        String routeName = methodCall.arguments;
        XMaterialPageRoute pageRoute = navState.history.firstWhere((Route route){
          return (route is XMaterialPageRoute && (route as XMaterialPageRoute).settings.name == routeName)?true:false;
        },orElse:()=>null);
        String imgPath = "";
        if(pageRoute.boundaryKey!=null){
          image.Image img = await Utils.getImage(pageRoute.boundaryKey.currentContext.findRenderObject());
          Random rd = new Random();
          File file = await Utils.writeFile(img, "${rd.nextInt(10000)}.jpg");
          imgPath = file.path;
        }
        return Future.sync(()=>imgPath);
      }
    });
  }

  popToRoot() {
    NavigatorState navState = Navigator.of(globalKeyForRouter.currentContext);
    List<Route<dynamic>> navHistory = navState.history;
    int histLen = navHistory.length;
    for (int i = histLen - 1; i >= 1; i--) {
      Route route = navHistory.elementAt(i);
      navState.removeRoute(route);
    }
  }

  popToRouteNamed(String routeName) {
    NavigatorState navState = Navigator.of(globalKeyForRouter.currentContext);
    List<Route<dynamic>> navHistory = navState.history;
    int histLen = navHistory.length;
    for (int i = histLen - 1; i >= 1; i--) {
      Route route = navHistory.elementAt(i);
      if (!(route is XMaterialPageRoute) ||
          ((route as XMaterialPageRoute).settings.name != routeName)) {
        navState.removeRoute(route);
      }
      if ((route is XMaterialPageRoute) &&
          ((route as XMaterialPageRoute).settings.name == routeName)) break;
    }
  }

  popRouteNamed(String routeName) {
    NavigatorState navState = Navigator.of(globalKeyForRouter.currentContext);
    List<Route<dynamic>> navHistory = navState.history;
    int histLen = navHistory.length;
    for (int i = histLen - 1; i >= 1; i--) {
      Route route = navHistory.elementAt(i);
      if ((route is XMaterialPageRoute) &&
          ((route as XMaterialPageRoute).settings.name == routeName)) {
        navState.removeRoute(route);
        break;
      }
    }
  }

  pushPageWithOptionsFromFlutter({RouterOption routeOption, bool animated}) {
    Widget page =
        Router.sharedInstance().pageFromOption(routeOption: routeOption);
    if (page != null) {
      GlobalKey boundaryKey = new GlobalKey();
      XMaterialPageRoute pageRoute = new XMaterialPageRoute(
          settings: new RouteSettings(name: routeOption.userInfo),
          animated: animated,
          boundaryKey: boundaryKey,
          builder: (BuildContext context) {
            return new RepaintBoundary(key:boundaryKey,child: page);
          });

      Navigator.of(globalKeyForRouter.currentContext).push(pageRoute);
      HybridStackManagerPlugin.hybridStackManagerPlugin
          .updateCurFlutterRoute(routeOption.userInfo);
    } else {
      HybridStackManagerPlugin.hybridStackManagerPlugin.openUrlFromNative(
          url: routeOption.url,
          query: routeOption.query,
          params: routeOption.params);
    }
    NavigatorState navState = Navigator.of(globalKeyForRouter.currentContext);
    List<Route<dynamic>> navHistory = navState.history;
  }

  pushPageWithOptionsFromNative({RouterOption routeOption, bool animated}) {
    HybridStackManagerPlugin.hybridStackManagerPlugin.openUrlFromNative(
        url: routeOption.url,
        query: routeOption.query,
        params: routeOption.params,
        animated: animated);
  }

  pageFromOption({RouterOption routeOption, Key key}) {
    try {
      currentPageUrl = routeOption.url + "?" + converUrl(routeOption.query);
    } catch (e) {}
    routeOption.userInfo = Utils.generateUniquePageName(routeOption.url);
    if (routerWidgetHandler != null)
      return routerWidgetHandler(routeOption: routeOption, key: key);
  }

  static String converUrl(Map query) {
    String tmpUrl = "";
    if (query != null) {
      bool skipfirst = true;
      query.forEach((key, value) {
        if (skipfirst) {
          skipfirst = false;
        } else {
          tmpUrl = tmpUrl + "&";
        }
        tmpUrl = tmpUrl + (key + "=" + value.toString());
      });
    }
    return Uri.encodeFull(tmpUrl);
  }
}
