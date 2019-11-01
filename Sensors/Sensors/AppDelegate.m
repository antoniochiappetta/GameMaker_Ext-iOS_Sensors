//
//  AppDelegate.m
//  Sensors
//
//  Created by Antonio Chiappetta on 27/10/2019.
//  Copyright © 2019 Antonio Chiappetta. All rights reserved.
//

#import "AppDelegate.h"
#import "Sensors.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // The following setup is needed to activate sensors on launch and debug their extracted values by printing them to Xcode console (only for debug purposes, comment out for production)
    Sensors *sensors = [[Sensors alloc] init];
    
    // MARK: - Test Gyroscope sensor
    if ([sensors Sensors_Gyroscope_isAvailable]) {
        [sensors Sensors_Gyroscope_Start:1.0]; // Prints an update every second
    }
    
    // MARK: - Test Light sensor
    if ([sensors Sensors_Light_isAvailable]) {
        [sensors Sensors_Light_Start]; // Prints an update every time the ambient light changes
    }
    
    // MARK: - Test Proximity sensor
    if ([sensors Sensors_Proximity_isAvailable]) {
        [sensors Sensors_Proximity_Start]; // Prints an update every time the proximity changes from false to true or viceversa
    }
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
