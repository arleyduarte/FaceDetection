//
//  EnrollmentQueueManager.m
//  SPF
//
//  Created by Marco Torres Morgado on 03-01-13.
//
//

#import "EnrollmentQueueManager.h"

@implementation EnrollmentQueueManager

-(id)init{
    
    self = [super init];
    
    return self;
    
}

-(void)proceed{
    [self setEnrollmentData:[EnrollmentDataManager getAllEnrollments]];
    
    //EnrollmentQueueViewController * view = [[EnrollmentQueueViewController alloc] initWithEnrollmentData:[self enrollmentData]];

   // [self setQueueView:view];
    
    queue_size = 5;

    
    //NSLog(@"To check");
    
//    [self listAllPictures];
    
//    [self changePhotoStatus:@"5572.2" to:100];
//    [self changePhotoStatus:@"5572.3" to:100];
    
//    [self listAllPictures];
//    NSLog(@"VERSIONASDASD: %@", [self getEnrollmentIDFromCoordinates:@"5572.3"]);
    
    //[self initQueue];
    
    //NSLog(@"Queue: %@", queue);
    
    //Detenido [self processQueuedPhotos];
    
    
    
    [self firstSteps];
    
}

# pragma mark - Process

-(void)firstSteps{
    
    checks = [[NSMutableDictionary alloc] init];
    
    [self prepareLocalEnrollments];
    
}

// Iterate over PENDING enrollments then check and change its status.
-(void)prepareLocalEnrollments{
    
    for (NSMutableDictionary * enrollment in [self enrollmentData]) {
        
        if([[enrollment objectForKey:@"status"] intValue] == PENDING){
            
            starting_queue = YES;
            
            [self checkStatus:[enrollment objectForKey:@"enrollment_id"]];
        }
        
    }
    
    if (starting_queue){
        [self performSelector:@selector(checkEnrollmentStatus) withObject:nil afterDelay:1];
    }else{
        watcher = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkRequestsStatus) userInfo:nil repeats:YES];
        [self performSelector:@selector(checkEnrollmentStatus)];
    }
    
}

// Create the queue with only true PENDING enrollments
-(void)initQueue{
    
    starting_queue = NO;
    
    requests = [[NSMutableDictionary alloc] init];
    
    NSMutableArray * newQueue = [[NSMutableArray alloc] init];
    
    int i;
    for (i=0; i<queue_size; i++) {
        
        id nextPhoto = [self getNextPhotoToProcess];
        
        if(nextPhoto != [NSNull null]){
            [newQueue addObject:nextPhoto];
            [self changePhotoStatus:nextPhoto to:P_QUEUED];
        }else{
            [newQueue addObject:[NSNull null]];
        }
    }
    
    queue = [NSArray arrayWithArray:newQueue];
    
    [self processQueuedPhotos];
    
    watcher = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkRequestsStatus) userInfo:nil repeats:YES];
}

- (void)processQueuedPhotos{
    
    int i;
    for (i=0; i<[queue count]; i++) {
        
        // If not NULL
        if (![[queue objectAtIndex:i] isEqual:[NSNull null]]){
            
            if([self getStatusForPhotoCoordinates:[queue objectAtIndex:i]] == P_QUEUED){
                
                NSLog(@"* Composing request for photo: %@", [queue objectAtIndex:i]);
                
                UIImage * photo = [EnrollmentDataManager getPictureWithCoordinate:[queue objectAtIndex:i]];
                
                NSString * enrollment_id = [self getEnrollmentIDFromCoordinates:[queue objectAtIndex:i]];
                
                
                //NSLog(@"Photo: %@", photo);
                //NSLog(@"ID: %@", enrollment_id);
                
                
                
                //OldSPFAPICall * request = [[OldSPFAPICall alloc] createSubmitEnrollmentPicture: photo forID: enrollment_id];
                
                EnrollmentPicture * request = [[EnrollmentPicture alloc] initWithEnrollmentID:[enrollment_id intValue] andFace:photo];
                
                [request submitFaceWithBlock:nil];
                
                [requests setObject:request forKey:[queue objectAtIndex:i]];
                
                [self changePhotoStatus:[queue objectAtIndex:i] to:P_WAITING];
            }
        }
    }
    
    NSLog(@"Requests generados: %@", requests);
    
    //[self refillQueue];
    
    /*
     statusBar.text = @"Sincronizando...";
     
     syncRequest = [[SPFAPICall alloc] createSyncRequest:YES];
     
     waitingSyncRequest = [NSTimer scheduledTimerWithTimeInterval:1 target:self  selector:@selector(checkRequestStatus) userInfo:nil repeats:YES];
     */
}

-(void)checkRequestsStatus{
    
    //NSLog(@"Queue antes de check: %@", queue);
    
    NSMutableDictionary * newRequests = [[NSMutableDictionary alloc] init];
    
    BOOL something_finished = NO;
    
    //NSLog(@"En requests: %i", [requests count]);
    
    /*
    
    for(NSString * key in requests) {
        
        OldSPFAPICall * request = [requests objectForKey:key];
        
        NSLog(@"*** Checking status for request %@", key);
        
        if ([[request status] intValue] != WAITING) {
            if ([[request status] intValue] == REQUEST_OK) {
                
                NSLog(@"*** Request %@ done.", key);
                
                [self changePhotoStatus:key to:P_DONE];
                
                something_finished = YES;
                
            }else{
                
                NSLog(@"*** Request %@ failed. Result: %@", key, [request result_dict]);
                [self changePhotoStatus:key to:P_FAILED];
                
                something_finished = YES;
            }
            
            
            NSString * enrollment_id = [NSString stringWithFormat:@"%i", [key intValue]];
            
            if(something_finished && ![self checkIfTheresSomethingElseToDoWithEnrollment:enrollment_id]){
                
                NSLog(@"Entró! (%@)", enrollment_id);
                
                [self checkStatus:enrollment_id];
                
            }else{
                NSLog(@"No entró");
            }
            
        }else{
            NSLog(@"*** Waiting for request %@", key);
            
            [newRequests setObject:request forKey:key];
            // Eventualmente implementar mecanismo que marque las fotos como P_SENT si se lleva mucho tiempo sin respuesta.
        }
        
    }
     
     */
    
    
    requests = newRequests;
    
    /*if(something_finished){
        NSLog(@"*************************");
        NSLog(@"* Queue: %@", queue);
        NSLog(@"* Requests: %@", requests);
        
        [self performSelector:@selector(refillQueue)];
    }*/
}

# pragma mark - Utilities

- (BOOL)checkIfTheresSomethingElseToDoWithEnrollment: (NSString *)enrollment_id{
    
    for (NSMutableDictionary * enrollment in [self enrollmentData]) {
        
        if([[enrollment objectForKey:@"enrollment_id"] isEqualToString:enrollment_id]){
            
          
            for (NSString* photo_status in [enrollment objectForKey:@"photo_status"]) {
                
                if ([photo_status intValue] == P_WAITING ||
                    [photo_status intValue] == P_STOPPED ||
                    [photo_status intValue] == P_QUEUED) {
                    return YES;
                }
                
            }
            
            
        }
        
    }
    
    
    return NO;
}

- (void)updateEnrollmentDataIfThereIsntAnyElementOnQueue{
    if([self queueIsEmpty]){
        NSLog(@"Queue is empty");
        [self setEnrollmentData:[EnrollmentDataManager getAllEnrollments]];
       
       // [[self queueView] addNewEnrollmentToView:[[self enrollmentData] objectAtIndex:[[self enrollmentData] count]-1]];

        [self performSelector:@selector(refillQueue)];

        
    }else{
        NSLog(@"Queue isn't empty");
        [self performSelector:@selector(updateEnrollmentDataIfThereIsntAnyElementOnQueue) withObject:nil afterDelay:2];
    }
}

- (void)deleteAllEnrollments{
    
    for (NSMutableDictionary * enrollment in _enrollmentData) {
        
        [EnrollmentDataManager deleteEnrollment:enrollment];
        
    }
        
    [self setEnrollmentData:[EnrollmentDataManager getAllEnrollments]];
        
    // update view;
    
//    [self performSelector:@selector(refillQueue)];
//    [self performSelector:@selector(createEmptyQueue)];
    
    //[requests dealloc];
    //requests = [[NSMutableDictionary alloc] init];
    
    dontCheckAnymore = YES;
    
   // [_queueView reloadViewWithDataSource:_enrollmentData];
    
}

- (void)deleteFinishedEnrollments{
    
    for (NSMutableDictionary * enrollment in _enrollmentData) {
        
        if ([[enrollment objectForKey:@"status"] intValue] == FINISHED) {
            [EnrollmentDataManager deleteEnrollment:enrollment];
        }
    
        
    }
    
    [self setEnrollmentData:[EnrollmentDataManager getAllEnrollments]];
    
    //[_queueView reloadViewWithDataSource:_enrollmentData];
    
}


-(NSString *)getEnrollmentIDFromCoordinates: (NSString *)coordinates{
    
    
    NSArray *listItems = [coordinates componentsSeparatedByString:@"."];
    
    return [listItems objectAtIndex:0];
    
}


-(void)changeStatusOfEnrollment: (NSMutableDictionary *)enrollment to: (int)status{

    [enrollment setValue:[NSNumber numberWithInt:status] forKey:@"status"];
    
    [EnrollmentDataManager updateEnrollment:enrollment];
    
    NSLog(@"Enrollment changed: %@", enrollment);
    
   // [_queueView updateEnrollment: enrollment];
}

-(void)changeStatusForEnrollmentID: (NSString *) enrollment_id to: (int)status{
        
    NSEnumerator *e = [[self enrollmentData] objectEnumerator];
        
    NSMutableDictionary *enrollment;
    
    while (enrollment = [e nextObject]) {
        
        if ([[enrollment objectForKey:@"enrollment_id"] isEqualToString:enrollment_id]) {
            
            if (status == FINISHED) {
                [self changeAllPhotoStatusTo:P_DONE forEnrollment:enrollment];
            }
            if (status == PENDING /*&& starting_queue*/) {
                [self changeAllPendingPhotosToStoppedForEnrollment:enrollment];
            }
            
            [self changeStatusOfEnrollment:enrollment to:status];
        }
    }
    
}

-(void)actionRequiredForID: (NSString *)enrollment_id{
    NSLog(@"Llamada desde enrolamiento %@", enrollment_id);
    //[self sendPicturesOfEnrollmentID:enrollment_id];
    

    //NSLog(@"Next enrollment: %@", [self getTheFirstAvailableEnrollmentPicture]);
    
}

-(int)getStatusForPhotoCoordinates: (NSString *)coordinates{
   
    NSEnumerator *e = [[self enrollmentData] objectEnumerator];
    
    NSMutableDictionary *enrollment;
    
    while (enrollment = [e nextObject]) {
        
        int i;
        for (i=0; i<[[enrollment objectForKey:@"photo_status"] count]; i++) {
            
            NSString * this_coordinates = [NSString stringWithFormat:@"%@.%i",[enrollment objectForKey:@"enrollment_id"], i+1];
            
            int status = [[[enrollment objectForKey:@"photo_status"] objectAtIndex:i] intValue];
            
            if([coordinates isEqualToString:this_coordinates]){
                return status;
            }
            
        }
        
    }
    return -1;
    
}

-(void)listAllPictures{
    
    NSEnumerator *e = [[self enrollmentData] objectEnumerator];
    
    NSMutableDictionary *enrollment;
    
    while (enrollment = [e nextObject]) {
        
        int i;
        for (i=0; i<[[enrollment objectForKey:@"photo_status"] count]; i++) {
            //NSLog(@"Photo: %@.%i - Status: %@", [enrollment objectForKey:@"enrollment_id"], i+1, [[enrollment objectForKey:@"photo_status"] objectAtIndex:i]);
        }
        
    }
}

// "Coordinates" parameter follows the format enrollment_id.photo_number
// Ex. 1567.1 (first photo of the enrollment 1567.
-(void)changePhotoStatus: (NSString *) coordinates to: (int) new_status{

    NSEnumerator *e = [[self enrollmentData] objectEnumerator];
    
    NSMutableDictionary *enrollment;
    
    while (enrollment = [e nextObject]) {
        
        int i;
        for (i=0; i<[[enrollment objectForKey:@"photo_status"] count]; i++) {
            
            NSString * this_coordinates = [NSString stringWithFormat:@"%@.%i",[enrollment objectForKey:@"enrollment_id"], i+1];
            
            //int status = [[[enrollment objectForKey:@"photo_status"] objectAtIndex:i] intValue];
            
            if([coordinates isEqualToString:this_coordinates]){
                //change
                NSMutableArray * statuses = [[enrollment objectForKey:@"photo_status"] mutableCopy];
                
                [statuses replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:new_status]];
    
                [enrollment setObject:statuses forKey:@"photo_status"];
                
                [EnrollmentDataManager updateEnrollment:enrollment];
                
                //[_queueView updateEnrollment: enrollment];
            }
            
        }
        
    }
    
}

-(void)changeAllPhotoStatusTo: (int) new_status forEnrollment: (NSMutableDictionary *) enrollment{
        
            NSMutableArray * statuses = [[enrollment objectForKey:@"photo_status"] mutableCopy];
            
            int i;
            for (i=0; i<[[enrollment objectForKey:@"photo_status"] count]; i++) {

                    [statuses replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:new_status]];
                
                }
            
            [enrollment setObject:statuses forKey:@"photo_status"];
            
            [EnrollmentDataManager updateEnrollment:enrollment];
    
    if (new_status == P_DONE) {
       // [_queueView updateEnrollment: enrollment];
        
        [self refillQueue];
    }
            
}

-(void)changeAllPendingPhotosToStoppedForEnrollment: (NSMutableDictionary *) enrollment{
    
    NSMutableArray * statuses = [[enrollment objectForKey:@"photo_status"] mutableCopy];
    
    int i;
    for (i=0; i<[[enrollment objectForKey:@"photo_status"] count]; i++) {
        
        if ([[statuses objectAtIndex:i] intValue] == P_QUEUED ||
            [[statuses objectAtIndex:i] intValue] == P_WAITING ||
            [[statuses objectAtIndex:i] intValue] == P_FAILED
            ) {
        
        [statuses replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:P_STOPPED]];
        }
        
    }
    
    [enrollment setObject:statuses forKey:@"photo_status"];
    
    [EnrollmentDataManager updateEnrollment:enrollment];
    
    [self performSelector:@selector(refillQueue)];
    
}

-(id)getNextPhotoToProcess{

    NSArray * tempEnrollmentData = [NSArray arrayWithArray:[self enrollmentData]];
    
    NSEnumerator *e = [tempEnrollmentData objectEnumerator];
    
    NSMutableDictionary *enrollment;
    
    while (enrollment = [e nextObject]) {
        
        if([[enrollment objectForKey:@"status"] intValue] == PENDING){
            int i;
            for (i=0; i<[[enrollment objectForKey:@"photo_status"] count]; i++) {
                //NSLog(@"Photo: %@.%i - Status: %@", [enrollment objectForKey:@"enrollment_id"], i+1, [[enrollment objectForKey:@"photo_status"] objectAtIndex:i]);
                
                int photo_status = [[[enrollment objectForKey:@"photo_status"] objectAtIndex:i] intValue];
                
                NSString * this_coordinates = [NSString stringWithFormat:@"%@.%i",[enrollment objectForKey:@"enrollment_id"], i+1];
                
                if (photo_status == P_STOPPED) {
                    return this_coordinates;
                }
            }
            
        }
        
    }
    
    return [NSNull null];
    
}

-(void)refillQueue{
    
    NSMutableArray * newQueue = [[NSMutableArray alloc] init];
    
    int i;
    for (i=0; i<[queue count]; i++) {
        
        if(![[queue objectAtIndex:i] isEqual:[NSNull null]]){
            int status = [self getStatusForPhotoCoordinates:[queue objectAtIndex:i]] ;
            
            if(status == P_QUEUED   &&
               status == P_WAITING  &&
               status == P_SENT){
                
                // Keep it on the queue.
                [newQueue addObject:[queue objectAtIndex:i]];
            
            }else{
                // Don't.
            }
        }
    }
    
    int new_size = [newQueue count];
    
    for(i=0; i<(queue_size - new_size);i++){
        
        id nextPhoto = [self getNextPhotoToProcess];
        
        if(nextPhoto != [NSNull null]){
            [newQueue addObject:nextPhoto];
            [self changePhotoStatus:nextPhoto to:P_QUEUED];
        }else{
            [newQueue addObject:[NSNull null]];
        }
        
    }
    
    
    queue = [NSArray arrayWithArray:newQueue];
    
    //[self processQueuedPhotos];
    [self performSelector:@selector(processQueuedPhotos)];
    
}

- (void)createEmptyQueue{
    
    NSMutableArray * newQueue = [[NSMutableArray alloc] init];
    
    int i = 0;
    for (i=0; i<queue_size; i++) {
        [newQueue addObject:[NSNull null]];
    }
    
    queue = [NSArray arrayWithArray:newQueue];
    
}

- (BOOL)queueIsEmpty{

    for (id element in queue) {
        if (![element isEqual:[NSNull null]]) {
            return NO;
        }
    }
    return YES;
    
}

# pragma mark - Check enrollment online status

- (void)checkStatus: (NSString *) enrollment_id{

    /*
    
    OldSPFAPICall * enrollmentStatusRequest = [[OldSPFAPICall alloc] createCheckEnrollmentStatus:[NSNumber numberWithInt:[enrollment_id intValue]]];
    
    [checks setObject:enrollmentStatusRequest forKey:enrollment_id];
     */
    
}

- (void)checkEnrollmentStatus{
    
    if ([checks count] > 0)
        NSLog(@"* Checking enrollments status");
    
    NSMutableDictionary * new_checks = [[NSMutableDictionary alloc] init];
    
    
    /*
     · Resend the enrollment  : create it again then add it to the new dict.
     · Recheck the enrollment : add the request to the new dict.
     · Reply received         : change the enrollment status without add it to the new dict.
    */
//    
//    for (NSString* key in checks) {
////        id value = [xyz objectForKey:key];
//        
//        NSLog(@"** Checking enrollment %@", key);
//        
//        OldSPFAPICall* request = [checks objectForKey:key];
//        
//        if ([[request status] intValue] != WAITING) {
//            
//            // There's a reply
//            NSLog(@"** We've got a reply");
//            
//            if ([[request status] intValue] == REQUEST_OK) {
//                
//                NSLog(@"** And it's a valid one");
//                
//                
//                int enrollment_status = [[[request result_dict] objectForKey:@"status"] intValue];
//                
//                int set_status;
//                
//                // set_status = FINISHED means that the device hasn't anything else to do with this enrollment.
//                
//                switch (enrollment_status) {
//                    case 20:
//                        NSLog(@"** Enrollment %@ PENDING", key);
//                        set_status = FINISHED;
//                        break;
//                        
//                    case 30:
//                        NSLog(@"** Enrollment %@ SYNCED", key);
//                        set_status = FINISHED;
//                        break;
//                    
//                    case 10:
//                        NSLog(@"** Enrollment %@ RECEIVING", key);
//                        set_status = PENDING;
//                        break;
//                        
//                    default:
//                        NSLog(@"** Enrollment %@ FAILED", key);
//                        set_status = FINISHED;
//                        break;
//                }
//            
//                [self changeStatusForEnrollmentID:key to:set_status];
//            
//                
//            }else{
//                
//                NSLog(@"** Aparently the request failed. We will resend it");
//                if(dontCheckAnymore){
//                    NSLog(@"Flagged as Don't Check Anymore");
//                    dontCheckAnymore = NO;
//                }else{
//                    request = nil;
//                    request = [[OldSPFAPICall alloc] createCheckEnrollmentStatus:[NSNumber numberWithInt:[key intValue]]];
//                
//                    [new_checks setObject:request forKey:key];
//                }
//            }
//            
//        }else{
//            
//            // There isn't
//            NSLog(@"** Waiting for a reply");
//            [new_checks setObject:request forKey:key];
//            
//        }
//        
//    }
//    
//    checks = new_checks;
//    
////    NSLog(@"Cantidad de checks: %i", [checks count]);
//    if(starting_queue && [checks count]<1){
//        [self performSelector:@selector(initQueue)];
//    }
//    
//    
//    [self performSelector:@selector(checkEnrollmentStatus) withObject:nil afterDelay:1.0f];
    
    
    
}

@end
