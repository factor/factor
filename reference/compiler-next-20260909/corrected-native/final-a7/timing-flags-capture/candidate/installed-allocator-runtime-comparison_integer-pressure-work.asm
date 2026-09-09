
/home/erg/factor-compiler-next-final-c6948-20260909/reference/compiler-next-20260909/installed-allocator-runtime-comparison_integer-pressure-work.bin:     file format binary


Disassembly of section .data:

000070610f1d17b0 <.data>:
    70610f1d17b0:	89 05 4a 28 38 13    	mov    %eax,0x1338284a(%rip)        # 0x706122554000
    70610f1d17b6:	53                   	push   %rbx
    70610f1d17b7:	31 db                	xor    %ebx,%ebx
    70610f1d17b9:	ba 80 3e 00 00       	mov    $0x3e80,%edx
    70610f1d17be:	49 83 c6 18          	add    $0x18,%r14
    70610f1d17c2:	49 c7 46 f0 00 00 00 	movq   $0x0,-0x10(%r14)
    70610f1d17c9:	00 
    70610f1d17ca:	e9 1d 00 00 00       	jmp    0x70610f1d17ec
    70610f1d17cf:	49 8b 1f             	mov    (%r15),%rbx
    70610f1d17d2:	49 8b 57 f8          	mov    -0x8(%r15),%rdx
    70610f1d17d6:	49 83 ee 10          	sub    $0x10,%r14
    70610f1d17da:	48 83 c3 10          	add    $0x10,%rbx
    70610f1d17de:	89 05 1c 28 38 13    	mov    %eax,0x1338281c(%rip)        # 0x706122554000
    70610f1d17e4:	49 83 c6 10          	add    $0x10,%r14
    70610f1d17e8:	49 83 ef 10          	sub    $0x10,%r15
    70610f1d17ec:	48 39 d3             	cmp    %rdx,%rbx
    70610f1d17ef:	0f 8d 5a 00 00 00    	jge    0x70610f1d184f
    70610f1d17f5:	31 c0                	xor    %eax,%eax
    70610f1d17f7:	b9 00 02 00 00       	mov    $0x200,%ecx
    70610f1d17fc:	49 83 c7 10          	add    $0x10,%r15
    70610f1d1800:	49 89 1f             	mov    %rbx,(%r15)
    70610f1d1803:	49 89 57 f8          	mov    %rdx,-0x8(%r15)
    70610f1d1807:	e9 35 00 00 00       	jmp    0x70610f1d1841
    70610f1d180c:	49 83 ee 08          	sub    $0x8,%r14
    70610f1d1810:	49 83 c7 10          	add    $0x10,%r15
    70610f1d1814:	49 89 07             	mov    %rax,(%r15)
    70610f1d1817:	49 89 06             	mov    %rax,(%r14)
    70610f1d181a:	49 89 4f f8          	mov    %rcx,-0x8(%r15)
    70610f1d181e:	e8 fd fd 27 00       	call   0x70610f451620
    70610f1d1823:	e8 38 e9 21 00       	call   0x70610f3f0160
    70610f1d1828:	49 8b 07             	mov    (%r15),%rax
    70610f1d182b:	49 8b 4f f8          	mov    -0x8(%r15),%rcx
    70610f1d182f:	48 83 c0 10          	add    $0x10,%rax
    70610f1d1833:	89 05 c7 27 38 13    	mov    %eax,0x133827c7(%rip)        # 0x706122554000
    70610f1d1839:	49 83 c6 10          	add    $0x10,%r14
    70610f1d183d:	49 83 ef 10          	sub    $0x10,%r15
    70610f1d1841:	48 39 c8             	cmp    %rcx,%rax
    70610f1d1844:	0f 8d 85 ff ff ff    	jge    0x70610f1d17cf
    70610f1d184a:	e9 bd ff ff ff       	jmp    0x70610f1d180c
    70610f1d184f:	49 83 ee 10          	sub    $0x10,%r14
    70610f1d1853:	49 83 c6 08          	add    $0x8,%r14
    70610f1d1857:	49 c7 06 00 00 f2 2b 	movq   $0x2bf20000,(%r14)
    70610f1d185e:	89 05 9c 27 38 13    	mov    %eax,0x1338279c(%rip)        # 0x706122554000
    70610f1d1864:	5b                   	pop    %rbx
    70610f1d1865:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x70610f1d1871
    70610f1d186c:	e9 5f d7 54 00       	jmp    0x70610f71efd0
	...
