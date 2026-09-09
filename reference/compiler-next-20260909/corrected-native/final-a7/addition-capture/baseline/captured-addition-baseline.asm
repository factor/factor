
/home/erg/factor-compiler-next-greedy-baseline-20260909/reference/compiler-next-20260909/captured-addition-baseline.bin:     file format binary


Disassembly of section .data:

0000000000000000 <.data>:
       0:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x6
       6:	48 81 ec a8 00 00 00 	sub    $0xa8,%rsp
       d:	49 8b 06             	mov    (%r14),%rax
      10:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
      14:	48 89 d9             	mov    %rbx,%rcx
      17:	48 89 c2             	mov    %rax,%rdx
      1a:	48 09 d1             	or     %rdx,%rcx
      1d:	f7 c1 0f 00 00 00    	test   $0xf,%ecx
      23:	0f 85 00 00 00 00    	jne    0x29
      29:	48 01 c3             	add    %rax,%rbx
      2c:	0f 80 00 00 00 00    	jo     0x32
      32:	49 83 ee 08          	sub    $0x8,%r14
      36:	49 89 1e             	mov    %rbx,(%r14)
      39:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x3f
      3f:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
      46:	c3                   	ret
      47:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x4d
      4d:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
      54:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x60
      5b:	e9 00 00 00 00       	jmp    0x60
      60:	48 89 d9             	mov    %rbx,%rcx
      63:	f7 c1 0f 00 00 00    	test   $0xf,%ecx
      69:	0f 85 00 00 00 00    	jne    0x6f
      6f:	48 89 c1             	mov    %rax,%rcx
      72:	83 e1 0f             	and    $0xf,%ecx
      75:	48 83 f9 03          	cmp    $0x3,%rcx
      79:	0f 85 00 00 00 00    	jne    0x7f
      7f:	49 8d 4d 10          	lea    0x10(%r13),%rcx
      83:	48 8b 11             	mov    (%rcx),%rdx
      86:	48 83 c2 10          	add    $0x10,%rdx
      8a:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
      8e:	0f 8e 00 00 00 00    	jle    0x94
      94:	48 89 1c 24          	mov    %rbx,(%rsp)
      98:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
      9d:	e8 00 00 00 00       	call   0xa2
      a2:	48 8b 1c 24          	mov    (%rsp),%rbx
      a6:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
      ab:	48 c1 fb 04          	sar    $0x4,%rbx
      af:	0f 57 c0             	xorps  %xmm0,%xmm0
      b2:	f2 48 0f 2a c3       	cvtsi2sd %rbx,%xmm0
      b7:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
      bd:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
      c1:	49 8d 5d 10          	lea    0x10(%r13),%rbx
      c5:	48 8b 03             	mov    (%rbx),%rax
      c8:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
      cf:	48 83 c8 03          	or     $0x3,%rax
      d3:	48 83 03 10          	addq   $0x10,(%rbx)
      d7:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
      dd:	49 83 ee 08          	sub    $0x8,%r14
      e1:	49 89 06             	mov    %rax,(%r14)
      e4:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0xea
      ea:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
      f1:	c3                   	ret
      f2:	48 89 c3             	mov    %rax,%rbx
      f5:	83 e3 0f             	and    $0xf,%ebx
      f8:	48 83 fb 05          	cmp    $0x5,%rbx
      fc:	0f 85 00 00 00 00    	jne    0x102
     102:	49 83 ee 08          	sub    $0x8,%r14
     106:	49 83 c7 08          	add    $0x8,%r15
     10a:	49 89 07             	mov    %rax,(%r15)
     10d:	e8 00 00 00 00       	call   0x112
     112:	49 8b 07             	mov    (%r15),%rax
     115:	49 83 c6 08          	add    $0x8,%r14
     119:	49 83 ef 08          	sub    $0x8,%r15
     11d:	49 89 06             	mov    %rax,(%r14)
     120:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x126
     126:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     12d:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x139
     134:	e9 00 00 00 00       	jmp    0x139
     139:	48 89 c3             	mov    %rax,%rbx
     13c:	83 e3 0f             	and    $0xf,%ebx
     13f:	48 83 fb 07          	cmp    $0x7,%rbx
     143:	0f 85 00 00 00 00    	jne    0x149
     149:	48 8b 58 01          	mov    0x1(%rax),%rbx
     14d:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
     151:	48 b9 00 00 00 00 00 	movabs $0x0,%rcx
     158:	00 00 00 
     15b:	48 39 cb             	cmp    %rcx,%rbx
     15e:	0f 85 00 00 00 00    	jne    0x164
     164:	48 8b 58 09          	mov    0x9(%rax),%rbx
     168:	48 8b 40 11          	mov    0x11(%rax),%rax
     16c:	49 83 c7 10          	add    $0x10,%r15
     170:	49 89 47 f8          	mov    %rax,-0x8(%r15)
     174:	49 89 1e             	mov    %rbx,(%r14)
     177:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
     17e:	e8 00 00 00 00       	call   0x183
     183:	49 8b 1f             	mov    (%r15),%rbx
     186:	49 8b 47 f8          	mov    -0x8(%r15),%rax
     18a:	49 83 c6 10          	add    $0x10,%r14
     18e:	49 83 ef 10          	sub    $0x10,%r15
     192:	49 89 5e f8          	mov    %rbx,-0x8(%r14)
     196:	49 89 06             	mov    %rax,(%r14)
     199:	e8 00 00 00 00       	call   0x19e
     19e:	49 8b 06             	mov    (%r14),%rax
     1a1:	49 83 c6 08          	add    $0x8,%r14
     1a5:	48 83 f8 00          	cmp    $0x0,%rax
     1a9:	0f 85 00 00 00 00    	jne    0x1af
     1af:	49 83 ee 08          	sub    $0x8,%r14
     1b3:	49 83 ee 08          	sub    $0x8,%r14
     1b7:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x1bd
     1bd:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     1c4:	c3                   	ret
     1c5:	48 89 c3             	mov    %rax,%rbx
     1c8:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
     1ce:	0f 85 00 00 00 00    	jne    0x1d4
     1d4:	49 83 ee 08          	sub    $0x8,%r14
     1d8:	49 8b 06             	mov    (%r14),%rax
     1db:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     1df:	e9 00 00 00 00       	jmp    0x1e4
     1e4:	48 89 c3             	mov    %rax,%rbx
     1e7:	83 e3 0f             	and    $0xf,%ebx
     1ea:	48 83 fb 05          	cmp    $0x5,%rbx
     1ee:	0f 85 00 00 00 00    	jne    0x1f4
     1f4:	48 bb 00 00 00 00 00 	movabs $0x0,%rbx
     1fb:	00 00 00 
     1fe:	49 83 c6 08          	add    $0x8,%r14
     202:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     206:	49 89 1e             	mov    %rbx,(%r14)
     209:	e8 00 00 00 00       	call   0x20e
     20e:	49 8b 06             	mov    (%r14),%rax
     211:	49 83 ee 08          	sub    $0x8,%r14
     215:	48 83 f8 01          	cmp    $0x1,%rax
     219:	0f 84 00 00 00 00    	je     0x21f
     21f:	49 83 ee 08          	sub    $0x8,%r14
     223:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x229
     229:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     230:	c3                   	ret
     231:	49 8b 06             	mov    (%r14),%rax
     234:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     238:	e9 00 00 00 00       	jmp    0x23d
     23d:	49 83 ee 08          	sub    $0x8,%r14
     241:	49 8b 06             	mov    (%r14),%rax
     244:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     248:	49 8d 55 10          	lea    0x10(%r13),%rdx
     24c:	48 8b 0a             	mov    (%rdx),%rcx
     24f:	48 83 c1 20          	add    $0x20,%rcx
     253:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
     257:	0f 8e 00 00 00 00    	jle    0x25d
     25d:	48 89 5c 24 10       	mov    %rbx,0x10(%rsp)
     262:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
     267:	e8 00 00 00 00       	call   0x26c
     26c:	48 8b 5c 24 10       	mov    0x10(%rsp),%rbx
     271:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
     276:	48 ba 00 00 00 00 00 	movabs $0x0,%rdx
     27d:	00 00 00 
     280:	49 8d 6d 10          	lea    0x10(%r13),%rbp
     284:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
     288:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
     28f:	48 83 c9 07          	or     $0x7,%rcx
     293:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
     298:	48 89 51 01          	mov    %rdx,0x1(%rcx)
     29c:	48 89 59 09          	mov    %rbx,0x9(%rcx)
     2a0:	48 89 41 11          	mov    %rax,0x11(%rcx)
     2a4:	49 83 ee 08          	sub    $0x8,%r14
     2a8:	49 89 0e             	mov    %rcx,(%r14)
     2ab:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x2b1
     2b1:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     2b8:	c3                   	ret
     2b9:	48 8b 40 01          	mov    0x1(%rax),%rax
     2bd:	48 8b 40 0e          	mov    0xe(%rax),%rax
     2c1:	48 bb 00 00 00 00 00 	movabs $0x0,%rbx
     2c8:	00 00 00 
     2cb:	48 39 d8             	cmp    %rbx,%rax
     2ce:	0f 85 00 00 00 00    	jne    0x2d4
     2d4:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x2da
     2da:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     2e1:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x2ed
     2e8:	e9 00 00 00 00       	jmp    0x2ed
     2ed:	48 b8 00 00 00 00 00 	movabs $0x0,%rax
     2f4:	00 00 00 
     2f7:	49 83 c6 08          	add    $0x8,%r14
     2fb:	49 89 06             	mov    %rax,(%r14)
     2fe:	e8 00 00 00 00       	call   0x303
     303:	48 b8 00 00 00 00 00 	movabs $0x0,%rax
     30a:	00 00 00 
     30d:	49 83 c6 08          	add    $0x8,%r14
     311:	49 89 06             	mov    %rax,(%r14)
     314:	e8 00 00 00 00       	call   0x319
     319:	48 89 d9             	mov    %rbx,%rcx
     31c:	83 e1 0f             	and    $0xf,%ecx
     31f:	48 83 f9 03          	cmp    $0x3,%rcx
     323:	0f 85 00 00 00 00    	jne    0x329
     329:	48 89 c1             	mov    %rax,%rcx
     32c:	f7 c1 0f 00 00 00    	test   $0xf,%ecx
     332:	0f 85 00 00 00 00    	jne    0x338
     338:	49 8d 55 10          	lea    0x10(%r13),%rdx
     33c:	48 8b 0a             	mov    (%rdx),%rcx
     33f:	48 83 c1 10          	add    $0x10,%rcx
     343:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
     347:	0f 8e 00 00 00 00    	jle    0x34d
     34d:	48 89 1c 24          	mov    %rbx,(%rsp)
     351:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
     356:	e8 00 00 00 00       	call   0x35b
     35b:	48 8b 1c 24          	mov    (%rsp),%rbx
     35f:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
     364:	48 c1 f8 04          	sar    $0x4,%rax
     368:	0f 57 c9             	xorps  %xmm1,%xmm1
     36b:	f2 48 0f 2a c8       	cvtsi2sd %rax,%xmm1
     370:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
     376:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
     37a:	49 8d 5d 10          	lea    0x10(%r13),%rbx
     37e:	48 8b 03             	mov    (%rbx),%rax
     381:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
     388:	48 83 c8 03          	or     $0x3,%rax
     38c:	48 83 03 10          	addq   $0x10,(%rbx)
     390:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
     396:	49 83 ee 08          	sub    $0x8,%r14
     39a:	49 89 06             	mov    %rax,(%r14)
     39d:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x3a3
     3a3:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     3aa:	c3                   	ret
     3ab:	48 89 c1             	mov    %rax,%rcx
     3ae:	83 e1 0f             	and    $0xf,%ecx
     3b1:	48 83 f9 03          	cmp    $0x3,%rcx
     3b5:	0f 85 00 00 00 00    	jne    0x3bb
     3bb:	49 8d 55 10          	lea    0x10(%r13),%rdx
     3bf:	48 8b 0a             	mov    (%rdx),%rcx
     3c2:	48 83 c1 10          	add    $0x10,%rcx
     3c6:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
     3ca:	0f 8e 00 00 00 00    	jle    0x3d0
     3d0:	48 89 1c 24          	mov    %rbx,(%rsp)
     3d4:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
     3d9:	e8 00 00 00 00       	call   0x3de
     3de:	48 8b 1c 24          	mov    (%rsp),%rbx
     3e2:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
     3e7:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
     3ed:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
     3f3:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
     3f7:	49 8d 5d 10          	lea    0x10(%r13),%rbx
     3fb:	48 8b 03             	mov    (%rbx),%rax
     3fe:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
     405:	48 83 c8 03          	or     $0x3,%rax
     409:	48 83 03 10          	addq   $0x10,(%rbx)
     40d:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
     413:	49 83 ee 08          	sub    $0x8,%r14
     417:	49 89 06             	mov    %rax,(%r14)
     41a:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x420
     420:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     427:	c3                   	ret
     428:	48 89 c3             	mov    %rax,%rbx
     42b:	83 e3 0f             	and    $0xf,%ebx
     42e:	48 83 fb 05          	cmp    $0x5,%rbx
     432:	0f 85 00 00 00 00    	jne    0x438
     438:	e8 00 00 00 00       	call   0x43d
     43d:	49 8d 5d 10          	lea    0x10(%r13),%rbx
     441:	48 8b 03             	mov    (%rbx),%rax
     444:	48 83 c0 10          	add    $0x10,%rax
     448:	48 3b 43 10          	cmp    0x10(%rbx),%rax
     44c:	0f 8e 00 00 00 00    	jle    0x452
     452:	e8 00 00 00 00       	call   0x457
     457:	49 8b 06             	mov    (%r14),%rax
     45a:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     45e:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
     464:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
     46a:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
     46e:	49 8d 5d 10          	lea    0x10(%r13),%rbx
     472:	48 8b 03             	mov    (%rbx),%rax
     475:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
     47c:	48 83 c8 03          	or     $0x3,%rax
     480:	48 83 03 10          	addq   $0x10,(%rbx)
     484:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
     48a:	49 83 ee 08          	sub    $0x8,%r14
     48e:	49 89 06             	mov    %rax,(%r14)
     491:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x497
     497:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     49e:	c3                   	ret
     49f:	48 89 c3             	mov    %rax,%rbx
     4a2:	83 e3 0f             	and    $0xf,%ebx
     4a5:	48 83 fb 07          	cmp    $0x7,%rbx
     4a9:	0f 85 00 00 00 00    	jne    0x4af
     4af:	48 8b 58 01          	mov    0x1(%rax),%rbx
     4b3:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
     4b7:	48 b9 00 00 00 00 00 	movabs $0x0,%rcx
     4be:	00 00 00 
     4c1:	48 39 cb             	cmp    %rcx,%rbx
     4c4:	0f 85 00 00 00 00    	jne    0x4ca
     4ca:	48 8b 58 09          	mov    0x9(%rax),%rbx
     4ce:	48 8b 40 11          	mov    0x11(%rax),%rax
     4d2:	49 83 c7 10          	add    $0x10,%r15
     4d6:	49 89 47 f8          	mov    %rax,-0x8(%r15)
     4da:	49 89 1e             	mov    %rbx,(%r14)
     4dd:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
     4e4:	e8 00 00 00 00       	call   0x4e9
     4e9:	49 8d 45 10          	lea    0x10(%r13),%rax
     4ed:	48 8b 18             	mov    (%rax),%rbx
     4f0:	48 83 c3 10          	add    $0x10,%rbx
     4f4:	48 3b 58 10          	cmp    0x10(%rax),%rbx
     4f8:	0f 8e 00 00 00 00    	jle    0x4fe
     4fe:	e8 00 00 00 00       	call   0x503
     503:	49 8b 0e             	mov    (%r14),%rcx
     506:	49 8b 07             	mov    (%r15),%rax
     509:	49 8b 56 f8          	mov    -0x8(%r14),%rdx
     50d:	49 8b 5f f8          	mov    -0x8(%r15),%rbx
     511:	f2 48 0f 10 42 05    	rex.W movsd 0x5(%rdx),%xmm0
     517:	f2 48 0f 10 49 05    	rex.W movsd 0x5(%rcx),%xmm1
     51d:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
     521:	49 8d 55 10          	lea    0x10(%r13),%rdx
     525:	48 8b 0a             	mov    (%rdx),%rcx
     528:	48 c7 01 0c 00 00 00 	movq   $0xc,(%rcx)
     52f:	48 83 c9 03          	or     $0x3,%rcx
     533:	48 83 02 10          	addq   $0x10,(%rdx)
     537:	f2 48 0f 11 41 05    	rex.W movsd %xmm0,0x5(%rcx)
     53d:	49 83 c6 08          	add    $0x8,%r14
     541:	49 83 ef 10          	sub    $0x10,%r15
     545:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     549:	49 89 1e             	mov    %rbx,(%r14)
     54c:	49 89 4e f0          	mov    %rcx,-0x10(%r14)
     550:	e8 00 00 00 00       	call   0x555
     555:	49 8b 06             	mov    (%r14),%rax
     558:	49 83 c6 08          	add    $0x8,%r14
     55c:	48 83 f8 00          	cmp    $0x0,%rax
     560:	0f 85 00 00 00 00    	jne    0x566
     566:	49 83 ee 08          	sub    $0x8,%r14
     56a:	49 83 ee 08          	sub    $0x8,%r14
     56e:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x574
     574:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     57b:	c3                   	ret
     57c:	48 89 c3             	mov    %rax,%rbx
     57f:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
     585:	0f 85 00 00 00 00    	jne    0x58b
     58b:	49 83 ee 08          	sub    $0x8,%r14
     58f:	49 8b 06             	mov    (%r14),%rax
     592:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     596:	e9 00 00 00 00       	jmp    0x59b
     59b:	48 89 c3             	mov    %rax,%rbx
     59e:	83 e3 0f             	and    $0xf,%ebx
     5a1:	48 83 fb 05          	cmp    $0x5,%rbx
     5a5:	0f 85 00 00 00 00    	jne    0x5ab
     5ab:	48 bb 00 00 00 00 00 	movabs $0x0,%rbx
     5b2:	00 00 00 
     5b5:	49 83 c6 08          	add    $0x8,%r14
     5b9:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     5bd:	49 89 1e             	mov    %rbx,(%r14)
     5c0:	e8 00 00 00 00       	call   0x5c5
     5c5:	49 8b 06             	mov    (%r14),%rax
     5c8:	49 83 ee 08          	sub    $0x8,%r14
     5cc:	48 83 f8 01          	cmp    $0x1,%rax
     5d0:	0f 84 00 00 00 00    	je     0x5d6
     5d6:	49 83 ee 08          	sub    $0x8,%r14
     5da:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x5e0
     5e0:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     5e7:	c3                   	ret
     5e8:	49 8b 06             	mov    (%r14),%rax
     5eb:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     5ef:	e9 00 00 00 00       	jmp    0x5f4
     5f4:	49 83 ee 08          	sub    $0x8,%r14
     5f8:	49 8b 06             	mov    (%r14),%rax
     5fb:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     5ff:	49 8d 55 10          	lea    0x10(%r13),%rdx
     603:	48 8b 0a             	mov    (%rdx),%rcx
     606:	48 83 c1 20          	add    $0x20,%rcx
     60a:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
     60e:	0f 8e 00 00 00 00    	jle    0x614
     614:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)
     619:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
     61e:	e8 00 00 00 00       	call   0x623
     623:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
     628:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
     62d:	48 ba 00 00 00 00 00 	movabs $0x0,%rdx
     634:	00 00 00 
     637:	49 8d 6d 10          	lea    0x10(%r13),%rbp
     63b:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
     63f:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
     646:	48 83 c9 07          	or     $0x7,%rcx
     64a:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
     64f:	48 89 51 01          	mov    %rdx,0x1(%rcx)
     653:	48 89 59 09          	mov    %rbx,0x9(%rcx)
     657:	48 89 41 11          	mov    %rax,0x11(%rcx)
     65b:	49 83 ee 08          	sub    $0x8,%r14
     65f:	49 89 0e             	mov    %rcx,(%r14)
     662:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x668
     668:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     66f:	c3                   	ret
     670:	48 8b 40 01          	mov    0x1(%rax),%rax
     674:	48 8b 40 0e          	mov    0xe(%rax),%rax
     678:	48 bb 00 00 00 00 00 	movabs $0x0,%rbx
     67f:	00 00 00 
     682:	48 39 d8             	cmp    %rbx,%rax
     685:	0f 85 00 00 00 00    	jne    0x68b
     68b:	e8 00 00 00 00       	call   0x690
     690:	49 8d 45 10          	lea    0x10(%r13),%rax
     694:	48 8b 18             	mov    (%rax),%rbx
     697:	48 83 c3 10          	add    $0x10,%rbx
     69b:	48 3b 58 10          	cmp    0x10(%rax),%rbx
     69f:	0f 8e 00 00 00 00    	jle    0x6a5
     6a5:	e8 00 00 00 00       	call   0x6aa
     6aa:	49 8b 06             	mov    (%r14),%rax
     6ad:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     6b1:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
     6b7:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
     6bd:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
     6c1:	49 8d 5d 10          	lea    0x10(%r13),%rbx
     6c5:	48 8b 03             	mov    (%rbx),%rax
     6c8:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
     6cf:	48 83 c8 03          	or     $0x3,%rax
     6d3:	48 83 03 10          	addq   $0x10,(%rbx)
     6d7:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
     6dd:	49 83 ee 08          	sub    $0x8,%r14
     6e1:	49 89 06             	mov    %rax,(%r14)
     6e4:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x6ea
     6ea:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     6f1:	c3                   	ret
     6f2:	48 b8 00 00 00 00 00 	movabs $0x0,%rax
     6f9:	00 00 00 
     6fc:	49 83 c6 08          	add    $0x8,%r14
     700:	49 89 06             	mov    %rax,(%r14)
     703:	e8 00 00 00 00       	call   0x708
     708:	48 b8 00 00 00 00 00 	movabs $0x0,%rax
     70f:	00 00 00 
     712:	49 83 c6 08          	add    $0x8,%r14
     716:	49 89 06             	mov    %rax,(%r14)
     719:	e8 00 00 00 00       	call   0x71e
     71e:	48 89 d9             	mov    %rbx,%rcx
     721:	83 e1 0f             	and    $0xf,%ecx
     724:	48 83 f9 05          	cmp    $0x5,%rcx
     728:	0f 85 00 00 00 00    	jne    0x72e
     72e:	48 89 c3             	mov    %rax,%rbx
     731:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
     737:	0f 85 00 00 00 00    	jne    0x73d
     73d:	e8 00 00 00 00       	call   0x742
     742:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x748
     748:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     74f:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x75b
     756:	e9 00 00 00 00       	jmp    0x75b
     75b:	48 89 c3             	mov    %rax,%rbx
     75e:	83 e3 0f             	and    $0xf,%ebx
     761:	48 83 fb 03          	cmp    $0x3,%rbx
     765:	0f 85 00 00 00 00    	jne    0x76b
     76b:	49 83 ee 08          	sub    $0x8,%r14
     76f:	49 83 c7 08          	add    $0x8,%r15
     773:	49 89 07             	mov    %rax,(%r15)
     776:	e8 00 00 00 00       	call   0x77b
     77b:	49 8d 5d 10          	lea    0x10(%r13),%rbx
     77f:	48 8b 03             	mov    (%rbx),%rax
     782:	48 83 c0 10          	add    $0x10,%rax
     786:	48 3b 43 10          	cmp    0x10(%rbx),%rax
     78a:	0f 8e 00 00 00 00    	jle    0x790
     790:	e8 00 00 00 00       	call   0x795
     795:	49 8b 07             	mov    (%r15),%rax
     798:	49 8b 1e             	mov    (%r14),%rbx
     79b:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
     7a1:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
     7a7:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
     7ab:	49 8d 5d 10          	lea    0x10(%r13),%rbx
     7af:	48 8b 03             	mov    (%rbx),%rax
     7b2:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
     7b9:	48 83 c8 03          	or     $0x3,%rax
     7bd:	48 83 03 10          	addq   $0x10,(%rbx)
     7c1:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
     7c7:	49 83 ef 08          	sub    $0x8,%r15
     7cb:	49 89 06             	mov    %rax,(%r14)
     7ce:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x7d4
     7d4:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     7db:	c3                   	ret
     7dc:	48 89 c3             	mov    %rax,%rbx
     7df:	83 e3 0f             	and    $0xf,%ebx
     7e2:	48 83 fb 05          	cmp    $0x5,%rbx
     7e6:	0f 85 00 00 00 00    	jne    0x7ec
     7ec:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x7f2
     7f2:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     7f9:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x805
     800:	e9 00 00 00 00       	jmp    0x805
     805:	48 89 c3             	mov    %rax,%rbx
     808:	83 e3 0f             	and    $0xf,%ebx
     80b:	48 83 fb 07          	cmp    $0x7,%rbx
     80f:	0f 85 00 00 00 00    	jne    0x815
     815:	48 8b 58 01          	mov    0x1(%rax),%rbx
     819:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
     81d:	48 b9 00 00 00 00 00 	movabs $0x0,%rcx
     824:	00 00 00 
     827:	48 39 cb             	cmp    %rcx,%rbx
     82a:	0f 85 00 00 00 00    	jne    0x830
     830:	48 8b 58 09          	mov    0x9(%rax),%rbx
     834:	48 8b 40 11          	mov    0x11(%rax),%rax
     838:	49 83 c7 10          	add    $0x10,%r15
     83c:	49 89 47 f8          	mov    %rax,-0x8(%r15)
     840:	49 89 1e             	mov    %rbx,(%r14)
     843:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
     84a:	e8 00 00 00 00       	call   0x84f
     84f:	49 8b 07             	mov    (%r15),%rax
     852:	49 8b 5f f8          	mov    -0x8(%r15),%rbx
     856:	49 83 c6 10          	add    $0x10,%r14
     85a:	49 83 ef 10          	sub    $0x10,%r15
     85e:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     862:	49 89 1e             	mov    %rbx,(%r14)
     865:	e8 00 00 00 00       	call   0x86a
     86a:	49 8b 06             	mov    (%r14),%rax
     86d:	49 83 c6 08          	add    $0x8,%r14
     871:	48 83 f8 00          	cmp    $0x0,%rax
     875:	0f 85 00 00 00 00    	jne    0x87b
     87b:	49 83 ee 08          	sub    $0x8,%r14
     87f:	49 83 ee 08          	sub    $0x8,%r14
     883:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x889
     889:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     890:	c3                   	ret
     891:	48 89 c3             	mov    %rax,%rbx
     894:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
     89a:	0f 85 00 00 00 00    	jne    0x8a0
     8a0:	49 83 ee 08          	sub    $0x8,%r14
     8a4:	49 8b 06             	mov    (%r14),%rax
     8a7:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     8ab:	e9 00 00 00 00       	jmp    0x8b0
     8b0:	48 89 c3             	mov    %rax,%rbx
     8b3:	83 e3 0f             	and    $0xf,%ebx
     8b6:	48 83 fb 05          	cmp    $0x5,%rbx
     8ba:	0f 85 00 00 00 00    	jne    0x8c0
     8c0:	48 bb 00 00 00 00 00 	movabs $0x0,%rbx
     8c7:	00 00 00 
     8ca:	49 83 c6 08          	add    $0x8,%r14
     8ce:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     8d2:	49 89 1e             	mov    %rbx,(%r14)
     8d5:	e8 00 00 00 00       	call   0x8da
     8da:	49 8b 06             	mov    (%r14),%rax
     8dd:	49 83 ee 08          	sub    $0x8,%r14
     8e1:	48 83 f8 01          	cmp    $0x1,%rax
     8e5:	0f 84 00 00 00 00    	je     0x8eb
     8eb:	49 83 ee 08          	sub    $0x8,%r14
     8ef:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x8f5
     8f5:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     8fc:	c3                   	ret
     8fd:	49 8b 06             	mov    (%r14),%rax
     900:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     904:	e9 00 00 00 00       	jmp    0x909
     909:	49 83 ee 08          	sub    $0x8,%r14
     90d:	49 8b 06             	mov    (%r14),%rax
     910:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     914:	49 8d 55 10          	lea    0x10(%r13),%rdx
     918:	48 8b 0a             	mov    (%rdx),%rcx
     91b:	48 83 c1 20          	add    $0x20,%rcx
     91f:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
     923:	0f 8e 00 00 00 00    	jle    0x929
     929:	48 89 5c 24 30       	mov    %rbx,0x30(%rsp)
     92e:	48 89 44 24 38       	mov    %rax,0x38(%rsp)
     933:	e8 00 00 00 00       	call   0x938
     938:	48 8b 5c 24 30       	mov    0x30(%rsp),%rbx
     93d:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
     942:	48 ba 00 00 00 00 00 	movabs $0x0,%rdx
     949:	00 00 00 
     94c:	49 8d 6d 10          	lea    0x10(%r13),%rbp
     950:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
     954:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
     95b:	48 83 c9 07          	or     $0x7,%rcx
     95f:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
     964:	48 89 51 01          	mov    %rdx,0x1(%rcx)
     968:	48 89 59 09          	mov    %rbx,0x9(%rcx)
     96c:	48 89 41 11          	mov    %rax,0x11(%rcx)
     970:	49 83 ee 08          	sub    $0x8,%r14
     974:	49 89 0e             	mov    %rcx,(%r14)
     977:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x97d
     97d:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     984:	c3                   	ret
     985:	48 8b 40 01          	mov    0x1(%rax),%rax
     989:	48 8b 40 0e          	mov    0xe(%rax),%rax
     98d:	48 bb 00 00 00 00 00 	movabs $0x0,%rbx
     994:	00 00 00 
     997:	48 39 d8             	cmp    %rbx,%rax
     99a:	0f 85 00 00 00 00    	jne    0x9a0
     9a0:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x9a6
     9a6:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     9ad:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x9b9
     9b4:	e9 00 00 00 00       	jmp    0x9b9
     9b9:	48 b8 00 00 00 00 00 	movabs $0x0,%rax
     9c0:	00 00 00 
     9c3:	49 83 c6 08          	add    $0x8,%r14
     9c7:	49 89 06             	mov    %rax,(%r14)
     9ca:	e8 00 00 00 00       	call   0x9cf
     9cf:	48 b8 00 00 00 00 00 	movabs $0x0,%rax
     9d6:	00 00 00 
     9d9:	49 83 c6 08          	add    $0x8,%r14
     9dd:	49 89 06             	mov    %rax,(%r14)
     9e0:	e8 00 00 00 00       	call   0x9e5
     9e5:	48 89 d9             	mov    %rbx,%rcx
     9e8:	83 e1 0f             	and    $0xf,%ecx
     9eb:	48 83 f9 07          	cmp    $0x7,%rcx
     9ef:	0f 85 00 00 00 00    	jne    0x9f5
     9f5:	48 8b 4b 01          	mov    0x1(%rbx),%rcx
     9f9:	48 8b 49 0e          	mov    0xe(%rcx),%rcx
     9fd:	48 ba 00 00 00 00 00 	movabs $0x0,%rdx
     a04:	00 00 00 
     a07:	48 39 d1             	cmp    %rdx,%rcx
     a0a:	0f 85 00 00 00 00    	jne    0xa10
     a10:	48 89 c1             	mov    %rax,%rcx
     a13:	f7 c1 0f 00 00 00    	test   $0xf,%ecx
     a19:	0f 85 00 00 00 00    	jne    0xa1f
     a1f:	48 8b 43 09          	mov    0x9(%rbx),%rax
     a23:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
     a27:	49 83 c7 08          	add    $0x8,%r15
     a2b:	49 89 1f             	mov    %rbx,(%r15)
     a2e:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     a32:	e8 00 00 00 00       	call   0xa37
     a37:	49 8b 07             	mov    (%r15),%rax
     a3a:	49 83 c6 10          	add    $0x10,%r14
     a3e:	49 83 ef 08          	sub    $0x8,%r15
     a42:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     a46:	49 c7 06 00 00 00 00 	movq   $0x0,(%r14)
     a4d:	e8 00 00 00 00       	call   0xa52
     a52:	49 8b 06             	mov    (%r14),%rax
     a55:	49 83 c6 08          	add    $0x8,%r14
     a59:	48 83 f8 00          	cmp    $0x0,%rax
     a5d:	0f 85 00 00 00 00    	jne    0xa63
     a63:	49 83 ee 08          	sub    $0x8,%r14
     a67:	49 83 ee 08          	sub    $0x8,%r14
     a6b:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0xa71
     a71:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     a78:	c3                   	ret
     a79:	48 89 c3             	mov    %rax,%rbx
     a7c:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
     a82:	0f 85 00 00 00 00    	jne    0xa88
     a88:	49 83 ee 08          	sub    $0x8,%r14
     a8c:	49 8b 06             	mov    (%r14),%rax
     a8f:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     a93:	e9 00 00 00 00       	jmp    0xa98
     a98:	48 89 c3             	mov    %rax,%rbx
     a9b:	83 e3 0f             	and    $0xf,%ebx
     a9e:	48 83 fb 05          	cmp    $0x5,%rbx
     aa2:	0f 85 00 00 00 00    	jne    0xaa8
     aa8:	48 bb 00 00 00 00 00 	movabs $0x0,%rbx
     aaf:	00 00 00 
     ab2:	49 83 c6 08          	add    $0x8,%r14
     ab6:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     aba:	49 89 1e             	mov    %rbx,(%r14)
     abd:	e8 00 00 00 00       	call   0xac2
     ac2:	49 8b 06             	mov    (%r14),%rax
     ac5:	49 83 ee 08          	sub    $0x8,%r14
     ac9:	48 83 f8 01          	cmp    $0x1,%rax
     acd:	0f 84 00 00 00 00    	je     0xad3
     ad3:	49 83 ee 08          	sub    $0x8,%r14
     ad7:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0xadd
     add:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     ae4:	c3                   	ret
     ae5:	49 8b 06             	mov    (%r14),%rax
     ae8:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     aec:	e9 00 00 00 00       	jmp    0xaf1
     af1:	49 83 ee 08          	sub    $0x8,%r14
     af5:	49 8b 06             	mov    (%r14),%rax
     af8:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     afc:	49 8d 55 10          	lea    0x10(%r13),%rdx
     b00:	48 8b 0a             	mov    (%rdx),%rcx
     b03:	48 83 c1 20          	add    $0x20,%rcx
     b07:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
     b0b:	0f 8e 00 00 00 00    	jle    0xb11
     b11:	48 89 5c 24 40       	mov    %rbx,0x40(%rsp)
     b16:	48 89 44 24 48       	mov    %rax,0x48(%rsp)
     b1b:	e8 00 00 00 00       	call   0xb20
     b20:	48 8b 5c 24 40       	mov    0x40(%rsp),%rbx
     b25:	48 8b 44 24 48       	mov    0x48(%rsp),%rax
     b2a:	48 ba 00 00 00 00 00 	movabs $0x0,%rdx
     b31:	00 00 00 
     b34:	49 8d 6d 10          	lea    0x10(%r13),%rbp
     b38:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
     b3c:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
     b43:	48 83 c9 07          	or     $0x7,%rcx
     b47:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
     b4c:	48 89 51 01          	mov    %rdx,0x1(%rcx)
     b50:	48 89 59 09          	mov    %rbx,0x9(%rcx)
     b54:	48 89 41 11          	mov    %rax,0x11(%rcx)
     b58:	49 83 ee 08          	sub    $0x8,%r14
     b5c:	49 89 0e             	mov    %rcx,(%r14)
     b5f:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0xb65
     b65:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     b6c:	c3                   	ret
     b6d:	48 89 c1             	mov    %rax,%rcx
     b70:	83 e1 0f             	and    $0xf,%ecx
     b73:	48 83 f9 03          	cmp    $0x3,%rcx
     b77:	0f 85 00 00 00 00    	jne    0xb7d
     b7d:	48 8b 4b 09          	mov    0x9(%rbx),%rcx
     b81:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
     b85:	49 83 ee 08          	sub    $0x8,%r14
     b89:	49 83 c7 10          	add    $0x10,%r15
     b8d:	49 89 07             	mov    %rax,(%r15)
     b90:	49 89 5f f8          	mov    %rbx,-0x8(%r15)
     b94:	49 89 0e             	mov    %rcx,(%r14)
     b97:	e8 00 00 00 00       	call   0xb9c
     b9c:	49 8d 45 10          	lea    0x10(%r13),%rax
     ba0:	48 8b 18             	mov    (%rax),%rbx
     ba3:	48 83 c3 10          	add    $0x10,%rbx
     ba7:	48 3b 58 10          	cmp    0x10(%rax),%rbx
     bab:	0f 8e 00 00 00 00    	jle    0xbb1
     bb1:	e8 00 00 00 00       	call   0xbb6
     bb6:	49 8b 1f             	mov    (%r15),%rbx
     bb9:	49 8b 0e             	mov    (%r14),%rcx
     bbc:	49 8b 47 f8          	mov    -0x8(%r15),%rax
     bc0:	f2 48 0f 10 41 05    	rex.W movsd 0x5(%rcx),%xmm0
     bc6:	f2 48 0f 10 4b 05    	rex.W movsd 0x5(%rbx),%xmm1
     bcc:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
     bd0:	49 8d 4d 10          	lea    0x10(%r13),%rcx
     bd4:	48 8b 19             	mov    (%rcx),%rbx
     bd7:	48 c7 03 0c 00 00 00 	movq   $0xc,(%rbx)
     bde:	48 83 cb 03          	or     $0x3,%rbx
     be2:	48 83 01 10          	addq   $0x10,(%rcx)
     be6:	f2 48 0f 11 43 05    	rex.W movsd %xmm0,0x5(%rbx)
     bec:	49 83 c6 10          	add    $0x10,%r14
     bf0:	49 83 ef 10          	sub    $0x10,%r15
     bf4:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     bf8:	49 c7 06 00 00 00 00 	movq   $0x0,(%r14)
     bff:	49 89 5e f0          	mov    %rbx,-0x10(%r14)
     c03:	e8 00 00 00 00       	call   0xc08
     c08:	49 8b 06             	mov    (%r14),%rax
     c0b:	49 83 c6 08          	add    $0x8,%r14
     c0f:	48 83 f8 00          	cmp    $0x0,%rax
     c13:	0f 85 00 00 00 00    	jne    0xc19
     c19:	49 83 ee 08          	sub    $0x8,%r14
     c1d:	49 83 ee 08          	sub    $0x8,%r14
     c21:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0xc27
     c27:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     c2e:	c3                   	ret
     c2f:	48 89 c3             	mov    %rax,%rbx
     c32:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
     c38:	0f 85 00 00 00 00    	jne    0xc3e
     c3e:	49 83 ee 08          	sub    $0x8,%r14
     c42:	49 8b 06             	mov    (%r14),%rax
     c45:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     c49:	e9 00 00 00 00       	jmp    0xc4e
     c4e:	48 89 c3             	mov    %rax,%rbx
     c51:	83 e3 0f             	and    $0xf,%ebx
     c54:	48 83 fb 05          	cmp    $0x5,%rbx
     c58:	0f 85 00 00 00 00    	jne    0xc5e
     c5e:	48 bb 00 00 00 00 00 	movabs $0x0,%rbx
     c65:	00 00 00 
     c68:	49 83 c6 08          	add    $0x8,%r14
     c6c:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     c70:	49 89 1e             	mov    %rbx,(%r14)
     c73:	e8 00 00 00 00       	call   0xc78
     c78:	49 8b 06             	mov    (%r14),%rax
     c7b:	49 83 ee 08          	sub    $0x8,%r14
     c7f:	48 83 f8 01          	cmp    $0x1,%rax
     c83:	0f 84 00 00 00 00    	je     0xc89
     c89:	49 83 ee 08          	sub    $0x8,%r14
     c8d:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0xc93
     c93:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     c9a:	c3                   	ret
     c9b:	49 8b 06             	mov    (%r14),%rax
     c9e:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     ca2:	e9 00 00 00 00       	jmp    0xca7
     ca7:	49 83 ee 08          	sub    $0x8,%r14
     cab:	49 8b 06             	mov    (%r14),%rax
     cae:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     cb2:	49 8d 55 10          	lea    0x10(%r13),%rdx
     cb6:	48 8b 0a             	mov    (%rdx),%rcx
     cb9:	48 83 c1 20          	add    $0x20,%rcx
     cbd:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
     cc1:	0f 8e 00 00 00 00    	jle    0xcc7
     cc7:	48 89 5c 24 50       	mov    %rbx,0x50(%rsp)
     ccc:	48 89 44 24 58       	mov    %rax,0x58(%rsp)
     cd1:	e8 00 00 00 00       	call   0xcd6
     cd6:	48 8b 5c 24 50       	mov    0x50(%rsp),%rbx
     cdb:	48 8b 44 24 58       	mov    0x58(%rsp),%rax
     ce0:	48 ba 00 00 00 00 00 	movabs $0x0,%rdx
     ce7:	00 00 00 
     cea:	49 8d 6d 10          	lea    0x10(%r13),%rbp
     cee:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
     cf2:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
     cf9:	48 83 c9 07          	or     $0x7,%rcx
     cfd:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
     d02:	48 89 51 01          	mov    %rdx,0x1(%rcx)
     d06:	48 89 59 09          	mov    %rbx,0x9(%rcx)
     d0a:	48 89 41 11          	mov    %rax,0x11(%rcx)
     d0e:	49 83 ee 08          	sub    $0x8,%r14
     d12:	49 89 0e             	mov    %rcx,(%r14)
     d15:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0xd1b
     d1b:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     d22:	c3                   	ret
     d23:	48 89 c1             	mov    %rax,%rcx
     d26:	83 e1 0f             	and    $0xf,%ecx
     d29:	48 83 f9 05          	cmp    $0x5,%rcx
     d2d:	0f 85 00 00 00 00    	jne    0xd33
     d33:	48 8b 43 09          	mov    0x9(%rbx),%rax
     d37:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
     d3b:	49 83 c7 08          	add    $0x8,%r15
     d3f:	49 89 1f             	mov    %rbx,(%r15)
     d42:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     d46:	e8 00 00 00 00       	call   0xd4b
     d4b:	49 8b 07             	mov    (%r15),%rax
     d4e:	49 83 c6 10          	add    $0x10,%r14
     d52:	49 83 ef 08          	sub    $0x8,%r15
     d56:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     d5a:	49 c7 06 00 00 00 00 	movq   $0x0,(%r14)
     d61:	e8 00 00 00 00       	call   0xd66
     d66:	49 8b 06             	mov    (%r14),%rax
     d69:	49 83 c6 08          	add    $0x8,%r14
     d6d:	48 83 f8 00          	cmp    $0x0,%rax
     d71:	0f 85 00 00 00 00    	jne    0xd77
     d77:	49 83 ee 08          	sub    $0x8,%r14
     d7b:	49 83 ee 08          	sub    $0x8,%r14
     d7f:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0xd85
     d85:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     d8c:	c3                   	ret
     d8d:	48 89 c3             	mov    %rax,%rbx
     d90:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
     d96:	0f 85 00 00 00 00    	jne    0xd9c
     d9c:	49 83 ee 08          	sub    $0x8,%r14
     da0:	49 8b 06             	mov    (%r14),%rax
     da3:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     da7:	e9 00 00 00 00       	jmp    0xdac
     dac:	48 89 c3             	mov    %rax,%rbx
     daf:	83 e3 0f             	and    $0xf,%ebx
     db2:	48 83 fb 05          	cmp    $0x5,%rbx
     db6:	0f 85 00 00 00 00    	jne    0xdbc
     dbc:	48 bb 00 00 00 00 00 	movabs $0x0,%rbx
     dc3:	00 00 00 
     dc6:	49 83 c6 08          	add    $0x8,%r14
     dca:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     dce:	49 89 1e             	mov    %rbx,(%r14)
     dd1:	e8 00 00 00 00       	call   0xdd6
     dd6:	49 8b 06             	mov    (%r14),%rax
     dd9:	49 83 ee 08          	sub    $0x8,%r14
     ddd:	48 83 f8 01          	cmp    $0x1,%rax
     de1:	0f 84 00 00 00 00    	je     0xde7
     de7:	49 83 ee 08          	sub    $0x8,%r14
     deb:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0xdf1
     df1:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     df8:	c3                   	ret
     df9:	49 8b 06             	mov    (%r14),%rax
     dfc:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     e00:	e9 00 00 00 00       	jmp    0xe05
     e05:	49 83 ee 08          	sub    $0x8,%r14
     e09:	49 8b 06             	mov    (%r14),%rax
     e0c:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     e10:	49 8d 55 10          	lea    0x10(%r13),%rdx
     e14:	48 8b 0a             	mov    (%rdx),%rcx
     e17:	48 83 c1 20          	add    $0x20,%rcx
     e1b:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
     e1f:	0f 8e 00 00 00 00    	jle    0xe25
     e25:	48 89 5c 24 60       	mov    %rbx,0x60(%rsp)
     e2a:	48 89 44 24 68       	mov    %rax,0x68(%rsp)
     e2f:	e8 00 00 00 00       	call   0xe34
     e34:	48 8b 5c 24 60       	mov    0x60(%rsp),%rbx
     e39:	48 8b 44 24 68       	mov    0x68(%rsp),%rax
     e3e:	48 ba 00 00 00 00 00 	movabs $0x0,%rdx
     e45:	00 00 00 
     e48:	49 8d 6d 10          	lea    0x10(%r13),%rbp
     e4c:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
     e50:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
     e57:	48 83 c9 07          	or     $0x7,%rcx
     e5b:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
     e60:	48 89 51 01          	mov    %rdx,0x1(%rcx)
     e64:	48 89 59 09          	mov    %rbx,0x9(%rcx)
     e68:	48 89 41 11          	mov    %rax,0x11(%rcx)
     e6c:	49 83 ee 08          	sub    $0x8,%r14
     e70:	49 89 0e             	mov    %rcx,(%r14)
     e73:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0xe79
     e79:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     e80:	c3                   	ret
     e81:	48 89 c1             	mov    %rax,%rcx
     e84:	83 e1 0f             	and    $0xf,%ecx
     e87:	48 83 f9 07          	cmp    $0x7,%rcx
     e8b:	0f 85 00 00 00 00    	jne    0xe91
     e91:	48 8b 48 01          	mov    0x1(%rax),%rcx
     e95:	48 8b 49 0e          	mov    0xe(%rcx),%rcx
     e99:	48 ba 00 00 00 00 00 	movabs $0x0,%rdx
     ea0:	00 00 00 
     ea3:	48 39 d1             	cmp    %rdx,%rcx
     ea6:	0f 85 00 00 00 00    	jne    0xeac
     eac:	48 8b 4b 09          	mov    0x9(%rbx),%rcx
     eb0:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
     eb4:	48 8b 50 09          	mov    0x9(%rax),%rdx
     eb8:	48 8b 40 11          	mov    0x11(%rax),%rax
     ebc:	49 83 c7 10          	add    $0x10,%r15
     ec0:	49 89 47 f8          	mov    %rax,-0x8(%r15)
     ec4:	49 89 4e f8          	mov    %rcx,-0x8(%r14)
     ec8:	49 89 16             	mov    %rdx,(%r14)
     ecb:	49 89 1f             	mov    %rbx,(%r15)
     ece:	e8 00 00 00 00       	call   0xed3
     ed3:	49 8b 07             	mov    (%r15),%rax
     ed6:	49 8b 5f f8          	mov    -0x8(%r15),%rbx
     eda:	49 83 c6 10          	add    $0x10,%r14
     ede:	49 83 ef 10          	sub    $0x10,%r15
     ee2:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     ee6:	49 89 1e             	mov    %rbx,(%r14)
     ee9:	e8 00 00 00 00       	call   0xeee
     eee:	49 8b 06             	mov    (%r14),%rax
     ef1:	49 83 c6 08          	add    $0x8,%r14
     ef5:	48 83 f8 00          	cmp    $0x0,%rax
     ef9:	0f 85 00 00 00 00    	jne    0xeff
     eff:	49 83 ee 08          	sub    $0x8,%r14
     f03:	49 83 ee 08          	sub    $0x8,%r14
     f07:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0xf0d
     f0d:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     f14:	c3                   	ret
     f15:	48 89 c3             	mov    %rax,%rbx
     f18:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
     f1e:	0f 85 00 00 00 00    	jne    0xf24
     f24:	49 83 ee 08          	sub    $0x8,%r14
     f28:	49 8b 06             	mov    (%r14),%rax
     f2b:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     f2f:	e9 00 00 00 00       	jmp    0xf34
     f34:	48 89 c3             	mov    %rax,%rbx
     f37:	83 e3 0f             	and    $0xf,%ebx
     f3a:	48 83 fb 05          	cmp    $0x5,%rbx
     f3e:	0f 85 00 00 00 00    	jne    0xf44
     f44:	48 bb 00 00 00 00 00 	movabs $0x0,%rbx
     f4b:	00 00 00 
     f4e:	49 83 c6 08          	add    $0x8,%r14
     f52:	49 89 46 f8          	mov    %rax,-0x8(%r14)
     f56:	49 89 1e             	mov    %rbx,(%r14)
     f59:	e8 00 00 00 00       	call   0xf5e
     f5e:	49 8b 06             	mov    (%r14),%rax
     f61:	49 83 ee 08          	sub    $0x8,%r14
     f65:	48 83 f8 01          	cmp    $0x1,%rax
     f69:	0f 84 00 00 00 00    	je     0xf6f
     f6f:	49 83 ee 08          	sub    $0x8,%r14
     f73:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0xf79
     f79:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
     f80:	c3                   	ret
     f81:	49 8b 06             	mov    (%r14),%rax
     f84:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     f88:	e9 00 00 00 00       	jmp    0xf8d
     f8d:	49 83 ee 08          	sub    $0x8,%r14
     f91:	49 8b 06             	mov    (%r14),%rax
     f94:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
     f98:	49 8d 55 10          	lea    0x10(%r13),%rdx
     f9c:	48 8b 0a             	mov    (%rdx),%rcx
     f9f:	48 83 c1 20          	add    $0x20,%rcx
     fa3:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
     fa7:	0f 8e 00 00 00 00    	jle    0xfad
     fad:	48 89 5c 24 70       	mov    %rbx,0x70(%rsp)
     fb2:	48 89 44 24 78       	mov    %rax,0x78(%rsp)
     fb7:	e8 00 00 00 00       	call   0xfbc
     fbc:	48 8b 5c 24 70       	mov    0x70(%rsp),%rbx
     fc1:	48 8b 44 24 78       	mov    0x78(%rsp),%rax
     fc6:	48 ba 00 00 00 00 00 	movabs $0x0,%rdx
     fcd:	00 00 00 
     fd0:	49 8d 6d 10          	lea    0x10(%r13),%rbp
     fd4:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
     fd8:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
     fdf:	48 83 c9 07          	or     $0x7,%rcx
     fe3:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
     fe8:	48 89 51 01          	mov    %rdx,0x1(%rcx)
     fec:	48 89 59 09          	mov    %rbx,0x9(%rcx)
     ff0:	48 89 41 11          	mov    %rax,0x11(%rcx)
     ff4:	49 83 ee 08          	sub    $0x8,%r14
     ff8:	49 89 0e             	mov    %rcx,(%r14)
     ffb:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x1001
    1001:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    1008:	c3                   	ret
    1009:	48 8b 40 01          	mov    0x1(%rax),%rax
    100d:	48 8b 40 0e          	mov    0xe(%rax),%rax
    1011:	48 b9 00 00 00 00 00 	movabs $0x0,%rcx
    1018:	00 00 00 
    101b:	48 39 c8             	cmp    %rcx,%rax
    101e:	0f 85 00 00 00 00    	jne    0x1024
    1024:	48 8b 43 09          	mov    0x9(%rbx),%rax
    1028:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
    102c:	49 83 c7 08          	add    $0x8,%r15
    1030:	49 89 1f             	mov    %rbx,(%r15)
    1033:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    1037:	e8 00 00 00 00       	call   0x103c
    103c:	49 8b 07             	mov    (%r15),%rax
    103f:	49 83 c6 10          	add    $0x10,%r14
    1043:	49 83 ef 08          	sub    $0x8,%r15
    1047:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    104b:	49 c7 06 00 00 00 00 	movq   $0x0,(%r14)
    1052:	e8 00 00 00 00       	call   0x1057
    1057:	49 8b 06             	mov    (%r14),%rax
    105a:	49 83 c6 08          	add    $0x8,%r14
    105e:	48 83 f8 00          	cmp    $0x0,%rax
    1062:	0f 85 00 00 00 00    	jne    0x1068
    1068:	49 83 ee 08          	sub    $0x8,%r14
    106c:	49 83 ee 08          	sub    $0x8,%r14
    1070:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x1076
    1076:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    107d:	c3                   	ret
    107e:	48 89 c3             	mov    %rax,%rbx
    1081:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    1087:	0f 85 00 00 00 00    	jne    0x108d
    108d:	49 83 ee 08          	sub    $0x8,%r14
    1091:	49 8b 06             	mov    (%r14),%rax
    1094:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    1098:	e9 00 00 00 00       	jmp    0x109d
    109d:	48 89 c3             	mov    %rax,%rbx
    10a0:	83 e3 0f             	and    $0xf,%ebx
    10a3:	48 83 fb 05          	cmp    $0x5,%rbx
    10a7:	0f 85 00 00 00 00    	jne    0x10ad
    10ad:	48 bb 00 00 00 00 00 	movabs $0x0,%rbx
    10b4:	00 00 00 
    10b7:	49 83 c6 08          	add    $0x8,%r14
    10bb:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    10bf:	49 89 1e             	mov    %rbx,(%r14)
    10c2:	e8 00 00 00 00       	call   0x10c7
    10c7:	49 8b 06             	mov    (%r14),%rax
    10ca:	49 83 ee 08          	sub    $0x8,%r14
    10ce:	48 83 f8 01          	cmp    $0x1,%rax
    10d2:	0f 84 00 00 00 00    	je     0x10d8
    10d8:	49 83 ee 08          	sub    $0x8,%r14
    10dc:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x10e2
    10e2:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    10e9:	c3                   	ret
    10ea:	49 8b 06             	mov    (%r14),%rax
    10ed:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    10f1:	e9 00 00 00 00       	jmp    0x10f6
    10f6:	49 83 ee 08          	sub    $0x8,%r14
    10fa:	49 8b 06             	mov    (%r14),%rax
    10fd:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    1101:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    1105:	48 8b 11             	mov    (%rcx),%rdx
    1108:	48 83 c2 20          	add    $0x20,%rdx
    110c:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    1110:	0f 8e 00 00 00 00    	jle    0x1116
    1116:	48 89 9c 24 80 00 00 	mov    %rbx,0x80(%rsp)
    111d:	00 
    111e:	48 89 84 24 88 00 00 	mov    %rax,0x88(%rsp)
    1125:	00 
    1126:	e8 00 00 00 00       	call   0x112b
    112b:	48 8b 9c 24 80 00 00 	mov    0x80(%rsp),%rbx
    1132:	00 
    1133:	48 8b 84 24 88 00 00 	mov    0x88(%rsp),%rax
    113a:	00 
    113b:	48 ba 00 00 00 00 00 	movabs $0x0,%rdx
    1142:	00 00 00 
    1145:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    1149:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    114d:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    1154:	48 83 c9 07          	or     $0x7,%rcx
    1158:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    115d:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    1161:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    1165:	48 89 41 11          	mov    %rax,0x11(%rcx)
    1169:	49 83 ee 08          	sub    $0x8,%r14
    116d:	49 89 0e             	mov    %rcx,(%r14)
    1170:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x1176
    1176:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    117d:	c3                   	ret
    117e:	48 b8 00 00 00 00 00 	movabs $0x0,%rax
    1185:	00 00 00 
    1188:	49 83 c6 08          	add    $0x8,%r14
    118c:	49 89 06             	mov    %rax,(%r14)
    118f:	e8 00 00 00 00       	call   0x1194
    1194:	48 b8 00 00 00 00 00 	movabs $0x0,%rax
    119b:	00 00 00 
    119e:	49 83 c6 08          	add    $0x8,%r14
    11a2:	49 89 06             	mov    %rax,(%r14)
    11a5:	e8 00 00 00 00       	call   0x11aa
    11aa:	48 8b 5b 01          	mov    0x1(%rbx),%rbx
    11ae:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
    11b2:	48 b9 00 00 00 00 00 	movabs $0x0,%rcx
    11b9:	00 00 00 
    11bc:	48 39 cb             	cmp    %rcx,%rbx
    11bf:	0f 85 00 00 00 00    	jne    0x11c5
    11c5:	48 89 c3             	mov    %rax,%rbx
    11c8:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    11ce:	0f 85 00 00 00 00    	jne    0x11d4
    11d4:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x11da
    11da:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    11e1:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x11ed
    11e8:	e9 00 00 00 00       	jmp    0x11ed
    11ed:	48 89 c3             	mov    %rax,%rbx
    11f0:	83 e3 0f             	and    $0xf,%ebx
    11f3:	48 83 fb 03          	cmp    $0x3,%rbx
    11f7:	0f 85 00 00 00 00    	jne    0x11fd
    11fd:	49 83 ee 08          	sub    $0x8,%r14
    1201:	49 83 c7 08          	add    $0x8,%r15
    1205:	49 89 07             	mov    %rax,(%r15)
    1208:	e8 00 00 00 00       	call   0x120d
    120d:	49 8d 45 10          	lea    0x10(%r13),%rax
    1211:	48 8b 18             	mov    (%rax),%rbx
    1214:	48 83 c3 10          	add    $0x10,%rbx
    1218:	48 3b 58 10          	cmp    0x10(%rax),%rbx
    121c:	0f 8e 00 00 00 00    	jle    0x1222
    1222:	e8 00 00 00 00       	call   0x1227
    1227:	49 8b 07             	mov    (%r15),%rax
    122a:	49 8b 1e             	mov    (%r14),%rbx
    122d:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
    1233:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
    1239:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    123d:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    1241:	48 8b 03             	mov    (%rbx),%rax
    1244:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    124b:	48 83 c8 03          	or     $0x3,%rax
    124f:	48 83 03 10          	addq   $0x10,(%rbx)
    1253:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    1259:	49 83 ef 08          	sub    $0x8,%r15
    125d:	49 89 06             	mov    %rax,(%r14)
    1260:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x1266
    1266:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    126d:	c3                   	ret
    126e:	48 89 c3             	mov    %rax,%rbx
    1271:	83 e3 0f             	and    $0xf,%ebx
    1274:	48 83 fb 05          	cmp    $0x5,%rbx
    1278:	0f 85 00 00 00 00    	jne    0x127e
    127e:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x1284
    1284:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    128b:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x1297
    1292:	e9 00 00 00 00       	jmp    0x1297
    1297:	48 89 c3             	mov    %rax,%rbx
    129a:	83 e3 0f             	and    $0xf,%ebx
    129d:	48 83 fb 07          	cmp    $0x7,%rbx
    12a1:	0f 85 00 00 00 00    	jne    0x12a7
    12a7:	48 8b 58 01          	mov    0x1(%rax),%rbx
    12ab:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
    12af:	48 b9 00 00 00 00 00 	movabs $0x0,%rcx
    12b6:	00 00 00 
    12b9:	48 39 cb             	cmp    %rcx,%rbx
    12bc:	0f 85 00 00 00 00    	jne    0x12c2
    12c2:	48 8b 58 09          	mov    0x9(%rax),%rbx
    12c6:	48 8b 40 11          	mov    0x11(%rax),%rax
    12ca:	49 83 c7 10          	add    $0x10,%r15
    12ce:	49 89 47 f8          	mov    %rax,-0x8(%r15)
    12d2:	49 89 1e             	mov    %rbx,(%r14)
    12d5:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
    12dc:	e8 00 00 00 00       	call   0x12e1
    12e1:	49 8b 07             	mov    (%r15),%rax
    12e4:	49 8b 5f f8          	mov    -0x8(%r15),%rbx
    12e8:	49 83 c6 10          	add    $0x10,%r14
    12ec:	49 83 ef 10          	sub    $0x10,%r15
    12f0:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    12f4:	49 89 1e             	mov    %rbx,(%r14)
    12f7:	e8 00 00 00 00       	call   0x12fc
    12fc:	49 8b 06             	mov    (%r14),%rax
    12ff:	49 83 c6 08          	add    $0x8,%r14
    1303:	48 83 f8 00          	cmp    $0x0,%rax
    1307:	0f 85 00 00 00 00    	jne    0x130d
    130d:	49 83 ee 08          	sub    $0x8,%r14
    1311:	49 83 ee 08          	sub    $0x8,%r14
    1315:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x131b
    131b:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    1322:	c3                   	ret
    1323:	48 89 c3             	mov    %rax,%rbx
    1326:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    132c:	0f 85 00 00 00 00    	jne    0x1332
    1332:	49 83 ee 08          	sub    $0x8,%r14
    1336:	49 8b 06             	mov    (%r14),%rax
    1339:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    133d:	e9 00 00 00 00       	jmp    0x1342
    1342:	48 89 c3             	mov    %rax,%rbx
    1345:	83 e3 0f             	and    $0xf,%ebx
    1348:	48 83 fb 05          	cmp    $0x5,%rbx
    134c:	0f 85 00 00 00 00    	jne    0x1352
    1352:	48 bb 00 00 00 00 00 	movabs $0x0,%rbx
    1359:	00 00 00 
    135c:	49 83 c6 08          	add    $0x8,%r14
    1360:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    1364:	49 89 1e             	mov    %rbx,(%r14)
    1367:	e8 00 00 00 00       	call   0x136c
    136c:	49 8b 06             	mov    (%r14),%rax
    136f:	49 83 ee 08          	sub    $0x8,%r14
    1373:	48 83 f8 01          	cmp    $0x1,%rax
    1377:	0f 84 00 00 00 00    	je     0x137d
    137d:	49 83 ee 08          	sub    $0x8,%r14
    1381:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x1387
    1387:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    138e:	c3                   	ret
    138f:	49 8b 06             	mov    (%r14),%rax
    1392:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    1396:	e9 00 00 00 00       	jmp    0x139b
    139b:	49 83 ee 08          	sub    $0x8,%r14
    139f:	49 8b 06             	mov    (%r14),%rax
    13a2:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    13a6:	49 8d 55 10          	lea    0x10(%r13),%rdx
    13aa:	48 8b 0a             	mov    (%rdx),%rcx
    13ad:	48 83 c1 20          	add    $0x20,%rcx
    13b1:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
    13b5:	0f 8e 00 00 00 00    	jle    0x13bb
    13bb:	48 89 9c 24 90 00 00 	mov    %rbx,0x90(%rsp)
    13c2:	00 
    13c3:	48 89 84 24 98 00 00 	mov    %rax,0x98(%rsp)
    13ca:	00 
    13cb:	e8 00 00 00 00       	call   0x13d0
    13d0:	48 8b 9c 24 90 00 00 	mov    0x90(%rsp),%rbx
    13d7:	00 
    13d8:	48 8b 84 24 98 00 00 	mov    0x98(%rsp),%rax
    13df:	00 
    13e0:	48 ba 00 00 00 00 00 	movabs $0x0,%rdx
    13e7:	00 00 00 
    13ea:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    13ee:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    13f2:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    13f9:	48 83 c9 07          	or     $0x7,%rcx
    13fd:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    1402:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    1406:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    140a:	48 89 41 11          	mov    %rax,0x11(%rcx)
    140e:	49 83 ee 08          	sub    $0x8,%r14
    1412:	49 89 0e             	mov    %rcx,(%r14)
    1415:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x141b
    141b:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    1422:	c3                   	ret
    1423:	48 8b 40 01          	mov    0x1(%rax),%rax
    1427:	48 8b 40 0e          	mov    0xe(%rax),%rax
    142b:	48 bb 00 00 00 00 00 	movabs $0x0,%rbx
    1432:	00 00 00 
    1435:	48 39 d8             	cmp    %rbx,%rax
    1438:	0f 85 00 00 00 00    	jne    0x143e
    143e:	89 05 00 00 00 00    	mov    %eax,0x0(%rip)        # 0x1444
    1444:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    144b:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x1457
    1452:	e9 00 00 00 00       	jmp    0x1457
    1457:	48 b8 00 00 00 00 00 	movabs $0x0,%rax
    145e:	00 00 00 
    1461:	49 83 c6 08          	add    $0x8,%r14
    1465:	49 89 06             	mov    %rax,(%r14)
    1468:	e8 00 00 00 00       	call   0x146d
    146d:	48 b8 00 00 00 00 00 	movabs $0x0,%rax
    1474:	00 00 00 
    1477:	49 83 c6 08          	add    $0x8,%r14
    147b:	49 89 06             	mov    %rax,(%r14)
    147e:	e8 00 00 00 00       	call   0x1483
    1483:	48 b8 00 00 00 00 00 	movabs $0x0,%rax
    148a:	00 00 00 
    148d:	49 83 c6 08          	add    $0x8,%r14
    1491:	49 89 06             	mov    %rax,(%r14)
    1494:	e8 00 00 00 00       	call   0x1499
    1499:	48 b8 00 00 00 00 00 	movabs $0x0,%rax
    14a0:	00 00 00 
    14a3:	49 83 c6 08          	add    $0x8,%r14
    14a7:	49 89 06             	mov    %rax,(%r14)
    14aa:	e8 00 00 00 00       	call   0x14af
    14af:	00 00                	add    %al,(%rax)
    14b1:	00 00                	add    %al,(%rax)
    14b3:	00 06                	add    %al,(%rsi)
    14b5:	00 00                	add    %al,(%rax)
    14b7:	03 00                	add    (%rax),%eax
    14b9:	18 00                	sbb    %al,(%rax)
    14bb:	00 03                	add    %al,(%rbx)
    14bd:	00 00                	add    %al,(%rax)
    14bf:	06                   	(bad)
    14c0:	00 00                	add    %al,(%rax)
    14c2:	03 00                	add    (%rax),%eax
    14c4:	80 01 00             	addb   $0x0,(%rcx)
    14c7:	c0 00 00             	rolb   $0x0,(%rax)
    14ca:	60                   	(bad)
    14cb:	00 00                	add    %al,(%rax)
    14cd:	30 00                	xor    %al,(%rax)
    14cf:	00 18                	add    %bl,(%rax)
    14d1:	00 00                	add    %al,(%rax)
    14d3:	0c a2                	or     $0xa2,%al
    14d5:	00 00                	add    %al,(%rax)
    14d7:	00 6c 02 00          	add    %ch,0x0(%rdx,%rax,1)
    14db:	00 5b 03             	add    %bl,0x3(%rbx)
    14de:	00 00                	add    %al,(%rax)
    14e0:	de 03                	fiadds (%rbx)
    14e2:	00 00                	add    %al,(%rax)
    14e4:	23 06                	and    (%rsi),%eax
    14e6:	00 00                	add    %al,(%rax)
    14e8:	38 09                	cmp    %cl,(%rcx)
    14ea:	00 00                	add    %al,(%rax)
    14ec:	20 0b                	and    %cl,(%rbx)
    14ee:	00 00                	add    %al,(%rax)
    14f0:	d6                   	udb
    14f1:	0c 00                	or     $0x0,%al
    14f3:	00 34 0e             	add    %dh,(%rsi,%rcx,1)
    14f6:	00 00                	add    %al,(%rax)
    14f8:	bc 0f 00 00 2b       	mov    $0x2b00000f,%esp
    14fd:	11 00                	adc    %eax,(%rax)
    14ff:	00 d0                	add    %dl,%al
    1501:	13 00                	adc    (%rax),%eax
    1503:	00 15 00 00 00 00    	add    %dl,0x0(%rip)        # 0x1509
    1509:	00 00                	add    %al,(%rax)
    150b:	00 0c 00             	add    %cl,(%rax,%rax,1)
	...
