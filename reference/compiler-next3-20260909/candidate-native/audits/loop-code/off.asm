
/home/erg/factor-compiler-next3-candidate-20260909/reference/compiler-next3-20260909/native-loop-code/off.bin:     file format binary


Disassembly of section .data:

000075382b7d9630 <.data>:
    75382b7d9630:	89 05 ca 59 c7 12    	mov    %eax,0x12c759ca(%rip)        # 0x75383e44f000
    75382b7d9636:	49 8b 06             	mov    (%r14),%rax
    75382b7d9639:	48 c1 f8 04          	sar    $0x4,%rax
    75382b7d963d:	49 8b 5e f0          	mov    -0x10(%r14),%rbx
    75382b7d9641:	48 c1 fb 04          	sar    $0x4,%rbx
    75382b7d9645:	49 8b 4e f8          	mov    -0x8(%r14),%rcx
    75382b7d9649:	48 c1 f9 04          	sar    $0x4,%rcx
    75382b7d964d:	31 d2                	xor    %edx,%edx
    75382b7d964f:	49 83 c6 10          	add    $0x10,%r14
    75382b7d9653:	48 89 d5             	mov    %rdx,%rbp
    75382b7d9656:	e9 12 00 00 00       	jmp    0x75382b7d966d
    75382b7d965b:	48 89 de             	mov    %rbx,%rsi
    75382b7d965e:	48 31 ce             	xor    %rcx,%rsi
    75382b7d9661:	48 31 f5             	xor    %rsi,%rbp
    75382b7d9664:	48 ff c2             	inc    %rdx
    75382b7d9667:	89 05 93 59 c7 12    	mov    %eax,0x12c75993(%rip)        # 0x75383e44f000
    75382b7d966d:	48 39 c2             	cmp    %rax,%rdx
    75382b7d9670:	0f 8c e5 ff ff ff    	jl     0x75382b7d965b
    75382b7d9676:	49 83 ee 20          	sub    $0x20,%r14
    75382b7d967a:	48 c1 e5 04          	shl    $0x4,%rbp
    75382b7d967e:	49 89 2e             	mov    %rbp,(%r14)
    75382b7d9681:	89 05 79 59 c7 12    	mov    %eax,0x12c75979(%rip)        # 0x75383e44f000
    75382b7d9687:	c3                   	ret
	...
