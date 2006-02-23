/* Cocoa exception handling for Mac OS X */

#include "../factor.h"
#import "Foundation/NSException.h"

void platform_run()
{
	for(;;)
	{
		SETJMP(stack_chain->toplevel);
		handle_error();
NS_DURING
		run();
		NS_VOIDRETURN;
NS_HANDLER
        	general_error(ERROR_OBJECTIVE_C,
			tag_object(make_alien(F,(CELL)localException)),
			true);
NS_ENDHANDLER
	}
}

