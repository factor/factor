void signal_handler(int signal, siginfo_t* siginfo, void* uap);
void call_profiling_step(int signal, siginfo_t* siginfo, void* uap);
void init_signals(void);
void primitive_call_profiling(void);
