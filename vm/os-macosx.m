#import <Cocoa/Cocoa.h>

#include "master.h"

static CELL error;

/* This code is convoluted because Cocoa places restrictions on longjmp and
exception handling. In particular, a longjmp can never cross an NS_DURING,
NS_HANDLER or NS_ENDHANDLER. */
void run()
{
	error = F;

	for(;;)
	{
NS_DURING
		stack_chain->native_stack_pointer = native_stack_pointer();
		SETJMP(stack_chain->toplevel);
		handle_error();

		if(error != F)
		{
			CELL e = error;
			error = F;
			simple_error(ERROR_OBJECTIVE_C,e,F);
		}

		interpreter_loop();
		NS_VOIDRETURN;
NS_HANDLER
		error = allot_alien(F,(CELL)localException);
NS_ENDHANDLER
	}
}

void run_toplevel(void)
{
	run();
}

void early_init(void)
{
	[[NSAutoreleasePool alloc] init];
}


const char *vm_executable_path(void)
{
	return [[[NSBundle mainBundle] executablePath] cString];
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

	return [returnVal cString];
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
