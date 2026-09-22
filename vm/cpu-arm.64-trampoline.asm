	EXPORT	trampoline
	EXPORT	trampoline2
	IMPORT	exception_handler
	ALIGN	4
	AREA	|.text|,CODE

; X16 = IP0
; X17 = IP1
; X20 = CTX

trampoline
	STP	FP, LR, [SP, -16]!
	MOV	FP, SP
	STR	FP, [X20]	; ctx.callstack_top
	BLR	X16
	LDP	FP, LR, [SP], 16
	RET
trampoline_end

trampoline2
	STP	FP, LR, [X17]
	MOV	FP, X17
	STR	FP, [X20]
	BLR	X16
	LDP	FP, LR, [FP]
	RET
trampoline2_end

; Describe the saved frame so native VM/FFI faults reach Factor's handler.
; A leaf/handler-only record cannot unwind past the native callee's LR.
; trampoline2 anchors the frame at FP, above the outgoing arguments.
; Factor's handler restores its own stacks, so no further OS unwind is needed.
; X=1, E=0, no epilog scopes, one code word.
	AREA	|.pdata|, PDATA
	DCD	trampoline
	RELOC	2	; IMAGE_REL_ARM64_ADDR32NB
	DCD	trampoline_unwind
	RELOC	2
	DCD	trampoline2
	RELOC	2
	DCD	trampoline2_unwind
	RELOC	2

	AREA	|.xdata|, DATA, READONLY
trampoline_unwind
	DCD	0x08100000 + (trampoline_end - trampoline) / 4
	DCD	0xe3e481e1	; set_fp; save_fplr_x 16; end; nop
	DCD	exception_handler
	RELOC	2
trampoline2_unwind
	DCD	0x08100000 + (trampoline2_end - trampoline2) / 4
	DCD	0xe3e440e1	; set_fp; save_fplr 0; end; nop
	DCD	exception_handler
	RELOC	2

	END
