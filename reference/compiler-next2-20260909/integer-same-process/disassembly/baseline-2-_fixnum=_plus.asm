
/home/erg/compiler-next2-integer-20260909/disassembly/baseline-2-_fixnum=_plus.bin:     file format binary


Disassembly of section .data:

00007b39ba171590 <.data>:
    7b39ba171590:	mov    %eax,0x12e48a6a(%rip)        # 0x7b39ccfba000
    7b39ba171596:	mov    (%r14),%rbx
    7b39ba171599:	mov    -0x8(%r14),%rax
    7b39ba17159d:	add    %rbx,%rax
    7b39ba1715a0:	jo     0x7b39ba1715b4
    7b39ba1715a6:	sub    $0x8,%r14
    7b39ba1715aa:	mov    %rax,(%r14)
    7b39ba1715ad:	mov    %eax,0x12e48a4d(%rip)        # 0x7b39ccfba000
    7b39ba1715b3:	ret
    7b39ba1715b4:	mov    %eax,0x12e48a46(%rip)        # 0x7b39ccfba000
    7b39ba1715ba:	lea    0x5(%rip),%rbx        # 0x7b39ba1715c6
    7b39ba1715c1:	jmp    0x7b39b8dc17a0
	...
