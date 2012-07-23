/*
 *  GetMetadataForFile.h
 *  Forth Spotlighter
 *
 *  Created by Dave on 5/10/05.
 *  Copyright 2005 PolyMicro Systems. All rights reserved.
 *
 */

#ifndef __GetMetadataForFile__
#define __GetMetadataForFile__

Boolean GetMetadataForFile(void* thisInterface, 
						   CFMutableDictionaryRef attributes, 
						   CFStringRef contentTypeUTI,
						   CFStringRef pathToFile);

Boolean assertRegex(NSString * stringToSearch, NSString * regexString);

Boolean extract(void * thisInterface,
                    NSMutableDictionary *attributes,
                    NSString * contentTypeUTI,
                    NSString * pathToFile);

#endif
