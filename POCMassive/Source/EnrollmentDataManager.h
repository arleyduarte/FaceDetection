//
//  EnrollmentDataManager.m
//  POCMassive
//
//  Created by Arley Mauricio Duarte on 4/20/14.
//  Copyright (c) 2014 Arley Mauricio Duarte. All rights reserved.
//

#define PENDING             0
#define WORKING             10
#define STOPPED             20
#define FINISHED            30

#define P_STOPPED             100
#define P_QUEUED              150
#define P_WAITING             200
#define P_SENT                300
#define P_DONE                400
#define P_FAILED              500

#import <Foundation/Foundation.h>

@interface EnrollmentDataManager : NSObject

@property (nonatomic, strong) NSMutableDictionary * enrollmentData;

@property (nonatomic, strong) NSArray * faces;

- (id)initWithEnrollmentData: (NSDictionary *)data andFaces: (NSArray *)faces;

+ (id)readFilename: (NSString *)filename;

+ (NSArray *)getAllEnrollmentFilenames;

+ (NSString *)getEnrollmentDirectoryAndcreateItIfNecessary;

+ (NSMutableArray *)getAllEnrollments;

+ (NSArray *) getAllPicturesFromEnrollment: (NSString *)enrollment_id;

+(void)updateEnrollment: (NSDictionary *)enrollment;

+ (UIImage *) getPictureWithCoordinate: (NSString *)coordinate;

+ (void)deleteEnrollment: (NSMutableDictionary *) enrollment;

@end