typedef struct _F_STACK_FRAME {
	/* ===== 24 bytes reserved ===== */
	struct _F_STACK_FRAME *previous;

	CELL padding1;

	/* Callee stores our LR here */
	XT return_address;

	CELL padding2;
	CELL padding3;
	CELL padding4;
	/* ===== 32 bytes saved register area ===== */
	CELL padding5[8];

	/* ===== 16 byte local variable area ===== */

	/* In compiled quotation frames, the quot->array slot.
	In compiled word frames, unused. */
	CELL array;

	/* In compiled quotation frames, position within the array.
	In compiled word frames, unused. */
	CELL scan;

	/* In all compiled frames, the XT on entry. */
	XT xt;

	/* ===== 12 byte padding to make it 16 byte aligned ===== */
	CELL padding6[3];
} F_STACK_FRAME;

#define MACH_EXC_STATE_TYPE ppc_exception_state_t
#define MACH_EXC_STATE_FLAVOR PPC_EXCEPTION_STATE
#define MACH_EXC_STATE_COUNT PPC_EXCEPTION_STATE_COUNT
#define MACH_THREAD_STATE_TYPE ppc_thread_state_t
#define MACH_THREAD_STATE_FLAVOR PPC_THREAD_STATE
#define MACH_THREAD_STATE_COUNT PPC_THREAD_STATE_COUNT

#if __DARWIN_UNIX03
    #define MACH_EXC_STATE_FAULT(exc_state) (exc_state)->__dar
    #define MACH_STACK_POINTER(thr_state) (thr_state)->__r1
    #define MACH_PROGRAM_COUNTER(thr_state) (thr_state)->__srr0
    #define UAP_PROGRAM_COUNTER(ucontext) \
		MACH_PROGRAM_COUNTER(&(((ucontext_t *)(ucontext))->uc_mcontext->__ss))
#else
    #define MACH_EXC_STATE_FAULT(exc_state) (exc_state)->dar
    #define MACH_STACK_POINTER(thr_state) (thr_state)->r1
    #define MACH_PROGRAM_COUNTER(thr_state) (thr_state)->srr0
    #define UAP_PROGRAM_COUNTER(ucontext) \
		MACH_PROGRAM_COUNTER(&(((ucontext_t *)(ucontext))->uc_mcontext->ss))
#endif
