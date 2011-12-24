#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "MySpotlightImporter.h"
#import "test.h"

Boolean processFile(NSString *path) {
	
    MySpotlightImporter *importer = [[MySpotlightImporter alloc] init];
    
    NSMutableDictionary *testDict = [NSMutableDictionary dictionaryWithCapacity: 1];
    NSError *error;
    
    Boolean ok = [importer importFileAtPath:path attributes:testDict error:&error];

    return ok;
}

void processFolder(NSString * path) {
	BOOL isDir;
	NSString *file;
	NSFileManager * fileManager = [NSFileManager defaultManager];
	
	if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
		NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:path];
		while ((file = [dirEnumerator nextObject])) {
			file = [path stringByAppendingPathComponent:file];
			//NSLog(@"LibSpotlight testing: %@", file);
			processFolder(file);
		}
	} else
		processFile(path);
}

int main (int argc, const char * argv[]) {
    if (argc < 2)
        return -1;
    @autoreleasepool {
        NSString * path = [NSString stringWithUTF8String: (const char *)argv[1]];
        processFolder(path);
    }
	return 0;
}

