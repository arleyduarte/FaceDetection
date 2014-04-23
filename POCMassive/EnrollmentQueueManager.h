//
//  EnrollmentQueueManager.h
//  SPF
//
//  Created by Marco Torres Morgado on 03-01-13.
//
//

#import <Foundation/Foundation.h>

#import "EnrollmentPicture.h"
#import "EnrollmentDataManager.h"

@interface EnrollmentQueueManager : NSObject{
    
    NSArray * queue;
    NSMutableDictionary * requests;
    
    int queue_size;
    
    NSTimer * watcher;
    
    NSMutableDictionary * checks;
    
    NSTimer * enrollmentStatusWatcher;
    
    BOOL starting_queue;
    
    BOOL dontCheckAnymore;
}

@property (nonatomic, strong) NSMutableArray *enrollmentData;


-(void)proceed;

-(void)actionRequiredForID: (NSString *)enrollment_id;

-(void)updateEnrollmentDataIfThereIsntAnyElementOnQueue;

-(void)firstSteps;

- (void)deleteAllEnrollments;

- (void)deleteFinishedEnrollments;

@end

