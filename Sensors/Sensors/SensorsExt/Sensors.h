//
//  Sensors.m
//  Sensors
//
//  Created by Antonio Chiappetta on 26/10/2019.
//  Copyright © 2019 Antonio Chiappetta. All rights reserved.
//

// MARK: - Definition

#ifndef Sensors_h
#define Sensors_h


#endif /* Sensors_h */

#import <UIKit/UIKit.h>
#import<CoreMotion/CoreMotion.h>
#import<AVFoundation/AVFoundation.h>
#import<ImageIO/ImageIO.h>
#import<CoreMedia/CoreMedia.h>

@interface Sensors : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
{
   
}

// MARK: - Initialization


-(id)init;

// MARK: - Gyroscope

-(double)Sensors_Gyroscope_isAvailable;
-(double)Sensors_Gyroscope_isActive;
-(void)Sensors_Gyroscope_Start:(double)interval;
-(void)Sensors_Gyroscope_Stop;

// MARK: - Light

-(double)Sensors_Light_isAvailable;
-(double)Sensors_Light_isActive;
-(void)Sensors_Light_Start;
-(void)Sensors_Light_Stop;

// MARK: - Proximity

-(double)Sensors_Proximity_isAvailable;
-(double)Sensors_Proximity_isActive;
-(void)Sensors_Proximity_Start;
-(void)Sensors_Proximity_Stop;

@end
