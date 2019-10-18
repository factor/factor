#include "../factor.h"

/* SEH support. Proceed with caution. */
typedef long exception_handler_t(
	void *rec, void *frame, void *context, void *dispatch);

typedef struct exception_record {
	struct exception_record *next_handler;
	void *handler_func;
} exception_record_t;

void seh_call(void (*func)(), exception_handler_t *handler)
{
	exception_record_t record;
	asm("mov %%fs:0, %0" : "=r" (record.next_handler));
	asm("mov %0, %%fs:0" : : "r" (&record));
	record.handler_func = handler;
	func();
	asm("mov %0, %%fs:0" : "=r" (record.next_handler));
}

static long exception_handler(void *rec, void *frame, void *ctx, void *dispatch)
{
	signal_error(SIGSEGV);
}

void platform_run ()
{
	seh_call(run, exception_handler);
}
