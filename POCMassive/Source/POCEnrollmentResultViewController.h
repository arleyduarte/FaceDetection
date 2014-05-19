//
//  POCEnrollmentResultViewController.h
//  POCMassive
//
//  Created by Arley Mauricio Duarte on 5/1/14.
//  Copyright (c) 2014 Arley Mauricio Duarte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POCEnrollmentResultViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) UIImage *resultImage;
@property (strong, nonatomic) NSString *enrollmentResult;



@end
