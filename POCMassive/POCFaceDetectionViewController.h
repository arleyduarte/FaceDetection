//
//  POCFaceDetectionViewController.h
//  POCMassive
//
//  Created by Arley Mauricio Duarte on 4/11/14.
//  Copyright (c) 2014 Arley Mauricio Duarte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@interface POCFaceDetectionViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureVideoPreviewLayer *_previewLayer;
    AVCaptureStillImageOutput *_stillImageOutput;
    AVCaptureSession *_session;
    CIDetector *_faceDetector;
    CIContext *_ciContext;

}
@property (weak, nonatomic) IBOutlet UIImageView *faceMask;
@property (weak, nonatomic) IBOutlet UIView *inclinationIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (strong,nonatomic) CMMotionManager *motionManager;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoPreview;

- (IBAction)takePictureAction:(id)sender;



@end
