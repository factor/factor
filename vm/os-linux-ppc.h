#define FRAME_RETURN_ADDRESS(frame,delta) *((XT *)(REBASE_FRAME_SUCCESSOR(frame,delta) + 1) + 1)

#define UAP_PROGRAM_COUNTER(ucontext) \
	(((ucontext_t *)(ucontext))->uc_mcontext.uc_regs->gregs[PT_NIP])
