#import <Cocoa/Cocoa.h>

#include "master.hpp"

namespace factor
{

void c_to_factor_toplevel(cell quot)
{
	for(;;)
	{
NS_DURING
		c_to_factor(quot);
		NS_VOIDRETURN;
NS_HANDLER
		dpush(allot_alien(F,(cell)localException));
		quot = userenv[COCOA_EXCEPTION_ENV];
		if(!tagged<object>(quot).type_p(QUOTATION_TYPE))
		{
			/* No Cocoa exception handler was registered, so
			extra/cocoa/ is not loaded. So we pass the exception
			along. */
			[localException raise];
		}
NS_ENDHANDLER
	}
}

void early_init(void)
{
	SInt32 version;
	Gestalt(gestaltSystemVersion,&version);
	if(version <= 0x1050)
	{
		printf("Factor requires Mac OS X 10.5 or later.\n");
		exit(1);
	}

	[[NSAutoreleasePool alloc] init];
}

const char *vm_executable_path(void)
{
	return [[[NSBundle mainBundle] executablePath] UTF8String];
}

const char *default_image_path(void)
{
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *path = [bundle bundlePath];
	NSString *executable = [[bundle executablePath] lastPathComponent];
	NSString *image = [executable stringByAppendingString:@".image"];

	NSString *returnVal;

	if([path hasSuffix:@".app"] || [path hasSuffix:@".app/"])
	{
		NSFileManager *mgr = [NSFileManager defaultManager];

		NSString *imageInBundle = [[path stringByAppendingPathComponent:@"Contents/Resources"] stringByAppendingPathComponent:image];
		NSString *imageAlongBundle = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:image];

		returnVal = ([mgr fileExistsAtPath:imageInBundle]
			? imageInBundle : imageAlongBundle);
	}
	else
		returnVal = [path stringByAppendingPathComponent:image];

	return [returnVal UTF8String];
}

void init_signals(void)
{
	unix_init_signals();
	mach_initialize();
}

/* Amateurs at Apple: implement this function, properly! */
Protocol *objc_getProtocol(char *name)
{
	if(strcmp(name,"NSTextInput") == 0)
		return @protocol(NSTextInput);
	else
		return nil;
}

}
