//
//  POCAPIClient.h
//  POCApp 
//
//  Created by Marco Torres Morgado on 2013/02/22.
//
//

#import <Foundation/Foundation.h>


@interface POCAPIClient : NSObject

+ (POCAPIClient *)sharedClient;
+ (NSString*)baseURL;
@end
