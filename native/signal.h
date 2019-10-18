#ifndef WIN32
void signal_handler(int signal, siginfo_t* siginfo, void* uap);
void dump_stack_signal(int signal, siginfo_t* siginfo, void* uap);
#endif
void init_signals(void);
