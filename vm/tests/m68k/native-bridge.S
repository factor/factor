/* GNU m68k Linux stack-argument ABI: callee-saved A6 anchors the frame. */
.text
.balign 2
.globl m68k_probe_bridge
.type m68k_probe_bridge,@function
m68k_probe_bridge:
    link %a6,#0
    movea.l 8(%a6),%a0
    move.l 16(%a6),-(%sp)
    move.l 12(%a6),-(%sp)
    jsr (%a0)
    addq.l #8,%sp
    unlk %a6
    rts
.size m68k_probe_bridge,.-m68k_probe_bridge
.section .note.GNU-stack,"",@progbits
