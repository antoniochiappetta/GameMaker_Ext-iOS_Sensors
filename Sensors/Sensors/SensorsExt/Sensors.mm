//
//  Sensors.m
//  Sensors
//
//  Created by Antonio Chiappetta on 26/10/2019.
//  Copyright © 2019 Antonio Chiappetta. All rights reserved.
//

// MARK: - Instructions
// You can comment the lines marked as GameMaker Connection to perform the compilation in Xcode and be able to test the native app on an iOS Device

// MARK: - Implementation

#import "Sensors.h"
 
// MARK: - GameMaker Connection

const int EVENT_OTHER_SOCIAL = 70;
extern int CreateDsMap( int _num, ... );
extern void CreateAsynEventWithDSMap(int dsmapindex, int event_index);
    extern UIViewController *g_controller;
    extern UIView *g_glView;
    extern int g_DeviceWidth;
    extern int g_DeviceHeight;

// MARK: - Implementation
    
@implementation Sensors
{
    
}

// MARK: - Properties

CMMotionManager *motionManager;

dispatch_queue_t sessionQueue;
AVCaptureSession *captureSession;
AVCaptureDevice *videoDevice;

BOOL isCameraAuthorized;

// MARK: - Initialization

-(id)init {
    
    self = [super init];
        
    if (self) {
        
        // Initialize Motion Manager
        motionManager = [[CMMotionManager alloc] init];

        // MARK: - Light OPTION 2 - Camera Capture Session
        // Comment/uncomment this snippet in the init method and the 5 methods in the corresponding section below to enable/disable this implementation of the Light sensor
                
//        // Initializa Camera Capture Session
//        captureSession = [[AVCaptureSession alloc] init];
//
//        // Communicate with the session and other session objects on this queue
//        sessionQueue = dispatch_queue_create( "session queue", DISPATCH_QUEUE_SERIAL );
//
//        // Check Video Authorization Status
//        switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
//            case AVAuthorizationStatusAuthorized: {
//                // The user has previously granted access to the camera
//                isCameraAuthorized = true;
//                break;
//            }
//            case AVAuthorizationStatusNotDetermined: {
//                // The user has not yet been presented with the option to grant video access.
//                // We suspend the session queue to delay session running until the access request has completed.
//                // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
//                dispatch_suspend( sessionQueue );
//                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
//                    isCameraAuthorized = granted;
//                    dispatch_resume( sessionQueue );
//                }];
//                break;
//            }
//            default: {
//                // The user has previously denied access
//                isCameraAuthorized = false;
//                break;
//            }
//        }
        
        // Setup the capture session.
        // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
        // Why not do all of this on the main queue?
        // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
        // so that the main queue isn't blocked, which keeps the UI responsive.
        dispatch_async( sessionQueue, ^{
            [captureSession beginConfiguration];
            
            // Add video input
            videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
            if (videoDevice != NULL) {
                AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:NULL];
                if ([captureSession canAddInput:videoDeviceInput]) {
                    [captureSession addInput:videoDeviceInput];
                    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
                    if ([captureSession canAddOutput:videoDataOutput]) {
                        [captureSession addOutput:videoDataOutput];
                        [captureSession commitConfiguration];
                        [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
                    }
                }
            }
        } );
        
    }
    return self;
    
}
 
// MARK: - Gyroscope
    
-(double)Sensors_Gyroscope_isAvailable {
    if([motionManager isGyroAvailable]) {
        NSLog(@"Gyroscope available: TRUE");
        return(1);
    } else {
        NSLog(@"Gyroscope available: FALSE");
        return(0);
	}
}
       
-(double)Sensors_Gyroscope_isActive {
    if([motionManager isGyroActive]) {
        NSLog(@"Gyroscope active: TRUE");
        return(1);
    } else {
        NSLog(@"Gyroscope active: FALSE");
        return(0);
	}
}                 
        

-(void)Sensors_Gyroscope_Start:(double)interval {
    [motionManager setGyroUpdateInterval:interval];
    
    [motionManager startGyroUpdatesToQueue: [NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroscopeData, NSError *error) {
        NSLog(@"Gyroscope start");
        [self handleGyroUpdates:gyroscopeData.rotationRate];
        [motionManager startDeviceMotionUpdates];
    }];

	[motionManager startDeviceMotionUpdates];
}       
    
-(void)Sensors_Gyroscope_Stop {
    NSLog(@"Gyroscope stop");
	[motionManager stopDeviceMotionUpdates];
    [motionManager stopGyroUpdates];
}


-(void) handleGyroUpdates:(CMRotationRate)gyroRotationRate {
    
//    NSLog(@"Gyroscope value: '%f', '%f', '%f'", gyroRotationRate.x, gyroRotationRate.y, gyroRotationRate.z);

    // MARK: - GameMaker Connection
    
	int dsMapIndex = CreateDsMap(4,
                                 "type",0,"Gyroscope",
                                 "X",gyroRotationRate.x, (void*)NULL,
                                 "Y",gyroRotationRate.y, (void*)NULL,
                                 "Z",gyroRotationRate.z, (void*)NULL
                                 );

    CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
}

// MARK: - Light

// MARK: - Light OPTION 1 - Screen Brightness (relying on user having auto brightness enabled)
// Comment/uncomment the next 5 methods to enable/disable this implementation of the Light sensor

- (double)Sensors_Light_isAvailable {
    NSLog(@"Light available: TRUE");
    return(1);
}

- (double)Sensors_Light_isActive {
    NSLog(@"Light active: TRUE");
    return(1);
}

- (void)Sensors_Light_Start {
    UIScreen *screen = [UIScreen mainScreen];
    NSLog(@"Light start");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLightUpdates:) name:UIScreenBrightnessDidChangeNotification object:screen];
}

- (void)Sensors_Light_Stop {
    UIScreen *screen = [UIScreen mainScreen];
    NSLog(@"Light stop");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenBrightnessDidChangeNotification object:screen];
}

- (void) handleLightUpdates:(NSNotification *)notification {

    UIScreen *screen = [notification object];
    float lightValue = [screen brightness];

    NSLog(@"Light value: '%f'", lightValue);

     // MARK: - GameMaker Connection

    int dsMapIndex = CreateDsMap(5,
                                 "type",0,"Light",
                                 "Value",lightValue, (void*)NULL
                                 );

    CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
}

// MARK: - Light OPTION 2 - Camera Capture Session
// Comment/uncomment the next 5 methods and the snippet in the init method above to enable/disable this implementation of the Light sensor

//- (double)Sensors_Light_isAvailable {
//    if (isCameraAuthorized) {
//        if ([captureSession.inputs count] > 0 && [captureSession.outputs count] > 0) {
//            NSLog(@"Light available: TRUE");
//            return(1);
//        } else {
//            NSLog(@"Light available: FALSE");
//            return(0);
//        }
//    } else {
//        NSLog(@"Light available: FALSE");
//        return(0);
//    }
//}
//
//- (double)Sensors_Light_isActive {
//    if ([captureSession isRunning]) {
//        NSLog(@"Light active: TRUE");
//        return(1);
//    } else {
//        NSLog(@"Light active: FALSE");
//        return(0);
//    }
//}
//
//- (void)Sensors_Light_Start {
//    NSLog(@"Light start");
//    [captureSession startRunning];
//}
//
//- (void)Sensors_Light_Stop {
//    NSLog(@"Light stop");
//    [captureSession stopRunning];
//}
//
//- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    
//    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,
//      sampleBuffer, kCMAttachmentMode_ShouldPropagate);
//    NSDictionary *metadata = [[NSMutableDictionary alloc]
//      initWithDictionary:(__bridge NSDictionary*)metadataDict];
//    CFRelease(metadataDict);
//    NSDictionary *exifMetadata = [[metadata
//      objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
//    float lightValue = [[exifMetadata
//      objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
//    
//    NSLog(@"Light value: '%f'", lightValue);
//    
//    // MARK: - GameMaker Connection
//    
//    int dsMapIndex = CreateDsMap(5,
//                                 "type",0,"Light",
//                                 "Value",lightValue, (void*)NULL
//                                 );
//
//    CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
//}

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
        NSLog(@"Proximity available: TRUE");
        return(1);
    } else {
        NSLog(@"Proximity available: FALSE");
        return(0);
    }
}

- (double)Sensors_Proximity_isActive {
    if([UIDevice.currentDevice isProximityMonitoringEnabled]) {
        NSLog(@"Proximity active: TRUE");
        return(1);
    } else {
        NSLog(@"Proximity active: FALSE");
        return(0);
    }
}

- (void)Sensors_Proximity_Start {
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled:TRUE];
    if ([self Sensors_Proximity_isActive]) {
        NSLog(@"Proximity start");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProximityUpdates:) name:UIDeviceProximityStateDidChangeNotification object:device];
    }
}

- (void)Sensors_Proximity_Stop {
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled:FALSE];
    NSLog(@"Proximity stop");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:device];
}

- (void) handleProximityUpdates:(NSNotification *)notification {
    
    UIDevice *device = [notification object];
    BOOL proximityState = [device proximityState];
    
    NSLog(@"Proximity value: '%d'", proximityState);

    // MARK: - GameMaker Connection
    
    int dsMapIndex = CreateDsMap(10,
                                 "type",0,"Proximity",
                                 "Value",proximityState, (void*)NULL
                                 );
                    
    CreateAsynEventWithDSMap(dsMapIndex,EVENT_OTHER_SOCIAL);
}


@end


