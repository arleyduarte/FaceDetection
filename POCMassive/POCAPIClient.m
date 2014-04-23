//
//  POCAPIClient.m
//  POCApp 
//
//  Created by Marco Torres Morgado on 2013/02/22.
//
//

#import "POCAPIClient.h"


static NSString * const kPOCAPIBaseURLString = @"http://www.poc.cl";

@implementation POCAPIClient

+ (POCAPIClient *)sharedClient{
    
    static POCAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
     //   _sharedClient = [[POCAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kPOCAPIBaseURLString]];
    });
    
    return _sharedClient;

}

- (id)initWithBaseURL:(NSURL *)url {
    //self = [super initWithBaseURL:url];
    //if (!self) {
     //   return nil;
    //}
    
   // [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	//[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

+ (NSString *)baseURL{
    return kPOCAPIBaseURLString;
}


@end
