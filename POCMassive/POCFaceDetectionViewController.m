//
//  POCFaceDetectionViewController.m
//  POCMassive
//
//  Created by Arley Mauricio Duarte on 4/11/14.
//  Copyright (c) 2014 Arley Mauricio Duarte. All rights reserved.
//

#import "POCFaceDetectionViewController.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@interface POCFaceDetectionViewController ()

@end

@implementation POCFaceDetectionViewController

@synthesize previewView;
@synthesize inclinationIndicatorView;
@synthesize motionManager;
@synthesize cameraButton;
@synthesize statusLabel;
@synthesize faceMask;
@synthesize photoPreview;

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
    [self setupAVCapture];
    [self startDeviceMotion];
    
    cameraButton.enabled = NO;
    photoPreview.hidden = YES;
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Face Detection


-(void) setupAVCapture
{
    // Create a new AVCaptureSession
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPreset640x480];
    AVCaptureDevice *device = [self frontCamera];
    NSError *error = nil;
    
    // Want the normal device
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if(input) {
        // Add the input to the session
        [_session addInput:input];
    } else {
        NSLog(@"error: %@", error);
        return;
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // Have to add the output before setting metadata types
    [_session addOutput:output];
    // What different things can we register to recognise?
    NSLog(@"%@", [output availableMetadataObjectTypes]);
    // We're only interested in faces
    // [output setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
    // This VC is the delegate. Please call us on the main queue
    
    
    output.metadataObjectTypes = [self metadataOutput:output allowedObjectTypes:self.faceMetadataObjectTypes];
    
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Prepare an output for snapshotting
    _stillImageOutput = [AVCaptureStillImageOutput new];
    [_session addOutput:_stillImageOutput];
    _stillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
    
    // Display on screen
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.bounds = self.previewView.bounds;
    _previewLayer.position = CGPointMake(CGRectGetMidX(self.previewView.bounds), CGRectGetMidY(self.previewView.bounds));
    [self.previewView.layer addSublayer:_previewLayer];
    // Start the AVSession running
    [_session startRunning];
}

-(AVCaptureDevice *) frontCamera
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if([device position] == AVCaptureDevicePositionFront){
            return device;
        }
        
    }
    
    return nil;
}
- (NSArray *)faceMetadataObjectTypes
{
	return @
	[
	 AVMetadataObjectTypeFace
	 ];
}



- (NSArray *)metadataOutput:(AVCaptureMetadataOutput *)metadataOutput
		 allowedObjectTypes:(NSArray *)objectTypes
{
	NSSet *available = [NSSet setWithArray:metadataOutput.availableMetadataObjectTypes];
    
	[available intersectsSet:[NSSet setWithArray:objectTypes]];
    
	return [available allObjects];
}


#pragma mark - Take Picture
- (IBAction)takePictureAction:(id)sender
{
    [self stopDeviceMotion];
    AVCaptureConnection *stillConnection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:stillConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if(error) {
            NSLog(@"There was a problem");
            return;
        }
        
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        
        _previewLayer.hidden = YES;
        
        self.previewView.hidden = NO;
        self.faceMask.backgroundColor = [UIColor whiteColor];
        self.faceMask.hidden = NO;
        self.statusLabel.text = @"Procesando..";
        self.statusLabel.hidden = NO;
        inclinationIndicatorView.hidden = YES;
        
        
        CIImage *image = [CIImage imageWithData:jpegData];
        [self imageContainsSmiles:image callback:^(BOOL happyFace) {
            UIImage *smileyImage = [UIImage imageWithData:jpegData];
            if(happyFace) {
                
                
                self.statusLabel.text = @"Fue una buena foto";
                cameraButton.hidden = YES;
                self.photoPreview.image = smileyImage;
                
                photoPreview.hidden = NO;
                
            } else {
                self.statusLabel.text = @"Mala foto...";
                self.photoPreview.image = smileyImage;
                photoPreview.hidden = NO;
            }
            
            [_session stopRunning];
            
        }];
        
        
        
    }];
}


#pragma mark -Motion Detection

- (void)startDeviceMotion {
    // Create a CMMotionManager
    motionManager = [[CMMotionManager alloc] init];
    
    // Tell CoreMotion to show the compass calibration HUD when required
    // to provide true north-referenced attitude
    motionManager.showsDeviceMovementDisplay = YES;
    motionManager.deviceMotionUpdateInterval = 2.0 / 60.0;
    
    NSTimeInterval delta = 0.005;
    NSTimeInterval updateInterval = 1 + delta * 100;
    
    // Attitude that is referenced to true north
    [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
    [motionManager setDeviceMotionUpdateInterval:updateInterval];
    
    [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        
        CGFloat angle =  atan2( motion.gravity.x, motion.gravity.y);
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        self.inclinationIndicatorView.transform = transform;
        CGFloat factorGravity =motion.gravity.z*1000;
        
        if(factorGravity >= -50.0 && factorGravity <= 50.0){
            inclinationIndicatorView.backgroundColor =  [UIColor greenColor];
            cameraButton.enabled = YES;
            
        }else{
            inclinationIndicatorView.backgroundColor =  [UIColor redColor];
            cameraButton.enabled = NO;
        }
        
    }];
}

- (void)stopDeviceMotion {
    [motionManager stopDeviceMotionUpdates];
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

#pragma mark - AVCaptureMetadataOutputObjectsDelegate methods
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    
    NSLog(@"captureOutput");
}

- (void)imageContainsSmiles:(CIImage *)image callback:(void (^)(BOOL happyFace))callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if(!_ciContext) {
            _ciContext = [CIContext contextWithOptions:nil];
        }
        
        if(!_faceDetector) {
            _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:_ciContext options:nil];
        }
        
        // Perform the detections
        NSArray *features = [_faceDetector featuresInImage:image
                                                   options:@{CIDetectorEyeBlink: @YES,
                                                             CIDetectorAccuracyHigh:@YES,
                                                             CIDetectorImageOrientation: @5}];
        
        BOOL happyPicture = NO;
        if([features count] > 0) {
            happyPicture = YES;
        }
        for(CIFeature *feature in features) {
            if ([feature isKindOfClass:[CIFaceFeature class]]) {
                CIFaceFeature *faceFeature = (CIFaceFeature *)feature;
                
                if(faceFeature.leftEyeClosed || faceFeature.rightEyeClosed) {
                    happyPicture = NO;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(happyPicture);
        });
    });
}


@end
