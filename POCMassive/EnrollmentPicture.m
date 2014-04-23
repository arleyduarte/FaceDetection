//
//  EnrollmentPicture.m
//  POCApp
//
//  Created by Marco Torres Morgado on 25-03-13.
//  Copyright (c) 2013 SPF S.A. All rights reserved.
//

#import "EnrollmentPicture.h"
#import "POCAPIClient.h"

#import "Extras.h"

@implementation EnrollmentPicture


-(id)initWithEnrollmentID: (int) enrollment_id andFace: (UIImage*) face{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _enrollment_id = enrollment_id;
    _face = face;
    
    
    return self;
}

-(void)submitFaceWithBlock: (void (^)(id JSON, NSError * error))block{
    
//    NSMutableDictionary * parameters = [[Extras getBaseParametersForRequest] mutableCopy];
//    
//    [parameters setObject:[NSNumber numberWithInt:_enrollment_id] forKey:@"enrollment_id"];
//    
//    UIImage * faceResized = [Extras imageWithImage:_face scaledToSize:CGSizeMake(430/2, 554/2)];
//    
//    NSData *imageData = UIImageJPEGRepresentation(faceResized, 0.8f);
//    
//    NSLog(@"Dimensions: %f x %f", faceResized.size.width, faceResized.size.height);
//    
//    NSMutableURLRequest *request = [[POCAPIClient sharedClient] multipartFormRequestWithMethod:@"POST" path:@"/srv/poc/submitEnrollmentPicture" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
//        [formData appendPartWithFileData:imageData name:@"face" fileName:@"face" mimeType:@"image/jpeg"];
//    }];
//    
//    
//    AFHTTPRequestOperation *operation =
//    [[POCAPIClient sharedClient] HTTPRequestOperationWithRequest:request
//                                                         success:^(AFHTTPRequestOperation *operation, id json) {
//                                                             
//                                                             _result_dict = json;
//                                                             
//                                                             
//                                                             NSLog(@"Reply: %@", json);
//                                                             
//                                                             if(!_result_dict){
//                                                                 [self setStatus: [NSNumber numberWithInt: JSON_PARSE_FAILED]];
//                                                                 NSLog(@"** JSON parse failed **");
//                                                            
//                                                             }else{
//                                                                 //If the result parsed dict has no value or no key for "result"
//                                                                 if(![_result_dict valueForKey:@"result"]){
//                                                                     
//                                                                     [self setStatus: [NSNumber numberWithInt: UNKNOW_SERVER_ERROR]];
//                                                                 }
//                                                                 //Server returned a generic error
//                                                                 else if([[_result_dict valueForKey:@"result"] intValue] == RESPONSE_REJECTED){
//                                                                     
//                                                                     [self setStatus: [NSNumber numberWithInt: GENERIC_ERROR]];
//                                                                     
//                                                                 }
//                                                                 else if ([[_result_dict valueForKey:@"result"] intValue] == RESPONSE_DEVICE_UNAVAILABLE){
//                                                                     
//                                                                     [self setStatus: [NSNumber numberWithInt: DEVICE_REJECTED]];
//                                                                     
//                                                                 }
//                                                                 else if ([[_result_dict valueForKey:@"result"] intValue] == 19){
//                                                                     
//                                                                     [self setStatus: [NSNumber numberWithInt: DEVICE_REJECTED]];
//                                                                     
//                                                                 }
//                                                                 else if ([[_result_dict valueForKey:@"result"] intValue] == 8000){
//                                                                     
//                                                                     [self setStatus: [NSNumber numberWithInt: DEVICE_DISABLED]];
//                                                                     
//                                                                 }
//                                                                 //Request ok
//                                                                 else if([[_result_dict valueForKey:@"result"] intValue] == RESPONSE_OK){
//                                                                     
//                                                                     [self setStatus: [NSNumber numberWithInt: REQUEST_OK]];
//                                                                     
//                                                                 }
//                                                                 //Invalid legal_id
//                                                                 else if([[_result_dict valueForKey:@"result"] intValue] == 15){
//                                                                     
//                                                                     [self setStatus: [NSNumber numberWithInt: RESPONSE_INVALID_LEGAL_ID]];
//                                                                     
//                                                                 }
//                                                                 else{
//                                                                     
//                                                                     [self setStatus: [NSNumber numberWithInt: GENERIC_ERROR]];
//                                                                     
//                                                                 }
//                                                             }
//                                                             if (block) {
//                                                                 block(json, nil);
//                                                             }
//                                                         }
//                                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                                             NSLog(@"** Submit Picture Request failed **");
//                                                             [self setStatus: [NSNumber numberWithInt: CALL_FAILED]];
//                                                             if (block) {
//                                                                 block(nil, error);
//                                                             }
//                                                         }];
//    
//    
//    
//    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
//    }];
//    
//    [[POCAPIClient sharedClient] enqueueHTTPRequestOperation:operation];
    
    
}


@end
