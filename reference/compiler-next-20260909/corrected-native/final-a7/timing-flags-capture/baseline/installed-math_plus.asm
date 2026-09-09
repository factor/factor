
/home/erg/factor-compiler-next-greedy-baseline-20260909/reference/compiler-next-20260909/installed-math_plus.bin:     file format binary


Disassembly of section .data:

00007095b0a2e600 <.data>:
    7095b0a2e600:	89 05 fa 19 0f 13    	mov    %eax,0x130f19fa(%rip)        # 0x7095c3b20000
    7095b0a2e606:	48 81 ec a8 00 00 00 	sub    $0xa8,%rsp
    7095b0a2e60d:	49 8b 06             	mov    (%r14),%rax
    7095b0a2e610:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2e614:	48 89 d9             	mov    %rbx,%rcx
    7095b0a2e617:	48 89 c2             	mov    %rax,%rdx
    7095b0a2e61a:	48 09 d1             	or     %rdx,%rcx
    7095b0a2e61d:	f7 c1 0f 00 00 00    	test   $0xf,%ecx
    7095b0a2e623:	0f 85 37 00 00 00    	jne    0x7095b0a2e660
    7095b0a2e629:	48 01 c3             	add    %rax,%rbx
    7095b0a2e62c:	0f 80 15 00 00 00    	jo     0x7095b0a2e647
    7095b0a2e632:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2e636:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2e639:	89 05 c1 19 0f 13    	mov    %eax,0x130f19c1(%rip)        # 0x7095c3b20000
    7095b0a2e63f:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2e646:	c3                   	ret
    7095b0a2e647:	89 05 b3 19 0f 13    	mov    %eax,0x130f19b3(%rip)        # 0x7095c3b20000
    7095b0a2e64d:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2e654:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x7095b0a2e660
    7095b0a2e65b:	e9 60 05 f5 fe       	jmp    0x7095af97ebc0
    7095b0a2e660:	48 89 d9             	mov    %rbx,%rcx
    7095b0a2e663:	f7 c1 0f 00 00 00    	test   $0xf,%ecx
    7095b0a2e669:	0f 85 aa 02 00 00    	jne    0x7095b0a2e919
    7095b0a2e66f:	48 89 c1             	mov    %rax,%rcx
    7095b0a2e672:	83 e1 0f             	and    $0xf,%ecx
    7095b0a2e675:	48 83 f9 03          	cmp    $0x3,%rcx
    7095b0a2e679:	0f 85 73 00 00 00    	jne    0x7095b0a2e6f2
    7095b0a2e67f:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    7095b0a2e683:	48 8b 11             	mov    (%rcx),%rdx
    7095b0a2e686:	48 83 c2 10          	add    $0x10,%rdx
    7095b0a2e68a:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    7095b0a2e68e:	0f 8e 17 00 00 00    	jle    0x7095b0a2e6ab
    7095b0a2e694:	48 89 1c 24          	mov    %rbx,(%rsp)
    7095b0a2e698:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    7095b0a2e69d:	e8 ce 88 06 00       	call   0x7095b0a96f70
    7095b0a2e6a2:	48 8b 1c 24          	mov    (%rsp),%rbx
    7095b0a2e6a6:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
    7095b0a2e6ab:	48 c1 fb 04          	sar    $0x4,%rbx
    7095b0a2e6af:	0f 57 c0             	xorps  %xmm0,%xmm0
    7095b0a2e6b2:	f2 48 0f 2a c3       	cvtsi2sd %rbx,%xmm0
    7095b0a2e6b7:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
    7095b0a2e6bd:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    7095b0a2e6c1:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    7095b0a2e6c5:	48 8b 03             	mov    (%rbx),%rax
    7095b0a2e6c8:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    7095b0a2e6cf:	48 83 c8 03          	or     $0x3,%rax
    7095b0a2e6d3:	48 83 03 10          	addq   $0x10,(%rbx)
    7095b0a2e6d7:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    7095b0a2e6dd:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2e6e1:	49 89 06             	mov    %rax,(%r14)
    7095b0a2e6e4:	89 05 16 19 0f 13    	mov    %eax,0x130f1916(%rip)        # 0x7095c3b20000
    7095b0a2e6ea:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2e6f1:	c3                   	ret
    7095b0a2e6f2:	48 89 c3             	mov    %rax,%rbx
    7095b0a2e6f5:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2e6f8:	48 83 fb 05          	cmp    $0x5,%rbx
    7095b0a2e6fc:	0f 85 37 00 00 00    	jne    0x7095b0a2e739
    7095b0a2e702:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2e706:	49 83 c7 08          	add    $0x8,%r15
    7095b0a2e70a:	49 89 07             	mov    %rax,(%r15)
    7095b0a2e70d:	e8 ee d6 43 00       	call   0x7095b0e6be00
    7095b0a2e712:	49 8b 07             	mov    (%r15),%rax
    7095b0a2e715:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2e719:	49 83 ef 08          	sub    $0x8,%r15
    7095b0a2e71d:	49 89 06             	mov    %rax,(%r14)
    7095b0a2e720:	89 05 da 18 0f 13    	mov    %eax,0x130f18da(%rip)        # 0x7095c3b20000
    7095b0a2e726:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2e72d:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x7095b0a2e739
    7095b0a2e734:	e9 97 b7 36 00       	jmp    0x7095b0d99ed0
    7095b0a2e739:	48 89 c3             	mov    %rax,%rbx
    7095b0a2e73c:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2e73f:	48 83 fb 07          	cmp    $0x7,%rbx
    7095b0a2e743:	0f 85 ba 01 00 00    	jne    0x7095b0a2e903
    7095b0a2e749:	48 8b 58 01          	mov    0x1(%rax),%rbx
    7095b0a2e74d:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
    7095b0a2e751:	48 b9 8c f9 00 b6 95 	movabs $0x7095b600f98c,%rcx
    7095b0a2e758:	70 00 00 
    7095b0a2e75b:	48 39 cb             	cmp    %rcx,%rbx
    7095b0a2e75e:	0f 85 55 01 00 00    	jne    0x7095b0a2e8b9
    7095b0a2e764:	48 8b 58 09          	mov    0x9(%rax),%rbx
    7095b0a2e768:	48 8b 40 11          	mov    0x11(%rax),%rax
    7095b0a2e76c:	49 83 c7 10          	add    $0x10,%r15
    7095b0a2e770:	49 89 47 f8          	mov    %rax,-0x8(%r15)
    7095b0a2e774:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2e777:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
    7095b0a2e77e:	e8 7d fe ff ff       	call   0x7095b0a2e600
    7095b0a2e783:	49 8b 07             	mov    (%r15),%rax
    7095b0a2e786:	49 8b 5f f8          	mov    -0x8(%r15),%rbx
    7095b0a2e78a:	49 83 c6 10          	add    $0x10,%r14
    7095b0a2e78e:	49 83 ef 10          	sub    $0x10,%r15
    7095b0a2e792:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2e796:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2e799:	e8 62 fe ff ff       	call   0x7095b0a2e600
    7095b0a2e79e:	49 8b 06             	mov    (%r14),%rax
    7095b0a2e7a1:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2e7a5:	48 83 f8 00          	cmp    $0x0,%rax
    7095b0a2e7a9:	0f 85 16 00 00 00    	jne    0x7095b0a2e7c5
    7095b0a2e7af:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2e7b3:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2e7b7:	89 05 43 18 0f 13    	mov    %eax,0x130f1843(%rip)        # 0x7095c3b20000
    7095b0a2e7bd:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2e7c4:	c3                   	ret
    7095b0a2e7c5:	48 89 c3             	mov    %rax,%rbx
    7095b0a2e7c8:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    7095b0a2e7ce:	0f 85 10 00 00 00    	jne    0x7095b0a2e7e4
    7095b0a2e7d4:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2e7d8:	49 8b 06             	mov    (%r14),%rax
    7095b0a2e7db:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2e7df:	e9 64 00 00 00       	jmp    0x7095b0a2e848
    7095b0a2e7e4:	48 89 c3             	mov    %rax,%rbx
    7095b0a2e7e7:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2e7ea:	48 83 fb 05          	cmp    $0x5,%rbx
    7095b0a2e7ee:	0f 85 49 00 00 00    	jne    0x7095b0a2e83d
    7095b0a2e7f4:	48 bb 05 ef 09 b6 95 	movabs $0x7095b609ef05,%rbx
    7095b0a2e7fb:	70 00 00 
    7095b0a2e7fe:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2e802:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2e806:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2e809:	e8 22 3f 36 00       	call   0x7095b0d92730
    7095b0a2e80e:	49 8b 06             	mov    (%r14),%rax
    7095b0a2e811:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2e815:	48 83 f8 01          	cmp    $0x1,%rax
    7095b0a2e819:	0f 84 12 00 00 00    	je     0x7095b0a2e831
    7095b0a2e81f:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2e823:	89 05 d7 17 0f 13    	mov    %eax,0x130f17d7(%rip)        # 0x7095c3b20000
    7095b0a2e829:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2e830:	c3                   	ret
    7095b0a2e831:	49 8b 06             	mov    (%r14),%rax
    7095b0a2e834:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2e838:	e9 0b 00 00 00       	jmp    0x7095b0a2e848
    7095b0a2e83d:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2e841:	49 8b 06             	mov    (%r14),%rax
    7095b0a2e844:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2e848:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    7095b0a2e84c:	48 8b 11             	mov    (%rcx),%rdx
    7095b0a2e84f:	48 83 c2 20          	add    $0x20,%rdx
    7095b0a2e853:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    7095b0a2e857:	0f 8e 19 00 00 00    	jle    0x7095b0a2e876
    7095b0a2e85d:	48 89 5c 24 10       	mov    %rbx,0x10(%rsp)
    7095b0a2e862:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
    7095b0a2e867:	e8 04 87 06 00       	call   0x7095b0a96f70
    7095b0a2e86c:	48 8b 5c 24 10       	mov    0x10(%rsp),%rbx
    7095b0a2e871:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
    7095b0a2e876:	48 ba 52 f5 00 b6 95 	movabs $0x7095b600f552,%rdx
    7095b0a2e87d:	70 00 00 
    7095b0a2e880:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    7095b0a2e884:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    7095b0a2e888:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    7095b0a2e88f:	48 83 c9 07          	or     $0x7,%rcx
    7095b0a2e893:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    7095b0a2e898:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    7095b0a2e89c:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    7095b0a2e8a0:	48 89 41 11          	mov    %rax,0x11(%rcx)
    7095b0a2e8a4:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2e8a8:	49 89 0e             	mov    %rcx,(%r14)
    7095b0a2e8ab:	89 05 4f 17 0f 13    	mov    %eax,0x130f174f(%rip)        # 0x7095c3b20000
    7095b0a2e8b1:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2e8b8:	c3                   	ret
    7095b0a2e8b9:	48 8b 40 01          	mov    0x1(%rax),%rax
    7095b0a2e8bd:	48 8b 40 0e          	mov    0xe(%rax),%rax
    7095b0a2e8c1:	48 bb 1c c6 ff b5 95 	movabs $0x7095b5ffc61c,%rbx
    7095b0a2e8c8:	70 00 00 
    7095b0a2e8cb:	48 39 d8             	cmp    %rbx,%rax
    7095b0a2e8ce:	0f 85 19 00 00 00    	jne    0x7095b0a2e8ed
    7095b0a2e8d4:	89 05 26 17 0f 13    	mov    %eax,0x130f1726(%rip)        # 0x7095c3b20000
    7095b0a2e8da:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2e8e1:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x7095b0a2e8ed
    7095b0a2e8e8:	e9 d3 10 1f 00       	jmp    0x7095b0c1f9c0
    7095b0a2e8ed:	48 b8 dc 9e fe b5 95 	movabs $0x7095b5fe9edc,%rax
    7095b0a2e8f4:	70 00 00 
    7095b0a2e8f7:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2e8fb:	49 89 06             	mov    %rax,(%r14)
    7095b0a2e8fe:	e8 1d 86 43 00       	call   0x7095b0e66f20
    7095b0a2e903:	48 b8 dc 9e fe b5 95 	movabs $0x7095b5fe9edc,%rax
    7095b0a2e90a:	70 00 00 
    7095b0a2e90d:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2e911:	49 89 06             	mov    %rax,(%r14)
    7095b0a2e914:	e8 07 86 43 00       	call   0x7095b0e66f20
    7095b0a2e919:	48 89 d9             	mov    %rbx,%rcx
    7095b0a2e91c:	83 e1 0f             	and    $0xf,%ecx
    7095b0a2e91f:	48 83 f9 03          	cmp    $0x3,%rcx
    7095b0a2e923:	0f 85 f5 03 00 00    	jne    0x7095b0a2ed1e
    7095b0a2e929:	48 89 c1             	mov    %rax,%rcx
    7095b0a2e92c:	f7 c1 0f 00 00 00    	test   $0xf,%ecx
    7095b0a2e932:	0f 85 73 00 00 00    	jne    0x7095b0a2e9ab
    7095b0a2e938:	49 8d 55 10          	lea    0x10(%r13),%rdx
    7095b0a2e93c:	48 8b 0a             	mov    (%rdx),%rcx
    7095b0a2e93f:	48 83 c1 10          	add    $0x10,%rcx
    7095b0a2e943:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
    7095b0a2e947:	0f 8e 17 00 00 00    	jle    0x7095b0a2e964
    7095b0a2e94d:	48 89 1c 24          	mov    %rbx,(%rsp)
    7095b0a2e951:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    7095b0a2e956:	e8 15 86 06 00       	call   0x7095b0a96f70
    7095b0a2e95b:	48 8b 1c 24          	mov    (%rsp),%rbx
    7095b0a2e95f:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
    7095b0a2e964:	48 c1 f8 04          	sar    $0x4,%rax
    7095b0a2e968:	0f 57 c9             	xorps  %xmm1,%xmm1
    7095b0a2e96b:	f2 48 0f 2a c8       	cvtsi2sd %rax,%xmm1
    7095b0a2e970:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
    7095b0a2e976:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    7095b0a2e97a:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    7095b0a2e97e:	48 8b 03             	mov    (%rbx),%rax
    7095b0a2e981:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    7095b0a2e988:	48 83 c8 03          	or     $0x3,%rax
    7095b0a2e98c:	48 83 03 10          	addq   $0x10,(%rbx)
    7095b0a2e990:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    7095b0a2e996:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2e99a:	49 89 06             	mov    %rax,(%r14)
    7095b0a2e99d:	89 05 5d 16 0f 13    	mov    %eax,0x130f165d(%rip)        # 0x7095c3b20000
    7095b0a2e9a3:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2e9aa:	c3                   	ret
    7095b0a2e9ab:	48 89 c1             	mov    %rax,%rcx
    7095b0a2e9ae:	83 e1 0f             	and    $0xf,%ecx
    7095b0a2e9b1:	48 83 f9 03          	cmp    $0x3,%rcx
    7095b0a2e9b5:	0f 85 6d 00 00 00    	jne    0x7095b0a2ea28
    7095b0a2e9bb:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    7095b0a2e9bf:	48 8b 11             	mov    (%rcx),%rdx
    7095b0a2e9c2:	48 83 c2 10          	add    $0x10,%rdx
    7095b0a2e9c6:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    7095b0a2e9ca:	0f 8e 17 00 00 00    	jle    0x7095b0a2e9e7
    7095b0a2e9d0:	48 89 1c 24          	mov    %rbx,(%rsp)
    7095b0a2e9d4:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    7095b0a2e9d9:	e8 92 85 06 00       	call   0x7095b0a96f70
    7095b0a2e9de:	48 8b 1c 24          	mov    (%rsp),%rbx
    7095b0a2e9e2:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
    7095b0a2e9e7:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
    7095b0a2e9ed:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
    7095b0a2e9f3:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    7095b0a2e9f7:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    7095b0a2e9fb:	48 8b 03             	mov    (%rbx),%rax
    7095b0a2e9fe:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    7095b0a2ea05:	48 83 c8 03          	or     $0x3,%rax
    7095b0a2ea09:	48 83 03 10          	addq   $0x10,(%rbx)
    7095b0a2ea0d:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    7095b0a2ea13:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2ea17:	49 89 06             	mov    %rax,(%r14)
    7095b0a2ea1a:	89 05 e0 15 0f 13    	mov    %eax,0x130f15e0(%rip)        # 0x7095c3b20000
    7095b0a2ea20:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2ea27:	c3                   	ret
    7095b0a2ea28:	48 89 c3             	mov    %rax,%rbx
    7095b0a2ea2b:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2ea2e:	48 83 fb 05          	cmp    $0x5,%rbx
    7095b0a2ea32:	0f 85 67 00 00 00    	jne    0x7095b0a2ea9f
    7095b0a2ea38:	e8 33 7b e3 ff       	call   0x7095b0866570
    7095b0a2ea3d:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    7095b0a2ea41:	48 8b 03             	mov    (%rbx),%rax
    7095b0a2ea44:	48 83 c0 10          	add    $0x10,%rax
    7095b0a2ea48:	48 3b 43 10          	cmp    0x10(%rbx),%rax
    7095b0a2ea4c:	0f 8e 05 00 00 00    	jle    0x7095b0a2ea57
    7095b0a2ea52:	e8 19 85 06 00       	call   0x7095b0a96f70
    7095b0a2ea57:	49 8b 06             	mov    (%r14),%rax
    7095b0a2ea5a:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2ea5e:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
    7095b0a2ea64:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
    7095b0a2ea6a:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    7095b0a2ea6e:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    7095b0a2ea72:	48 8b 03             	mov    (%rbx),%rax
    7095b0a2ea75:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    7095b0a2ea7c:	48 83 c8 03          	or     $0x3,%rax
    7095b0a2ea80:	48 83 03 10          	addq   $0x10,(%rbx)
    7095b0a2ea84:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    7095b0a2ea8a:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2ea8e:	49 89 06             	mov    %rax,(%r14)
    7095b0a2ea91:	89 05 69 15 0f 13    	mov    %eax,0x130f1569(%rip)        # 0x7095c3b20000
    7095b0a2ea97:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2ea9e:	c3                   	ret
    7095b0a2ea9f:	48 89 c3             	mov    %rax,%rbx
    7095b0a2eaa2:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2eaa5:	48 83 fb 07          	cmp    $0x7,%rbx
    7095b0a2eaa9:	0f 85 59 02 00 00    	jne    0x7095b0a2ed08
    7095b0a2eaaf:	48 8b 58 01          	mov    0x1(%rax),%rbx
    7095b0a2eab3:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
    7095b0a2eab7:	48 b9 8c f9 00 b6 95 	movabs $0x7095b600f98c,%rcx
    7095b0a2eabe:	70 00 00 
    7095b0a2eac1:	48 39 cb             	cmp    %rcx,%rbx
    7095b0a2eac4:	0f 85 a6 01 00 00    	jne    0x7095b0a2ec70
    7095b0a2eaca:	48 8b 58 09          	mov    0x9(%rax),%rbx
    7095b0a2eace:	48 8b 40 11          	mov    0x11(%rax),%rax
    7095b0a2ead2:	49 83 c7 10          	add    $0x10,%r15
    7095b0a2ead6:	49 89 47 f8          	mov    %rax,-0x8(%r15)
    7095b0a2eada:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2eadd:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
    7095b0a2eae4:	e8 37 d4 e2 fe       	call   0x7095af85bf20
    7095b0a2eae9:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    7095b0a2eaed:	48 8b 03             	mov    (%rbx),%rax
    7095b0a2eaf0:	48 83 c0 10          	add    $0x10,%rax
    7095b0a2eaf4:	48 3b 43 10          	cmp    0x10(%rbx),%rax
    7095b0a2eaf8:	0f 8e 05 00 00 00    	jle    0x7095b0a2eb03
    7095b0a2eafe:	e8 6d 84 06 00       	call   0x7095b0a96f70
    7095b0a2eb03:	49 8b 0e             	mov    (%r14),%rcx
    7095b0a2eb06:	49 8b 07             	mov    (%r15),%rax
    7095b0a2eb09:	49 8b 56 f8          	mov    -0x8(%r14),%rdx
    7095b0a2eb0d:	49 8b 5f f8          	mov    -0x8(%r15),%rbx
    7095b0a2eb11:	f2 48 0f 10 42 05    	rex.W movsd 0x5(%rdx),%xmm0
    7095b0a2eb17:	f2 48 0f 10 49 05    	rex.W movsd 0x5(%rcx),%xmm1
    7095b0a2eb1d:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    7095b0a2eb21:	49 8d 55 10          	lea    0x10(%r13),%rdx
    7095b0a2eb25:	48 8b 0a             	mov    (%rdx),%rcx
    7095b0a2eb28:	48 c7 01 0c 00 00 00 	movq   $0xc,(%rcx)
    7095b0a2eb2f:	48 83 c9 03          	or     $0x3,%rcx
    7095b0a2eb33:	48 83 02 10          	addq   $0x10,(%rdx)
    7095b0a2eb37:	f2 48 0f 11 41 05    	rex.W movsd %xmm0,0x5(%rcx)
    7095b0a2eb3d:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2eb41:	49 83 ef 10          	sub    $0x10,%r15
    7095b0a2eb45:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2eb49:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2eb4c:	49 89 4e f0          	mov    %rcx,-0x10(%r14)
    7095b0a2eb50:	e8 ab fa ff ff       	call   0x7095b0a2e600
    7095b0a2eb55:	49 8b 06             	mov    (%r14),%rax
    7095b0a2eb58:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2eb5c:	48 83 f8 00          	cmp    $0x0,%rax
    7095b0a2eb60:	0f 85 16 00 00 00    	jne    0x7095b0a2eb7c
    7095b0a2eb66:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2eb6a:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2eb6e:	89 05 8c 14 0f 13    	mov    %eax,0x130f148c(%rip)        # 0x7095c3b20000
    7095b0a2eb74:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2eb7b:	c3                   	ret
    7095b0a2eb7c:	48 89 c3             	mov    %rax,%rbx
    7095b0a2eb7f:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    7095b0a2eb85:	0f 85 10 00 00 00    	jne    0x7095b0a2eb9b
    7095b0a2eb8b:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2eb8f:	49 8b 06             	mov    (%r14),%rax
    7095b0a2eb92:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2eb96:	e9 64 00 00 00       	jmp    0x7095b0a2ebff
    7095b0a2eb9b:	48 89 c3             	mov    %rax,%rbx
    7095b0a2eb9e:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2eba1:	48 83 fb 05          	cmp    $0x5,%rbx
    7095b0a2eba5:	0f 85 49 00 00 00    	jne    0x7095b0a2ebf4
    7095b0a2ebab:	48 bb 05 ef 09 b6 95 	movabs $0x7095b609ef05,%rbx
    7095b0a2ebb2:	70 00 00 
    7095b0a2ebb5:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2ebb9:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2ebbd:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2ebc0:	e8 6b 3b 36 00       	call   0x7095b0d92730
    7095b0a2ebc5:	49 8b 06             	mov    (%r14),%rax
    7095b0a2ebc8:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2ebcc:	48 83 f8 01          	cmp    $0x1,%rax
    7095b0a2ebd0:	0f 84 12 00 00 00    	je     0x7095b0a2ebe8
    7095b0a2ebd6:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2ebda:	89 05 20 14 0f 13    	mov    %eax,0x130f1420(%rip)        # 0x7095c3b20000
    7095b0a2ebe0:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2ebe7:	c3                   	ret
    7095b0a2ebe8:	49 8b 06             	mov    (%r14),%rax
    7095b0a2ebeb:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2ebef:	e9 0b 00 00 00       	jmp    0x7095b0a2ebff
    7095b0a2ebf4:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2ebf8:	49 8b 06             	mov    (%r14),%rax
    7095b0a2ebfb:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2ebff:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    7095b0a2ec03:	48 8b 11             	mov    (%rcx),%rdx
    7095b0a2ec06:	48 83 c2 20          	add    $0x20,%rdx
    7095b0a2ec0a:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    7095b0a2ec0e:	0f 8e 19 00 00 00    	jle    0x7095b0a2ec2d
    7095b0a2ec14:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)
    7095b0a2ec19:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    7095b0a2ec1e:	e8 4d 83 06 00       	call   0x7095b0a96f70
    7095b0a2ec23:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
    7095b0a2ec28:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    7095b0a2ec2d:	48 ba 52 f5 00 b6 95 	movabs $0x7095b600f552,%rdx
    7095b0a2ec34:	70 00 00 
    7095b0a2ec37:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    7095b0a2ec3b:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    7095b0a2ec3f:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    7095b0a2ec46:	48 83 c9 07          	or     $0x7,%rcx
    7095b0a2ec4a:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    7095b0a2ec4f:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    7095b0a2ec53:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    7095b0a2ec57:	48 89 41 11          	mov    %rax,0x11(%rcx)
    7095b0a2ec5b:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2ec5f:	49 89 0e             	mov    %rcx,(%r14)
    7095b0a2ec62:	89 05 98 13 0f 13    	mov    %eax,0x130f1398(%rip)        # 0x7095c3b20000
    7095b0a2ec68:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2ec6f:	c3                   	ret
    7095b0a2ec70:	48 8b 40 01          	mov    0x1(%rax),%rax
    7095b0a2ec74:	48 8b 40 0e          	mov    0xe(%rax),%rax
    7095b0a2ec78:	48 bb 1c c6 ff b5 95 	movabs $0x7095b5ffc61c,%rbx
    7095b0a2ec7f:	70 00 00 
    7095b0a2ec82:	48 39 d8             	cmp    %rbx,%rax
    7095b0a2ec85:	0f 85 67 00 00 00    	jne    0x7095b0a2ecf2
    7095b0a2ec8b:	e8 90 bd d8 ff       	call   0x7095b07baa20
    7095b0a2ec90:	49 8d 45 10          	lea    0x10(%r13),%rax
    7095b0a2ec94:	48 8b 18             	mov    (%rax),%rbx
    7095b0a2ec97:	48 83 c3 10          	add    $0x10,%rbx
    7095b0a2ec9b:	48 3b 58 10          	cmp    0x10(%rax),%rbx
    7095b0a2ec9f:	0f 8e 05 00 00 00    	jle    0x7095b0a2ecaa
    7095b0a2eca5:	e8 c6 82 06 00       	call   0x7095b0a96f70
    7095b0a2ecaa:	49 8b 06             	mov    (%r14),%rax
    7095b0a2ecad:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2ecb1:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
    7095b0a2ecb7:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
    7095b0a2ecbd:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    7095b0a2ecc1:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    7095b0a2ecc5:	48 8b 03             	mov    (%rbx),%rax
    7095b0a2ecc8:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    7095b0a2eccf:	48 83 c8 03          	or     $0x3,%rax
    7095b0a2ecd3:	48 83 03 10          	addq   $0x10,(%rbx)
    7095b0a2ecd7:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    7095b0a2ecdd:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2ece1:	49 89 06             	mov    %rax,(%r14)
    7095b0a2ece4:	89 05 16 13 0f 13    	mov    %eax,0x130f1316(%rip)        # 0x7095c3b20000
    7095b0a2ecea:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2ecf1:	c3                   	ret
    7095b0a2ecf2:	48 b8 dc 9e fe b5 95 	movabs $0x7095b5fe9edc,%rax
    7095b0a2ecf9:	70 00 00 
    7095b0a2ecfc:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2ed00:	49 89 06             	mov    %rax,(%r14)
    7095b0a2ed03:	e8 18 82 43 00       	call   0x7095b0e66f20
    7095b0a2ed08:	48 b8 dc 9e fe b5 95 	movabs $0x7095b5fe9edc,%rax
    7095b0a2ed0f:	70 00 00 
    7095b0a2ed12:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2ed16:	49 89 06             	mov    %rax,(%r14)
    7095b0a2ed19:	e8 02 82 43 00       	call   0x7095b0e66f20
    7095b0a2ed1e:	48 89 d9             	mov    %rbx,%rcx
    7095b0a2ed21:	83 e1 0f             	and    $0xf,%ecx
    7095b0a2ed24:	48 83 f9 05          	cmp    $0x5,%rcx
    7095b0a2ed28:	0f 85 b7 02 00 00    	jne    0x7095b0a2efe5
    7095b0a2ed2e:	48 89 c3             	mov    %rax,%rbx
    7095b0a2ed31:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    7095b0a2ed37:	0f 85 1e 00 00 00    	jne    0x7095b0a2ed5b
    7095b0a2ed3d:	e8 be d0 43 00       	call   0x7095b0e6be00
    7095b0a2ed42:	89 05 b8 12 0f 13    	mov    %eax,0x130f12b8(%rip)        # 0x7095c3b20000
    7095b0a2ed48:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2ed4f:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x7095b0a2ed5b
    7095b0a2ed56:	e9 75 b1 36 00       	jmp    0x7095b0d99ed0
    7095b0a2ed5b:	48 89 c3             	mov    %rax,%rbx
    7095b0a2ed5e:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2ed61:	48 83 fb 03          	cmp    $0x3,%rbx
    7095b0a2ed65:	0f 85 71 00 00 00    	jne    0x7095b0a2eddc
    7095b0a2ed6b:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2ed6f:	49 83 c7 08          	add    $0x8,%r15
    7095b0a2ed73:	49 89 07             	mov    %rax,(%r15)
    7095b0a2ed76:	e8 f5 77 e3 ff       	call   0x7095b0866570
    7095b0a2ed7b:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    7095b0a2ed7f:	48 8b 03             	mov    (%rbx),%rax
    7095b0a2ed82:	48 83 c0 10          	add    $0x10,%rax
    7095b0a2ed86:	48 3b 43 10          	cmp    0x10(%rbx),%rax
    7095b0a2ed8a:	0f 8e 05 00 00 00    	jle    0x7095b0a2ed95
    7095b0a2ed90:	e8 db 81 06 00       	call   0x7095b0a96f70
    7095b0a2ed95:	49 8b 07             	mov    (%r15),%rax
    7095b0a2ed98:	49 8b 1e             	mov    (%r14),%rbx
    7095b0a2ed9b:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
    7095b0a2eda1:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
    7095b0a2eda7:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    7095b0a2edab:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    7095b0a2edaf:	48 8b 03             	mov    (%rbx),%rax
    7095b0a2edb2:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    7095b0a2edb9:	48 83 c8 03          	or     $0x3,%rax
    7095b0a2edbd:	48 83 03 10          	addq   $0x10,(%rbx)
    7095b0a2edc1:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    7095b0a2edc7:	49 83 ef 08          	sub    $0x8,%r15
    7095b0a2edcb:	49 89 06             	mov    %rax,(%r14)
    7095b0a2edce:	89 05 2c 12 0f 13    	mov    %eax,0x130f122c(%rip)        # 0x7095c3b20000
    7095b0a2edd4:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2eddb:	c3                   	ret
    7095b0a2eddc:	48 89 c3             	mov    %rax,%rbx
    7095b0a2eddf:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2ede2:	48 83 fb 05          	cmp    $0x5,%rbx
    7095b0a2ede6:	0f 85 19 00 00 00    	jne    0x7095b0a2ee05
    7095b0a2edec:	89 05 0e 12 0f 13    	mov    %eax,0x130f120e(%rip)        # 0x7095c3b20000
    7095b0a2edf2:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2edf9:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x7095b0a2ee05
    7095b0a2ee00:	e9 cb b0 36 00       	jmp    0x7095b0d99ed0
    7095b0a2ee05:	48 89 c3             	mov    %rax,%rbx
    7095b0a2ee08:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2ee0b:	48 83 fb 07          	cmp    $0x7,%rbx
    7095b0a2ee0f:	0f 85 ba 01 00 00    	jne    0x7095b0a2efcf
    7095b0a2ee15:	48 8b 58 01          	mov    0x1(%rax),%rbx
    7095b0a2ee19:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
    7095b0a2ee1d:	48 b9 8c f9 00 b6 95 	movabs $0x7095b600f98c,%rcx
    7095b0a2ee24:	70 00 00 
    7095b0a2ee27:	48 39 cb             	cmp    %rcx,%rbx
    7095b0a2ee2a:	0f 85 55 01 00 00    	jne    0x7095b0a2ef85
    7095b0a2ee30:	48 8b 58 09          	mov    0x9(%rax),%rbx
    7095b0a2ee34:	48 8b 40 11          	mov    0x11(%rax),%rax
    7095b0a2ee38:	49 83 c7 10          	add    $0x10,%r15
    7095b0a2ee3c:	49 89 47 f8          	mov    %rax,-0x8(%r15)
    7095b0a2ee40:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2ee43:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
    7095b0a2ee4a:	e8 b1 f7 ff ff       	call   0x7095b0a2e600
    7095b0a2ee4f:	49 8b 07             	mov    (%r15),%rax
    7095b0a2ee52:	49 8b 5f f8          	mov    -0x8(%r15),%rbx
    7095b0a2ee56:	49 83 c6 10          	add    $0x10,%r14
    7095b0a2ee5a:	49 83 ef 10          	sub    $0x10,%r15
    7095b0a2ee5e:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2ee62:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2ee65:	e8 96 f7 ff ff       	call   0x7095b0a2e600
    7095b0a2ee6a:	49 8b 06             	mov    (%r14),%rax
    7095b0a2ee6d:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2ee71:	48 83 f8 00          	cmp    $0x0,%rax
    7095b0a2ee75:	0f 85 16 00 00 00    	jne    0x7095b0a2ee91
    7095b0a2ee7b:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2ee7f:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2ee83:	89 05 77 11 0f 13    	mov    %eax,0x130f1177(%rip)        # 0x7095c3b20000
    7095b0a2ee89:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2ee90:	c3                   	ret
    7095b0a2ee91:	48 89 c3             	mov    %rax,%rbx
    7095b0a2ee94:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    7095b0a2ee9a:	0f 85 10 00 00 00    	jne    0x7095b0a2eeb0
    7095b0a2eea0:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2eea4:	49 8b 06             	mov    (%r14),%rax
    7095b0a2eea7:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2eeab:	e9 64 00 00 00       	jmp    0x7095b0a2ef14
    7095b0a2eeb0:	48 89 c3             	mov    %rax,%rbx
    7095b0a2eeb3:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2eeb6:	48 83 fb 05          	cmp    $0x5,%rbx
    7095b0a2eeba:	0f 85 49 00 00 00    	jne    0x7095b0a2ef09
    7095b0a2eec0:	48 bb 05 ef 09 b6 95 	movabs $0x7095b609ef05,%rbx
    7095b0a2eec7:	70 00 00 
    7095b0a2eeca:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2eece:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2eed2:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2eed5:	e8 56 38 36 00       	call   0x7095b0d92730
    7095b0a2eeda:	49 8b 06             	mov    (%r14),%rax
    7095b0a2eedd:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2eee1:	48 83 f8 01          	cmp    $0x1,%rax
    7095b0a2eee5:	0f 84 12 00 00 00    	je     0x7095b0a2eefd
    7095b0a2eeeb:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2eeef:	89 05 0b 11 0f 13    	mov    %eax,0x130f110b(%rip)        # 0x7095c3b20000
    7095b0a2eef5:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2eefc:	c3                   	ret
    7095b0a2eefd:	49 8b 06             	mov    (%r14),%rax
    7095b0a2ef00:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2ef04:	e9 0b 00 00 00       	jmp    0x7095b0a2ef14
    7095b0a2ef09:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2ef0d:	49 8b 06             	mov    (%r14),%rax
    7095b0a2ef10:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2ef14:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    7095b0a2ef18:	48 8b 11             	mov    (%rcx),%rdx
    7095b0a2ef1b:	48 83 c2 20          	add    $0x20,%rdx
    7095b0a2ef1f:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    7095b0a2ef23:	0f 8e 19 00 00 00    	jle    0x7095b0a2ef42
    7095b0a2ef29:	48 89 5c 24 30       	mov    %rbx,0x30(%rsp)
    7095b0a2ef2e:	48 89 44 24 38       	mov    %rax,0x38(%rsp)
    7095b0a2ef33:	e8 38 80 06 00       	call   0x7095b0a96f70
    7095b0a2ef38:	48 8b 5c 24 30       	mov    0x30(%rsp),%rbx
    7095b0a2ef3d:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
    7095b0a2ef42:	48 ba 52 f5 00 b6 95 	movabs $0x7095b600f552,%rdx
    7095b0a2ef49:	70 00 00 
    7095b0a2ef4c:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    7095b0a2ef50:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    7095b0a2ef54:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    7095b0a2ef5b:	48 83 c9 07          	or     $0x7,%rcx
    7095b0a2ef5f:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    7095b0a2ef64:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    7095b0a2ef68:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    7095b0a2ef6c:	48 89 41 11          	mov    %rax,0x11(%rcx)
    7095b0a2ef70:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2ef74:	49 89 0e             	mov    %rcx,(%r14)
    7095b0a2ef77:	89 05 83 10 0f 13    	mov    %eax,0x130f1083(%rip)        # 0x7095c3b20000
    7095b0a2ef7d:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2ef84:	c3                   	ret
    7095b0a2ef85:	48 8b 40 01          	mov    0x1(%rax),%rax
    7095b0a2ef89:	48 8b 40 0e          	mov    0xe(%rax),%rax
    7095b0a2ef8d:	48 bb 1c c6 ff b5 95 	movabs $0x7095b5ffc61c,%rbx
    7095b0a2ef94:	70 00 00 
    7095b0a2ef97:	48 39 d8             	cmp    %rbx,%rax
    7095b0a2ef9a:	0f 85 19 00 00 00    	jne    0x7095b0a2efb9
    7095b0a2efa0:	89 05 5a 10 0f 13    	mov    %eax,0x130f105a(%rip)        # 0x7095c3b20000
    7095b0a2efa6:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2efad:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x7095b0a2efb9
    7095b0a2efb4:	e9 07 0a 1f 00       	jmp    0x7095b0c1f9c0
    7095b0a2efb9:	48 b8 dc 9e fe b5 95 	movabs $0x7095b5fe9edc,%rax
    7095b0a2efc0:	70 00 00 
    7095b0a2efc3:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2efc7:	49 89 06             	mov    %rax,(%r14)
    7095b0a2efca:	e8 51 7f 43 00       	call   0x7095b0e66f20
    7095b0a2efcf:	48 b8 dc 9e fe b5 95 	movabs $0x7095b5fe9edc,%rax
    7095b0a2efd6:	70 00 00 
    7095b0a2efd9:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2efdd:	49 89 06             	mov    %rax,(%r14)
    7095b0a2efe0:	e8 3b 7f 43 00       	call   0x7095b0e66f20
    7095b0a2efe5:	48 89 d9             	mov    %rbx,%rcx
    7095b0a2efe8:	83 e1 0f             	and    $0xf,%ecx
    7095b0a2efeb:	48 83 f9 07          	cmp    $0x7,%rcx
    7095b0a2efef:	0f 85 a4 0a 00 00    	jne    0x7095b0a2fa99
    7095b0a2eff5:	48 8b 4b 01          	mov    0x1(%rbx),%rcx
    7095b0a2eff9:	48 8b 49 0e          	mov    0xe(%rcx),%rcx
    7095b0a2effd:	48 ba 8c f9 00 b6 95 	movabs $0x7095b600f98c,%rdx
    7095b0a2f004:	70 00 00 
    7095b0a2f007:	48 39 d1             	cmp    %rdx,%rcx
    7095b0a2f00a:	0f 85 9a 07 00 00    	jne    0x7095b0a2f7aa
    7095b0a2f010:	48 89 c1             	mov    %rax,%rcx
    7095b0a2f013:	f7 c1 0f 00 00 00    	test   $0xf,%ecx
    7095b0a2f019:	0f 85 4e 01 00 00    	jne    0x7095b0a2f16d
    7095b0a2f01f:	48 8b 43 09          	mov    0x9(%rbx),%rax
    7095b0a2f023:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
    7095b0a2f027:	49 83 c7 08          	add    $0x8,%r15
    7095b0a2f02b:	49 89 1f             	mov    %rbx,(%r15)
    7095b0a2f02e:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f032:	e8 c9 f5 ff ff       	call   0x7095b0a2e600
    7095b0a2f037:	49 8b 07             	mov    (%r15),%rax
    7095b0a2f03a:	49 83 c6 10          	add    $0x10,%r14
    7095b0a2f03e:	49 83 ef 08          	sub    $0x8,%r15
    7095b0a2f042:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f046:	49 c7 06 00 00 00 00 	movq   $0x0,(%r14)
    7095b0a2f04d:	e8 ae f5 ff ff       	call   0x7095b0a2e600
    7095b0a2f052:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f055:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2f059:	48 83 f8 00          	cmp    $0x0,%rax
    7095b0a2f05d:	0f 85 16 00 00 00    	jne    0x7095b0a2f079
    7095b0a2f063:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f067:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f06b:	89 05 8f 0f 0f 13    	mov    %eax,0x130f0f8f(%rip)        # 0x7095c3b20000
    7095b0a2f071:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f078:	c3                   	ret
    7095b0a2f079:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f07c:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    7095b0a2f082:	0f 85 10 00 00 00    	jne    0x7095b0a2f098
    7095b0a2f088:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f08c:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f08f:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f093:	e9 64 00 00 00       	jmp    0x7095b0a2f0fc
    7095b0a2f098:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f09b:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2f09e:	48 83 fb 05          	cmp    $0x5,%rbx
    7095b0a2f0a2:	0f 85 49 00 00 00    	jne    0x7095b0a2f0f1
    7095b0a2f0a8:	48 bb 05 ef 09 b6 95 	movabs $0x7095b609ef05,%rbx
    7095b0a2f0af:	70 00 00 
    7095b0a2f0b2:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2f0b6:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f0ba:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2f0bd:	e8 6e 36 36 00       	call   0x7095b0d92730
    7095b0a2f0c2:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f0c5:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f0c9:	48 83 f8 01          	cmp    $0x1,%rax
    7095b0a2f0cd:	0f 84 12 00 00 00    	je     0x7095b0a2f0e5
    7095b0a2f0d3:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f0d7:	89 05 23 0f 0f 13    	mov    %eax,0x130f0f23(%rip)        # 0x7095c3b20000
    7095b0a2f0dd:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f0e4:	c3                   	ret
    7095b0a2f0e5:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f0e8:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f0ec:	e9 0b 00 00 00       	jmp    0x7095b0a2f0fc
    7095b0a2f0f1:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f0f5:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f0f8:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f0fc:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    7095b0a2f100:	48 8b 11             	mov    (%rcx),%rdx
    7095b0a2f103:	48 83 c2 20          	add    $0x20,%rdx
    7095b0a2f107:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    7095b0a2f10b:	0f 8e 19 00 00 00    	jle    0x7095b0a2f12a
    7095b0a2f111:	48 89 5c 24 40       	mov    %rbx,0x40(%rsp)
    7095b0a2f116:	48 89 44 24 48       	mov    %rax,0x48(%rsp)
    7095b0a2f11b:	e8 50 7e 06 00       	call   0x7095b0a96f70
    7095b0a2f120:	48 8b 5c 24 40       	mov    0x40(%rsp),%rbx
    7095b0a2f125:	48 8b 44 24 48       	mov    0x48(%rsp),%rax
    7095b0a2f12a:	48 ba 52 f5 00 b6 95 	movabs $0x7095b600f552,%rdx
    7095b0a2f131:	70 00 00 
    7095b0a2f134:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    7095b0a2f138:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    7095b0a2f13c:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    7095b0a2f143:	48 83 c9 07          	or     $0x7,%rcx
    7095b0a2f147:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    7095b0a2f14c:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    7095b0a2f150:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    7095b0a2f154:	48 89 41 11          	mov    %rax,0x11(%rcx)
    7095b0a2f158:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f15c:	49 89 0e             	mov    %rcx,(%r14)
    7095b0a2f15f:	89 05 9b 0e 0f 13    	mov    %eax,0x130f0e9b(%rip)        # 0x7095c3b20000
    7095b0a2f165:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f16c:	c3                   	ret
    7095b0a2f16d:	48 89 c1             	mov    %rax,%rcx
    7095b0a2f170:	83 e1 0f             	and    $0xf,%ecx
    7095b0a2f173:	48 83 f9 03          	cmp    $0x3,%rcx
    7095b0a2f177:	0f 85 a6 01 00 00    	jne    0x7095b0a2f323
    7095b0a2f17d:	48 8b 4b 09          	mov    0x9(%rbx),%rcx
    7095b0a2f181:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
    7095b0a2f185:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f189:	49 83 c7 10          	add    $0x10,%r15
    7095b0a2f18d:	49 89 07             	mov    %rax,(%r15)
    7095b0a2f190:	49 89 5f f8          	mov    %rbx,-0x8(%r15)
    7095b0a2f194:	49 89 0e             	mov    %rcx,(%r14)
    7095b0a2f197:	e8 84 cd e2 fe       	call   0x7095af85bf20
    7095b0a2f19c:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    7095b0a2f1a0:	48 8b 03             	mov    (%rbx),%rax
    7095b0a2f1a3:	48 83 c0 10          	add    $0x10,%rax
    7095b0a2f1a7:	48 3b 43 10          	cmp    0x10(%rbx),%rax
    7095b0a2f1ab:	0f 8e 05 00 00 00    	jle    0x7095b0a2f1b6
    7095b0a2f1b1:	e8 ba 7d 06 00       	call   0x7095b0a96f70
    7095b0a2f1b6:	49 8b 1f             	mov    (%r15),%rbx
    7095b0a2f1b9:	49 8b 0e             	mov    (%r14),%rcx
    7095b0a2f1bc:	49 8b 47 f8          	mov    -0x8(%r15),%rax
    7095b0a2f1c0:	f2 48 0f 10 41 05    	rex.W movsd 0x5(%rcx),%xmm0
    7095b0a2f1c6:	f2 48 0f 10 4b 05    	rex.W movsd 0x5(%rbx),%xmm1
    7095b0a2f1cc:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    7095b0a2f1d0:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    7095b0a2f1d4:	48 8b 19             	mov    (%rcx),%rbx
    7095b0a2f1d7:	48 c7 03 0c 00 00 00 	movq   $0xc,(%rbx)
    7095b0a2f1de:	48 83 cb 03          	or     $0x3,%rbx
    7095b0a2f1e2:	48 83 01 10          	addq   $0x10,(%rcx)
    7095b0a2f1e6:	f2 48 0f 11 43 05    	rex.W movsd %xmm0,0x5(%rbx)
    7095b0a2f1ec:	49 83 c6 10          	add    $0x10,%r14
    7095b0a2f1f0:	49 83 ef 10          	sub    $0x10,%r15
    7095b0a2f1f4:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f1f8:	49 c7 06 00 00 00 00 	movq   $0x0,(%r14)
    7095b0a2f1ff:	49 89 5e f0          	mov    %rbx,-0x10(%r14)
    7095b0a2f203:	e8 f8 f3 ff ff       	call   0x7095b0a2e600
    7095b0a2f208:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f20b:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2f20f:	48 83 f8 00          	cmp    $0x0,%rax
    7095b0a2f213:	0f 85 16 00 00 00    	jne    0x7095b0a2f22f
    7095b0a2f219:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f21d:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f221:	89 05 d9 0d 0f 13    	mov    %eax,0x130f0dd9(%rip)        # 0x7095c3b20000
    7095b0a2f227:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f22e:	c3                   	ret
    7095b0a2f22f:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f232:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    7095b0a2f238:	0f 85 10 00 00 00    	jne    0x7095b0a2f24e
    7095b0a2f23e:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f242:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f245:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f249:	e9 64 00 00 00       	jmp    0x7095b0a2f2b2
    7095b0a2f24e:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f251:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2f254:	48 83 fb 05          	cmp    $0x5,%rbx
    7095b0a2f258:	0f 85 49 00 00 00    	jne    0x7095b0a2f2a7
    7095b0a2f25e:	48 bb 05 ef 09 b6 95 	movabs $0x7095b609ef05,%rbx
    7095b0a2f265:	70 00 00 
    7095b0a2f268:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2f26c:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f270:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2f273:	e8 b8 34 36 00       	call   0x7095b0d92730
    7095b0a2f278:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f27b:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f27f:	48 83 f8 01          	cmp    $0x1,%rax
    7095b0a2f283:	0f 84 12 00 00 00    	je     0x7095b0a2f29b
    7095b0a2f289:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f28d:	89 05 6d 0d 0f 13    	mov    %eax,0x130f0d6d(%rip)        # 0x7095c3b20000
    7095b0a2f293:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f29a:	c3                   	ret
    7095b0a2f29b:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f29e:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f2a2:	e9 0b 00 00 00       	jmp    0x7095b0a2f2b2
    7095b0a2f2a7:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f2ab:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f2ae:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f2b2:	49 8d 55 10          	lea    0x10(%r13),%rdx
    7095b0a2f2b6:	48 8b 0a             	mov    (%rdx),%rcx
    7095b0a2f2b9:	48 83 c1 20          	add    $0x20,%rcx
    7095b0a2f2bd:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
    7095b0a2f2c1:	0f 8e 19 00 00 00    	jle    0x7095b0a2f2e0
    7095b0a2f2c7:	48 89 5c 24 50       	mov    %rbx,0x50(%rsp)
    7095b0a2f2cc:	48 89 44 24 58       	mov    %rax,0x58(%rsp)
    7095b0a2f2d1:	e8 9a 7c 06 00       	call   0x7095b0a96f70
    7095b0a2f2d6:	48 8b 5c 24 50       	mov    0x50(%rsp),%rbx
    7095b0a2f2db:	48 8b 44 24 58       	mov    0x58(%rsp),%rax
    7095b0a2f2e0:	48 ba 52 f5 00 b6 95 	movabs $0x7095b600f552,%rdx
    7095b0a2f2e7:	70 00 00 
    7095b0a2f2ea:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    7095b0a2f2ee:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    7095b0a2f2f2:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    7095b0a2f2f9:	48 83 c9 07          	or     $0x7,%rcx
    7095b0a2f2fd:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    7095b0a2f302:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    7095b0a2f306:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    7095b0a2f30a:	48 89 41 11          	mov    %rax,0x11(%rcx)
    7095b0a2f30e:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f312:	49 89 0e             	mov    %rcx,(%r14)
    7095b0a2f315:	89 05 e5 0c 0f 13    	mov    %eax,0x130f0ce5(%rip)        # 0x7095c3b20000
    7095b0a2f31b:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f322:	c3                   	ret
    7095b0a2f323:	48 89 c1             	mov    %rax,%rcx
    7095b0a2f326:	83 e1 0f             	and    $0xf,%ecx
    7095b0a2f329:	48 83 f9 05          	cmp    $0x5,%rcx
    7095b0a2f32d:	0f 85 4e 01 00 00    	jne    0x7095b0a2f481
    7095b0a2f333:	48 8b 43 09          	mov    0x9(%rbx),%rax
    7095b0a2f337:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
    7095b0a2f33b:	49 83 c7 08          	add    $0x8,%r15
    7095b0a2f33f:	49 89 1f             	mov    %rbx,(%r15)
    7095b0a2f342:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f346:	e8 b5 f2 ff ff       	call   0x7095b0a2e600
    7095b0a2f34b:	49 8b 07             	mov    (%r15),%rax
    7095b0a2f34e:	49 83 c6 10          	add    $0x10,%r14
    7095b0a2f352:	49 83 ef 08          	sub    $0x8,%r15
    7095b0a2f356:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f35a:	49 c7 06 00 00 00 00 	movq   $0x0,(%r14)
    7095b0a2f361:	e8 9a f2 ff ff       	call   0x7095b0a2e600
    7095b0a2f366:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f369:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2f36d:	48 83 f8 00          	cmp    $0x0,%rax
    7095b0a2f371:	0f 85 16 00 00 00    	jne    0x7095b0a2f38d
    7095b0a2f377:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f37b:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f37f:	89 05 7b 0c 0f 13    	mov    %eax,0x130f0c7b(%rip)        # 0x7095c3b20000
    7095b0a2f385:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f38c:	c3                   	ret
    7095b0a2f38d:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f390:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    7095b0a2f396:	0f 85 10 00 00 00    	jne    0x7095b0a2f3ac
    7095b0a2f39c:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f3a0:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f3a3:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f3a7:	e9 64 00 00 00       	jmp    0x7095b0a2f410
    7095b0a2f3ac:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f3af:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2f3b2:	48 83 fb 05          	cmp    $0x5,%rbx
    7095b0a2f3b6:	0f 85 49 00 00 00    	jne    0x7095b0a2f405
    7095b0a2f3bc:	48 bb 05 ef 09 b6 95 	movabs $0x7095b609ef05,%rbx
    7095b0a2f3c3:	70 00 00 
    7095b0a2f3c6:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2f3ca:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f3ce:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2f3d1:	e8 5a 33 36 00       	call   0x7095b0d92730
    7095b0a2f3d6:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f3d9:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f3dd:	48 83 f8 01          	cmp    $0x1,%rax
    7095b0a2f3e1:	0f 84 12 00 00 00    	je     0x7095b0a2f3f9
    7095b0a2f3e7:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f3eb:	89 05 0f 0c 0f 13    	mov    %eax,0x130f0c0f(%rip)        # 0x7095c3b20000
    7095b0a2f3f1:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f3f8:	c3                   	ret
    7095b0a2f3f9:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f3fc:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f400:	e9 0b 00 00 00       	jmp    0x7095b0a2f410
    7095b0a2f405:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f409:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f40c:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f410:	49 8d 55 10          	lea    0x10(%r13),%rdx
    7095b0a2f414:	48 8b 0a             	mov    (%rdx),%rcx
    7095b0a2f417:	48 83 c1 20          	add    $0x20,%rcx
    7095b0a2f41b:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
    7095b0a2f41f:	0f 8e 19 00 00 00    	jle    0x7095b0a2f43e
    7095b0a2f425:	48 89 5c 24 60       	mov    %rbx,0x60(%rsp)
    7095b0a2f42a:	48 89 44 24 68       	mov    %rax,0x68(%rsp)
    7095b0a2f42f:	e8 3c 7b 06 00       	call   0x7095b0a96f70
    7095b0a2f434:	48 8b 5c 24 60       	mov    0x60(%rsp),%rbx
    7095b0a2f439:	48 8b 44 24 68       	mov    0x68(%rsp),%rax
    7095b0a2f43e:	48 ba 52 f5 00 b6 95 	movabs $0x7095b600f552,%rdx
    7095b0a2f445:	70 00 00 
    7095b0a2f448:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    7095b0a2f44c:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    7095b0a2f450:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    7095b0a2f457:	48 83 c9 07          	or     $0x7,%rcx
    7095b0a2f45b:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    7095b0a2f460:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    7095b0a2f464:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    7095b0a2f468:	48 89 41 11          	mov    %rax,0x11(%rcx)
    7095b0a2f46c:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f470:	49 89 0e             	mov    %rcx,(%r14)
    7095b0a2f473:	89 05 87 0b 0f 13    	mov    %eax,0x130f0b87(%rip)        # 0x7095c3b20000
    7095b0a2f479:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f480:	c3                   	ret
    7095b0a2f481:	48 89 c1             	mov    %rax,%rcx
    7095b0a2f484:	83 e1 0f             	and    $0xf,%ecx
    7095b0a2f487:	48 83 f9 07          	cmp    $0x7,%rcx
    7095b0a2f48b:	0f 85 03 03 00 00    	jne    0x7095b0a2f794
    7095b0a2f491:	48 8b 48 01          	mov    0x1(%rax),%rcx
    7095b0a2f495:	48 8b 49 0e          	mov    0xe(%rcx),%rcx
    7095b0a2f499:	48 ba 8c f9 00 b6 95 	movabs $0x7095b600f98c,%rdx
    7095b0a2f4a0:	70 00 00 
    7095b0a2f4a3:	48 39 d1             	cmp    %rdx,%rcx
    7095b0a2f4a6:	0f 85 5d 01 00 00    	jne    0x7095b0a2f609
    7095b0a2f4ac:	48 8b 4b 09          	mov    0x9(%rbx),%rcx
    7095b0a2f4b0:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
    7095b0a2f4b4:	48 8b 50 09          	mov    0x9(%rax),%rdx
    7095b0a2f4b8:	48 8b 40 11          	mov    0x11(%rax),%rax
    7095b0a2f4bc:	49 83 c7 10          	add    $0x10,%r15
    7095b0a2f4c0:	49 89 47 f8          	mov    %rax,-0x8(%r15)
    7095b0a2f4c4:	49 89 4e f8          	mov    %rcx,-0x8(%r14)
    7095b0a2f4c8:	49 89 16             	mov    %rdx,(%r14)
    7095b0a2f4cb:	49 89 1f             	mov    %rbx,(%r15)
    7095b0a2f4ce:	e8 2d f1 ff ff       	call   0x7095b0a2e600
    7095b0a2f4d3:	49 8b 07             	mov    (%r15),%rax
    7095b0a2f4d6:	49 8b 5f f8          	mov    -0x8(%r15),%rbx
    7095b0a2f4da:	49 83 c6 10          	add    $0x10,%r14
    7095b0a2f4de:	49 83 ef 10          	sub    $0x10,%r15
    7095b0a2f4e2:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f4e6:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2f4e9:	e8 12 f1 ff ff       	call   0x7095b0a2e600
    7095b0a2f4ee:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f4f1:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2f4f5:	48 83 f8 00          	cmp    $0x0,%rax
    7095b0a2f4f9:	0f 85 16 00 00 00    	jne    0x7095b0a2f515
    7095b0a2f4ff:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f503:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f507:	89 05 f3 0a 0f 13    	mov    %eax,0x130f0af3(%rip)        # 0x7095c3b20000
    7095b0a2f50d:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f514:	c3                   	ret
    7095b0a2f515:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f518:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    7095b0a2f51e:	0f 85 10 00 00 00    	jne    0x7095b0a2f534
    7095b0a2f524:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f528:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f52b:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f52f:	e9 64 00 00 00       	jmp    0x7095b0a2f598
    7095b0a2f534:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f537:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2f53a:	48 83 fb 05          	cmp    $0x5,%rbx
    7095b0a2f53e:	0f 85 49 00 00 00    	jne    0x7095b0a2f58d
    7095b0a2f544:	48 bb 05 ef 09 b6 95 	movabs $0x7095b609ef05,%rbx
    7095b0a2f54b:	70 00 00 
    7095b0a2f54e:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2f552:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f556:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2f559:	e8 d2 31 36 00       	call   0x7095b0d92730
    7095b0a2f55e:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f561:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f565:	48 83 f8 01          	cmp    $0x1,%rax
    7095b0a2f569:	0f 84 12 00 00 00    	je     0x7095b0a2f581
    7095b0a2f56f:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f573:	89 05 87 0a 0f 13    	mov    %eax,0x130f0a87(%rip)        # 0x7095c3b20000
    7095b0a2f579:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f580:	c3                   	ret
    7095b0a2f581:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f584:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f588:	e9 0b 00 00 00       	jmp    0x7095b0a2f598
    7095b0a2f58d:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f591:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f594:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f598:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    7095b0a2f59c:	48 8b 11             	mov    (%rcx),%rdx
    7095b0a2f59f:	48 83 c2 20          	add    $0x20,%rdx
    7095b0a2f5a3:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    7095b0a2f5a7:	0f 8e 19 00 00 00    	jle    0x7095b0a2f5c6
    7095b0a2f5ad:	48 89 5c 24 70       	mov    %rbx,0x70(%rsp)
    7095b0a2f5b2:	48 89 44 24 78       	mov    %rax,0x78(%rsp)
    7095b0a2f5b7:	e8 b4 79 06 00       	call   0x7095b0a96f70
    7095b0a2f5bc:	48 8b 5c 24 70       	mov    0x70(%rsp),%rbx
    7095b0a2f5c1:	48 8b 44 24 78       	mov    0x78(%rsp),%rax
    7095b0a2f5c6:	48 ba 52 f5 00 b6 95 	movabs $0x7095b600f552,%rdx
    7095b0a2f5cd:	70 00 00 
    7095b0a2f5d0:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    7095b0a2f5d4:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    7095b0a2f5d8:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    7095b0a2f5df:	48 83 c9 07          	or     $0x7,%rcx
    7095b0a2f5e3:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    7095b0a2f5e8:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    7095b0a2f5ec:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    7095b0a2f5f0:	48 89 41 11          	mov    %rax,0x11(%rcx)
    7095b0a2f5f4:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f5f8:	49 89 0e             	mov    %rcx,(%r14)
    7095b0a2f5fb:	89 05 ff 09 0f 13    	mov    %eax,0x130f09ff(%rip)        # 0x7095c3b20000
    7095b0a2f601:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f608:	c3                   	ret
    7095b0a2f609:	48 8b 40 01          	mov    0x1(%rax),%rax
    7095b0a2f60d:	48 8b 40 0e          	mov    0xe(%rax),%rax
    7095b0a2f611:	48 b9 1c c6 ff b5 95 	movabs $0x7095b5ffc61c,%rcx
    7095b0a2f618:	70 00 00 
    7095b0a2f61b:	48 39 c8             	cmp    %rcx,%rax
    7095b0a2f61e:	0f 85 5a 01 00 00    	jne    0x7095b0a2f77e
    7095b0a2f624:	48 8b 43 09          	mov    0x9(%rbx),%rax
    7095b0a2f628:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
    7095b0a2f62c:	49 83 c7 08          	add    $0x8,%r15
    7095b0a2f630:	49 89 1f             	mov    %rbx,(%r15)
    7095b0a2f633:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f637:	e8 c4 ef ff ff       	call   0x7095b0a2e600
    7095b0a2f63c:	49 8b 07             	mov    (%r15),%rax
    7095b0a2f63f:	49 83 c6 10          	add    $0x10,%r14
    7095b0a2f643:	49 83 ef 08          	sub    $0x8,%r15
    7095b0a2f647:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f64b:	49 c7 06 00 00 00 00 	movq   $0x0,(%r14)
    7095b0a2f652:	e8 a9 ef ff ff       	call   0x7095b0a2e600
    7095b0a2f657:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f65a:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2f65e:	48 83 f8 00          	cmp    $0x0,%rax
    7095b0a2f662:	0f 85 16 00 00 00    	jne    0x7095b0a2f67e
    7095b0a2f668:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f66c:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f670:	89 05 8a 09 0f 13    	mov    %eax,0x130f098a(%rip)        # 0x7095c3b20000
    7095b0a2f676:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f67d:	c3                   	ret
    7095b0a2f67e:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f681:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    7095b0a2f687:	0f 85 10 00 00 00    	jne    0x7095b0a2f69d
    7095b0a2f68d:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f691:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f694:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f698:	e9 64 00 00 00       	jmp    0x7095b0a2f701
    7095b0a2f69d:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f6a0:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2f6a3:	48 83 fb 05          	cmp    $0x5,%rbx
    7095b0a2f6a7:	0f 85 49 00 00 00    	jne    0x7095b0a2f6f6
    7095b0a2f6ad:	48 bb 05 ef 09 b6 95 	movabs $0x7095b609ef05,%rbx
    7095b0a2f6b4:	70 00 00 
    7095b0a2f6b7:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2f6bb:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f6bf:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2f6c2:	e8 69 30 36 00       	call   0x7095b0d92730
    7095b0a2f6c7:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f6ca:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f6ce:	48 83 f8 01          	cmp    $0x1,%rax
    7095b0a2f6d2:	0f 84 12 00 00 00    	je     0x7095b0a2f6ea
    7095b0a2f6d8:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f6dc:	89 05 1e 09 0f 13    	mov    %eax,0x130f091e(%rip)        # 0x7095c3b20000
    7095b0a2f6e2:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f6e9:	c3                   	ret
    7095b0a2f6ea:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f6ed:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f6f1:	e9 0b 00 00 00       	jmp    0x7095b0a2f701
    7095b0a2f6f6:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f6fa:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f6fd:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f701:	49 8d 55 10          	lea    0x10(%r13),%rdx
    7095b0a2f705:	48 8b 0a             	mov    (%rdx),%rcx
    7095b0a2f708:	48 83 c1 20          	add    $0x20,%rcx
    7095b0a2f70c:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
    7095b0a2f710:	0f 8e 25 00 00 00    	jle    0x7095b0a2f73b
    7095b0a2f716:	48 89 9c 24 80 00 00 	mov    %rbx,0x80(%rsp)
    7095b0a2f71d:	00 
    7095b0a2f71e:	48 89 84 24 88 00 00 	mov    %rax,0x88(%rsp)
    7095b0a2f725:	00 
    7095b0a2f726:	e8 45 78 06 00       	call   0x7095b0a96f70
    7095b0a2f72b:	48 8b 9c 24 80 00 00 	mov    0x80(%rsp),%rbx
    7095b0a2f732:	00 
    7095b0a2f733:	48 8b 84 24 88 00 00 	mov    0x88(%rsp),%rax
    7095b0a2f73a:	00 
    7095b0a2f73b:	48 ba 52 f5 00 b6 95 	movabs $0x7095b600f552,%rdx
    7095b0a2f742:	70 00 00 
    7095b0a2f745:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    7095b0a2f749:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    7095b0a2f74d:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    7095b0a2f754:	48 83 c9 07          	or     $0x7,%rcx
    7095b0a2f758:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    7095b0a2f75d:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    7095b0a2f761:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    7095b0a2f765:	48 89 41 11          	mov    %rax,0x11(%rcx)
    7095b0a2f769:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f76d:	49 89 0e             	mov    %rcx,(%r14)
    7095b0a2f770:	89 05 8a 08 0f 13    	mov    %eax,0x130f088a(%rip)        # 0x7095c3b20000
    7095b0a2f776:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f77d:	c3                   	ret
    7095b0a2f77e:	48 b8 dc 9e fe b5 95 	movabs $0x7095b5fe9edc,%rax
    7095b0a2f785:	70 00 00 
    7095b0a2f788:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2f78c:	49 89 06             	mov    %rax,(%r14)
    7095b0a2f78f:	e8 8c 77 43 00       	call   0x7095b0e66f20
    7095b0a2f794:	48 b8 dc 9e fe b5 95 	movabs $0x7095b5fe9edc,%rax
    7095b0a2f79b:	70 00 00 
    7095b0a2f79e:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2f7a2:	49 89 06             	mov    %rax,(%r14)
    7095b0a2f7a5:	e8 76 77 43 00       	call   0x7095b0e66f20
    7095b0a2f7aa:	48 8b 5b 01          	mov    0x1(%rbx),%rbx
    7095b0a2f7ae:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
    7095b0a2f7b2:	48 b9 1c c6 ff b5 95 	movabs $0x7095b5ffc61c,%rcx
    7095b0a2f7b9:	70 00 00 
    7095b0a2f7bc:	48 39 cb             	cmp    %rcx,%rbx
    7095b0a2f7bf:	0f 85 be 02 00 00    	jne    0x7095b0a2fa83
    7095b0a2f7c5:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f7c8:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    7095b0a2f7ce:	0f 85 19 00 00 00    	jne    0x7095b0a2f7ed
    7095b0a2f7d4:	89 05 26 08 0f 13    	mov    %eax,0x130f0826(%rip)        # 0x7095c3b20000
    7095b0a2f7da:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f7e1:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x7095b0a2f7ed
    7095b0a2f7e8:	e9 d3 01 1f 00       	jmp    0x7095b0c1f9c0
    7095b0a2f7ed:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f7f0:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2f7f3:	48 83 fb 03          	cmp    $0x3,%rbx
    7095b0a2f7f7:	0f 85 71 00 00 00    	jne    0x7095b0a2f86e
    7095b0a2f7fd:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f801:	49 83 c7 08          	add    $0x8,%r15
    7095b0a2f805:	49 89 07             	mov    %rax,(%r15)
    7095b0a2f808:	e8 13 b2 d8 ff       	call   0x7095b07baa20
    7095b0a2f80d:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    7095b0a2f811:	48 8b 03             	mov    (%rbx),%rax
    7095b0a2f814:	48 83 c0 10          	add    $0x10,%rax
    7095b0a2f818:	48 3b 43 10          	cmp    0x10(%rbx),%rax
    7095b0a2f81c:	0f 8e 05 00 00 00    	jle    0x7095b0a2f827
    7095b0a2f822:	e8 49 77 06 00       	call   0x7095b0a96f70
    7095b0a2f827:	49 8b 07             	mov    (%r15),%rax
    7095b0a2f82a:	49 8b 1e             	mov    (%r14),%rbx
    7095b0a2f82d:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
    7095b0a2f833:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
    7095b0a2f839:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    7095b0a2f83d:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    7095b0a2f841:	48 8b 03             	mov    (%rbx),%rax
    7095b0a2f844:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    7095b0a2f84b:	48 83 c8 03          	or     $0x3,%rax
    7095b0a2f84f:	48 83 03 10          	addq   $0x10,(%rbx)
    7095b0a2f853:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    7095b0a2f859:	49 83 ef 08          	sub    $0x8,%r15
    7095b0a2f85d:	49 89 06             	mov    %rax,(%r14)
    7095b0a2f860:	89 05 9a 07 0f 13    	mov    %eax,0x130f079a(%rip)        # 0x7095c3b20000
    7095b0a2f866:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f86d:	c3                   	ret
    7095b0a2f86e:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f871:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2f874:	48 83 fb 05          	cmp    $0x5,%rbx
    7095b0a2f878:	0f 85 19 00 00 00    	jne    0x7095b0a2f897
    7095b0a2f87e:	89 05 7c 07 0f 13    	mov    %eax,0x130f077c(%rip)        # 0x7095c3b20000
    7095b0a2f884:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f88b:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x7095b0a2f897
    7095b0a2f892:	e9 29 01 1f 00       	jmp    0x7095b0c1f9c0
    7095b0a2f897:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f89a:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2f89d:	48 83 fb 07          	cmp    $0x7,%rbx
    7095b0a2f8a1:	0f 85 c6 01 00 00    	jne    0x7095b0a2fa6d
    7095b0a2f8a7:	48 8b 58 01          	mov    0x1(%rax),%rbx
    7095b0a2f8ab:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
    7095b0a2f8af:	48 b9 8c f9 00 b6 95 	movabs $0x7095b600f98c,%rcx
    7095b0a2f8b6:	70 00 00 
    7095b0a2f8b9:	48 39 cb             	cmp    %rcx,%rbx
    7095b0a2f8bc:	0f 85 61 01 00 00    	jne    0x7095b0a2fa23
    7095b0a2f8c2:	48 8b 58 09          	mov    0x9(%rax),%rbx
    7095b0a2f8c6:	48 8b 40 11          	mov    0x11(%rax),%rax
    7095b0a2f8ca:	49 83 c7 10          	add    $0x10,%r15
    7095b0a2f8ce:	49 89 47 f8          	mov    %rax,-0x8(%r15)
    7095b0a2f8d2:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2f8d5:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
    7095b0a2f8dc:	e8 1f ed ff ff       	call   0x7095b0a2e600
    7095b0a2f8e1:	49 8b 07             	mov    (%r15),%rax
    7095b0a2f8e4:	49 8b 5f f8          	mov    -0x8(%r15),%rbx
    7095b0a2f8e8:	49 83 c6 10          	add    $0x10,%r14
    7095b0a2f8ec:	49 83 ef 10          	sub    $0x10,%r15
    7095b0a2f8f0:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f8f4:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2f8f7:	e8 04 ed ff ff       	call   0x7095b0a2e600
    7095b0a2f8fc:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f8ff:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2f903:	48 83 f8 00          	cmp    $0x0,%rax
    7095b0a2f907:	0f 85 16 00 00 00    	jne    0x7095b0a2f923
    7095b0a2f90d:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f911:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f915:	89 05 e5 06 0f 13    	mov    %eax,0x130f06e5(%rip)        # 0x7095c3b20000
    7095b0a2f91b:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f922:	c3                   	ret
    7095b0a2f923:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f926:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    7095b0a2f92c:	0f 85 10 00 00 00    	jne    0x7095b0a2f942
    7095b0a2f932:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f936:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f939:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f93d:	e9 64 00 00 00       	jmp    0x7095b0a2f9a6
    7095b0a2f942:	48 89 c3             	mov    %rax,%rbx
    7095b0a2f945:	83 e3 0f             	and    $0xf,%ebx
    7095b0a2f948:	48 83 fb 05          	cmp    $0x5,%rbx
    7095b0a2f94c:	0f 85 49 00 00 00    	jne    0x7095b0a2f99b
    7095b0a2f952:	48 bb 05 ef 09 b6 95 	movabs $0x7095b609ef05,%rbx
    7095b0a2f959:	70 00 00 
    7095b0a2f95c:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2f960:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    7095b0a2f964:	49 89 1e             	mov    %rbx,(%r14)
    7095b0a2f967:	e8 c4 2d 36 00       	call   0x7095b0d92730
    7095b0a2f96c:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f96f:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f973:	48 83 f8 01          	cmp    $0x1,%rax
    7095b0a2f977:	0f 84 12 00 00 00    	je     0x7095b0a2f98f
    7095b0a2f97d:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f981:	89 05 79 06 0f 13    	mov    %eax,0x130f0679(%rip)        # 0x7095c3b20000
    7095b0a2f987:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2f98e:	c3                   	ret
    7095b0a2f98f:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f992:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f996:	e9 0b 00 00 00       	jmp    0x7095b0a2f9a6
    7095b0a2f99b:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2f99f:	49 8b 06             	mov    (%r14),%rax
    7095b0a2f9a2:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    7095b0a2f9a6:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    7095b0a2f9aa:	48 8b 11             	mov    (%rcx),%rdx
    7095b0a2f9ad:	48 83 c2 20          	add    $0x20,%rdx
    7095b0a2f9b1:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    7095b0a2f9b5:	0f 8e 25 00 00 00    	jle    0x7095b0a2f9e0
    7095b0a2f9bb:	48 89 9c 24 90 00 00 	mov    %rbx,0x90(%rsp)
    7095b0a2f9c2:	00 
    7095b0a2f9c3:	48 89 84 24 98 00 00 	mov    %rax,0x98(%rsp)
    7095b0a2f9ca:	00 
    7095b0a2f9cb:	e8 a0 75 06 00       	call   0x7095b0a96f70
    7095b0a2f9d0:	48 8b 9c 24 90 00 00 	mov    0x90(%rsp),%rbx
    7095b0a2f9d7:	00 
    7095b0a2f9d8:	48 8b 84 24 98 00 00 	mov    0x98(%rsp),%rax
    7095b0a2f9df:	00 
    7095b0a2f9e0:	48 ba 52 f5 00 b6 95 	movabs $0x7095b600f552,%rdx
    7095b0a2f9e7:	70 00 00 
    7095b0a2f9ea:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    7095b0a2f9ee:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    7095b0a2f9f2:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    7095b0a2f9f9:	48 83 c9 07          	or     $0x7,%rcx
    7095b0a2f9fd:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    7095b0a2fa02:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    7095b0a2fa06:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    7095b0a2fa0a:	48 89 41 11          	mov    %rax,0x11(%rcx)
    7095b0a2fa0e:	49 83 ee 08          	sub    $0x8,%r14
    7095b0a2fa12:	49 89 0e             	mov    %rcx,(%r14)
    7095b0a2fa15:	89 05 e5 05 0f 13    	mov    %eax,0x130f05e5(%rip)        # 0x7095c3b20000
    7095b0a2fa1b:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2fa22:	c3                   	ret
    7095b0a2fa23:	48 8b 40 01          	mov    0x1(%rax),%rax
    7095b0a2fa27:	48 8b 40 0e          	mov    0xe(%rax),%rax
    7095b0a2fa2b:	48 bb 1c c6 ff b5 95 	movabs $0x7095b5ffc61c,%rbx
    7095b0a2fa32:	70 00 00 
    7095b0a2fa35:	48 39 d8             	cmp    %rbx,%rax
    7095b0a2fa38:	0f 85 19 00 00 00    	jne    0x7095b0a2fa57
    7095b0a2fa3e:	89 05 bc 05 0f 13    	mov    %eax,0x130f05bc(%rip)        # 0x7095c3b20000
    7095b0a2fa44:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    7095b0a2fa4b:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x7095b0a2fa57
    7095b0a2fa52:	e9 69 ff 1e 00       	jmp    0x7095b0c1f9c0
    7095b0a2fa57:	48 b8 dc 9e fe b5 95 	movabs $0x7095b5fe9edc,%rax
    7095b0a2fa5e:	70 00 00 
    7095b0a2fa61:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2fa65:	49 89 06             	mov    %rax,(%r14)
    7095b0a2fa68:	e8 b3 74 43 00       	call   0x7095b0e66f20
    7095b0a2fa6d:	48 b8 dc 9e fe b5 95 	movabs $0x7095b5fe9edc,%rax
    7095b0a2fa74:	70 00 00 
    7095b0a2fa77:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2fa7b:	49 89 06             	mov    %rax,(%r14)
    7095b0a2fa7e:	e8 9d 74 43 00       	call   0x7095b0e66f20
    7095b0a2fa83:	48 b8 dc 9e fe b5 95 	movabs $0x7095b5fe9edc,%rax
    7095b0a2fa8a:	70 00 00 
    7095b0a2fa8d:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2fa91:	49 89 06             	mov    %rax,(%r14)
    7095b0a2fa94:	e8 87 74 43 00       	call   0x7095b0e66f20
    7095b0a2fa99:	48 b8 dc 9e fe b5 95 	movabs $0x7095b5fe9edc,%rax
    7095b0a2faa0:	70 00 00 
    7095b0a2faa3:	49 83 c6 08          	add    $0x8,%r14
    7095b0a2faa7:	49 89 06             	mov    %rax,(%r14)
    7095b0a2faaa:	e8 71 74 43 00       	call   0x7095b0e66f20
    7095b0a2faaf:	00 00                	add    %al,(%rax)
    7095b0a2fab1:	00 00                	add    %al,(%rax)
    7095b0a2fab3:	00 06                	add    %al,(%rsi)
    7095b0a2fab5:	00 00                	add    %al,(%rax)
    7095b0a2fab7:	03 00                	add    (%rax),%eax
    7095b0a2fab9:	18 00                	sbb    %al,(%rax)
    7095b0a2fabb:	00 03                	add    %al,(%rbx)
    7095b0a2fabd:	00 00                	add    %al,(%rax)
    7095b0a2fabf:	06                   	(bad)
    7095b0a2fac0:	00 00                	add    %al,(%rax)
    7095b0a2fac2:	03 00                	add    (%rax),%eax
    7095b0a2fac4:	80 01 00             	addb   $0x0,(%rcx)
    7095b0a2fac7:	c0 00 00             	rolb   $0x0,(%rax)
    7095b0a2faca:	60                   	(bad)
    7095b0a2facb:	00 00                	add    %al,(%rax)
    7095b0a2facd:	30 00                	xor    %al,(%rax)
    7095b0a2facf:	00 18                	add    %bl,(%rax)
    7095b0a2fad1:	00 00                	add    %al,(%rax)
    7095b0a2fad3:	0c a2                	or     $0xa2,%al
    7095b0a2fad5:	00 00                	add    %al,(%rax)
    7095b0a2fad7:	00 6c 02 00          	add    %ch,0x0(%rdx,%rax,1)
    7095b0a2fadb:	00 5b 03             	add    %bl,0x3(%rbx)
    7095b0a2fade:	00 00                	add    %al,(%rax)
    7095b0a2fae0:	de 03                	fiadds (%rbx)
    7095b0a2fae2:	00 00                	add    %al,(%rax)
    7095b0a2fae4:	23 06                	and    (%rsi),%eax
    7095b0a2fae6:	00 00                	add    %al,(%rax)
    7095b0a2fae8:	38 09                	cmp    %cl,(%rcx)
    7095b0a2faea:	00 00                	add    %al,(%rax)
    7095b0a2faec:	20 0b                	and    %cl,(%rbx)
    7095b0a2faee:	00 00                	add    %al,(%rax)
    7095b0a2faf0:	d6                   	udb
    7095b0a2faf1:	0c 00                	or     $0x0,%al
    7095b0a2faf3:	00 34 0e             	add    %dh,(%rsi,%rcx,1)
    7095b0a2faf6:	00 00                	add    %al,(%rax)
    7095b0a2faf8:	bc 0f 00 00 2b       	mov    $0x2b00000f,%esp
    7095b0a2fafd:	11 00                	adc    %eax,(%rax)
    7095b0a2faff:	00 d0                	add    %dl,%al
    7095b0a2fb01:	13 00                	adc    (%rax),%eax
    7095b0a2fb03:	00 15 00 00 00 00    	add    %dl,0x0(%rip)        # 0x7095b0a2fb09
    7095b0a2fb09:	00 00                	add    %al,(%rax)
    7095b0a2fb0b:	00 0c 00             	add    %cl,(%rax,%rax,1)
	...
