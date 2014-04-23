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
@synthesize inRect;
@synthesize outRect;

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
    
    
}

-(void) setupAVCapture
{
    NSError *error = nil;
    session = [AVCaptureSession new];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	    [session setSessionPreset:AVCaptureSessionPreset640x480];
	else
	    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDevice *device = [self frontCamera];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if ( [session canAddInput:deviceInput] )
		[session addInput:deviceInput];
    
    
    videoDataOutput = [AVCaptureVideoDataOutput new];
    
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
									   [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[videoDataOutput setVideoSettings:rgbOutputSettings];
	[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    if ( [session canAddOutput:videoDataOutput] )
		[session addOutput:videoDataOutput];
	[[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
	
	effectiveScale = 1.0;
	previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	//[previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
	CALayer *rootLayer = [previewView layer];
	[rootLayer setMasksToBounds:YES];
	[previewLayer setFrame:[rootLayer bounds]];
	[rootLayer addSublayer:previewLayer];
	[session startRunning];
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





// called asynchronously as the capture output is capturing sample buffers, this method asks the face detector (if on)
// to detect features and for each draw the red square in a layer and set appropriate orientation
- (void)drawFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation
{
    
    //NSLog(@".");
    
	NSInteger featuresCount = [features count], currentFeature = 0;
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    
	if ( featuresCount == 0 || !detectFaces ) {
		[CATransaction commit];
        
        [self setMessageShown:@"searchingFace"];
        
		return; // early bail.
	}
    
	CGSize parentFrameSize = [previewView frame].size;
	NSString *gravity = [previewLayer videoGravity];
	//BOOL isMirrored = [previewLayer isMirrored];
	CGRect previewBox = [POCFaceDetectionViewController videoPreviewBoxForGravity:gravity
                                                              frameSize:parentFrameSize
                                                           apertureSize:clap.size];
    
    CIFaceFeature *ff = [features objectAtIndex:0];
    
    // find the correct position for the square layer within the previewLayer
    // the feature box originates in the bottom left of the video frame.
    // (Bottom right if mirroring is turned on)
    faceRect = [ff bounds];
    
    // flip preview width and height
    CGFloat temp = faceRect.size.width;
    faceRect.size.width = faceRect.size.height;
    faceRect.size.height = temp;
    temp = faceRect.origin.x;
    faceRect.origin.x = faceRect.origin.y;
    faceRect.origin.y = temp;
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
    CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
    faceRect.size.width *= widthScaleBy;
    faceRect.size.height *= heightScaleBy;
    faceRect.origin.x *= widthScaleBy;
    faceRect.origin.y *= heightScaleBy;
    
    faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
    
    [faceSquare setHidden:NO];
    
    BOOL outOfInnerRect;
    BOOL inOfOuterRect;
    
    // Actual face frame
    CGRect aff = CGRectOffset (faceRect, 14, 12);
    
    if(CGRectGetMinX(aff) < CGRectGetMinX(inRect.frame) &&
       CGRectGetMinY(aff) < CGRectGetMinY(inRect.frame) &&
       CGRectGetMaxX(aff) > CGRectGetMaxX(inRect.frame) &&
       CGRectGetMaxY(aff) > CGRectGetMaxX(inRect.frame)
       ){
        outOfInnerRect = YES;
    }else{
        outOfInnerRect = NO;
    }
    
    if(CGRectGetMinX(aff) > CGRectGetMinX(outRect.frame) &&
       CGRectGetMinX(aff) > CGRectGetMinX(outRect.frame) &&
       CGRectGetMaxX(aff) < CGRectGetMaxX(outRect.frame) &&
       CGRectGetMaxY(aff) < CGRectGetMaxY(outRect.frame)
       ){
        inOfOuterRect = YES;
    }else{
        inOfOuterRect = NO;
    }
    
    if (outOfInnerRect && inOfOuterRect) {
        NSLog(@"Dentro");
        [self setMessageShown:@"keepStill"];
    }else{
        NSLog(@"Fuera");
        [self setMessageShown:@"alignFace"];
    }
    
    currentFeature++;
	
	[CATransaction commit];
    
}

// find where the video box is positioned within the preview layer based on the video size and gravity
+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
	
	CGRect videoBox;
	videoBox.size = size;
	if (size.width < frameSize.width)
		videoBox.origin.x = (frameSize.width - size.width) / 2;
	else
		videoBox.origin.x = (size.width - frameSize.width) / 2;
	
	if ( size.height < frameSize.height )
		videoBox.origin.y = (frameSize.height - size.height) / 2;
	else
		videoBox.origin.y = (size.height - frameSize.height) / 2;
    
	return videoBox;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	// got an image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
	if (attachments)
		CFRelease(attachments);
	NSDictionary *imageOptions = nil;
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	int exifOrientation;
	
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
	};
	
	switch (curDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}
    
	imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
	NSArray *features = [faceDetector featuresInImage:ciImage options:imageOptions];
	
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
	CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
	CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
	
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[self drawFaceBoxesForFeatures:features forVideoBox:clap orientation:curDeviceOrientation];
	});
}

// utility routing used during image capture to set up capture orientation
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
	AVCaptureVideoOrientation result = deviceOrientation;
	if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
		result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}

- (IBAction)takePictureAction:(id)sender {
    
    // Find out the current orientation and tell the still image output.
	AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
	[stillImageConnection setVideoOrientation:avcaptureOrientation];
	[stillImageConnection setVideoScaleAndCropFactor:effectiveScale];
	
    
    [stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG
                                                                    forKey:AVVideoCodecKey]];
	
    
    
    
    
	[stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (error) {
            [self displayErrorOnMainQueue:error withMessage:@"Take picture failed"];
        }else {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            face = [[UIImage alloc] initWithData:imageData];
            
            
            NSLog(@"Picture?0 %@ - size: %fx%f", face, face.size.width, face.size.height);
            
            
            
        }
    }];
}

- (void)setupEverythingFaceDetectionRelated{
    
    [self setupAVCapture];
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
	faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    
    [self toggleFaceDetection:nil];
    
    [self performSelector:@selector(setMessageShown:) withObject:@"searchingFace"afterDelay:0.2f];
}

// turn on/off face detection
- (IBAction)toggleFaceDetection:(id)sender
{
    
	detectFaces = YES;
	[[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:detectFaces];
	if (!detectFaces) {
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			// clear out any squares currently displaying.
			[self drawFaceBoxesForFeatures:[NSArray array] forVideoBox:CGRectZero orientation:UIDeviceOrientationPortrait];
		});
	}
}
- (void)setMessageShown:(NSString *)messageShown{
    
    NSLog(@"setMessageShown %@", messageShown);
    
//    if (stopAnimations)
//        return;
//    
//    NSString * old = [self messageShown];
//    NSString * new = messageShown;
//    
//    NSString * text;
//    NSString * imageName;
//    
//    float delay = 0;
//    BOOL hide = NO;
//    
//    _messageShown = messageShown;
//    
//    float duration = 0.3f;
//    
//    if(![old isEqualToString:new] && old){
//        delay = duration;
//        hide = YES;
//    }
//    
//    if ([messageShown isEqualToString:@"searchingFace"]) {
//        
//        text = @"Buscando cara...";
//        imageName = @"User2";
//        
//        
//        
//    }else if ([messageShown isEqualToString:@"alignFace"]) {
//        
//        text = @"Superpón ambos cuadros";
//        imageName = @"BackToTheFore";
//        
//        
//        
//    }else if ([messageShown isEqualToString:@"keepStill"]){
//        
//        text = @"¡Quédate quieto!";
//        imageName = @"Hand";
//        
//        
//        
//        if (!filling)
//            [self fillBar];
//    }
//    /*
//     if (hide) {
//     NSLog(@"hiding first");
//     }else{
//     NSLog(@"no hiding");
//     }*/
//    
//    if(hide){
//        
//        [self unfillBar];
//        
//        [UIView
//         animateWithDuration:.0
//         animations:^(void){}
//         completion:^(BOOL finished){
//             [UIView
//              animateWithDuration:duration
//              delay:0.0
//              options:UIViewAnimationOptionCurveEaseOut
//              animations:^{
//                  CGRect f = messageView.frame;
//                  
//                  f.origin.y += 44;
//                  messageView.frame = f;
//                  
//              }
//              completion:^(BOOL finished){
//                  [self setMessageWithText:text andImageNamed:imageName];
//                  NSLog(@"Frame: %@", NSStringFromCGRect(messageView.frame));
//                  [UIView
//                   animateWithDuration:duration
//                   delay:0.0
//                   options:UIViewAnimationOptionCurveEaseOut
//                   animations:^{
//                       CGRect f = messageView.frame;
//                       f.origin.y -= 44;
//                       messageView.frame = f;
//                   }
//                   completion:nil];
//                  NSLog(@"Frame: %@", NSStringFromCGRect(messageView.frame));
//              }];}
//         ];
//    }else if(![old isEqualToString:new]){
//        [self setMessageWithText:text andImageNamed:imageName];
//        NSLog(@"Frame: %@", NSStringFromCGRect(messageView.frame));
//        [UIView animateWithDuration:duration delay:0.0
//                            options:UIViewAnimationOptionCurveEaseOut
//                         animations:^{
//                             CGRect f = messageView.frame;
//                             f.origin.y -= 44;
//                             messageView.frame = f;
//                         }
//                         completion:nil];
//        NSLog(@"Frame: %@", NSStringFromCGRect(messageView.frame));
//    }
}

// utility routine to display error aleart if takePicture fails
- (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%d)", message, (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil
												  cancelButtonTitle:@"Dismiss"
												  otherButtonTitles:nil];
		[alertView show];
	});
}
@end
