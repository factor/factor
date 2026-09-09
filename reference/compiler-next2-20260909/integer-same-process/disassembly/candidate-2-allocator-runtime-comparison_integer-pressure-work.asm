
/home/erg/compiler-next2-integer-20260909/disassembly/candidate-2-allocator-runtime-comparison_integer-pressure-work.bin:     file format binary


Disassembly of section .data:

000073b725e84dc0 <.data>:
    73b725e84dc0:	mov    %eax,0x1336623a(%rip)        # 0x73b7391eb000
    73b725e84dc6:	push   %rbx
    73b725e84dc7:	xor    %eax,%eax
    73b725e84dc9:	mov    $0x3e80,%ecx
    73b725e84dce:	add    $0x18,%r14
    73b725e84dd2:	movq   $0x0,-0x10(%r14)
    73b725e84dda:	jmp    0x73b725e84dfc
    73b725e84ddf:	mov    (%r15),%rax
    73b725e84de2:	mov    -0x8(%r15),%rcx
    73b725e84de6:	sub    $0x10,%r14
    73b725e84dea:	add    $0x10,%rax
    73b725e84dee:	mov    %eax,0x1336620c(%rip)        # 0x73b7391eb000
    73b725e84df4:	add    $0x10,%r14
    73b725e84df8:	sub    $0x10,%r15
    73b725e84dfc:	cmp    %rcx,%rax
    73b725e84dff:	jge    0x73b725e84e5f
    73b725e84e05:	xor    %ebx,%ebx
    73b725e84e07:	mov    $0x200,%edx
    73b725e84e0c:	add    $0x10,%r15
    73b725e84e10:	mov    %rax,(%r15)
    73b725e84e13:	mov    %rcx,-0x8(%r15)
    73b725e84e17:	jmp    0x73b725e84e51
    73b725e84e1c:	sub    $0x8,%r14
    73b725e84e20:	add    $0x10,%r15
    73b725e84e24:	mov    %rbx,(%r15)
    73b725e84e27:	mov    %rbx,(%r14)
    73b725e84e2a:	mov    %rdx,-0x8(%r15)
    73b725e84e2e:	call   0x73b726105920
    73b725e84e33:	call   0x73b7260a38d0
    73b725e84e38:	mov    (%r15),%rbx
    73b725e84e3b:	mov    -0x8(%r15),%rdx
    73b725e84e3f:	add    $0x10,%rbx
    73b725e84e43:	mov    %eax,0x133661b7(%rip)        # 0x73b7391eb000
    73b725e84e49:	add    $0x10,%r14
    73b725e84e4d:	sub    $0x10,%r15
    73b725e84e51:	cmp    %rdx,%rbx
    73b725e84e54:	jge    0x73b725e84ddf
    73b725e84e5a:	jmp    0x73b725e84e1c
    73b725e84e5f:	sub    $0x10,%r14
    73b725e84e63:	add    $0x8,%r14
    73b725e84e67:	movq   $0x2bf20000,(%r14)
    73b725e84e6e:	mov    %eax,0x1336618c(%rip)        # 0x73b7391eb000
    73b725e84e74:	pop    %rbx
    73b725e84e75:	lea    0x5(%rip),%rbx        # 0x73b725e84e81
    73b725e84e7c:	jmp    0x73b7263d2520
	...
