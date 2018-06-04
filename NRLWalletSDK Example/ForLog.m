//
//  ForLog.m
//  NRLWalletSDK Example
//
//  Created by David Bala on 30/05/2018.
//  Copyright © 2018 NoRestLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDLog.h"
#import "DDTTYLogger.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_ALL;
#else
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#endif

