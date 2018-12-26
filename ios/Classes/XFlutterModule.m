//
//  XFlutterModule.m
//  FleaMarket
//
//  Created by 正物 on 2018/03/08.
//  Copyright © 2017 正物. All rights reserved.
//

#import "XFlutterModule.h"
#import "HybridStackManager.h"
#import <hybrid_stack_manager/HybridStackManager.h>

@interface XFlutterModule()
{
    BOOL _isInFlutterRootPage;
    bool _isFlutterWarmedup;
}
@end

@implementation XFlutterModule
@synthesize isInFlutterRootPage = _isInFlutterRootPage;
#pragma mark - XModuleProtocol
+ (instancetype)sharedInstance{
    static XFlutterModule *sXFlutterModule;
    if(sXFlutterModule)
        return sXFlutterModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sXFlutterModule = [[[self class] alloc] initInstance];
        [sXFlutterModule warmupFlutter];
});
    return sXFlutterModule;
}

- (instancetype)initInstance{
    if(self = [super init]){
        _isInFlutterRootPage = TRUE;
    }
    return self;
}

- (void)warmupFlutter{
    if(_isFlutterWarmedup)
        return;
    _flutterEngine = [[FlutterEngine alloc] initWithName:@"default_engine" project:nil];
    [_flutterEngine runWithEntrypoint:nil];
    [NSClassFromString(@"GeneratedPluginRegistrant") performSelector:NSSelectorFromString(@"registerWithRegistry:") withObject:_flutterEngine];
    _isFlutterWarmedup = true;
}

+ (NSDictionary *)parseParamsKV:(NSString *)aParamsStr{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *kvAry = [aParamsStr componentsSeparatedByString:@"&"];
    for(NSString *kv in kvAry){
        NSArray *ary = [kv componentsSeparatedByString:@"="];
        if (ary.count == 2) {
            NSString *key = ary.firstObject;
            NSString *value = [ary.lastObject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [dict setValue:value forKey:key];
        }
    }
    return dict;
}

- (void)openURL:(NSString *)url query:(NSDictionary *)query params:(NSDictionary *)params{
    XFlutterViewController *flutterWrapperVC = [self  queryFlutterVCWithURL:url query:query params:params];
    //Push
    UINavigationController *currentNavigation = (UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    [currentNavigation pushViewController:flutterWrapperVC animated:YES];
}

- (XFlutterViewController *)queryFlutterVCWithURL:(NSString *)url query:(NSDictionary *)query params:(NSDictionary *)params{
    static BOOL sIsFirstPush = TRUE;
    //Process aUrl and Query Stuff.
    NSURL *aUrl = [NSURL URLWithString:url];
    
    NSMutableDictionary *mQuery = [NSMutableDictionary dictionaryWithDictionary:query];
    [mQuery addEntriesFromDictionary:[XFlutterModule parseParamsKV:aUrl.query]];
    NSMutableDictionary *mParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [mParams addEntriesFromDictionary:[XFlutterModule parseParamsKV:aUrl.parameterString]];
    NSString *pageUrl = [NSString stringWithFormat:@"%@://%@",aUrl.scheme,aUrl.host];
    
    FlutterMethodChannel *methodChann = [HybridStackManager sharedInstance].methodChannel;
    NSMutableDictionary *arguments = [NSMutableDictionary dictionary];
    [arguments setValue:pageUrl forKey:@"url"];
    
    NSMutableDictionary *mutQuery = [NSMutableDictionary dictionary];
    for(NSString *key in query.allKeys){
        id value = [query objectForKey:key];
        //[TODO]: Add customized implementations for non-json-serializable objects into json-serializable ones.
        [mutQuery setValue:value forKey:key];
    }
    [arguments setValue:mutQuery forKey:@"query"];
    
    NSMutableDictionary *mutParams = [NSMutableDictionary dictionary];
    for(NSString *key in mParams.allKeys){
        id value = [mParams objectForKey:key];
        //[TODO]: Add customized implementations for non-json-serializable objects into json-serializable ones.
        [mutParams setValue:value forKey:key];
    }
    [arguments setValue:mutParams forKey:@"params"];
    
    [arguments setValue:@(0) forKey:@"animated"];
    if(sIsFirstPush){
        [HybridStackManager sharedInstance].mainEntryParams = arguments;
        sIsFirstPush = FALSE;
    }
    XFlutterViewController *viewController = [[XFlutterViewController alloc] initWithEngine:_flutterEngine nibName:nil bundle:nil];
    viewController.viewWillAppearBlock = ^(){
        //Process first & later message sending according distinguishly.

        if(!sIsFirstPush){
            [methodChann invokeMethod:@"openURLFromFlutter" arguments:arguments result:^(id  _Nullable result) {
            }];
        }
    };
    return viewController;
}
#pragma mark - XFlutterModuleProtocol
@end
