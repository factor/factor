
/home/erg/compiler-next2-integer-20260909/disassembly/candidate-2-_fixnum=_plus.bin:     file format binary


Disassembly of section .data:

000073b7263c0720 <.data>:
    73b7263c0720:	mov    %eax,0x12e2a8da(%rip)        # 0x73b7391eb000
    73b7263c0726:	mov    (%r14),%rbx
    73b7263c0729:	mov    -0x8(%r14),%rax
    73b7263c072d:	add    %rbx,%rax
    73b7263c0730:	jo     0x73b7263c0744
    73b7263c0736:	sub    $0x8,%r14
    73b7263c073a:	mov    %rax,(%r14)
    73b7263c073d:	mov    %eax,0x12e2a8bd(%rip)        # 0x73b7391eb000
    73b7263c0743:	ret
    73b7263c0744:	mov    %eax,0x12e2a8b6(%rip)        # 0x73b7391eb000
    73b7263c074a:	lea    0x5(%rip),%rbx        # 0x73b7263c0756
    73b7263c0751:	jmp    0x73b72500a130
	...
