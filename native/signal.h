#ifndef WIN32
void signal_handler(int signal, siginfo_t* siginfo, void* uap);
void dump_stack_signal(int signal, siginfo_t* siginfo, void* uap);
void call_profiling_step(int signal, siginfo_t* siginfo, void* uap);
void init_signals(void);
#endif

void primitive_call_profiling(F_WORD *);
