	EXPORT	trampoline
	EXPORT	trampoline2
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

trampoline2
	STP	FP, LR, [X17]
	MOV	FP, X17
	STR	FP, [X20]
	BLR	X16
	LDP	FP, LR, [FP]
	RET

	END
