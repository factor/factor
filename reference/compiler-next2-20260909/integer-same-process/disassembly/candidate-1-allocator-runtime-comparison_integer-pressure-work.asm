
/home/erg/compiler-next2-integer-20260909/disassembly/candidate-1-allocator-runtime-comparison_integer-pressure-work.bin:     file format binary


Disassembly of section .data:

000077d34dcc6dc0 <.data>:
    77d34dcc6dc0:	mov    %eax,0x1335223a(%rip)        # 0x77d361019000
    77d34dcc6dc6:	push   %rbx
    77d34dcc6dc7:	xor    %eax,%eax
    77d34dcc6dc9:	mov    $0x3e80,%ecx
    77d34dcc6dce:	add    $0x18,%r14
    77d34dcc6dd2:	movq   $0x0,-0x10(%r14)
    77d34dcc6dda:	jmp    0x77d34dcc6dfc
    77d34dcc6ddf:	mov    (%r15),%rax
    77d34dcc6de2:	mov    -0x8(%r15),%rcx
    77d34dcc6de6:	sub    $0x10,%r14
    77d34dcc6dea:	add    $0x10,%rax
    77d34dcc6dee:	mov    %eax,0x1335220c(%rip)        # 0x77d361019000
    77d34dcc6df4:	add    $0x10,%r14
    77d34dcc6df8:	sub    $0x10,%r15
    77d34dcc6dfc:	cmp    %rcx,%rax
    77d34dcc6dff:	jge    0x77d34dcc6e5f
    77d34dcc6e05:	xor    %ebx,%ebx
    77d34dcc6e07:	mov    $0x200,%edx
    77d34dcc6e0c:	add    $0x10,%r15
    77d34dcc6e10:	mov    %rax,(%r15)
    77d34dcc6e13:	mov    %rcx,-0x8(%r15)
    77d34dcc6e17:	jmp    0x77d34dcc6e51
    77d34dcc6e1c:	sub    $0x8,%r14
    77d34dcc6e20:	add    $0x10,%r15
    77d34dcc6e24:	mov    %rbx,(%r15)
    77d34dcc6e27:	mov    %rbx,(%r14)
    77d34dcc6e2a:	mov    %rdx,-0x8(%r15)
    77d34dcc6e2e:	call   0x77d34df47920
    77d34dcc6e33:	call   0x77d34dee58d0
    77d34dcc6e38:	mov    (%r15),%rbx
    77d34dcc6e3b:	mov    -0x8(%r15),%rdx
    77d34dcc6e3f:	add    $0x10,%rbx
    77d34dcc6e43:	mov    %eax,0x133521b7(%rip)        # 0x77d361019000
    77d34dcc6e49:	add    $0x10,%r14
    77d34dcc6e4d:	sub    $0x10,%r15
    77d34dcc6e51:	cmp    %rdx,%rbx
    77d34dcc6e54:	jge    0x77d34dcc6ddf
    77d34dcc6e5a:	jmp    0x77d34dcc6e1c
    77d34dcc6e5f:	sub    $0x10,%r14
    77d34dcc6e63:	add    $0x8,%r14
    77d34dcc6e67:	movq   $0x2bf20000,(%r14)
    77d34dcc6e6e:	mov    %eax,0x1335218c(%rip)        # 0x77d361019000
    77d34dcc6e74:	pop    %rbx
    77d34dcc6e75:	lea    0x5(%rip),%rbx        # 0x77d34dcc6e81
    77d34dcc6e7c:	jmp    0x77d34e214520
	...
