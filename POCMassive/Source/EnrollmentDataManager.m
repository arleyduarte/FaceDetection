//
//  EnrollmentDataManager.m
//  POCMassive
//
//  Created by Arley Mauricio Duarte on 4/20/14.
//  Copyright (c) 2014 Arley Mauricio Duarte. All rights reserved.
//

//
//  EnrollmentDataManager.m
//  SPF
//
//  Created by Marco Torres Morgado on 24-12-12.
//
//

#import "EnrollmentDataManager.h"

@implementation EnrollmentDataManager

- (id)init{
    self = [super init];
    
    return self;
}

- (id)initWithEnrollmentData: (NSDictionary *)data andFaces: (NSArray *)faces{
    
    self = [self init];
    
    NSLog(@"Datos: %@", data);
    NSLog(@"Caras: %@", faces);
    
    self.enrollmentData = [[NSMutableDictionary alloc] init];
    self.faces = faces;
    
    [self fillEnrollmentDataDictionary:data];
    
    NSLog(@"Otros datos: %@", [self enrollmentData]);
    
    [self write:self.enrollmentData];
    
    return self;
}

+(NSString *)getEnrollmentDirectoryAndcreateItIfNecessary{
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *enrollmentPath = [rootPath stringByAppendingPathComponent:@"enrollment"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:enrollmentPath]){
        
        NSError* error;
        
        if(  [[NSFileManager defaultManager] createDirectoryAtPath:enrollmentPath withIntermediateDirectories:NO attributes:nil error:&error])
            NSLog(@"Success");// success
        else
        {
            NSLog(@"[%@] ERROR: attempting to write create MyFolder directory", [self class]);
            NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
        }
    }
    
    return enrollmentPath;
}

- (void)fillEnrollmentDataDictionary: (NSDictionary *)data{
    
    //    NSMutableDictionary * temp = [[NSMutableDictionary alloc] init];
    
    if([data objectForKey:@"enrollment_id"]){
        
        [[self enrollmentData] setObject:[NSString stringWithFormat:@"%@", [data objectForKey:@"enrollment_id"]] forKey:@"enrollment_id"];
    }
    
    if([data objectForKey:@"legal_id"]){
        
        [[self enrollmentData] setObject:[NSString stringWithFormat:@"%@", [data objectForKey:@"legal_id"]] forKey:@"legal_id"];
    }
    
    if([data objectForKey:@"check_digit"]){
        
        [[self enrollmentData] setObject:[NSString stringWithFormat:@"%@", [data objectForKey:@"check_digit"]] forKey:@"check_digit"];
    }
    
    if([data objectForKey:@"fname"]){
        
        [[self enrollmentData] setObject:[NSString stringWithFormat:@"%@", [data objectForKey:@"fname"]] forKey:@"fname"];
    }
    
    if([data objectForKey:@"lname"]){
        
        [[self enrollmentData] setObject:[NSString stringWithFormat:@"%@", [data objectForKey:@"lname"]] forKey:@"lname"];
    }
    
    if([data objectForKey:@"nickname"]){
        [[self enrollmentData] setObject:[NSString stringWithFormat:@"%@", [data objectForKey:@"nickname"]] forKey:@"nickname"];
    }
    
    if([data objectForKey:@"email"]){
        
        [[self enrollmentData] setObject:[NSString stringWithFormat:@"%@", [data objectForKey:@"email"]] forKey:@"email"];
    }
    
    if([data objectForKey:@"picture_count"]){
        
        [[self enrollmentData] setObject:[NSString stringWithFormat:@"%@", [data objectForKey:@"picture_count"]] forKey:@"picture_count"];
    }
    
    if([data objectForKey:@"picture_count"]){
        
        NSMutableArray * photoStatus = [[NSMutableArray alloc] init];
        
        int i;
        for (i=0; i<[[data objectForKey:@"picture_count"] intValue]; i++) {
            [photoStatus addObject:[NSNumber numberWithInt:P_STOPPED]];
        }
        
        [[self enrollmentData] setObject:photoStatus forKey:@"photo_status"];
    }
    
    if([data objectForKey:@"new_person"]){
        
        [[self enrollmentData] setObject:[NSString stringWithFormat:@"%@", [data objectForKey:@"new_person"]] forKey:@"new_person"];
    }
    
    [[self enrollmentData] setObject:[NSNumber numberWithInt:PENDING] forKey:@"status"];
    
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_CL"];
    [locale description]; // Using locale to avoid warning.
    [formatter setDateFormat:@"d MMM, HH:mm"];
    NSString *created_at = [formatter stringFromDate:now];
    
    [[self enrollmentData] setObject:created_at forKey:@"created_at"];
}

+(void)updateEnrollment: (NSDictionary *)enrollment{
    
    NSString *error;
    
    NSString * enrollmentPath = [EnrollmentDataManager getEnrollmentDirectoryAndcreateItIfNecessary];
    
    NSLog(@"rootpath: %@", enrollmentPath);
    
    NSString *filename = [NSString stringWithFormat:@"%@.plist", [enrollment objectForKey:@"enrollment_id"]];
    
    NSString *plistPath = [enrollmentPath stringByAppendingPathComponent:filename];
    
    NSLog(@"Plist path: %@", plistPath);
    
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:enrollment
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
        NSLog(@"Escrito, supuestamente");
    }
    else {
        NSLog(@"%@", error);
    }
    
    
}

-(void)write: (NSDictionary *)enrollment{
    
    NSString *error;
    
    NSString * enrollmentPath = [EnrollmentDataManager getEnrollmentDirectoryAndcreateItIfNecessary];
    
    NSLog(@"rootpath: %@", enrollmentPath);
    
    NSString *filename = [NSString stringWithFormat:@"%@.plist", [enrollment objectForKey:@"enrollment_id"]];
    
    NSString *plistPath = [enrollmentPath stringByAppendingPathComponent:filename];
    
    NSLog(@"Plist path: %@", plistPath);
    
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:enrollment
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
        NSLog(@"Escrito, supuestamente");
        
        NSLog(@"Ahora, las fotos.");
        [self savePictures:[self faces]];
    }
    else {
        NSLog(@"%@", error);
    }
    
}

-(void)savePictures: (NSArray *)faces{
    
    
    
    NSEnumerator *e = [faces objectEnumerator];
    UIImage * face;
    int i = 0;
    while (face = [e nextObject]) {
        i++;
        NSLog(@"Face %i: %@", i, face);
        //NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(face, 1.0f)];//1.0f = 100% quality
        
        NSData *imageData = UIImageJPEGRepresentation(face, 0.8f);
        
        NSData *data=[[NSData alloc]initWithData:imageData];
        
        NSString * file = [NSString stringWithFormat:@"%@.%i.jpg", [[self enrollmentData] objectForKey:@"enrollment_id"], i];
        
        NSString * facepath = [[EnrollmentDataManager getEnrollmentDirectoryAndcreateItIfNecessary] stringByAppendingPathComponent:file];
        
        NSLog(@"Path: %@", facepath);
        
        [data writeToFile:facepath atomically:YES ];
    }
    
}



+(NSArray *)getAllEnrollmentFilenames{
    
    NSString * enrollmentPath = [self getEnrollmentDirectoryAndcreateItIfNecessary];
    
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:enrollmentPath error:nil];
    
    //NSLog(@"Content: %@", directoryContents);
    
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.plist'"];
    NSArray *onlyPlists = [directoryContents filteredArrayUsingPredicate:fltr];
    
    //NSLog(@"Plists: %@", onlyPlists);
    
    return onlyPlists;
}

+ (id)readFilename: (NSString *)filename{
    
    //self = [super init];
    if (self) {
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSString *plistPath;
        
        NSString * rootPath = [self getEnrollmentDirectoryAndcreateItIfNecessary];
        
        plistPath = [rootPath stringByAppendingPathComponent:filename];
        
        //NSLog(@"plistPath: %@", plistPath);
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            plistPath = [[NSBundle mainBundle] pathForResource:@"enrollment" ofType:@"plist"];
            //NSLog(@"plistPath then: %@", plistPath);
        }
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSDictionary *tmp = (NSDictionary *)[NSPropertyListSerialization
                                             propertyListFromData:plistXML
                                             mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                             format:&format
                                             errorDescription:&errorDesc];
        
        NSMutableDictionary * temp = [[NSMutableDictionary alloc] initWithDictionary:tmp];
        
        if (!temp) {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }else{
            NSLog(@"Leido %@", filename);
            //[self write:temp];
            return temp;
        }
        
    }
    
    
    
    return self;
}

+ (NSMutableArray *)getAllEnrollments{
    NSArray * filenames = [self getAllEnrollmentFilenames];
    
    NSEnumerator *e = [filenames objectEnumerator];
    
    NSString * filename;
    
    NSMutableArray *enrollments = [[NSMutableArray alloc]init];
    
    while (filename = [e nextObject]) {
        
        [enrollments addObject:[self readFilename:filename]];
        //NSLog(@"Enrolamiento: %@", [self readFilename:filename]);
        
    }
    
    return enrollments;
    
}

+ (NSArray *) getAllPicturesFromEnrollment: (NSString *)enrollment_id{
    NSString * enrollmentPath = [self getEnrollmentDirectoryAndcreateItIfNecessary];
    
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:enrollmentPath error:nil];
    
    //NSLog(@"Content: %@", directoryContents);
    
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@ and self ENDSWITH '.jpg'", enrollment_id];
    NSArray *onlyPhotosFilenames = [directoryContents filteredArrayUsingPredicate:fltr];
    
    //NSString *plistPath = [enrollmentPath stringByAppendingPathComponent:filename];
    
    //image = [[UIImage alloc] initWithContentsOfFile:str];
    
    NSEnumerator *e = [onlyPhotosFilenames objectEnumerator];
    
    NSString * filename;
    
    NSMutableArray * pictures = [[NSMutableArray alloc] init];
    
    while (filename = [e nextObject]) {
        
        NSString * picfname = [enrollmentPath stringByAppendingPathComponent:filename];
        
        [pictures addObject:[[UIImage alloc] initWithContentsOfFile:picfname]];
        
        
    }
    
    //NSLog(@"Fotos: %@", pictures);
    
    return pictures;
}

+ (UIImage *) getPictureWithCoordinate: (NSString *)coordinate{
    NSString * enrollmentPath = [self getEnrollmentDirectoryAndcreateItIfNecessary];
    
    NSString * picfname = [NSString stringWithFormat:@"%@/%@.jpg", enrollmentPath, coordinate];
    
    //NSLog(@"RUTASD: %@", picfname);
    
    UIImage * picture = [[UIImage alloc] initWithContentsOfFile:picfname];
    
    return picture;
}

+ (void)deleteEnrollment: (NSMutableDictionary *) enrollment{
    
    // For error information
    NSError *error;
    
    NSString * enrollmentPath = [EnrollmentDataManager getEnrollmentDirectoryAndcreateItIfNecessary];
    
    NSLog(@"rootpath: %@", enrollmentPath);
    
    NSString * enrollment_id = [enrollment objectForKey:@"enrollment_id"];
    
    int i;
    for (i=1; i<=[[enrollment objectForKey:@"picture_count"] intValue]; i++) {
        
        NSString *filename = [NSString stringWithFormat:@"%@.%i.jpg", enrollment_id, i];
        
        NSString *filepath = [enrollmentPath stringByAppendingPathComponent:filename];
        
        if ([[NSFileManager defaultManager] removeItemAtPath:filepath error:&error] != YES){
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        }else{
            NSLog(@"Photo %@.%i deleted!", enrollment_id, i);
        }
        
    }
    
    NSString *filename = [NSString stringWithFormat:@"%@.plist", enrollment_id];
    
    NSString *plistPath = [enrollmentPath stringByAppendingPathComponent:filename];
    
    if ([[NSFileManager defaultManager] removeItemAtPath:plistPath error:&error] != YES){
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    }else{
        NSLog(@"Enrollment %@ deleted!", enrollment_id);
    }
    
}

@end
