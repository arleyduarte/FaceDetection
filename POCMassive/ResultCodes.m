//
//  ResultCodes.m
//  SPF
//
//  Created by Marco Torres Morgado on 01-06-12.
//  Copyright (c) 2012 SPF. All rights reserved.
//

#import "ResultCodes.h"

int const RESPONSE_OK                           = 0;
int const RESPONSE_INVALID_REQUEST              = 1; 
int const RESPONSE_INVALID_CREDENTIALS          = 2;
int const RESPONSE_REQUEST_TIMEOUT              = 3;    
int const RESPONSE_DEVICE_UNAVAILABLE           = 4; 
int const RESPONSE_UNKNOWN_ERROR                = 5;      
int const RESPONSE_CREATE_TRANSACTION_ERROR     = 6;
int const RESPONSE_RESUME_TRANSACTION_ERROR     = 7;
int const RESPONSE_VERIFICATION_REJECTED        = 8;   
int const RESPONSE_VERIFICATION_ERROR           = 9;      

int const RESPONSE_NOT_RECOGNIZED               = 18;
int const RESPONSE_FORBIDDEN                    = 19;
int const RESPONSE_REJECTED                     = 20;

int const RESPONSE_RESUME_TRANSACTION_TIMEOUT   = 10;

int const RESPONSE_DEVICE_DISABLED = 8000;