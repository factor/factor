
/home/erg/compiler-next2-integer-20260909/disassembly/baseline-1-_fixnum=_plus.bin:     file format binary


Disassembly of section .data:

000075da27682590 <.data>:
    75da27682590:	mov    %eax,0x12e07a6a(%rip)        # 0x75da3a48a000
    75da27682596:	mov    (%r14),%rbx
    75da27682599:	mov    -0x8(%r14),%rax
    75da2768259d:	add    %rbx,%rax
    75da276825a0:	jo     0x75da276825b4
    75da276825a6:	sub    $0x8,%r14
    75da276825aa:	mov    %rax,(%r14)
    75da276825ad:	mov    %eax,0x12e07a4d(%rip)        # 0x75da3a48a000
    75da276825b3:	ret
    75da276825b4:	mov    %eax,0x12e07a46(%rip)        # 0x75da3a48a000
    75da276825ba:	lea    0x5(%rip),%rbx        # 0x75da276825c6
    75da276825c1:	jmp    0x75da262d27a0
	...
