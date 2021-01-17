//
//  AppDelegate.m
//  testXML
//
//  Created by lbxia on 2021/1/14.
//

#import "AppDelegate.h"


#import "MainViewController.h"

@interface AppDelegate ()
@property (strong, nonatomic) UIWindow *window;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UIWindow *window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    window.backgroundColor = [UIColor whiteColor];
    window.rootViewController = [[MainViewController alloc]init];
    [window makeKeyAndVisible];
    self.window = window;

    return YES;
}





@end
