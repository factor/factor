
/home/erg/factor-compiler-next-final-c6948-20260909/reference/compiler-next-20260909/installed-math_plus.bin:     file format binary


Disassembly of section .data:

000070610f3f0160 <.data>:
    70610f3f0160:	89 05 9a 3e 16 13    	mov    %eax,0x13163e9a(%rip)        # 0x706122554000
    70610f3f0166:	48 81 ec a8 00 00 00 	sub    $0xa8,%rsp
    70610f3f016d:	49 8b 06             	mov    (%r14),%rax
    70610f3f0170:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0174:	48 89 d9             	mov    %rbx,%rcx
    70610f3f0177:	48 89 c2             	mov    %rax,%rdx
    70610f3f017a:	48 09 d1             	or     %rdx,%rcx
    70610f3f017d:	f7 c1 0f 00 00 00    	test   $0xf,%ecx
    70610f3f0183:	0f 85 37 00 00 00    	jne    0x70610f3f01c0
    70610f3f0189:	48 01 c3             	add    %rax,%rbx
    70610f3f018c:	0f 80 15 00 00 00    	jo     0x70610f3f01a7
    70610f3f0192:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0196:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f0199:	89 05 61 3e 16 13    	mov    %eax,0x13163e61(%rip)        # 0x706122554000
    70610f3f019f:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f01a6:	c3                   	ret
    70610f3f01a7:	89 05 53 3e 16 13    	mov    %eax,0x13163e53(%rip)        # 0x706122554000
    70610f3f01ad:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f01b4:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x70610f3f01c0
    70610f3f01bb:	e9 50 a6 f4 fe       	jmp    0x70610e33a810
    70610f3f01c0:	48 89 d9             	mov    %rbx,%rcx
    70610f3f01c3:	f7 c1 0f 00 00 00    	test   $0xf,%ecx
    70610f3f01c9:	0f 85 aa 02 00 00    	jne    0x70610f3f0479
    70610f3f01cf:	48 89 c1             	mov    %rax,%rcx
    70610f3f01d2:	83 e1 0f             	and    $0xf,%ecx
    70610f3f01d5:	48 83 f9 03          	cmp    $0x3,%rcx
    70610f3f01d9:	0f 85 73 00 00 00    	jne    0x70610f3f0252
    70610f3f01df:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    70610f3f01e3:	48 8b 11             	mov    (%rcx),%rdx
    70610f3f01e6:	48 83 c2 10          	add    $0x10,%rdx
    70610f3f01ea:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    70610f3f01ee:	0f 8e 17 00 00 00    	jle    0x70610f3f020b
    70610f3f01f4:	48 89 1c 24          	mov    %rbx,(%rsp)
    70610f3f01f8:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    70610f3f01fd:	e8 fe 88 06 00       	call   0x70610f458b00
    70610f3f0202:	48 8b 1c 24          	mov    (%rsp),%rbx
    70610f3f0206:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
    70610f3f020b:	48 c1 fb 04          	sar    $0x4,%rbx
    70610f3f020f:	0f 57 c0             	xorps  %xmm0,%xmm0
    70610f3f0212:	f2 48 0f 2a c3       	cvtsi2sd %rbx,%xmm0
    70610f3f0217:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
    70610f3f021d:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    70610f3f0221:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    70610f3f0225:	48 8b 03             	mov    (%rbx),%rax
    70610f3f0228:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    70610f3f022f:	48 83 c8 03          	or     $0x3,%rax
    70610f3f0233:	48 83 03 10          	addq   $0x10,(%rbx)
    70610f3f0237:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    70610f3f023d:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0241:	49 89 06             	mov    %rax,(%r14)
    70610f3f0244:	89 05 b6 3d 16 13    	mov    %eax,0x13163db6(%rip)        # 0x706122554000
    70610f3f024a:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0251:	c3                   	ret
    70610f3f0252:	48 89 c3             	mov    %rax,%rbx
    70610f3f0255:	83 e3 0f             	and    $0xf,%ebx
    70610f3f0258:	48 83 fb 05          	cmp    $0x5,%rbx
    70610f3f025c:	0f 85 37 00 00 00    	jne    0x70610f3f0299
    70610f3f0262:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0266:	49 83 c7 08          	add    $0x8,%r15
    70610f3f026a:	49 89 07             	mov    %rax,(%r15)
    70610f3f026d:	e8 ae d4 43 00       	call   0x70610f82d720
    70610f3f0272:	49 8b 07             	mov    (%r15),%rax
    70610f3f0275:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0279:	49 83 ef 08          	sub    $0x8,%r15
    70610f3f027d:	49 89 06             	mov    %rax,(%r14)
    70610f3f0280:	89 05 7a 3d 16 13    	mov    %eax,0x13163d7a(%rip)        # 0x706122554000
    70610f3f0286:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f028d:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x70610f3f0299
    70610f3f0294:	e9 47 ba 36 00       	jmp    0x70610f75bce0
    70610f3f0299:	48 89 c3             	mov    %rax,%rbx
    70610f3f029c:	83 e3 0f             	and    $0xf,%ebx
    70610f3f029f:	48 83 fb 07          	cmp    $0x7,%rbx
    70610f3f02a3:	0f 85 ba 01 00 00    	jne    0x70610f3f0463
    70610f3f02a9:	48 8b 58 01          	mov    0x1(%rax),%rbx
    70610f3f02ad:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
    70610f3f02b1:	48 b9 8c a0 9c 14 61 	movabs $0x7061149ca08c,%rcx
    70610f3f02b8:	70 00 00 
    70610f3f02bb:	48 39 cb             	cmp    %rcx,%rbx
    70610f3f02be:	0f 85 55 01 00 00    	jne    0x70610f3f0419
    70610f3f02c4:	48 8b 58 09          	mov    0x9(%rax),%rbx
    70610f3f02c8:	48 8b 40 11          	mov    0x11(%rax),%rax
    70610f3f02cc:	49 83 c7 10          	add    $0x10,%r15
    70610f3f02d0:	49 89 47 f8          	mov    %rax,-0x8(%r15)
    70610f3f02d4:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f02d7:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
    70610f3f02de:	e8 7d fe ff ff       	call   0x70610f3f0160
    70610f3f02e3:	49 8b 1f             	mov    (%r15),%rbx
    70610f3f02e6:	49 8b 47 f8          	mov    -0x8(%r15),%rax
    70610f3f02ea:	49 83 c6 10          	add    $0x10,%r14
    70610f3f02ee:	49 83 ef 10          	sub    $0x10,%r15
    70610f3f02f2:	49 89 5e f8          	mov    %rbx,-0x8(%r14)
    70610f3f02f6:	49 89 06             	mov    %rax,(%r14)
    70610f3f02f9:	e8 62 fe ff ff       	call   0x70610f3f0160
    70610f3f02fe:	49 8b 06             	mov    (%r14),%rax
    70610f3f0301:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0305:	48 83 f8 00          	cmp    $0x0,%rax
    70610f3f0309:	0f 85 16 00 00 00    	jne    0x70610f3f0325
    70610f3f030f:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0313:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0317:	89 05 e3 3c 16 13    	mov    %eax,0x13163ce3(%rip)        # 0x706122554000
    70610f3f031d:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0324:	c3                   	ret
    70610f3f0325:	48 89 c3             	mov    %rax,%rbx
    70610f3f0328:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    70610f3f032e:	0f 85 10 00 00 00    	jne    0x70610f3f0344
    70610f3f0334:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0338:	49 8b 06             	mov    (%r14),%rax
    70610f3f033b:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f033f:	e9 64 00 00 00       	jmp    0x70610f3f03a8
    70610f3f0344:	48 89 c3             	mov    %rax,%rbx
    70610f3f0347:	83 e3 0f             	and    $0xf,%ebx
    70610f3f034a:	48 83 fb 05          	cmp    $0x5,%rbx
    70610f3f034e:	0f 85 49 00 00 00    	jne    0x70610f3f039d
    70610f3f0354:	48 bb b5 80 a5 14 61 	movabs $0x706114a580b5,%rbx
    70610f3f035b:	70 00 00 
    70610f3f035e:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0362:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f0366:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f0369:	e8 22 41 36 00       	call   0x70610f754490
    70610f3f036e:	49 8b 06             	mov    (%r14),%rax
    70610f3f0371:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0375:	48 83 f8 01          	cmp    $0x1,%rax
    70610f3f0379:	0f 84 12 00 00 00    	je     0x70610f3f0391
    70610f3f037f:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0383:	89 05 77 3c 16 13    	mov    %eax,0x13163c77(%rip)        # 0x706122554000
    70610f3f0389:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0390:	c3                   	ret
    70610f3f0391:	49 8b 06             	mov    (%r14),%rax
    70610f3f0394:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0398:	e9 0b 00 00 00       	jmp    0x70610f3f03a8
    70610f3f039d:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f03a1:	49 8b 06             	mov    (%r14),%rax
    70610f3f03a4:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f03a8:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    70610f3f03ac:	48 8b 11             	mov    (%rcx),%rdx
    70610f3f03af:	48 83 c2 20          	add    $0x20,%rdx
    70610f3f03b3:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    70610f3f03b7:	0f 8e 19 00 00 00    	jle    0x70610f3f03d6
    70610f3f03bd:	48 89 5c 24 10       	mov    %rbx,0x10(%rsp)
    70610f3f03c2:	48 89 44 24 18       	mov    %rax,0x18(%rsp)
    70610f3f03c7:	e8 34 87 06 00       	call   0x70610f458b00
    70610f3f03cc:	48 8b 5c 24 10       	mov    0x10(%rsp),%rbx
    70610f3f03d1:	48 8b 44 24 18       	mov    0x18(%rsp),%rax
    70610f3f03d6:	48 ba 52 9c 9c 14 61 	movabs $0x7061149c9c52,%rdx
    70610f3f03dd:	70 00 00 
    70610f3f03e0:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    70610f3f03e4:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    70610f3f03e8:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    70610f3f03ef:	48 83 c9 07          	or     $0x7,%rcx
    70610f3f03f3:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    70610f3f03f8:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    70610f3f03fc:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    70610f3f0400:	48 89 41 11          	mov    %rax,0x11(%rcx)
    70610f3f0404:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0408:	49 89 0e             	mov    %rcx,(%r14)
    70610f3f040b:	89 05 ef 3b 16 13    	mov    %eax,0x13163bef(%rip)        # 0x706122554000
    70610f3f0411:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0418:	c3                   	ret
    70610f3f0419:	48 8b 40 01          	mov    0x1(%rax),%rax
    70610f3f041d:	48 8b 40 0e          	mov    0xe(%rax),%rax
    70610f3f0421:	48 bb 2c 72 9b 14 61 	movabs $0x7061149b722c,%rbx
    70610f3f0428:	70 00 00 
    70610f3f042b:	48 39 d8             	cmp    %rbx,%rax
    70610f3f042e:	0f 85 19 00 00 00    	jne    0x70610f3f044d
    70610f3f0434:	89 05 c6 3b 16 13    	mov    %eax,0x13163bc6(%rip)        # 0x706122554000
    70610f3f043a:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0441:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x70610f3f044d
    70610f3f0448:	e9 43 fd 1e 00       	jmp    0x70610f5e0190
    70610f3f044d:	48 b8 4c 4e 9a 14 61 	movabs $0x7061149a4e4c,%rax
    70610f3f0454:	70 00 00 
    70610f3f0457:	49 83 c6 08          	add    $0x8,%r14
    70610f3f045b:	49 89 06             	mov    %rax,(%r14)
    70610f3f045e:	e8 5d 8c 43 00       	call   0x70610f8290c0
    70610f3f0463:	48 b8 4c 4e 9a 14 61 	movabs $0x7061149a4e4c,%rax
    70610f3f046a:	70 00 00 
    70610f3f046d:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0471:	49 89 06             	mov    %rax,(%r14)
    70610f3f0474:	e8 47 8c 43 00       	call   0x70610f8290c0
    70610f3f0479:	48 89 d9             	mov    %rbx,%rcx
    70610f3f047c:	83 e1 0f             	and    $0xf,%ecx
    70610f3f047f:	48 83 f9 03          	cmp    $0x3,%rcx
    70610f3f0483:	0f 85 f5 03 00 00    	jne    0x70610f3f087e
    70610f3f0489:	48 89 c1             	mov    %rax,%rcx
    70610f3f048c:	f7 c1 0f 00 00 00    	test   $0xf,%ecx
    70610f3f0492:	0f 85 73 00 00 00    	jne    0x70610f3f050b
    70610f3f0498:	49 8d 55 10          	lea    0x10(%r13),%rdx
    70610f3f049c:	48 8b 0a             	mov    (%rdx),%rcx
    70610f3f049f:	48 83 c1 10          	add    $0x10,%rcx
    70610f3f04a3:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
    70610f3f04a7:	0f 8e 17 00 00 00    	jle    0x70610f3f04c4
    70610f3f04ad:	48 89 1c 24          	mov    %rbx,(%rsp)
    70610f3f04b1:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    70610f3f04b6:	e8 45 86 06 00       	call   0x70610f458b00
    70610f3f04bb:	48 8b 1c 24          	mov    (%rsp),%rbx
    70610f3f04bf:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
    70610f3f04c4:	48 c1 f8 04          	sar    $0x4,%rax
    70610f3f04c8:	0f 57 c9             	xorps  %xmm1,%xmm1
    70610f3f04cb:	f2 48 0f 2a c8       	cvtsi2sd %rax,%xmm1
    70610f3f04d0:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
    70610f3f04d6:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    70610f3f04da:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    70610f3f04de:	48 8b 03             	mov    (%rbx),%rax
    70610f3f04e1:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    70610f3f04e8:	48 83 c8 03          	or     $0x3,%rax
    70610f3f04ec:	48 83 03 10          	addq   $0x10,(%rbx)
    70610f3f04f0:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    70610f3f04f6:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f04fa:	49 89 06             	mov    %rax,(%r14)
    70610f3f04fd:	89 05 fd 3a 16 13    	mov    %eax,0x13163afd(%rip)        # 0x706122554000
    70610f3f0503:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f050a:	c3                   	ret
    70610f3f050b:	48 89 c1             	mov    %rax,%rcx
    70610f3f050e:	83 e1 0f             	and    $0xf,%ecx
    70610f3f0511:	48 83 f9 03          	cmp    $0x3,%rcx
    70610f3f0515:	0f 85 6d 00 00 00    	jne    0x70610f3f0588
    70610f3f051b:	49 8d 55 10          	lea    0x10(%r13),%rdx
    70610f3f051f:	48 8b 0a             	mov    (%rdx),%rcx
    70610f3f0522:	48 83 c1 10          	add    $0x10,%rcx
    70610f3f0526:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
    70610f3f052a:	0f 8e 17 00 00 00    	jle    0x70610f3f0547
    70610f3f0530:	48 89 1c 24          	mov    %rbx,(%rsp)
    70610f3f0534:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
    70610f3f0539:	e8 c2 85 06 00       	call   0x70610f458b00
    70610f3f053e:	48 8b 1c 24          	mov    (%rsp),%rbx
    70610f3f0542:	48 8b 44 24 08       	mov    0x8(%rsp),%rax
    70610f3f0547:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
    70610f3f054d:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
    70610f3f0553:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    70610f3f0557:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    70610f3f055b:	48 8b 03             	mov    (%rbx),%rax
    70610f3f055e:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    70610f3f0565:	48 83 c8 03          	or     $0x3,%rax
    70610f3f0569:	48 83 03 10          	addq   $0x10,(%rbx)
    70610f3f056d:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    70610f3f0573:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0577:	49 89 06             	mov    %rax,(%r14)
    70610f3f057a:	89 05 80 3a 16 13    	mov    %eax,0x13163a80(%rip)        # 0x706122554000
    70610f3f0580:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0587:	c3                   	ret
    70610f3f0588:	48 89 c3             	mov    %rax,%rbx
    70610f3f058b:	83 e3 0f             	and    $0xf,%ebx
    70610f3f058e:	48 83 fb 05          	cmp    $0x5,%rbx
    70610f3f0592:	0f 85 67 00 00 00    	jne    0x70610f3f05ff
    70610f3f0598:	e8 f3 75 e3 ff       	call   0x70610f227b90
    70610f3f059d:	49 8d 45 10          	lea    0x10(%r13),%rax
    70610f3f05a1:	48 8b 18             	mov    (%rax),%rbx
    70610f3f05a4:	48 83 c3 10          	add    $0x10,%rbx
    70610f3f05a8:	48 3b 58 10          	cmp    0x10(%rax),%rbx
    70610f3f05ac:	0f 8e 05 00 00 00    	jle    0x70610f3f05b7
    70610f3f05b2:	e8 49 85 06 00       	call   0x70610f458b00
    70610f3f05b7:	49 8b 06             	mov    (%r14),%rax
    70610f3f05ba:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f05be:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
    70610f3f05c4:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
    70610f3f05ca:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    70610f3f05ce:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    70610f3f05d2:	48 8b 03             	mov    (%rbx),%rax
    70610f3f05d5:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    70610f3f05dc:	48 83 c8 03          	or     $0x3,%rax
    70610f3f05e0:	48 83 03 10          	addq   $0x10,(%rbx)
    70610f3f05e4:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    70610f3f05ea:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f05ee:	49 89 06             	mov    %rax,(%r14)
    70610f3f05f1:	89 05 09 3a 16 13    	mov    %eax,0x13163a09(%rip)        # 0x706122554000
    70610f3f05f7:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f05fe:	c3                   	ret
    70610f3f05ff:	48 89 c3             	mov    %rax,%rbx
    70610f3f0602:	83 e3 0f             	and    $0xf,%ebx
    70610f3f0605:	48 83 fb 07          	cmp    $0x7,%rbx
    70610f3f0609:	0f 85 59 02 00 00    	jne    0x70610f3f0868
    70610f3f060f:	48 8b 58 01          	mov    0x1(%rax),%rbx
    70610f3f0613:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
    70610f3f0617:	48 b9 8c a0 9c 14 61 	movabs $0x7061149ca08c,%rcx
    70610f3f061e:	70 00 00 
    70610f3f0621:	48 39 cb             	cmp    %rcx,%rbx
    70610f3f0624:	0f 85 a6 01 00 00    	jne    0x70610f3f07d0
    70610f3f062a:	48 8b 58 09          	mov    0x9(%rax),%rbx
    70610f3f062e:	48 8b 40 11          	mov    0x11(%rax),%rax
    70610f3f0632:	49 83 c7 10          	add    $0x10,%r15
    70610f3f0636:	49 89 47 f8          	mov    %rax,-0x8(%r15)
    70610f3f063a:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f063d:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
    70610f3f0644:	e8 d7 86 e2 fe       	call   0x70610e218d20
    70610f3f0649:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    70610f3f064d:	48 8b 03             	mov    (%rbx),%rax
    70610f3f0650:	48 83 c0 10          	add    $0x10,%rax
    70610f3f0654:	48 3b 43 10          	cmp    0x10(%rbx),%rax
    70610f3f0658:	0f 8e 05 00 00 00    	jle    0x70610f3f0663
    70610f3f065e:	e8 9d 84 06 00       	call   0x70610f458b00
    70610f3f0663:	49 8b 0e             	mov    (%r14),%rcx
    70610f3f0666:	49 8b 07             	mov    (%r15),%rax
    70610f3f0669:	49 8b 56 f8          	mov    -0x8(%r14),%rdx
    70610f3f066d:	49 8b 5f f8          	mov    -0x8(%r15),%rbx
    70610f3f0671:	f2 48 0f 10 42 05    	rex.W movsd 0x5(%rdx),%xmm0
    70610f3f0677:	f2 48 0f 10 49 05    	rex.W movsd 0x5(%rcx),%xmm1
    70610f3f067d:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    70610f3f0681:	49 8d 55 10          	lea    0x10(%r13),%rdx
    70610f3f0685:	48 8b 0a             	mov    (%rdx),%rcx
    70610f3f0688:	48 c7 01 0c 00 00 00 	movq   $0xc,(%rcx)
    70610f3f068f:	48 83 c9 03          	or     $0x3,%rcx
    70610f3f0693:	48 83 02 10          	addq   $0x10,(%rdx)
    70610f3f0697:	f2 48 0f 11 41 05    	rex.W movsd %xmm0,0x5(%rcx)
    70610f3f069d:	49 83 c6 08          	add    $0x8,%r14
    70610f3f06a1:	49 83 ef 10          	sub    $0x10,%r15
    70610f3f06a5:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f06a9:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f06ac:	49 89 4e f0          	mov    %rcx,-0x10(%r14)
    70610f3f06b0:	e8 ab fa ff ff       	call   0x70610f3f0160
    70610f3f06b5:	49 8b 06             	mov    (%r14),%rax
    70610f3f06b8:	49 83 c6 08          	add    $0x8,%r14
    70610f3f06bc:	48 83 f8 00          	cmp    $0x0,%rax
    70610f3f06c0:	0f 85 16 00 00 00    	jne    0x70610f3f06dc
    70610f3f06c6:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f06ca:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f06ce:	89 05 2c 39 16 13    	mov    %eax,0x1316392c(%rip)        # 0x706122554000
    70610f3f06d4:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f06db:	c3                   	ret
    70610f3f06dc:	48 89 c3             	mov    %rax,%rbx
    70610f3f06df:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    70610f3f06e5:	0f 85 10 00 00 00    	jne    0x70610f3f06fb
    70610f3f06eb:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f06ef:	49 8b 06             	mov    (%r14),%rax
    70610f3f06f2:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f06f6:	e9 64 00 00 00       	jmp    0x70610f3f075f
    70610f3f06fb:	48 89 c3             	mov    %rax,%rbx
    70610f3f06fe:	83 e3 0f             	and    $0xf,%ebx
    70610f3f0701:	48 83 fb 05          	cmp    $0x5,%rbx
    70610f3f0705:	0f 85 49 00 00 00    	jne    0x70610f3f0754
    70610f3f070b:	48 bb b5 80 a5 14 61 	movabs $0x706114a580b5,%rbx
    70610f3f0712:	70 00 00 
    70610f3f0715:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0719:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f071d:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f0720:	e8 6b 3d 36 00       	call   0x70610f754490
    70610f3f0725:	49 8b 06             	mov    (%r14),%rax
    70610f3f0728:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f072c:	48 83 f8 01          	cmp    $0x1,%rax
    70610f3f0730:	0f 84 12 00 00 00    	je     0x70610f3f0748
    70610f3f0736:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f073a:	89 05 c0 38 16 13    	mov    %eax,0x131638c0(%rip)        # 0x706122554000
    70610f3f0740:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0747:	c3                   	ret
    70610f3f0748:	49 8b 06             	mov    (%r14),%rax
    70610f3f074b:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f074f:	e9 0b 00 00 00       	jmp    0x70610f3f075f
    70610f3f0754:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0758:	49 8b 06             	mov    (%r14),%rax
    70610f3f075b:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f075f:	49 8d 55 10          	lea    0x10(%r13),%rdx
    70610f3f0763:	48 8b 0a             	mov    (%rdx),%rcx
    70610f3f0766:	48 83 c1 20          	add    $0x20,%rcx
    70610f3f076a:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
    70610f3f076e:	0f 8e 19 00 00 00    	jle    0x70610f3f078d
    70610f3f0774:	48 89 5c 24 20       	mov    %rbx,0x20(%rsp)
    70610f3f0779:	48 89 44 24 28       	mov    %rax,0x28(%rsp)
    70610f3f077e:	e8 7d 83 06 00       	call   0x70610f458b00
    70610f3f0783:	48 8b 5c 24 20       	mov    0x20(%rsp),%rbx
    70610f3f0788:	48 8b 44 24 28       	mov    0x28(%rsp),%rax
    70610f3f078d:	48 ba 52 9c 9c 14 61 	movabs $0x7061149c9c52,%rdx
    70610f3f0794:	70 00 00 
    70610f3f0797:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    70610f3f079b:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    70610f3f079f:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    70610f3f07a6:	48 83 c9 07          	or     $0x7,%rcx
    70610f3f07aa:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    70610f3f07af:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    70610f3f07b3:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    70610f3f07b7:	48 89 41 11          	mov    %rax,0x11(%rcx)
    70610f3f07bb:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f07bf:	49 89 0e             	mov    %rcx,(%r14)
    70610f3f07c2:	89 05 38 38 16 13    	mov    %eax,0x13163838(%rip)        # 0x706122554000
    70610f3f07c8:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f07cf:	c3                   	ret
    70610f3f07d0:	48 8b 40 01          	mov    0x1(%rax),%rax
    70610f3f07d4:	48 8b 40 0e          	mov    0xe(%rax),%rax
    70610f3f07d8:	48 bb 2c 72 9b 14 61 	movabs $0x7061149b722c,%rbx
    70610f3f07df:	70 00 00 
    70610f3f07e2:	48 39 d8             	cmp    %rbx,%rax
    70610f3f07e5:	0f 85 67 00 00 00    	jne    0x70610f3f0852
    70610f3f07eb:	e8 20 bb d8 ff       	call   0x70610f17c310
    70610f3f07f0:	49 8d 45 10          	lea    0x10(%r13),%rax
    70610f3f07f4:	48 8b 18             	mov    (%rax),%rbx
    70610f3f07f7:	48 83 c3 10          	add    $0x10,%rbx
    70610f3f07fb:	48 3b 58 10          	cmp    0x10(%rax),%rbx
    70610f3f07ff:	0f 8e 05 00 00 00    	jle    0x70610f3f080a
    70610f3f0805:	e8 f6 82 06 00       	call   0x70610f458b00
    70610f3f080a:	49 8b 06             	mov    (%r14),%rax
    70610f3f080d:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0811:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
    70610f3f0817:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
    70610f3f081d:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    70610f3f0821:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    70610f3f0825:	48 8b 03             	mov    (%rbx),%rax
    70610f3f0828:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    70610f3f082f:	48 83 c8 03          	or     $0x3,%rax
    70610f3f0833:	48 83 03 10          	addq   $0x10,(%rbx)
    70610f3f0837:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    70610f3f083d:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0841:	49 89 06             	mov    %rax,(%r14)
    70610f3f0844:	89 05 b6 37 16 13    	mov    %eax,0x131637b6(%rip)        # 0x706122554000
    70610f3f084a:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0851:	c3                   	ret
    70610f3f0852:	48 b8 4c 4e 9a 14 61 	movabs $0x7061149a4e4c,%rax
    70610f3f0859:	70 00 00 
    70610f3f085c:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0860:	49 89 06             	mov    %rax,(%r14)
    70610f3f0863:	e8 58 88 43 00       	call   0x70610f8290c0
    70610f3f0868:	48 b8 4c 4e 9a 14 61 	movabs $0x7061149a4e4c,%rax
    70610f3f086f:	70 00 00 
    70610f3f0872:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0876:	49 89 06             	mov    %rax,(%r14)
    70610f3f0879:	e8 42 88 43 00       	call   0x70610f8290c0
    70610f3f087e:	48 89 d9             	mov    %rbx,%rcx
    70610f3f0881:	83 e1 0f             	and    $0xf,%ecx
    70610f3f0884:	48 83 f9 05          	cmp    $0x5,%rcx
    70610f3f0888:	0f 85 b7 02 00 00    	jne    0x70610f3f0b45
    70610f3f088e:	48 89 c3             	mov    %rax,%rbx
    70610f3f0891:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    70610f3f0897:	0f 85 1e 00 00 00    	jne    0x70610f3f08bb
    70610f3f089d:	e8 7e ce 43 00       	call   0x70610f82d720
    70610f3f08a2:	89 05 58 37 16 13    	mov    %eax,0x13163758(%rip)        # 0x706122554000
    70610f3f08a8:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f08af:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x70610f3f08bb
    70610f3f08b6:	e9 25 b4 36 00       	jmp    0x70610f75bce0
    70610f3f08bb:	48 89 c3             	mov    %rax,%rbx
    70610f3f08be:	83 e3 0f             	and    $0xf,%ebx
    70610f3f08c1:	48 83 fb 03          	cmp    $0x3,%rbx
    70610f3f08c5:	0f 85 71 00 00 00    	jne    0x70610f3f093c
    70610f3f08cb:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f08cf:	49 83 c7 08          	add    $0x8,%r15
    70610f3f08d3:	49 89 07             	mov    %rax,(%r15)
    70610f3f08d6:	e8 b5 72 e3 ff       	call   0x70610f227b90
    70610f3f08db:	49 8d 45 10          	lea    0x10(%r13),%rax
    70610f3f08df:	48 8b 18             	mov    (%rax),%rbx
    70610f3f08e2:	48 83 c3 10          	add    $0x10,%rbx
    70610f3f08e6:	48 3b 58 10          	cmp    0x10(%rax),%rbx
    70610f3f08ea:	0f 8e 05 00 00 00    	jle    0x70610f3f08f5
    70610f3f08f0:	e8 0b 82 06 00       	call   0x70610f458b00
    70610f3f08f5:	49 8b 07             	mov    (%r15),%rax
    70610f3f08f8:	49 8b 1e             	mov    (%r14),%rbx
    70610f3f08fb:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
    70610f3f0901:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
    70610f3f0907:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    70610f3f090b:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    70610f3f090f:	48 8b 03             	mov    (%rbx),%rax
    70610f3f0912:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    70610f3f0919:	48 83 c8 03          	or     $0x3,%rax
    70610f3f091d:	48 83 03 10          	addq   $0x10,(%rbx)
    70610f3f0921:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    70610f3f0927:	49 83 ef 08          	sub    $0x8,%r15
    70610f3f092b:	49 89 06             	mov    %rax,(%r14)
    70610f3f092e:	89 05 cc 36 16 13    	mov    %eax,0x131636cc(%rip)        # 0x706122554000
    70610f3f0934:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f093b:	c3                   	ret
    70610f3f093c:	48 89 c3             	mov    %rax,%rbx
    70610f3f093f:	83 e3 0f             	and    $0xf,%ebx
    70610f3f0942:	48 83 fb 05          	cmp    $0x5,%rbx
    70610f3f0946:	0f 85 19 00 00 00    	jne    0x70610f3f0965
    70610f3f094c:	89 05 ae 36 16 13    	mov    %eax,0x131636ae(%rip)        # 0x706122554000
    70610f3f0952:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0959:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x70610f3f0965
    70610f3f0960:	e9 7b b3 36 00       	jmp    0x70610f75bce0
    70610f3f0965:	48 89 c3             	mov    %rax,%rbx
    70610f3f0968:	83 e3 0f             	and    $0xf,%ebx
    70610f3f096b:	48 83 fb 07          	cmp    $0x7,%rbx
    70610f3f096f:	0f 85 ba 01 00 00    	jne    0x70610f3f0b2f
    70610f3f0975:	48 8b 58 01          	mov    0x1(%rax),%rbx
    70610f3f0979:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
    70610f3f097d:	48 b9 8c a0 9c 14 61 	movabs $0x7061149ca08c,%rcx
    70610f3f0984:	70 00 00 
    70610f3f0987:	48 39 cb             	cmp    %rcx,%rbx
    70610f3f098a:	0f 85 55 01 00 00    	jne    0x70610f3f0ae5
    70610f3f0990:	48 8b 58 09          	mov    0x9(%rax),%rbx
    70610f3f0994:	48 8b 40 11          	mov    0x11(%rax),%rax
    70610f3f0998:	49 83 c7 10          	add    $0x10,%r15
    70610f3f099c:	49 89 47 f8          	mov    %rax,-0x8(%r15)
    70610f3f09a0:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f09a3:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
    70610f3f09aa:	e8 b1 f7 ff ff       	call   0x70610f3f0160
    70610f3f09af:	49 8b 07             	mov    (%r15),%rax
    70610f3f09b2:	49 8b 5f f8          	mov    -0x8(%r15),%rbx
    70610f3f09b6:	49 83 c6 10          	add    $0x10,%r14
    70610f3f09ba:	49 83 ef 10          	sub    $0x10,%r15
    70610f3f09be:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f09c2:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f09c5:	e8 96 f7 ff ff       	call   0x70610f3f0160
    70610f3f09ca:	49 8b 06             	mov    (%r14),%rax
    70610f3f09cd:	49 83 c6 08          	add    $0x8,%r14
    70610f3f09d1:	48 83 f8 00          	cmp    $0x0,%rax
    70610f3f09d5:	0f 85 16 00 00 00    	jne    0x70610f3f09f1
    70610f3f09db:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f09df:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f09e3:	89 05 17 36 16 13    	mov    %eax,0x13163617(%rip)        # 0x706122554000
    70610f3f09e9:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f09f0:	c3                   	ret
    70610f3f09f1:	48 89 c3             	mov    %rax,%rbx
    70610f3f09f4:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    70610f3f09fa:	0f 85 10 00 00 00    	jne    0x70610f3f0a10
    70610f3f0a00:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0a04:	49 8b 06             	mov    (%r14),%rax
    70610f3f0a07:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0a0b:	e9 64 00 00 00       	jmp    0x70610f3f0a74
    70610f3f0a10:	48 89 c3             	mov    %rax,%rbx
    70610f3f0a13:	83 e3 0f             	and    $0xf,%ebx
    70610f3f0a16:	48 83 fb 05          	cmp    $0x5,%rbx
    70610f3f0a1a:	0f 85 49 00 00 00    	jne    0x70610f3f0a69
    70610f3f0a20:	48 bb b5 80 a5 14 61 	movabs $0x706114a580b5,%rbx
    70610f3f0a27:	70 00 00 
    70610f3f0a2a:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0a2e:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f0a32:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f0a35:	e8 56 3a 36 00       	call   0x70610f754490
    70610f3f0a3a:	49 8b 06             	mov    (%r14),%rax
    70610f3f0a3d:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0a41:	48 83 f8 01          	cmp    $0x1,%rax
    70610f3f0a45:	0f 84 12 00 00 00    	je     0x70610f3f0a5d
    70610f3f0a4b:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0a4f:	89 05 ab 35 16 13    	mov    %eax,0x131635ab(%rip)        # 0x706122554000
    70610f3f0a55:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0a5c:	c3                   	ret
    70610f3f0a5d:	49 8b 06             	mov    (%r14),%rax
    70610f3f0a60:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0a64:	e9 0b 00 00 00       	jmp    0x70610f3f0a74
    70610f3f0a69:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0a6d:	49 8b 06             	mov    (%r14),%rax
    70610f3f0a70:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0a74:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    70610f3f0a78:	48 8b 11             	mov    (%rcx),%rdx
    70610f3f0a7b:	48 83 c2 20          	add    $0x20,%rdx
    70610f3f0a7f:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    70610f3f0a83:	0f 8e 19 00 00 00    	jle    0x70610f3f0aa2
    70610f3f0a89:	48 89 5c 24 30       	mov    %rbx,0x30(%rsp)
    70610f3f0a8e:	48 89 44 24 38       	mov    %rax,0x38(%rsp)
    70610f3f0a93:	e8 68 80 06 00       	call   0x70610f458b00
    70610f3f0a98:	48 8b 5c 24 30       	mov    0x30(%rsp),%rbx
    70610f3f0a9d:	48 8b 44 24 38       	mov    0x38(%rsp),%rax
    70610f3f0aa2:	48 ba 52 9c 9c 14 61 	movabs $0x7061149c9c52,%rdx
    70610f3f0aa9:	70 00 00 
    70610f3f0aac:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    70610f3f0ab0:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    70610f3f0ab4:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    70610f3f0abb:	48 83 c9 07          	or     $0x7,%rcx
    70610f3f0abf:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    70610f3f0ac4:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    70610f3f0ac8:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    70610f3f0acc:	48 89 41 11          	mov    %rax,0x11(%rcx)
    70610f3f0ad0:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0ad4:	49 89 0e             	mov    %rcx,(%r14)
    70610f3f0ad7:	89 05 23 35 16 13    	mov    %eax,0x13163523(%rip)        # 0x706122554000
    70610f3f0add:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0ae4:	c3                   	ret
    70610f3f0ae5:	48 8b 40 01          	mov    0x1(%rax),%rax
    70610f3f0ae9:	48 8b 40 0e          	mov    0xe(%rax),%rax
    70610f3f0aed:	48 bb 2c 72 9b 14 61 	movabs $0x7061149b722c,%rbx
    70610f3f0af4:	70 00 00 
    70610f3f0af7:	48 39 d8             	cmp    %rbx,%rax
    70610f3f0afa:	0f 85 19 00 00 00    	jne    0x70610f3f0b19
    70610f3f0b00:	89 05 fa 34 16 13    	mov    %eax,0x131634fa(%rip)        # 0x706122554000
    70610f3f0b06:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0b0d:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x70610f3f0b19
    70610f3f0b14:	e9 77 f6 1e 00       	jmp    0x70610f5e0190
    70610f3f0b19:	48 b8 4c 4e 9a 14 61 	movabs $0x7061149a4e4c,%rax
    70610f3f0b20:	70 00 00 
    70610f3f0b23:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0b27:	49 89 06             	mov    %rax,(%r14)
    70610f3f0b2a:	e8 91 85 43 00       	call   0x70610f8290c0
    70610f3f0b2f:	48 b8 4c 4e 9a 14 61 	movabs $0x7061149a4e4c,%rax
    70610f3f0b36:	70 00 00 
    70610f3f0b39:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0b3d:	49 89 06             	mov    %rax,(%r14)
    70610f3f0b40:	e8 7b 85 43 00       	call   0x70610f8290c0
    70610f3f0b45:	48 89 d9             	mov    %rbx,%rcx
    70610f3f0b48:	83 e1 0f             	and    $0xf,%ecx
    70610f3f0b4b:	48 83 f9 07          	cmp    $0x7,%rcx
    70610f3f0b4f:	0f 85 a4 0a 00 00    	jne    0x70610f3f15f9
    70610f3f0b55:	48 8b 4b 01          	mov    0x1(%rbx),%rcx
    70610f3f0b59:	48 8b 49 0e          	mov    0xe(%rcx),%rcx
    70610f3f0b5d:	48 ba 8c a0 9c 14 61 	movabs $0x7061149ca08c,%rdx
    70610f3f0b64:	70 00 00 
    70610f3f0b67:	48 39 d1             	cmp    %rdx,%rcx
    70610f3f0b6a:	0f 85 9a 07 00 00    	jne    0x70610f3f130a
    70610f3f0b70:	48 89 c1             	mov    %rax,%rcx
    70610f3f0b73:	f7 c1 0f 00 00 00    	test   $0xf,%ecx
    70610f3f0b79:	0f 85 4e 01 00 00    	jne    0x70610f3f0ccd
    70610f3f0b7f:	48 8b 43 09          	mov    0x9(%rbx),%rax
    70610f3f0b83:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
    70610f3f0b87:	49 83 c7 08          	add    $0x8,%r15
    70610f3f0b8b:	49 89 1f             	mov    %rbx,(%r15)
    70610f3f0b8e:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f0b92:	e8 c9 f5 ff ff       	call   0x70610f3f0160
    70610f3f0b97:	49 8b 07             	mov    (%r15),%rax
    70610f3f0b9a:	49 83 c6 10          	add    $0x10,%r14
    70610f3f0b9e:	49 83 ef 08          	sub    $0x8,%r15
    70610f3f0ba2:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f0ba6:	49 c7 06 00 00 00 00 	movq   $0x0,(%r14)
    70610f3f0bad:	e8 ae f5 ff ff       	call   0x70610f3f0160
    70610f3f0bb2:	49 8b 06             	mov    (%r14),%rax
    70610f3f0bb5:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0bb9:	48 83 f8 00          	cmp    $0x0,%rax
    70610f3f0bbd:	0f 85 16 00 00 00    	jne    0x70610f3f0bd9
    70610f3f0bc3:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0bc7:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0bcb:	89 05 2f 34 16 13    	mov    %eax,0x1316342f(%rip)        # 0x706122554000
    70610f3f0bd1:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0bd8:	c3                   	ret
    70610f3f0bd9:	48 89 c3             	mov    %rax,%rbx
    70610f3f0bdc:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    70610f3f0be2:	0f 85 10 00 00 00    	jne    0x70610f3f0bf8
    70610f3f0be8:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0bec:	49 8b 06             	mov    (%r14),%rax
    70610f3f0bef:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0bf3:	e9 64 00 00 00       	jmp    0x70610f3f0c5c
    70610f3f0bf8:	48 89 c3             	mov    %rax,%rbx
    70610f3f0bfb:	83 e3 0f             	and    $0xf,%ebx
    70610f3f0bfe:	48 83 fb 05          	cmp    $0x5,%rbx
    70610f3f0c02:	0f 85 49 00 00 00    	jne    0x70610f3f0c51
    70610f3f0c08:	48 bb b5 80 a5 14 61 	movabs $0x706114a580b5,%rbx
    70610f3f0c0f:	70 00 00 
    70610f3f0c12:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0c16:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f0c1a:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f0c1d:	e8 6e 38 36 00       	call   0x70610f754490
    70610f3f0c22:	49 8b 06             	mov    (%r14),%rax
    70610f3f0c25:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0c29:	48 83 f8 01          	cmp    $0x1,%rax
    70610f3f0c2d:	0f 84 12 00 00 00    	je     0x70610f3f0c45
    70610f3f0c33:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0c37:	89 05 c3 33 16 13    	mov    %eax,0x131633c3(%rip)        # 0x706122554000
    70610f3f0c3d:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0c44:	c3                   	ret
    70610f3f0c45:	49 8b 06             	mov    (%r14),%rax
    70610f3f0c48:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0c4c:	e9 0b 00 00 00       	jmp    0x70610f3f0c5c
    70610f3f0c51:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0c55:	49 8b 06             	mov    (%r14),%rax
    70610f3f0c58:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0c5c:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    70610f3f0c60:	48 8b 11             	mov    (%rcx),%rdx
    70610f3f0c63:	48 83 c2 20          	add    $0x20,%rdx
    70610f3f0c67:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    70610f3f0c6b:	0f 8e 19 00 00 00    	jle    0x70610f3f0c8a
    70610f3f0c71:	48 89 5c 24 40       	mov    %rbx,0x40(%rsp)
    70610f3f0c76:	48 89 44 24 48       	mov    %rax,0x48(%rsp)
    70610f3f0c7b:	e8 80 7e 06 00       	call   0x70610f458b00
    70610f3f0c80:	48 8b 5c 24 40       	mov    0x40(%rsp),%rbx
    70610f3f0c85:	48 8b 44 24 48       	mov    0x48(%rsp),%rax
    70610f3f0c8a:	48 ba 52 9c 9c 14 61 	movabs $0x7061149c9c52,%rdx
    70610f3f0c91:	70 00 00 
    70610f3f0c94:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    70610f3f0c98:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    70610f3f0c9c:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    70610f3f0ca3:	48 83 c9 07          	or     $0x7,%rcx
    70610f3f0ca7:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    70610f3f0cac:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    70610f3f0cb0:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    70610f3f0cb4:	48 89 41 11          	mov    %rax,0x11(%rcx)
    70610f3f0cb8:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0cbc:	49 89 0e             	mov    %rcx,(%r14)
    70610f3f0cbf:	89 05 3b 33 16 13    	mov    %eax,0x1316333b(%rip)        # 0x706122554000
    70610f3f0cc5:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0ccc:	c3                   	ret
    70610f3f0ccd:	48 89 c1             	mov    %rax,%rcx
    70610f3f0cd0:	83 e1 0f             	and    $0xf,%ecx
    70610f3f0cd3:	48 83 f9 03          	cmp    $0x3,%rcx
    70610f3f0cd7:	0f 85 a6 01 00 00    	jne    0x70610f3f0e83
    70610f3f0cdd:	48 8b 4b 09          	mov    0x9(%rbx),%rcx
    70610f3f0ce1:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
    70610f3f0ce5:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0ce9:	49 83 c7 10          	add    $0x10,%r15
    70610f3f0ced:	49 89 07             	mov    %rax,(%r15)
    70610f3f0cf0:	49 89 5f f8          	mov    %rbx,-0x8(%r15)
    70610f3f0cf4:	49 89 0e             	mov    %rcx,(%r14)
    70610f3f0cf7:	e8 24 80 e2 fe       	call   0x70610e218d20
    70610f3f0cfc:	49 8d 45 10          	lea    0x10(%r13),%rax
    70610f3f0d00:	48 8b 18             	mov    (%rax),%rbx
    70610f3f0d03:	48 83 c3 10          	add    $0x10,%rbx
    70610f3f0d07:	48 3b 58 10          	cmp    0x10(%rax),%rbx
    70610f3f0d0b:	0f 8e 05 00 00 00    	jle    0x70610f3f0d16
    70610f3f0d11:	e8 ea 7d 06 00       	call   0x70610f458b00
    70610f3f0d16:	49 8b 1f             	mov    (%r15),%rbx
    70610f3f0d19:	49 8b 0e             	mov    (%r14),%rcx
    70610f3f0d1c:	49 8b 47 f8          	mov    -0x8(%r15),%rax
    70610f3f0d20:	f2 48 0f 10 41 05    	rex.W movsd 0x5(%rcx),%xmm0
    70610f3f0d26:	f2 48 0f 10 4b 05    	rex.W movsd 0x5(%rbx),%xmm1
    70610f3f0d2c:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    70610f3f0d30:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    70610f3f0d34:	48 8b 19             	mov    (%rcx),%rbx
    70610f3f0d37:	48 c7 03 0c 00 00 00 	movq   $0xc,(%rbx)
    70610f3f0d3e:	48 83 cb 03          	or     $0x3,%rbx
    70610f3f0d42:	48 83 01 10          	addq   $0x10,(%rcx)
    70610f3f0d46:	f2 48 0f 11 43 05    	rex.W movsd %xmm0,0x5(%rbx)
    70610f3f0d4c:	49 83 c6 10          	add    $0x10,%r14
    70610f3f0d50:	49 83 ef 10          	sub    $0x10,%r15
    70610f3f0d54:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f0d58:	49 c7 06 00 00 00 00 	movq   $0x0,(%r14)
    70610f3f0d5f:	49 89 5e f0          	mov    %rbx,-0x10(%r14)
    70610f3f0d63:	e8 f8 f3 ff ff       	call   0x70610f3f0160
    70610f3f0d68:	49 8b 06             	mov    (%r14),%rax
    70610f3f0d6b:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0d6f:	48 83 f8 00          	cmp    $0x0,%rax
    70610f3f0d73:	0f 85 16 00 00 00    	jne    0x70610f3f0d8f
    70610f3f0d79:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0d7d:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0d81:	89 05 79 32 16 13    	mov    %eax,0x13163279(%rip)        # 0x706122554000
    70610f3f0d87:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0d8e:	c3                   	ret
    70610f3f0d8f:	48 89 c3             	mov    %rax,%rbx
    70610f3f0d92:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    70610f3f0d98:	0f 85 10 00 00 00    	jne    0x70610f3f0dae
    70610f3f0d9e:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0da2:	49 8b 06             	mov    (%r14),%rax
    70610f3f0da5:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0da9:	e9 64 00 00 00       	jmp    0x70610f3f0e12
    70610f3f0dae:	48 89 c3             	mov    %rax,%rbx
    70610f3f0db1:	83 e3 0f             	and    $0xf,%ebx
    70610f3f0db4:	48 83 fb 05          	cmp    $0x5,%rbx
    70610f3f0db8:	0f 85 49 00 00 00    	jne    0x70610f3f0e07
    70610f3f0dbe:	48 bb b5 80 a5 14 61 	movabs $0x706114a580b5,%rbx
    70610f3f0dc5:	70 00 00 
    70610f3f0dc8:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0dcc:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f0dd0:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f0dd3:	e8 b8 36 36 00       	call   0x70610f754490
    70610f3f0dd8:	49 8b 06             	mov    (%r14),%rax
    70610f3f0ddb:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0ddf:	48 83 f8 01          	cmp    $0x1,%rax
    70610f3f0de3:	0f 84 12 00 00 00    	je     0x70610f3f0dfb
    70610f3f0de9:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0ded:	89 05 0d 32 16 13    	mov    %eax,0x1316320d(%rip)        # 0x706122554000
    70610f3f0df3:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0dfa:	c3                   	ret
    70610f3f0dfb:	49 8b 06             	mov    (%r14),%rax
    70610f3f0dfe:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0e02:	e9 0b 00 00 00       	jmp    0x70610f3f0e12
    70610f3f0e07:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0e0b:	49 8b 06             	mov    (%r14),%rax
    70610f3f0e0e:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0e12:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    70610f3f0e16:	48 8b 11             	mov    (%rcx),%rdx
    70610f3f0e19:	48 83 c2 20          	add    $0x20,%rdx
    70610f3f0e1d:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    70610f3f0e21:	0f 8e 19 00 00 00    	jle    0x70610f3f0e40
    70610f3f0e27:	48 89 5c 24 50       	mov    %rbx,0x50(%rsp)
    70610f3f0e2c:	48 89 44 24 58       	mov    %rax,0x58(%rsp)
    70610f3f0e31:	e8 ca 7c 06 00       	call   0x70610f458b00
    70610f3f0e36:	48 8b 5c 24 50       	mov    0x50(%rsp),%rbx
    70610f3f0e3b:	48 8b 44 24 58       	mov    0x58(%rsp),%rax
    70610f3f0e40:	48 ba 52 9c 9c 14 61 	movabs $0x7061149c9c52,%rdx
    70610f3f0e47:	70 00 00 
    70610f3f0e4a:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    70610f3f0e4e:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    70610f3f0e52:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    70610f3f0e59:	48 83 c9 07          	or     $0x7,%rcx
    70610f3f0e5d:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    70610f3f0e62:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    70610f3f0e66:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    70610f3f0e6a:	48 89 41 11          	mov    %rax,0x11(%rcx)
    70610f3f0e6e:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0e72:	49 89 0e             	mov    %rcx,(%r14)
    70610f3f0e75:	89 05 85 31 16 13    	mov    %eax,0x13163185(%rip)        # 0x706122554000
    70610f3f0e7b:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0e82:	c3                   	ret
    70610f3f0e83:	48 89 c1             	mov    %rax,%rcx
    70610f3f0e86:	83 e1 0f             	and    $0xf,%ecx
    70610f3f0e89:	48 83 f9 05          	cmp    $0x5,%rcx
    70610f3f0e8d:	0f 85 4e 01 00 00    	jne    0x70610f3f0fe1
    70610f3f0e93:	48 8b 43 09          	mov    0x9(%rbx),%rax
    70610f3f0e97:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
    70610f3f0e9b:	49 83 c7 08          	add    $0x8,%r15
    70610f3f0e9f:	49 89 1f             	mov    %rbx,(%r15)
    70610f3f0ea2:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f0ea6:	e8 b5 f2 ff ff       	call   0x70610f3f0160
    70610f3f0eab:	49 8b 07             	mov    (%r15),%rax
    70610f3f0eae:	49 83 c6 10          	add    $0x10,%r14
    70610f3f0eb2:	49 83 ef 08          	sub    $0x8,%r15
    70610f3f0eb6:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f0eba:	49 c7 06 00 00 00 00 	movq   $0x0,(%r14)
    70610f3f0ec1:	e8 9a f2 ff ff       	call   0x70610f3f0160
    70610f3f0ec6:	49 8b 06             	mov    (%r14),%rax
    70610f3f0ec9:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0ecd:	48 83 f8 00          	cmp    $0x0,%rax
    70610f3f0ed1:	0f 85 16 00 00 00    	jne    0x70610f3f0eed
    70610f3f0ed7:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0edb:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0edf:	89 05 1b 31 16 13    	mov    %eax,0x1316311b(%rip)        # 0x706122554000
    70610f3f0ee5:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0eec:	c3                   	ret
    70610f3f0eed:	48 89 c3             	mov    %rax,%rbx
    70610f3f0ef0:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    70610f3f0ef6:	0f 85 10 00 00 00    	jne    0x70610f3f0f0c
    70610f3f0efc:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0f00:	49 8b 06             	mov    (%r14),%rax
    70610f3f0f03:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0f07:	e9 64 00 00 00       	jmp    0x70610f3f0f70
    70610f3f0f0c:	48 89 c3             	mov    %rax,%rbx
    70610f3f0f0f:	83 e3 0f             	and    $0xf,%ebx
    70610f3f0f12:	48 83 fb 05          	cmp    $0x5,%rbx
    70610f3f0f16:	0f 85 49 00 00 00    	jne    0x70610f3f0f65
    70610f3f0f1c:	48 bb b5 80 a5 14 61 	movabs $0x706114a580b5,%rbx
    70610f3f0f23:	70 00 00 
    70610f3f0f26:	49 83 c6 08          	add    $0x8,%r14
    70610f3f0f2a:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f0f2e:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f0f31:	e8 5a 35 36 00       	call   0x70610f754490
    70610f3f0f36:	49 8b 06             	mov    (%r14),%rax
    70610f3f0f39:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0f3d:	48 83 f8 01          	cmp    $0x1,%rax
    70610f3f0f41:	0f 84 12 00 00 00    	je     0x70610f3f0f59
    70610f3f0f47:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0f4b:	89 05 af 30 16 13    	mov    %eax,0x131630af(%rip)        # 0x706122554000
    70610f3f0f51:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0f58:	c3                   	ret
    70610f3f0f59:	49 8b 06             	mov    (%r14),%rax
    70610f3f0f5c:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0f60:	e9 0b 00 00 00       	jmp    0x70610f3f0f70
    70610f3f0f65:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0f69:	49 8b 06             	mov    (%r14),%rax
    70610f3f0f6c:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f0f70:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    70610f3f0f74:	48 8b 11             	mov    (%rcx),%rdx
    70610f3f0f77:	48 83 c2 20          	add    $0x20,%rdx
    70610f3f0f7b:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    70610f3f0f7f:	0f 8e 19 00 00 00    	jle    0x70610f3f0f9e
    70610f3f0f85:	48 89 5c 24 60       	mov    %rbx,0x60(%rsp)
    70610f3f0f8a:	48 89 44 24 68       	mov    %rax,0x68(%rsp)
    70610f3f0f8f:	e8 6c 7b 06 00       	call   0x70610f458b00
    70610f3f0f94:	48 8b 5c 24 60       	mov    0x60(%rsp),%rbx
    70610f3f0f99:	48 8b 44 24 68       	mov    0x68(%rsp),%rax
    70610f3f0f9e:	48 ba 52 9c 9c 14 61 	movabs $0x7061149c9c52,%rdx
    70610f3f0fa5:	70 00 00 
    70610f3f0fa8:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    70610f3f0fac:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    70610f3f0fb0:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    70610f3f0fb7:	48 83 c9 07          	or     $0x7,%rcx
    70610f3f0fbb:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    70610f3f0fc0:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    70610f3f0fc4:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    70610f3f0fc8:	48 89 41 11          	mov    %rax,0x11(%rcx)
    70610f3f0fcc:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f0fd0:	49 89 0e             	mov    %rcx,(%r14)
    70610f3f0fd3:	89 05 27 30 16 13    	mov    %eax,0x13163027(%rip)        # 0x706122554000
    70610f3f0fd9:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f0fe0:	c3                   	ret
    70610f3f0fe1:	48 89 c1             	mov    %rax,%rcx
    70610f3f0fe4:	83 e1 0f             	and    $0xf,%ecx
    70610f3f0fe7:	48 83 f9 07          	cmp    $0x7,%rcx
    70610f3f0feb:	0f 85 03 03 00 00    	jne    0x70610f3f12f4
    70610f3f0ff1:	48 8b 48 01          	mov    0x1(%rax),%rcx
    70610f3f0ff5:	48 8b 49 0e          	mov    0xe(%rcx),%rcx
    70610f3f0ff9:	48 ba 8c a0 9c 14 61 	movabs $0x7061149ca08c,%rdx
    70610f3f1000:	70 00 00 
    70610f3f1003:	48 39 d1             	cmp    %rdx,%rcx
    70610f3f1006:	0f 85 5d 01 00 00    	jne    0x70610f3f1169
    70610f3f100c:	48 8b 4b 09          	mov    0x9(%rbx),%rcx
    70610f3f1010:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
    70610f3f1014:	48 8b 50 09          	mov    0x9(%rax),%rdx
    70610f3f1018:	48 8b 40 11          	mov    0x11(%rax),%rax
    70610f3f101c:	49 83 c7 10          	add    $0x10,%r15
    70610f3f1020:	49 89 47 f8          	mov    %rax,-0x8(%r15)
    70610f3f1024:	49 89 4e f8          	mov    %rcx,-0x8(%r14)
    70610f3f1028:	49 89 16             	mov    %rdx,(%r14)
    70610f3f102b:	49 89 1f             	mov    %rbx,(%r15)
    70610f3f102e:	e8 2d f1 ff ff       	call   0x70610f3f0160
    70610f3f1033:	49 8b 07             	mov    (%r15),%rax
    70610f3f1036:	49 8b 5f f8          	mov    -0x8(%r15),%rbx
    70610f3f103a:	49 83 c6 10          	add    $0x10,%r14
    70610f3f103e:	49 83 ef 10          	sub    $0x10,%r15
    70610f3f1042:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f1046:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f1049:	e8 12 f1 ff ff       	call   0x70610f3f0160
    70610f3f104e:	49 8b 06             	mov    (%r14),%rax
    70610f3f1051:	49 83 c6 08          	add    $0x8,%r14
    70610f3f1055:	48 83 f8 00          	cmp    $0x0,%rax
    70610f3f1059:	0f 85 16 00 00 00    	jne    0x70610f3f1075
    70610f3f105f:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f1063:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f1067:	89 05 93 2f 16 13    	mov    %eax,0x13162f93(%rip)        # 0x706122554000
    70610f3f106d:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f1074:	c3                   	ret
    70610f3f1075:	48 89 c3             	mov    %rax,%rbx
    70610f3f1078:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    70610f3f107e:	0f 85 10 00 00 00    	jne    0x70610f3f1094
    70610f3f1084:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f1088:	49 8b 06             	mov    (%r14),%rax
    70610f3f108b:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f108f:	e9 64 00 00 00       	jmp    0x70610f3f10f8
    70610f3f1094:	48 89 c3             	mov    %rax,%rbx
    70610f3f1097:	83 e3 0f             	and    $0xf,%ebx
    70610f3f109a:	48 83 fb 05          	cmp    $0x5,%rbx
    70610f3f109e:	0f 85 49 00 00 00    	jne    0x70610f3f10ed
    70610f3f10a4:	48 bb b5 80 a5 14 61 	movabs $0x706114a580b5,%rbx
    70610f3f10ab:	70 00 00 
    70610f3f10ae:	49 83 c6 08          	add    $0x8,%r14
    70610f3f10b2:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f10b6:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f10b9:	e8 d2 33 36 00       	call   0x70610f754490
    70610f3f10be:	49 8b 06             	mov    (%r14),%rax
    70610f3f10c1:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f10c5:	48 83 f8 01          	cmp    $0x1,%rax
    70610f3f10c9:	0f 84 12 00 00 00    	je     0x70610f3f10e1
    70610f3f10cf:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f10d3:	89 05 27 2f 16 13    	mov    %eax,0x13162f27(%rip)        # 0x706122554000
    70610f3f10d9:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f10e0:	c3                   	ret
    70610f3f10e1:	49 8b 06             	mov    (%r14),%rax
    70610f3f10e4:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f10e8:	e9 0b 00 00 00       	jmp    0x70610f3f10f8
    70610f3f10ed:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f10f1:	49 8b 06             	mov    (%r14),%rax
    70610f3f10f4:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f10f8:	49 8d 4d 10          	lea    0x10(%r13),%rcx
    70610f3f10fc:	48 8b 11             	mov    (%rcx),%rdx
    70610f3f10ff:	48 83 c2 20          	add    $0x20,%rdx
    70610f3f1103:	48 3b 51 10          	cmp    0x10(%rcx),%rdx
    70610f3f1107:	0f 8e 19 00 00 00    	jle    0x70610f3f1126
    70610f3f110d:	48 89 5c 24 70       	mov    %rbx,0x70(%rsp)
    70610f3f1112:	48 89 44 24 78       	mov    %rax,0x78(%rsp)
    70610f3f1117:	e8 e4 79 06 00       	call   0x70610f458b00
    70610f3f111c:	48 8b 5c 24 70       	mov    0x70(%rsp),%rbx
    70610f3f1121:	48 8b 44 24 78       	mov    0x78(%rsp),%rax
    70610f3f1126:	48 ba 52 9c 9c 14 61 	movabs $0x7061149c9c52,%rdx
    70610f3f112d:	70 00 00 
    70610f3f1130:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    70610f3f1134:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    70610f3f1138:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    70610f3f113f:	48 83 c9 07          	or     $0x7,%rcx
    70610f3f1143:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    70610f3f1148:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    70610f3f114c:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    70610f3f1150:	48 89 41 11          	mov    %rax,0x11(%rcx)
    70610f3f1154:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f1158:	49 89 0e             	mov    %rcx,(%r14)
    70610f3f115b:	89 05 9f 2e 16 13    	mov    %eax,0x13162e9f(%rip)        # 0x706122554000
    70610f3f1161:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f1168:	c3                   	ret
    70610f3f1169:	48 8b 40 01          	mov    0x1(%rax),%rax
    70610f3f116d:	48 8b 40 0e          	mov    0xe(%rax),%rax
    70610f3f1171:	48 b9 2c 72 9b 14 61 	movabs $0x7061149b722c,%rcx
    70610f3f1178:	70 00 00 
    70610f3f117b:	48 39 c8             	cmp    %rcx,%rax
    70610f3f117e:	0f 85 5a 01 00 00    	jne    0x70610f3f12de
    70610f3f1184:	48 8b 43 09          	mov    0x9(%rbx),%rax
    70610f3f1188:	48 8b 5b 11          	mov    0x11(%rbx),%rbx
    70610f3f118c:	49 83 c7 08          	add    $0x8,%r15
    70610f3f1190:	49 89 1f             	mov    %rbx,(%r15)
    70610f3f1193:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f1197:	e8 c4 ef ff ff       	call   0x70610f3f0160
    70610f3f119c:	49 8b 07             	mov    (%r15),%rax
    70610f3f119f:	49 83 c6 10          	add    $0x10,%r14
    70610f3f11a3:	49 83 ef 08          	sub    $0x8,%r15
    70610f3f11a7:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f11ab:	49 c7 06 00 00 00 00 	movq   $0x0,(%r14)
    70610f3f11b2:	e8 a9 ef ff ff       	call   0x70610f3f0160
    70610f3f11b7:	49 8b 06             	mov    (%r14),%rax
    70610f3f11ba:	49 83 c6 08          	add    $0x8,%r14
    70610f3f11be:	48 83 f8 00          	cmp    $0x0,%rax
    70610f3f11c2:	0f 85 16 00 00 00    	jne    0x70610f3f11de
    70610f3f11c8:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f11cc:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f11d0:	89 05 2a 2e 16 13    	mov    %eax,0x13162e2a(%rip)        # 0x706122554000
    70610f3f11d6:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f11dd:	c3                   	ret
    70610f3f11de:	48 89 c3             	mov    %rax,%rbx
    70610f3f11e1:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    70610f3f11e7:	0f 85 10 00 00 00    	jne    0x70610f3f11fd
    70610f3f11ed:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f11f1:	49 8b 06             	mov    (%r14),%rax
    70610f3f11f4:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f11f8:	e9 64 00 00 00       	jmp    0x70610f3f1261
    70610f3f11fd:	48 89 c3             	mov    %rax,%rbx
    70610f3f1200:	83 e3 0f             	and    $0xf,%ebx
    70610f3f1203:	48 83 fb 05          	cmp    $0x5,%rbx
    70610f3f1207:	0f 85 49 00 00 00    	jne    0x70610f3f1256
    70610f3f120d:	48 bb b5 80 a5 14 61 	movabs $0x706114a580b5,%rbx
    70610f3f1214:	70 00 00 
    70610f3f1217:	49 83 c6 08          	add    $0x8,%r14
    70610f3f121b:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f121f:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f1222:	e8 69 32 36 00       	call   0x70610f754490
    70610f3f1227:	49 8b 06             	mov    (%r14),%rax
    70610f3f122a:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f122e:	48 83 f8 01          	cmp    $0x1,%rax
    70610f3f1232:	0f 84 12 00 00 00    	je     0x70610f3f124a
    70610f3f1238:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f123c:	89 05 be 2d 16 13    	mov    %eax,0x13162dbe(%rip)        # 0x706122554000
    70610f3f1242:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f1249:	c3                   	ret
    70610f3f124a:	49 8b 06             	mov    (%r14),%rax
    70610f3f124d:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f1251:	e9 0b 00 00 00       	jmp    0x70610f3f1261
    70610f3f1256:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f125a:	49 8b 06             	mov    (%r14),%rax
    70610f3f125d:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f1261:	49 8d 55 10          	lea    0x10(%r13),%rdx
    70610f3f1265:	48 8b 0a             	mov    (%rdx),%rcx
    70610f3f1268:	48 83 c1 20          	add    $0x20,%rcx
    70610f3f126c:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
    70610f3f1270:	0f 8e 25 00 00 00    	jle    0x70610f3f129b
    70610f3f1276:	48 89 9c 24 80 00 00 	mov    %rbx,0x80(%rsp)
    70610f3f127d:	00 
    70610f3f127e:	48 89 84 24 88 00 00 	mov    %rax,0x88(%rsp)
    70610f3f1285:	00 
    70610f3f1286:	e8 75 78 06 00       	call   0x70610f458b00
    70610f3f128b:	48 8b 9c 24 80 00 00 	mov    0x80(%rsp),%rbx
    70610f3f1292:	00 
    70610f3f1293:	48 8b 84 24 88 00 00 	mov    0x88(%rsp),%rax
    70610f3f129a:	00 
    70610f3f129b:	48 ba 52 9c 9c 14 61 	movabs $0x7061149c9c52,%rdx
    70610f3f12a2:	70 00 00 
    70610f3f12a5:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    70610f3f12a9:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    70610f3f12ad:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    70610f3f12b4:	48 83 c9 07          	or     $0x7,%rcx
    70610f3f12b8:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    70610f3f12bd:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    70610f3f12c1:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    70610f3f12c5:	48 89 41 11          	mov    %rax,0x11(%rcx)
    70610f3f12c9:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f12cd:	49 89 0e             	mov    %rcx,(%r14)
    70610f3f12d0:	89 05 2a 2d 16 13    	mov    %eax,0x13162d2a(%rip)        # 0x706122554000
    70610f3f12d6:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f12dd:	c3                   	ret
    70610f3f12de:	48 b8 4c 4e 9a 14 61 	movabs $0x7061149a4e4c,%rax
    70610f3f12e5:	70 00 00 
    70610f3f12e8:	49 83 c6 08          	add    $0x8,%r14
    70610f3f12ec:	49 89 06             	mov    %rax,(%r14)
    70610f3f12ef:	e8 cc 7d 43 00       	call   0x70610f8290c0
    70610f3f12f4:	48 b8 4c 4e 9a 14 61 	movabs $0x7061149a4e4c,%rax
    70610f3f12fb:	70 00 00 
    70610f3f12fe:	49 83 c6 08          	add    $0x8,%r14
    70610f3f1302:	49 89 06             	mov    %rax,(%r14)
    70610f3f1305:	e8 b6 7d 43 00       	call   0x70610f8290c0
    70610f3f130a:	48 8b 5b 01          	mov    0x1(%rbx),%rbx
    70610f3f130e:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
    70610f3f1312:	48 b9 2c 72 9b 14 61 	movabs $0x7061149b722c,%rcx
    70610f3f1319:	70 00 00 
    70610f3f131c:	48 39 cb             	cmp    %rcx,%rbx
    70610f3f131f:	0f 85 be 02 00 00    	jne    0x70610f3f15e3
    70610f3f1325:	48 89 c3             	mov    %rax,%rbx
    70610f3f1328:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    70610f3f132e:	0f 85 19 00 00 00    	jne    0x70610f3f134d
    70610f3f1334:	89 05 c6 2c 16 13    	mov    %eax,0x13162cc6(%rip)        # 0x706122554000
    70610f3f133a:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f1341:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x70610f3f134d
    70610f3f1348:	e9 43 ee 1e 00       	jmp    0x70610f5e0190
    70610f3f134d:	48 89 c3             	mov    %rax,%rbx
    70610f3f1350:	83 e3 0f             	and    $0xf,%ebx
    70610f3f1353:	48 83 fb 03          	cmp    $0x3,%rbx
    70610f3f1357:	0f 85 71 00 00 00    	jne    0x70610f3f13ce
    70610f3f135d:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f1361:	49 83 c7 08          	add    $0x8,%r15
    70610f3f1365:	49 89 07             	mov    %rax,(%r15)
    70610f3f1368:	e8 a3 af d8 ff       	call   0x70610f17c310
    70610f3f136d:	49 8d 45 10          	lea    0x10(%r13),%rax
    70610f3f1371:	48 8b 18             	mov    (%rax),%rbx
    70610f3f1374:	48 83 c3 10          	add    $0x10,%rbx
    70610f3f1378:	48 3b 58 10          	cmp    0x10(%rax),%rbx
    70610f3f137c:	0f 8e 05 00 00 00    	jle    0x70610f3f1387
    70610f3f1382:	e8 79 77 06 00       	call   0x70610f458b00
    70610f3f1387:	49 8b 07             	mov    (%r15),%rax
    70610f3f138a:	49 8b 1e             	mov    (%r14),%rbx
    70610f3f138d:	f2 48 0f 10 43 05    	rex.W movsd 0x5(%rbx),%xmm0
    70610f3f1393:	f2 48 0f 10 48 05    	rex.W movsd 0x5(%rax),%xmm1
    70610f3f1399:	f2 0f 58 c1          	addsd  %xmm1,%xmm0
    70610f3f139d:	49 8d 5d 10          	lea    0x10(%r13),%rbx
    70610f3f13a1:	48 8b 03             	mov    (%rbx),%rax
    70610f3f13a4:	48 c7 00 0c 00 00 00 	movq   $0xc,(%rax)
    70610f3f13ab:	48 83 c8 03          	or     $0x3,%rax
    70610f3f13af:	48 83 03 10          	addq   $0x10,(%rbx)
    70610f3f13b3:	f2 48 0f 11 40 05    	rex.W movsd %xmm0,0x5(%rax)
    70610f3f13b9:	49 83 ef 08          	sub    $0x8,%r15
    70610f3f13bd:	49 89 06             	mov    %rax,(%r14)
    70610f3f13c0:	89 05 3a 2c 16 13    	mov    %eax,0x13162c3a(%rip)        # 0x706122554000
    70610f3f13c6:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f13cd:	c3                   	ret
    70610f3f13ce:	48 89 c3             	mov    %rax,%rbx
    70610f3f13d1:	83 e3 0f             	and    $0xf,%ebx
    70610f3f13d4:	48 83 fb 05          	cmp    $0x5,%rbx
    70610f3f13d8:	0f 85 19 00 00 00    	jne    0x70610f3f13f7
    70610f3f13de:	89 05 1c 2c 16 13    	mov    %eax,0x13162c1c(%rip)        # 0x706122554000
    70610f3f13e4:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f13eb:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x70610f3f13f7
    70610f3f13f2:	e9 99 ed 1e 00       	jmp    0x70610f5e0190
    70610f3f13f7:	48 89 c3             	mov    %rax,%rbx
    70610f3f13fa:	83 e3 0f             	and    $0xf,%ebx
    70610f3f13fd:	48 83 fb 07          	cmp    $0x7,%rbx
    70610f3f1401:	0f 85 c6 01 00 00    	jne    0x70610f3f15cd
    70610f3f1407:	48 8b 58 01          	mov    0x1(%rax),%rbx
    70610f3f140b:	48 8b 5b 0e          	mov    0xe(%rbx),%rbx
    70610f3f140f:	48 b9 8c a0 9c 14 61 	movabs $0x7061149ca08c,%rcx
    70610f3f1416:	70 00 00 
    70610f3f1419:	48 39 cb             	cmp    %rcx,%rbx
    70610f3f141c:	0f 85 61 01 00 00    	jne    0x70610f3f1583
    70610f3f1422:	48 8b 58 09          	mov    0x9(%rax),%rbx
    70610f3f1426:	48 8b 40 11          	mov    0x11(%rax),%rax
    70610f3f142a:	49 83 c7 10          	add    $0x10,%r15
    70610f3f142e:	49 89 47 f8          	mov    %rax,-0x8(%r15)
    70610f3f1432:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f1435:	49 c7 07 00 00 00 00 	movq   $0x0,(%r15)
    70610f3f143c:	e8 1f ed ff ff       	call   0x70610f3f0160
    70610f3f1441:	49 8b 07             	mov    (%r15),%rax
    70610f3f1444:	49 8b 5f f8          	mov    -0x8(%r15),%rbx
    70610f3f1448:	49 83 c6 10          	add    $0x10,%r14
    70610f3f144c:	49 83 ef 10          	sub    $0x10,%r15
    70610f3f1450:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f1454:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f1457:	e8 04 ed ff ff       	call   0x70610f3f0160
    70610f3f145c:	49 8b 06             	mov    (%r14),%rax
    70610f3f145f:	49 83 c6 08          	add    $0x8,%r14
    70610f3f1463:	48 83 f8 00          	cmp    $0x0,%rax
    70610f3f1467:	0f 85 16 00 00 00    	jne    0x70610f3f1483
    70610f3f146d:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f1471:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f1475:	89 05 85 2b 16 13    	mov    %eax,0x13162b85(%rip)        # 0x706122554000
    70610f3f147b:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f1482:	c3                   	ret
    70610f3f1483:	48 89 c3             	mov    %rax,%rbx
    70610f3f1486:	f7 c3 0f 00 00 00    	test   $0xf,%ebx
    70610f3f148c:	0f 85 10 00 00 00    	jne    0x70610f3f14a2
    70610f3f1492:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f1496:	49 8b 06             	mov    (%r14),%rax
    70610f3f1499:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f149d:	e9 64 00 00 00       	jmp    0x70610f3f1506
    70610f3f14a2:	48 89 c3             	mov    %rax,%rbx
    70610f3f14a5:	83 e3 0f             	and    $0xf,%ebx
    70610f3f14a8:	48 83 fb 05          	cmp    $0x5,%rbx
    70610f3f14ac:	0f 85 49 00 00 00    	jne    0x70610f3f14fb
    70610f3f14b2:	48 bb b5 80 a5 14 61 	movabs $0x706114a580b5,%rbx
    70610f3f14b9:	70 00 00 
    70610f3f14bc:	49 83 c6 08          	add    $0x8,%r14
    70610f3f14c0:	49 89 46 f8          	mov    %rax,-0x8(%r14)
    70610f3f14c4:	49 89 1e             	mov    %rbx,(%r14)
    70610f3f14c7:	e8 c4 2f 36 00       	call   0x70610f754490
    70610f3f14cc:	49 8b 06             	mov    (%r14),%rax
    70610f3f14cf:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f14d3:	48 83 f8 01          	cmp    $0x1,%rax
    70610f3f14d7:	0f 84 12 00 00 00    	je     0x70610f3f14ef
    70610f3f14dd:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f14e1:	89 05 19 2b 16 13    	mov    %eax,0x13162b19(%rip)        # 0x706122554000
    70610f3f14e7:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f14ee:	c3                   	ret
    70610f3f14ef:	49 8b 06             	mov    (%r14),%rax
    70610f3f14f2:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f14f6:	e9 0b 00 00 00       	jmp    0x70610f3f1506
    70610f3f14fb:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f14ff:	49 8b 06             	mov    (%r14),%rax
    70610f3f1502:	49 8b 5e f8          	mov    -0x8(%r14),%rbx
    70610f3f1506:	49 8d 55 10          	lea    0x10(%r13),%rdx
    70610f3f150a:	48 8b 0a             	mov    (%rdx),%rcx
    70610f3f150d:	48 83 c1 20          	add    $0x20,%rcx
    70610f3f1511:	48 3b 4a 10          	cmp    0x10(%rdx),%rcx
    70610f3f1515:	0f 8e 25 00 00 00    	jle    0x70610f3f1540
    70610f3f151b:	48 89 9c 24 90 00 00 	mov    %rbx,0x90(%rsp)
    70610f3f1522:	00 
    70610f3f1523:	48 89 84 24 98 00 00 	mov    %rax,0x98(%rsp)
    70610f3f152a:	00 
    70610f3f152b:	e8 d0 75 06 00       	call   0x70610f458b00
    70610f3f1530:	48 8b 9c 24 90 00 00 	mov    0x90(%rsp),%rbx
    70610f3f1537:	00 
    70610f3f1538:	48 8b 84 24 98 00 00 	mov    0x98(%rsp),%rax
    70610f3f153f:	00 
    70610f3f1540:	48 ba 52 9c 9c 14 61 	movabs $0x7061149c9c52,%rdx
    70610f3f1547:	70 00 00 
    70610f3f154a:	49 8d 6d 10          	lea    0x10(%r13),%rbp
    70610f3f154e:	48 8b 4d 00          	mov    0x0(%rbp),%rcx
    70610f3f1552:	48 c7 01 1c 00 00 00 	movq   $0x1c,(%rcx)
    70610f3f1559:	48 83 c9 07          	or     $0x7,%rcx
    70610f3f155d:	48 83 45 00 20       	addq   $0x20,0x0(%rbp)
    70610f3f1562:	48 89 51 01          	mov    %rdx,0x1(%rcx)
    70610f3f1566:	48 89 59 09          	mov    %rbx,0x9(%rcx)
    70610f3f156a:	48 89 41 11          	mov    %rax,0x11(%rcx)
    70610f3f156e:	49 83 ee 08          	sub    $0x8,%r14
    70610f3f1572:	49 89 0e             	mov    %rcx,(%r14)
    70610f3f1575:	89 05 85 2a 16 13    	mov    %eax,0x13162a85(%rip)        # 0x706122554000
    70610f3f157b:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f1582:	c3                   	ret
    70610f3f1583:	48 8b 40 01          	mov    0x1(%rax),%rax
    70610f3f1587:	48 8b 40 0e          	mov    0xe(%rax),%rax
    70610f3f158b:	48 bb 2c 72 9b 14 61 	movabs $0x7061149b722c,%rbx
    70610f3f1592:	70 00 00 
    70610f3f1595:	48 39 d8             	cmp    %rbx,%rax
    70610f3f1598:	0f 85 19 00 00 00    	jne    0x70610f3f15b7
    70610f3f159e:	89 05 5c 2a 16 13    	mov    %eax,0x13162a5c(%rip)        # 0x706122554000
    70610f3f15a4:	48 81 c4 a8 00 00 00 	add    $0xa8,%rsp
    70610f3f15ab:	48 8d 1d 05 00 00 00 	lea    0x5(%rip),%rbx        # 0x70610f3f15b7
    70610f3f15b2:	e9 d9 eb 1e 00       	jmp    0x70610f5e0190
    70610f3f15b7:	48 b8 4c 4e 9a 14 61 	movabs $0x7061149a4e4c,%rax
    70610f3f15be:	70 00 00 
    70610f3f15c1:	49 83 c6 08          	add    $0x8,%r14
    70610f3f15c5:	49 89 06             	mov    %rax,(%r14)
    70610f3f15c8:	e8 f3 7a 43 00       	call   0x70610f8290c0
    70610f3f15cd:	48 b8 4c 4e 9a 14 61 	movabs $0x7061149a4e4c,%rax
    70610f3f15d4:	70 00 00 
    70610f3f15d7:	49 83 c6 08          	add    $0x8,%r14
    70610f3f15db:	49 89 06             	mov    %rax,(%r14)
    70610f3f15de:	e8 dd 7a 43 00       	call   0x70610f8290c0
    70610f3f15e3:	48 b8 4c 4e 9a 14 61 	movabs $0x7061149a4e4c,%rax
    70610f3f15ea:	70 00 00 
    70610f3f15ed:	49 83 c6 08          	add    $0x8,%r14
    70610f3f15f1:	49 89 06             	mov    %rax,(%r14)
    70610f3f15f4:	e8 c7 7a 43 00       	call   0x70610f8290c0
    70610f3f15f9:	48 b8 4c 4e 9a 14 61 	movabs $0x7061149a4e4c,%rax
    70610f3f1600:	70 00 00 
    70610f3f1603:	49 83 c6 08          	add    $0x8,%r14
    70610f3f1607:	49 89 06             	mov    %rax,(%r14)
    70610f3f160a:	e8 b1 7a 43 00       	call   0x70610f8290c0
    70610f3f160f:	00 00                	add    %al,(%rax)
    70610f3f1611:	00 00                	add    %al,(%rax)
    70610f3f1613:	00 06                	add    %al,(%rsi)
    70610f3f1615:	00 00                	add    %al,(%rax)
    70610f3f1617:	03 00                	add    (%rax),%eax
    70610f3f1619:	18 00                	sbb    %al,(%rax)
    70610f3f161b:	00 03                	add    %al,(%rbx)
    70610f3f161d:	00 00                	add    %al,(%rax)
    70610f3f161f:	06                   	(bad)
    70610f3f1620:	00 00                	add    %al,(%rax)
    70610f3f1622:	03 00                	add    (%rax),%eax
    70610f3f1624:	80 01 00             	addb   $0x0,(%rcx)
    70610f3f1627:	c0 00 00             	rolb   $0x0,(%rax)
    70610f3f162a:	60                   	(bad)
    70610f3f162b:	00 00                	add    %al,(%rax)
    70610f3f162d:	30 00                	xor    %al,(%rax)
    70610f3f162f:	00 18                	add    %bl,(%rax)
    70610f3f1631:	00 00                	add    %al,(%rax)
    70610f3f1633:	0c a2                	or     $0xa2,%al
    70610f3f1635:	00 00                	add    %al,(%rax)
    70610f3f1637:	00 6c 02 00          	add    %ch,0x0(%rdx,%rax,1)
    70610f3f163b:	00 5b 03             	add    %bl,0x3(%rbx)
    70610f3f163e:	00 00                	add    %al,(%rax)
    70610f3f1640:	de 03                	fiadds (%rbx)
    70610f3f1642:	00 00                	add    %al,(%rax)
    70610f3f1644:	23 06                	and    (%rsi),%eax
    70610f3f1646:	00 00                	add    %al,(%rax)
    70610f3f1648:	38 09                	cmp    %cl,(%rcx)
    70610f3f164a:	00 00                	add    %al,(%rax)
    70610f3f164c:	20 0b                	and    %cl,(%rbx)
    70610f3f164e:	00 00                	add    %al,(%rax)
    70610f3f1650:	d6                   	udb
    70610f3f1651:	0c 00                	or     $0x0,%al
    70610f3f1653:	00 34 0e             	add    %dh,(%rsi,%rcx,1)
    70610f3f1656:	00 00                	add    %al,(%rax)
    70610f3f1658:	bc 0f 00 00 2b       	mov    $0x2b00000f,%esp
    70610f3f165d:	11 00                	adc    %eax,(%rax)
    70610f3f165f:	00 d0                	add    %dl,%al
    70610f3f1661:	13 00                	adc    (%rax),%eax
    70610f3f1663:	00 15 00 00 00 00    	add    %dl,0x0(%rip)        # 0x70610f3f1669
    70610f3f1669:	00 00                	add    %al,(%rax)
    70610f3f166b:	00 0c 00             	add    %cl,(%rax,%rax,1)
	...
