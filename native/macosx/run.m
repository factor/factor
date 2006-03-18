/* Cocoa exception handling for Mac OS X */

#include "../factor.h"
#import "Foundation/NSException.h"

/* This code is convoluted because Cocoa places restrictions on longjmp and
exception handling. In particular, a longjmp can never cross an NS_DURING,
NS_HANDLER or NS_ENDHANDLER. */
void platform_run()
{
	CELL error = F;

	for(;;)
	{
NS_DURING
		SETJMP(stack_chain->toplevel);
		handle_error();

		if(error != F)
		{
			CELL e = error;
			error = F;
			general_error(ERROR_OBJECTIVE_C,error,true);
		}

		run();
		NS_VOIDRETURN;
NS_HANDLER
		error = tag_object(make_alien(F,(CELL)localException));
NS_ENDHANDLER
	}
}

