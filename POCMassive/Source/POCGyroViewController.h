//
//  POCGyroViewController.h
//  POCMassive
//
//  Created by Arley Mauricio Duarte on 4/23/14.
//  Copyright (c) 2014 Arley Mauricio Duarte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface POCGyroViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *gY;
@property (weak, nonatomic) IBOutlet UILabel *gX;
@property (weak, nonatomic) IBOutlet UILabel *az;
@property (weak, nonatomic) IBOutlet UILabel *aX;
@property (weak, nonatomic) IBOutlet UILabel *aY;
@property (weak, nonatomic) IBOutlet UIView *inclinationView;
@property (strong,nonatomic) CMMotionManager *mManager;
@end
