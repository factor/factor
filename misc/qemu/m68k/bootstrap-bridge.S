/* GNU m68k C ABI: preserve D2..D7/A2..A6, run generated Factor bytes. */
.text
.globl factor_probe_run
.type factor_probe_run,@function
factor_probe_run:
        movem.l %d2-%d7/%a2-%a6,-(%sp)
        lea -32(%sp),%sp
        move.l %sp,%a5
        move.l 80(%sp),%a0
        move.l 84(%sp),%a2
        move.l 88(%sp),%d0
        lsl.l #2,%d0
        adda.l %d0,%a2
        jsr (%a0)
        move.l %a2,%d0
        sub.l 84(%sp),%d0
        asr.l #2,%d0
        lea 32(%sp),%sp
        movem.l (%sp)+,%d2-%d7/%a2-%a6
        rts
.size factor_probe_run,.-factor_probe_run
/* Stand-in Factor word verifies the native input snapshot and returns both
   an integer in D0 and a pointer in A0, as the two native result conventions. */
.globl factor_probe_callback_body
.type factor_probe_callback_body,@function
factor_probe_callback_body:
        move.l -4(%a6),%d1
        move.l %d1,factor_probe_callback_snapshot
        move.l -8(%a6),%d1
        move.l %d1,factor_probe_callback_snapshot+4
        moveq #-1,%d2
        moveq #-1,%d3
        moveq #-1,%d4
        moveq #-1,%d5
        moveq #-1,%d6
        moveq #-1,%d7
        suba.l %a2,%a2
        suba.l %a3,%a3
        suba.l %a4,%a4
        suba.l %a5,%a5
        suba.l %a6,%a6
        fmove.x %fp0,%fp2
        fmove.x %fp0,%fp3
        fmove.x %fp0,%fp4
        fmove.x %fp0,%fp5
        fmove.x %fp0,%fp6
        fmove.x %fp0,%fp7
        moveq #0,%d0
        fmove.l %d0,%fpcr
        moveq #42,%d0
        lea factor_probe_callback_snapshot,%a0
        rts
.size factor_probe_callback_body,.-factor_probe_callback_body
.section .note.GNU-stack,"",@progbits

.text
.globl factor_probe_unwind
.type factor_probe_unwind,@function
factor_probe_unwind:
        movem.l %d2-%d7/%a2-%a6,-(%sp)
        move.l 48(%sp),%a0
        move.l 52(%sp),%d0
        pea .Lunwind_resume
        move.l %sp,%a1
        move.l %a1,-(%sp)
        move.l %d0,-(%sp)
        jsr (%a0)
        illegal
.Lunwind_resume:
        movem.l (%sp)+,%d2-%d7/%a2-%a6
        rts
.size factor_probe_unwind,.-factor_probe_unwind
.globl factor_probe_unwind_body
.type factor_probe_unwind_body,@function
factor_probe_unwind_body:
        moveq #42,%d0
        rts
.size factor_probe_unwind_body,.-factor_probe_unwind_body

.text
.globl factor_probe_restore_stack
.type factor_probe_restore_stack,@function
factor_probe_restore_stack:
        movem.l %d2-%d7/%a2-%a6,-(%sp)
        lea -32(%sp),%sp
        move.l %sp,%a5
        lea 32(%sp),%a1
        move.l %a1,4(%a5)
        move.l 80(%sp),%a0
        move.l 84(%sp),%a2
        jsr (%a0)
        illegal
.globl factor_probe_restore_resume
factor_probe_restore_resume:
        moveq #42,%d0
        movem.l (%sp)+,%d2-%d7/%a2-%a6
        rts
.size factor_probe_restore_stack,.-factor_probe_restore_stack

/* MEGA-LOOKUP consumes the receiver already selected by PIC-LOAD. */
.text
.globl factor_probe_mega
.type factor_probe_mega,@function
factor_probe_mega:
        movem.l %d2-%d7/%a2-%a6,-(%sp)
        lea -32(%sp),%sp
        move.l %sp,%a5
        move.l 80(%sp),%a0
        move.l 84(%sp),%a2
        move.l 88(%sp),%d0
        lsl.l #2,%d0
        adda.l %d0,%a2
        move.l 92(%sp),%d1
        lsl.l #2,%d1
        move.l %a2,%a1
        suba.l %d1,%a1
        move.l (%a1),%d5
        jsr (%a0)
        move.l %a2,%d0
        sub.l 84(%sp),%d0
        asr.l #2,%d0
        lea 32(%sp),%sp
        movem.l (%sp)+,%d2-%d7/%a2-%a6
        rts
.size factor_probe_mega,.-factor_probe_mega
