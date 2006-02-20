/* Cocoa exception handling for Mac OS X */

#include "../factor.h"
#import "Foundation/NSException.h"

void platform_run()
{
	for(;;)
	{
		SETJMP(toplevel);
		handle_error();
NS_DURING
		run(false);
		NS_VOIDRETURN;
NS_HANDLER
        	general_error(ERROR_OBJECTIVE_C,
			tag_object(make_alien(F,localException)),
			true);
NS_ENDHANDLER
	}
}

