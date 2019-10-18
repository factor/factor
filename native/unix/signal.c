#include "../factor.h"
#include "../macosx/mach_signal.h"

// this function tests if a given faulting location is in a poison page. The
// page address is taken from area + round_up_to_page_size(area_size) + 
// pagesize*offset
static bool in_page(void *fault, void *i_area, CELL area_size, int offset)
{
	const int pagesize = getpagesize();
	intptr_t area = (intptr_t) i_area;
	area += pagesize * ((area_size + (pagesize - 1)) / pagesize);
	area += offset * pagesize;

	const int page = area / pagesize;
	const int fault_page = (intptr_t)fault / pagesize;
	return page == fault_page;
}

void signal_handler(int signal, siginfo_t* siginfo, void* uap)
{
	if(in_page(siginfo->si_addr, (void *) ds_bot, 0, -1))
		signal_stack_error(false, false);
	else if(in_page(siginfo->si_addr, (void *) ds_bot, ds_size, 0))
		signal_stack_error(false, true);
	else if(in_page(siginfo->si_addr, (void *) cs_bot, 0, -1))
		signal_stack_error(true, false);
	else if(in_page(siginfo->si_addr, (void *) cs_bot, cs_size, 0))
		signal_stack_error(true, true);
	else
		signal_error(signal);
}

static void sigaction_safe(int signum, const struct sigaction *act, struct sigaction *oldact)
{
	int ret;
	do
	{
		ret = sigaction(signum, act, oldact);
	} while(ret == -1 && errno == EINTR);
}

void init_signals(void)
{
	struct sigaction custom_sigaction;
	struct sigaction ign_sigaction;
	
	sigemptyset(&custom_sigaction.sa_mask);
	custom_sigaction.sa_sigaction = signal_handler;
	custom_sigaction.sa_flags = SA_SIGINFO;
	sigaction_safe(SIGABRT,&custom_sigaction,NULL);
	sigaction_safe(SIGFPE,&custom_sigaction,NULL);
	sigaction_safe(SIGBUS,&custom_sigaction,NULL);
	sigaction_safe(SIGQUIT,&custom_sigaction,NULL);
	sigaction_safe(SIGSEGV,&custom_sigaction,NULL);
	
	sigemptyset(&ign_sigaction.sa_mask);
	ign_sigaction.sa_handler = SIG_IGN;
	sigaction_safe(SIGPIPE,&ign_sigaction,NULL);

#ifdef __APPLE__
	mach_initialize();
#endif
}
