#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t *)(ucontext))->uc_mcontext.mc_eip)
