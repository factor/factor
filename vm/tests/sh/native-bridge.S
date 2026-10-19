// GNU SH ABI: pointer in R4, integer arguments R5/R6; return R0.
// R8..R14 and FR12..FR15 are preserved. Save PR across nested JSR.
.text
.balign 4
.global sh_probe_bridge
.type sh_probe_bridge,@function
sh_probe_bridge:
    sts.l pr,@-r15
    mov r4,r1
    mov r5,r4
    jsr @r1
    mov r6,r5
    lds.l @r15+,pr
    rts
    nop
.size sh_probe_bridge,.-sh_probe_bridge
.section .note.GNU-stack,"",@progbits
.text
.balign 4
.global sh_probe_fp_bridge
.type sh_probe_fp_bridge,@function
sh_probe_fp_bridge:
    sts.l pr,@-r15
    jsr @r4
    nop
    lds.l @r15+,pr
    rts
    nop
.size sh_probe_fp_bridge,.-sh_probe_fp_bridge

// Under the SH4 double-FPU ABI the record cannot fit the remaining three
// integer argument registers, so the complete record arrives on the stack.
// The aggregate return address remains in R2.
.global sh_probe_record_bridge
.type sh_probe_record_bridge,@function
sh_probe_record_bridge:
    sts.l pr,@-r15
    mov r4,r1
    mov.l @(4,r15),r4
    mov.l @(8,r15),r5
    mov.l @(12,r15),r6
    jsr @r1
    mov.l @(16,r15),r7
    lds.l @r15+,pr
    rts
    nop
.size sh_probe_record_bridge,.-sh_probe_record_bridge

// Four bytes with byte alignment return through hidden R2, not R0.
.global sh_probe_byte_record_bridge
.type sh_probe_byte_record_bridge,@function
sh_probe_byte_record_bridge:
    sts.l pr,@-r15
    mov r4,r1
    jsr @r1
    mov r5,r4
    lds.l @r15+,pr
    rts
    nop
.size sh_probe_byte_record_bridge,.-sh_probe_byte_record_bridge
// A pair of integers uses the same R4/R5 -> R0/R1 transport.
.global sh_probe_pair_record_bridge
.set sh_probe_pair_record_bridge,sh_probe_bridge
// A single-float record retains its FR5 argument and FR0 result.
.global sh_probe_single_record_bridge
.set sh_probe_single_record_bridge,sh_probe_fp_bridge
