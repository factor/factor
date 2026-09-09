
/home/erg/factor-compiler-next3-candidate-20260909/reference/compiler-next3-20260909/native-loop-code/loops.bin:     file format binary


Disassembly of section .data:

000075382b7d9430 <.data>:
    75382b7d9430:	89 05 ca 5b c7 12    	mov    %eax,0x12c75bca(%rip)        # 0x75383e44f000
    75382b7d9436:	49 8b 06             	mov    (%r14),%rax
    75382b7d9439:	48 c1 f8 04          	sar    $0x4,%rax
    75382b7d943d:	49 8b 5e f0          	mov    -0x10(%r14),%rbx
    75382b7d9441:	49 8b 4e f8          	mov    -0x8(%r14),%rcx
    75382b7d9445:	31 d2                	xor    %edx,%edx
    75382b7d9447:	49 83 c6 10          	add    $0x10,%r14
    75382b7d944b:	48 c1 fb 04          	sar    $0x4,%rbx
    75382b7d944f:	48 c1 f9 04          	sar    $0x4,%rcx
    75382b7d9453:	48 31 cb             	xor    %rcx,%rbx
    75382b7d9456:	48 89 d1             	mov    %rdx,%rcx
    75382b7d9459:	e9 0c 00 00 00       	jmp    0x75382b7d946a
    75382b7d945e:	48 31 d9             	xor    %rbx,%rcx
    75382b7d9461:	48 ff c2             	inc    %rdx
    75382b7d9464:	89 05 96 5b c7 12    	mov    %eax,0x12c75b96(%rip)        # 0x75383e44f000
    75382b7d946a:	48 39 c2             	cmp    %rax,%rdx
    75382b7d946d:	0f 8c eb ff ff ff    	jl     0x75382b7d945e
    75382b7d9473:	49 83 ee 20          	sub    $0x20,%r14
    75382b7d9477:	48 c1 e1 04          	shl    $0x4,%rcx
    75382b7d947b:	49 89 0e             	mov    %rcx,(%r14)
    75382b7d947e:	89 05 7c 5b c7 12    	mov    %eax,0x12c75b7c(%rip)        # 0x75383e44f000
    75382b7d9484:	c3                   	ret
	...
