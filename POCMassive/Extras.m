//
//  Extras.m
//  POCApp 
//
//  Created by Marco Torres Morgado on 2013/02/19.
//
//

#import "Extras.h"
#import "NSStringMD5.h"


@implementation Extras

+(UIImage *) forUIImage: (UIImage *)image changeColor: (UIColor *)color_ {
	CGColorRef color = [color_ CGColor];
    
	CGRect contextRect = (CGRect){CGPointZero, [image size]};
 	UIGraphicsBeginImageContext(contextRect.size);
 	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextBeginTransparencyLayer(ctx, NULL);
	CGContextScaleCTM(ctx, 1.f, -1.f);
	CGContextClipToMask(ctx, CGRectMake(contextRect.origin.x, -contextRect.origin.y, contextRect.size.width, -contextRect.size.height), [image CGImage]);
	
	CGColorSpaceRef colorSpace = CGColorGetColorSpace(color);
	CGColorSpaceModel model = CGColorSpaceGetModel(colorSpace);
	const CGFloat *colors = CGColorGetComponents(color);
	if (model == kCGColorSpaceModelMonochrome)
		CGContextSetRGBFillColor(ctx, colors[0], colors[0], colors[0], colors[1]);
	else
		CGContextSetRGBFillColor(ctx, colors[0], colors[1], colors[2], colors[3]);
	
	contextRect.size.height = -contextRect.size.height;
	CGContextFillRect(ctx, contextRect);
	
	CGContextEndTransparencyLayer(ctx);
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return img;
}

+(int) getTimeStampIntValue{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    return [timeStampObj intValue];
}

+(NSString*) generateKeyWithSerial:(NSString *)serial andTimeStamp: (int)timeStamp{
    NSString *passphrase = [[NSString alloc] initWithFormat:@"%@{B$8m%i", serial, timeStamp];
    NSString *key = [passphrase MD5String];
    return key;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSMutableDictionary *)getBaseParametersForRequest{
    
    NSString * serial = @"3b00fcab8f6132ccdb9717c2e0532cd996f9bc9f";
    
   // NSString * serial = [OpenUDID value];
    
    NSString * timestamp = [NSString stringWithFormat:@"%i", [Extras getTimeStampIntValue]];
    
    NSString * key = [NSString stringWithString:[Extras generateKeyWithSerial:serial andTimeStamp:[Extras getTimeStampIntValue]]];
    
    NSNumber * lat =  [NSNumber numberWithDouble:0];
    NSNumber * lng = [NSNumber numberWithDouble:0];
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 serial, @"serial",
                                 key, @"key",
                                 lat, @"lat",
                                 lng, @"lng",
                                 timestamp, @"timestamp",
                                 nil];
    
    return parameters;
}


+ (BOOL) verifyRut: (int) _rut Validador: (NSString *) _valid
{
    int digit;
    int count;
    int mult;
    int accum;
    NSString *realValid;
    
    NSLog(@"Valid: %@", _valid);
    
    count = 2;
    accum = 0;
    
    while (_rut != 0){
        mult = (_rut % 10) * count;
        accum = accum + mult;
        _rut = _rut/10;
        count = count + 1;
        if (count == 8){ count = 2; }
    }
    
    digit = 11 - (accum % 11);
    realValid = [NSString stringWithFormat:@"%d", digit];
    if (digit == 10 ){
        realValid = @"K";
    }
    if (digit == 11){
        realValid = @"0";
    }
    
    return [realValid isEqualToString:_valid];
}

+ (NSString *) printIntAsNumberWithThousandFormat: (int) number {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:(float)number]];
    
    return [NSString stringWithFormat:@"%@",formattedNumberString];
}

+(NSString *) currentTime{
	char buffer[80];
	
    NSString *timeFormat = @"%d/%m/%Y %H:%M";
    
	const char *format = [timeFormat UTF8String];
	
	time_t rawtime;
	
	struct tm * timeinfo;
	
	time(&rawtime);
	
	timeinfo = localtime(&rawtime);
	
	strftime(buffer, 80, format, timeinfo);
	
	return [NSString  stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

+ (BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}



@end
