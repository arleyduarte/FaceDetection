//
//  POCGyroViewController.m
//  POCMassive
//
//  Created by Arley Mauricio Duarte on 4/23/14.
//  Copyright (c) 2014 Arley Mauricio Duarte. All rights reserved.
//

#import "POCGyroViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface POCGyroViewController ()

@end

@implementation POCGyroViewController
@synthesize mManager;
@synthesize display;
@synthesize aX;
@synthesize az;
@synthesize aY;
@synthesize gX;
@synthesize gY;
@synthesize inclinationView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self startDeviceMotion];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (void)startDeviceMotion {
    // Create a CMMotionManager
    mManager = [[CMMotionManager alloc] init];
    
    // Tell CoreMotion to show the compass calibration HUD when required
    // to provide true north-referenced attitude
    mManager.showsDeviceMovementDisplay = YES;
    mManager.deviceMotionUpdateInterval = 2.0 / 60.0;
    
    NSTimeInterval delta = 0.005;
    NSTimeInterval updateInterval = 1 + delta * 50;
    
    // Attitude that is referenced to true north
    [mManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
    [mManager setDeviceMotionUpdateInterval:updateInterval];
    
    [mManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        NSLog(@"Y value is: %f", motion.userAcceleration.y);
        
        
        CGFloat angle =  atan2( motion.gravity.x, motion.gravity.y );
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        self.inclinationView.transform = transform;;
        
        display.text = [NSString stringWithFormat:@" X G Z: %.4f", motion.gravity.z];
    
        
    }];
}

- (void)startDeviceMotion1 {
    // Create a CMMotionManager
    mManager = [[CMMotionManager alloc] init];
    
    // Tell CoreMotion to show the compass calibration HUD when required
    // to provide true north-referenced attitude
    mManager.showsDeviceMovementDisplay = YES;
    mManager.deviceMotionUpdateInterval = 2.0 / 60.0;
    
    NSTimeInterval delta = 0.005;
    NSTimeInterval updateInterval = 1 + delta * 50;
    
    // Attitude that is referenced to true north
    [mManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
    [mManager setDeviceMotionUpdateInterval:updateInterval];
    
    [mManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
         NSLog(@"Y value is: %f", motion.userAcceleration.y);
        

        CGFloat angle =  atan2( motion.gravity.x, motion.gravity.y );
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        self.inclinationView.transform = transform;;
        
        
        display.text = [NSString stringWithFormat:@" X G Z: %.4f", motion.gravity.z];
        
        gY.text = [NSString stringWithFormat:@" G Y: %.4f",motion.gravity.y];
        
        gX.text = [NSString stringWithFormat:@" G X: %.4f",motion.gravity.x];
        
        aX.text = [NSString stringWithFormat:@" A X: %.2f",motion.rotationRate.x];
        
        az.text = [NSString stringWithFormat:@" A Z: %.2f",motion.rotationRate.z];
        
        aY.text = [NSString stringWithFormat:@" A Y: %.2f",motion.rotationRate.y];
        
        
        // Check whether the gyroscope is available
        if ([mManager isGyroAvailable] == YES) {
            // Assign the update interval to the motion manager
            [mManager setGyroUpdateInterval:updateInterval];
            [mManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
                NSLog(@"Y X gyroData: %f %f %f", gyroData.rotationRate.y, gyroData.rotationRate.x, gyroData.rotationRate.z);
             //   display.text = [NSString stringWithFormat:@" G Z: %.2f",self.mManager.gyroData.rotationRate.z];
                
//                gY.text = [NSString stringWithFormat:@" G Y: %.2f",self.mManager.gyroData.rotationRate.y];
//                
//                gX.text = [NSString stringWithFormat:@" G X: %.2f",self.mManager.gyroData.rotationRate.x];
            }];
        }
        
        if ([mManager isAccelerometerAvailable] == YES) {
            // Assign the update interval to the motion manager
            [mManager setAccelerometerUpdateInterval:updateInterval];
            [mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                NSLog(@"Y X gyroData: %f %f %f", accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z);
                
//                aX.text = [NSString stringWithFormat:@" A X: %.2f",self.mManager.accelerometerData.acceleration.x];
//                
//                az.text = [NSString stringWithFormat:@" A Z: %.2f",self.mManager.accelerometerData.acceleration.z];
//                
//                aY.text = [NSString stringWithFormat:@" A Y: %.2f",self.mManager.accelerometerData.acceleration.y];
                
            }];
        }
        
        
    }];
}



- (void)stopDeviceMotion {
    [mManager stopDeviceMotionUpdates];
}


@end
