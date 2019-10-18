#include "factor.h"

#import "Foundation/NSAutoreleasePool.h"
#import "Foundation/NSBundle.h"
#import "Foundation/NSException.h"
#import "Foundation/NSString.h"

static CELL error;

/* This code is convoluted because Cocoa places restrictions on longjmp and
exception handling. In particular, a longjmp can never cross an NS_DURING,
NS_HANDLER or NS_ENDHANDLER. */
void platform_run()
{
	error = F;

	for(;;)
	{
NS_DURING
		SETJMP(stack_chain->toplevel);
		handle_error();

		if(error != F)
		{
			CELL e = error;
			error = F;
			general_error(ERROR_OBJECTIVE_C,e,F,true);
		}

		run();
		NS_VOIDRETURN;
NS_HANDLER
		error = tag_object(make_alien(F,(CELL)localException));
NS_ENDHANDLER
	}
}

void early_init(void)
{
	[[NSAutoreleasePool alloc] init];
}

const char *default_image_path(void)
{
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *image = [[bundle resourcePath] stringByAppendingString:@"/factor.image"];
	return [image cString];
}

void init_signals(void)
{
	unix_init_signals();
	mach_initialize();
}
