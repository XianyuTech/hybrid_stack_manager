//
//  XFlutterViewController.m
//  flutter_chann_plugin
//
//  Created by 正物 on 18/03/2018.
//

#import "XFlutterViewController.h"
#import "HybridStackManager.h"

@interface XFlutterViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) UIImageView *fakeSnapImgView;
@property(nonatomic,weak) id<UIGestureRecognizerDelegate> originalGestureDelegate;
@property(nonatomic,assign) BOOL isDisappeared;
@end

@implementation XFlutterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
    
- (void)dealloc{
    [self tryPopRoute];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = TRUE;
    self.originalGestureDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [super viewWillAppear:animated];
    if(self.viewWillAppearBlock){
        self.viewWillAppearBlock();
        self.viewWillAppearBlock = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.curFlutterRouteName.length && self.isDisappeared){
        [[HybridStackManager sharedInstance].methodChannel invokeMethod:@"popToRouteNamed" arguments:self.curFlutterRouteName];
    }
    [self.view setUserInteractionEnabled:TRUE];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    UINavigationController *rootNav = (UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    rootNav.interactivePopGestureRecognizer.delegate = self.originalGestureDelegate;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.isDisappeared = TRUE;
}
    
- (void)tryPopRoute{
    UINavigationController *rootNav = (UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    NSArray *ary = [rootNav.viewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        if([evaluatedObject isKindOfClass:[XFlutterViewController class]])
            return TRUE;
        return FALSE;
    }]];
    if(!ary.count){
        [[HybridStackManager sharedInstance].methodChannel invokeMethod:@"popToRoot" arguments:nil];
    }
    
    NSArray *curStackAry = rootNav.viewControllers;
    NSInteger idx = [curStackAry indexOfObject:self];
    if(idx == NSNotFound){
        [[HybridStackManager sharedInstance].methodChannel invokeMethod:@"popRouteNamed" arguments:self.curFlutterRouteName];
    }
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods{
    return TRUE;
}
    
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return TRUE;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer{
    return TRUE;
}
@end

