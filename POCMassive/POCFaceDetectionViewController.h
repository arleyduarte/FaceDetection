//
//  POCFaceDetectionViewController.h
//  POCMassive
//
//  Created by Arley Mauricio Duarte on 4/11/14.
//  Copyright (c) 2014 Arley Mauricio Duarte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface POCFaceDetectionViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *session;
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureVideoDataOutput *videoDataOutput;
    AVCaptureVideoPreviewLayer *previewLayer;
    dispatch_queue_t videoDataOutputQueue;
   	CIDetector *faceDetector;
    CGRect faceRect;
    CALayer * faceSquare;
    CGFloat effectiveScale;
    UIImage * face;
    BOOL detectFaces;
}
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
- (IBAction)takePictureAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *inRect;
@property (weak, nonatomic) IBOutlet UIView *outRect;

@property (weak, nonatomic) IBOutlet UIView *previewView;
@end
