//
//  POCFaceDetectorViewController.m
//  POCMassive
//
//  Created by Arley Mauricio Duarte on 4/24/14.
//  Copyright (c) 2014 Arley Mauricio Duarte. All rights reserved.
//

#import "POCFaceDetectorViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>

@import AVFoundation;

@interface POCFaceDetectorViewController () <AVCaptureMetadataOutputObjectsDelegate> {
    AVCaptureVideoPreviewLayer *_previewLayer;
    AVCaptureStillImageOutput *_stillImageOutput;
    AVCaptureSession *_session;
    CIDetector *_faceDetector;
    CIContext *_ciContext;
}

@end

@implementation POCFaceDetectorViewController

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
//    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
//    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    _previewLayer.bounds = self.imageView.bounds;
//    _previewLayer.position = CGPointMake(CGRectGetMidX(self.imageView.bounds), CGRectGetMidY(self.imageView.bounds));
//    [self.imageView.layer addSublayer:_previewLayer];
//    
//    //self.imageView.hidden = YES;
//    // self.imageView.contentMode = UIViewContentModeScaleAspectFill;
//    self.retakeButton.hidden = NO;
//    
//    // Start the AVSession running
//    [_session startRunning];
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


- (IBAction)takePhotoAction:(id)sender {
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

@end
