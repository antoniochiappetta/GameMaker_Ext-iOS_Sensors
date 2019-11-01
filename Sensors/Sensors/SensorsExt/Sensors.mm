//
//  Sensors.m
//  Sensors
//
//  Created by Antonio Chiappetta on 26/10/2019.
//  Copyright © 2019 Antonio Chiappetta. All rights reserved.
//

// MARK: - Implementation

#import "Sensors.h"
	
@implementation Sensors
{
    
}
 
// MARK: - Properties

const int EVENT_OTHER_SOCIAL = 70;
extern int CreateDsMap( int _num, ... );
extern void CreateAsynEventWithDSMap(int dsmapindex, int event_index);

CMMotionManager *motionManager;

// MARK: - Initialization

-(id)init {
    
    self = [super init];
        
    if (self) {
        // Initialize Motion Manager
       motionManager = [[CMMotionManager alloc] init];

    }
    return self;
    
}
 
// MARK: - Gyroscope
    
-(double)Sensors_Gyroscope_isAvailable {
    if([motionManager isGyroAvailable]) {
        return(1);
    } else {
        return(0);
	}
}
       
-(double)Sensors_Gyroscope_isActive {
    if([motionManager isGyroActive]) {
        return(1);
    } else {
        return(0);
	}
}                 
        

-(void)Sensors_Gyroscope_Start:(double)interval {
    [motionManager setGyroUpdateInterval:interval];
    
    [motionManager startGyroUpdatesToQueue: [NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroscopeData, NSError *error) {
        [self handleGyroUpdates:gyroscopeData.rotationRate];
        [motionManager startDeviceMotionUpdates];
    }];

	[motionManager startDeviceMotionUpdates];
}       
    
-(void)Sensors_Gyroscope_Stop {
	[motionManager stopDeviceMotionUpdates];
    [motionManager stopGyroUpdates];
}


-(void) handleGyroUpdates:(CMRotationRate)gyroRotationRate {
    
	int dsMapIndex = CreateDsMap(4,
                                 "type",0,"Gyroscope",
                                 "X",gyroRotationRate.x, (void*)NULL,
                                 "Y",gyroRotationRate.y, (void*)NULL,
                                 "Z",gyroRotationRate.z, (void*)NULL
                                 );
					
    CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
}

// MARK: - Light

- (double)Sensors_Light_isAvailable {
    // TODO: - Sensor Light isAvailable
    return(0);
}

- (double)Sensors_Light_isActive {
    // TODO: - Sensor Light isActive
    return(0);
}

- (void)Sensors_Light_Start:(double)interval {
    // TODO: - Sensor Light start
}

- (void)Sensors_Light_Stop {
    // TODO: - Sensor Light stop
}

// MARK: - Proximity

- (double)Sensors_Proximity_isAvailable {
    // Not all iOS devices have proximity sensors. To determine if proximity monitoring is available, attempt to enable it.
    // If the value of the proximityMonitoringEnabled property remains NO, proximity monitoring is not available
    // Once the check is done, reset the property to its original value
    BOOL oldProximityValue = [UIDevice.currentDevice isProximityMonitoringEnabled];
    [UIDevice.currentDevice setProximityMonitoringEnabled:!oldProximityValue];
    BOOL newProximityValue = [UIDevice.currentDevice isProximityMonitoringEnabled];
    [UIDevice.currentDevice setProximityMonitoringEnabled:oldProximityValue];
    
    if (oldProximityValue != newProximityValue) {
        return(1);
    } else {
        return(0);
    }
}

- (double)Sensors_Proximity_isActive {
    if([UIDevice.currentDevice isProximityMonitoringEnabled]) {
        return(1);
    } else {
        return(0);
    }
}

- (void)Sensors_Proximity_Start:(double)interval {
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled:true];
    if ([device isProximityMonitoringEnabled]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProximityUpdates:) name:@"UIDeviceProximityStateDidChangeNotification" object:device];
    }
}

- (void)Sensors_Proximity_Stop {
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled:false];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:device];
}

- (void) handleProximityUpdates:(NSNotification *)notification {
    
    UIDevice *device = [notification object];
    BOOL proximityState = [device proximityState];
    
    int dsMapIndex = CreateDsMap(10,
                                 "type",0,"Proximity",
                                 "Value",proximityState, (void*)NULL
                                 );
                    
    CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
}


@end


