    .file "cpu-ppc.linux.S"
    .section ".text"
    .align 2
    .globl flush_icache
    .type flush_icache, @function
flush_icache:
    add 4,4,3     # end += ptr
#ifdef _ARCH_PPC64
    clrrdi 3,3,5  # ptr &= ~0x1f
#else
    clrrwi 3,3,5  # ptr &= ~0x1f
#endif
    sub 4,4,3     # end -= aligned_ptr
    addi 4,4,0x1f # end += 0x1f
#ifdef _ARCH_PPC64
    srdi. 4,4,5   # end >>= 5, set cr
#else
    srwi. 4,4,5   # end >>= 5, set cr
#endif
    beqlr

    # Loop over the buffer by cache line and flush the data cache.
    mr 5,3
    mtctr 4
loop1:
    dcbst 0,5
    addi 5,5,0x20
    bdnz loop1

    # Synchronize to ensure the cache line flushes are complete.
    sync

    # Loop over the buffer by cache line and flush the instruction cache.
    mr 5,3
    mtctr 4
loop2:
    icbi 0,5
    addi 5,5,0x20
    bdnz loop2

    # Clear instruction pipeline to force reloading of instructions.
    isync
    blr

    .size flush_icache,.-flush_icache
    .section .note.GNU-stack,"",@progbits
