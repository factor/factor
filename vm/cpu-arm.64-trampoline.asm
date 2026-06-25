	EXPORT	trampoline [FUNC]
	EXPORT	trampoline2 [FUNC]
	ALIGN	4
	AREA	|.text|,CODE

; X16 = IP0
; X17 = IP1
; X20 = CTX

trampoline PROC
	STP	FP, LR, [SP, -16]!
	MOV	FP, SP
	STR	FP, [X20]	; ctx.callstack_top
	BLR	X16
	LDP	FP, LR, [SP], 16
	RET
trampoline ENDP

; trampoline2 has no .pdata/.xdata: it builds its frame at [X17] with a
; per-call-site SP delta, so no single static unwind descriptor applies.
trampoline2 PROC
	STP	FP, LR, [X17]
	MOV	FP, X17
	STR	FP, [X20]
	BLR	X16
	LDP	FP, LR, [FP]
	RET
trampoline2 ENDP

	AREA	|.xdata|,DATA,READONLY
	ALIGN	4
trampoline_unwind
	DCD	0x08000006
	DCD	0xe3e481e1

	AREA	|.pdata|,DATA,READONLY
	ALIGN	4
	DCD	0
	RELOC	2, trampoline
	DCD	0
	RELOC	2, trampoline_unwind

	END
