#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <CoreFoundation/CFPlugInCOM.h>
#import <Foundation/Foundation.h>
#import <stdio.h>
#import <syslog.h>
#import "pms.h"

#import "extract.h"

/* -----------------------------------------------------------------------------
   Step 1
   Set the UTI types the importer supports

   Modify the CFBundleDocumentTypes entry in Info.plist to contain
   an array of Uniform Type Identifiers (UTI) for the LSItemContentTypes
   that your importer can handle

   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 2
   Implement the GetMetadataForFile function

   Implement the GetMetadataForFile function below to scrape the relevant
   metadata from your document and return it as a CFDictionary using standard keys
   (defined in MDItem.h) whenever possible.
   ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
   Step 3 (optional)
   If you have defined new attributes, update the schema.xml file

   Edit the schema.xml file to include the metadata keys that your importer returns.
   Add them to the <allattrs> and <displayattrs> elements.

   Add any custom types that your importer requires to the <attributes> element

   <attribute name="com_mycompany_metadatakey" type="CFString" multivalued="true"/>

   ----------------------------------------------------------------------------- */

Boolean
assertRegex(NSString * stringToSearch, NSString * regexString)
{
	NSPredicate * regex = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", regexString];

	return [regex evaluateWithObject: stringToSearch];
}

/* -----------------------------------------------------------------------------
    Get metadata attributes from file

   This function's job is to extract useful information your file format supports
   and return it as a dictionary
   ----------------------------------------------------------------------------- */

Boolean
extract(void * thisInterface,
	NSMutableDictionary *attributes,
	NSString * contentTypeUTI,
	NSString * pathToFile)
{
	/* Pull any available metadata from the file at the specified path */
	/* Return the attribute keys and attribute values in the dict */
	/* Return TRUE if successful, FALSE if there was no data provided */

	NSRange    range, theRange;
	NSString    *version, *author, *description, *uses, *copyright;
	NSArray           * lineComponents;
	NSArray           * lineSubComponents;
	Boolean             success = NO; // found at least one attribute
	NSMutableArray    * definitions = [NSMutableArray arrayWithCapacity: 128];
	NSMutableArray    * usesArray = [NSMutableArray arrayWithCapacity: 128];
	NSMutableString   * sourceContent = [NSMutableString stringWithCapacity: 4096];

    NSLog(@"FactorSpotlight: %@", pathToFile);

	// Grab our plist for file extensions
	NSBundle     * myBundle = [NSBundle bundleWithIdentifier: @"org.factorcode.Factor.spotlight"];
	NSDictionary * bundleDictionary = [myBundle infoDictionary];
	NSArray      * myDocuentTypes = [bundleDictionary objectForKey: @"CFBundleDocumentTypes"];
	NSDictionary * myDocuentTypesDictionary = [myDocuentTypes objectAtIndex: 0];
	NSArray      * myFileExtensions = [myDocuentTypesDictionary objectForKey: @"CFBundleTypeExtensions"];

	// Fallback option for testing
	if ([myFileExtensions count] == 0)
		myFileExtensions = [NSArray arrayWithObjects: @"factor", @"of", @"fs", @"fth", @"4th", @"fo", @"fas", nil];

	NSString * fileExtension = [pathToFile pathExtension];
	NSString * extObject;
	Boolean    extensionOK = NO;
	for (extObject in myFileExtensions) {
		if ([fileExtension isEqualToString: extObject]) {
			extensionOK = YES;
			break;
		}
	}

	if (!extensionOK)
        return success;
    
	NSStringEncoding fileEncoding;
	NSError        * fileError = nil;
	NSString * fileContent = [NSString stringWithContentsOfFile: pathToFile usedEncoding: &fileEncoding error: &fileError];
	if (!fileContent)
		return success;

	NSArray * fileLines = nil;
	if (fileContent) {
		fileContent = [fileContent stringByReplacingOccurrencesOfString: @"\r" withString: @"\n"];
		fileContent = [fileContent stringByReplacingOccurrencesOfString: @"\n\n" withString: @"\n"];
		fileLines = [fileContent componentsSeparatedByString: @"\n"];
	}

	for (NSString * aString in fileLines) {
//        PMLOG(1, @"Factor File line: %@", aString);

        NSString *fileLine = aString;
		range.location = 0;
		range.length = [fileLine length];

		// Look thu header lines to glean info
		// Look for '! Copyright` in the line
		theRange = [fileLine rangeOfString: @"! Copyright" options: NSLiteralSearch range: range];
		// syslog(LOG_ALERT, "Factor File: theRange = %d %d", theRange.location, theRange.length);
		if (theRange.location != NSNotFound) {
			// found it, now split line at the ',` to see if it is an old CVS style tagged file
			lineComponents = [fileLine componentsSeparatedByString: @"! Copyright "];
			if ([lineComponents count] == 2) {
				copyright = [lineComponents objectAtIndex: 1];
                [attributes setObject: copyright
                               forKey: (NSString *)kMDItemCopyright];
					success = YES;
            }
        }
        // Look for a description tag
        theRange = [fileLine rangeOfString: @"! Description:" options: NSLiteralSearch range: range];
		if (theRange.location != NSNotFound) {
			// found it, now split line
			lineComponents = [fileLine componentsSeparatedByString: @"! Description: "];
			if ([lineComponents count] == 2) {
				description = [lineComponents objectAtIndex: 1];
                [attributes setObject: description
                               forKey: (NSString *)kMDItemDescription];
                success = YES;
            }
        }

		// Find the Version number, if any
        theRange = [fileLine rangeOfString: @"Version:" options: NSLiteralSearch range: range];
        if (theRange.location != NSNotFound) {
            fileLine = [fileLine stringByReplacingOccurrencesOfString: @"\t" withString: @" "];
            NSArray  * lineComponents = [fileLine componentsSeparatedByString: @" "];
            NSString * version = [lineComponents objectAtIndex: 1];
            version = [version stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            [attributes setObject: version
                           forKey: (NSString *)kMDItemVersion];
            success = YES;
        }
        // Find the Directly Responsible Individual (DRI), if any
        theRange = [fileLine rangeOfString: @"DRI:" options: NSLiteralSearch range: range];
        if (theRange.location != NSNotFound) {
            fileLine = [fileLine stringByReplacingOccurrencesOfString: @"\t" withString: @" "];
            NSArray  * lineComponents = [fileLine componentsSeparatedByString: @"DRI:"];
            NSString * author = [lineComponents objectAtIndex: 1];
            author = [author stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            [attributes setObject: author
                           forKey: (NSString *)kMDItemAuthors];
            success = YES;
        }

		// Look for other data after the initial header line
		// Find the containing line describing the file uses array
		theRange = [fileLine rangeOfString: @"USING:" options: NSLiteralSearch range: range];
		if (theRange.location != NSNotFound) {
			// found it, now split line at USING:
			fileLine = [fileLine stringByReplacingOccurrencesOfString: @"\t" withString: @" "];
			lineComponents = [fileLine componentsSeparatedByString: @"USING:"];
            if ([lineComponents count] == 2) {
                lineSubComponents = [lineComponents objectAtIndex: 1];
                lineComponents = [(NSString *)lineSubComponents componentsSeparatedByString: @" "];
                if ([lineComponents count]) {
                    for (uses in lineComponents) {
                        if ( ! [uses isEqualToString: @";"] &&
                            [uses length] )
                            [usesArray addObject: uses];
                    }
                    [attributes setObject: usesArray
                                   forKey: (NSString *)@"public_factor_uses"];
                    success = YES;
                }
            }
        }

		// Parse for defining words
		if ( assertRegex(fileLine, @"^:\\s*(\\S+)\\s+.*") ||
            assertRegex(fileLine, @"^::\\s*(\\S+)\\s+.*") ||
            assertRegex(fileLine, @"^M:\\s*(\\S+)\\s+.*") ||
            assertRegex(fileLine, @"^M::\\s*(\\S+)\\s+.*") ||
		    assertRegex(fileLine, @"^\\s*(TUPLE:)\\s+(\\S+)\\s+.*") ||
		    assertRegex(fileLine, @"^\\s*(code|CODE)\\s+(\\S+)\\s+.*") ||
		    assertRegex(fileLine, @"^\\s*(tcode|TCODE)\\s+(\\S+)\\s+.*") ) {
			fileLine = [fileLine stringByReplacingOccurrencesOfString: @"\t" withString: @" "];
			NSArray  * lineComponents = [fileLine componentsSeparatedByString: @" "];
			NSString * definition = [lineComponents objectAtIndex: 1];
			definition = [definition stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
			[definitions addObject: definition];
		}
		// accumulate line
		fileLine = [fileLine stringByReplacingOccurrencesOfString: @"\t" withString: @" "];
		[sourceContent appendString: fileLine];
	}

	// store definitions into metadata
	if ([definitions count] > 0) {
		[attributes setObject: definitions forKey: @"public_factor_definitions"];
		int i;
		for(i=0; i < [definitions count]; i++) {
			NSLog(@"Factor Def %d = %@", i, [definitions objectAtIndex: i]);
		}
		success = YES;
	}

	[attributes setObject: @"Factor Sourcecode File" forKey: (NSString *)kMDItemKind];
	[attributes setObject: sourceContent forKey: (id)kMDItemTextContent];

end:
	return success;
} /* extract */