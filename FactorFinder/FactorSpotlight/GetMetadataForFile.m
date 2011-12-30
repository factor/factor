//
//  GetMetadataForFile.m
//  FactorSpotlight
//
//  Created by Dave Carlton on 12/23/11.
//  Copyright (c) 2011 PolyMicro Systems. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#import <CoreData/CoreData.h>
#import "MySpotlightImporter.h"
#import "extract.h"

Boolean GetMetadataForFile(void* thisInterface, 
                           CFMutableDictionaryRef attributes, 
                           CFStringRef contentTypeUTI,
                           CFStringRef pathToFile);

Boolean GetMetadataForFile(void* thisInterface, 
                           CFMutableDictionaryRef attributes, 
                           CFStringRef contentTypeUTI,
                           CFStringRef pathToFile)
{
    @autoreleasepool {
        return extract(thisInterface, (NSMutableDictionary *)attributes, (NSString *)contentTypeUTI, (NSString *)pathToFile);
    }
}


