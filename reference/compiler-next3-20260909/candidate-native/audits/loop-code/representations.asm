
/home/erg/factor-compiler-next3-candidate-20260909/reference/compiler-next3-20260909/native-loop-code/representations.bin:     file format binary


Disassembly of section .data:

000075382b7d9330 <.data>:
    75382b7d9330:	89 05 ca 5c c7 12    	mov    %eax,0x12c75cca(%rip)        # 0x75383e44f000
    75382b7d9336:	49 8b 06             	mov    (%r14),%rax
    75382b7d9339:	48 c1 f8 04          	sar    $0x4,%rax
    75382b7d933d:	49 8b 5e f0          	mov    -0x10(%r14),%rbx
    75382b7d9341:	48 c1 fb 04          	sar    $0x4,%rbx
    75382b7d9345:	49 8b 4e f8          	mov    -0x8(%r14),%rcx
    75382b7d9349:	48 c1 f9 04          	sar    $0x4,%rcx
    75382b7d934d:	31 d2                	xor    %edx,%edx
    75382b7d934f:	49 83 c6 10          	add    $0x10,%r14
    75382b7d9353:	48 89 d5             	mov    %rdx,%rbp
    75382b7d9356:	e9 12 00 00 00       	jmp    0x75382b7d936d
    75382b7d935b:	48 89 de             	mov    %rbx,%rsi
    75382b7d935e:	48 31 ce             	xor    %rcx,%rsi
    75382b7d9361:	48 31 f5             	xor    %rsi,%rbp
    75382b7d9364:	48 ff c2             	inc    %rdx
    75382b7d9367:	89 05 93 5c c7 12    	mov    %eax,0x12c75c93(%rip)        # 0x75383e44f000
    75382b7d936d:	48 39 c2             	cmp    %rax,%rdx
    75382b7d9370:	0f 8c e5 ff ff ff    	jl     0x75382b7d935b
    75382b7d9376:	49 83 ee 20          	sub    $0x20,%r14
    75382b7d937a:	48 c1 e5 04          	shl    $0x4,%rbp
    75382b7d937e:	49 89 2e             	mov    %rbp,(%r14)
    75382b7d9381:	89 05 79 5c c7 12    	mov    %eax,0x12c75c79(%rip)        # 0x75383e44f000
    75382b7d9387:	c3                   	ret
	...
