
/home/erg/factor-compiler-next-greedy-baseline-20260909/reference/compiler-next-20260909/installed-allocator-runtime-comparison_integer-pressure-work.bin:     file format binary


Disassembly of section .data:

00007095b081c880 <.data>:
    7095b081c880:	89 05 7a 37 30 13    	mov    %eax,0x1330377a(%rip)        # 0x7095c3b20000
    7095b081c886:	53                   	push   %rbx
    7095b081c887:	31 db                	xor    %ebx,%ebx
    7095b081c889:	ba 80 3e 00 00       	mov    $0x3e80,%edx
    7095b081c88e:	49 83 c6 18          	add    $0x18,%r14
    7095b081c892:	49 c7 46 f0 00 00 00 	movq   $0x0,-0x10(%r14)
    7095b081c899:	00 
    7095b081c89a:	e9 1d 00 00 00       	jmp    0x7095b081c8bc
    7095b081c89f:	49 8b 1f             	mov    (%r15),%rbx
    7095b081c8a2:	49 8b 57 f8          	mov    -0x8(%r15),%rdx
    7095b081c8a6:	49 83 ee 10          	sub    $0x10,%r14
    7095b081c8aa:	48 83 c3 10          	add    $0x10,%rbx
    7095b081c8ae:	89 05 4c 37 30 13    	mov    %eax,0x1330374c(%rip)        # 0x7095c3b20000
    7095b081c8b4:	49 83 c6 10          	add    $0x10,%r14
    7095b081c8b8:	49 83 ef 10          	sub    $0x10,%r15
    7095b081c8bc:	48 39 d3             	cmp    %rdx,%rbx
    7095b081c8bf:	0f 8d 5a 00 00 00    	jge    0x7095b081c91f
    7095b081c8c5:	31 c0                	xor    %eax,%eax
    7095b081c8c7:	b9 00 02 00 00       	mov    $0x200,%ecx
    7095b081c8cc:	49 83 c7 10          	add    $0x10,%r15
    7095b081c8d0:	49 89 1f             	mov    %rbx,(%r15)
    7095b081c8d3:	49 89 57 f8          	mov    %rdx,-0x8(%r15)
    7095b081c8d7:	e9 35 00 00 00       	jmp    0x7095b081c911
    7095b081c8dc:	49 83 ee 08          	sub    $0x8,%r14
    7095b081c8e0:	49 83 c7 10          	add    $0x10,%r15
    7095b081c8e4:	49 89 07             	mov    %rax,(%r15)
    7095b081c8e7:	49 89 06             	mov    %rax,(%r14)
    7095b081c8ea:	49 89 4f f8          	mov    %rcx,-0x8(%r15)
    7095b081c8ee:	e8 9d 35 27 00       	call   0x7095b0a8fe90
    7095b081c8f3:	e8 08 1d 21 00       	call   0x7095b0a2e600
    7095b081c8f8:	49 8b 07             	mov    (%r15),%rax
    7095b081c8fb:	49 8b 4f f8          	mov    -0x8(%r15),%rcx
    7095b081c8ff:	48 83 c0 10          	add    $0x10,%rax
    7095b081c903:	89 05 f7 36 30 13    	mov    %eax,0x133036f7(%rip)        # 0x7095c3b20000
    7095b081c909:	49 83 c6 10          	add    $0x10,%r14
    7095b081c90d:	49 83 ef 10          	sub    $0x10,%r15
    7095b081c911:	48 39 c8             	cmp    %rcx,%rax
    7095b081c914:	0f 8d 85 ff ff ff    	jge    0x7095b081c89f
    7095b081c91a:	e9 bd ff ff ff       	jmp    0x7095b081c8dc
    7095b081c91f:	49 83 ee 10          	sub    $0x10,%r14
    7095b081c923:	49 83 c6 08          	add    $0x8,%r14
    7095b081c927:	49 c7 06 00 00 f2 2b 	movq   $0x2bf20000,(%r14)
    7095b081c92e:	89 05 cc 36 30 13    	mov    %eax,0x133036cc(%rip)        # 0x7095c3b20000
    7095b081c934:	5b                   	pop    %rbx
    7095b081c935:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x7095b081c941
    7095b081c93c:	e9 ef ee 53 00       	jmp    0x7095b0d5b830
	...
