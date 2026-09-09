
/home/erg/compiler-next2-integer-20260909/disassembly/candidate-1-_fixnum=_plus.bin:     file format binary


Disassembly of section .data:

000077d34e202720 <.data>:
    77d34e202720:	mov    %eax,0x12e168da(%rip)        # 0x77d361019000
    77d34e202726:	mov    (%r14),%rbx
    77d34e202729:	mov    -0x8(%r14),%rax
    77d34e20272d:	add    %rbx,%rax
    77d34e202730:	jo     0x77d34e202744
    77d34e202736:	sub    $0x8,%r14
    77d34e20273a:	mov    %rax,(%r14)
    77d34e20273d:	mov    %eax,0x12e168bd(%rip)        # 0x77d361019000
    77d34e202743:	ret
    77d34e202744:	mov    %eax,0x12e168b6(%rip)        # 0x77d361019000
    77d34e20274a:	lea    0x5(%rip),%rbx        # 0x77d34e202756
    77d34e202751:	jmp    0x77d34ce4c130
	...
