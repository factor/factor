! Exact leaf bodies used by math.floats.env.sh4; first pointer argument R4.
    .text
    .align 2
    .global sh4_get_env_probe
    .type sh4_get_env_probe,@function
sh4_get_env_probe:
    sts fpscr,r0
    mov.l r0,@r4
    rts
    nop
    .size sh4_get_env_probe,.-sh4_get_env_probe
    .align 2
    .global sh4_set_env_probe
    .type sh4_set_env_probe,@function
sh4_set_env_probe:
    mov.l @r4,r0
    lds r0,fpscr
    rts
    nop
    .size sh4_set_env_probe,.-sh4_set_env_probe
    .section .note.GNU-stack,"",@progbits
