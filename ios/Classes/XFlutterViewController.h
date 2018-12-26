//
//  XFlutterViewController.h
//  flutter_chann_plugin
//
//  Created by 正物 on 18/03/2018.
//

#import <Flutter/Flutter.h>
#import "UIViewController+URLRouter.h"

typedef void (^FlutterViewWillAppearBlock) (void);

@interface XFlutterViewController : FlutterViewController
@property(nonatomic,copy) NSString *curFlutterRouteName;
@property(nonatomic,copy) FlutterViewWillAppearBlock viewWillAppearBlock;
@end
