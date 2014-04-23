//
//  EnrollmentPicture.h
//  POCApp
//
//  Created by Marco Torres Morgado on 25-03-13.
//  Copyright (c) 2013 SPF S.A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResultCodes.h"

#ifndef SPF_SPFAPIEndStates_h
#define SPF_SPFAPIEndStates_h

#define WAITING             0
#define REQUEST_OK          10
#define GENERIC_ERROR       20
#define CALL_FAILED         21
#define JSON_PARSE_FAILED   22
#define UNKNOW_SERVER_ERROR 23
#define DEVICE_REJECTED     24
#define DEVICE_DISABLED     25

#define RESPONSE_INVALID_LEGAL_ID 26

#endif

@interface EnrollmentPicture : NSObject

@property (nonatomic, strong) UIImage * face;
@property (nonatomic, assign) NSInteger enrollment_id;
@property (nonatomic, strong) NSNumber * status;
@property (nonatomic, strong) NSDictionary * result_dict;

-(id)initWithEnrollmentID: (int) enrollment_id andFace: (UIImage*) face;


-(void)submitFaceWithBlock: (void (^)(id JSON, NSError * error))block;



@end
