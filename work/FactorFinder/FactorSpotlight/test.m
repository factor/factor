#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "MySpotlightImporter.h"
#import "test.h"

Boolean processFile(NSString *path) {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity: 1];
    
    return extract(NULL, attributes, @"", path);

}

void processFolder(NSString * path) {
	BOOL isDir;
	NSString *file;
	NSFileManager * fileManager = [NSFileManager defaultManager];
	
	if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
		NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:path];
		while ((file = [dirEnumerator nextObject])) {
			file = [path stringByAppendingPathComponent:file];
            if ([file hasSuffix:@".factor"]) {
                NSLog(@"LibSpotlight testing: %@", file);
                processFolder(file);
            }
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

