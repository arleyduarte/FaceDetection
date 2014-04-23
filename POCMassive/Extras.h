//
//  Extras.h
//  POCApp 
//
//  Created by Marco Torres Morgado on 2013/02/19.
//
//

#import <Foundation/Foundation.h>


@interface Extras : NSObject

+(UIImage *) forUIImage: (UIImage *)image changeColor: (UIColor *)color_;

+(int) getTimeStampIntValue;

+(NSString*) generateKeyWithSerial:(NSString *)serial andTimeStamp: (int)timeStamp;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (NSMutableDictionary *)getBaseParametersForRequest;

+ (BOOL) verifyRut: (int) _rut Validador: (NSString *) _valid;

+ (NSString *) printIntAsNumberWithThousandFormat: (int) number;

+ (NSString *) currentTime;

+ (BOOL) NSStringIsValidEmail:(NSString *)checkString;



@end
