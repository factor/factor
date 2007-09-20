typedef struct _F_STACK_FRAME
{
	struct _F_STACK_FRAME *previous;

	/* Callee stores our LR here */
	XT return_address;

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

#define UAP_PROGRAM_COUNTER(ucontext) \
	(((ucontext_t *)(ucontext))->uc_mcontext.uc_regs->gregs[PT_NIP])
