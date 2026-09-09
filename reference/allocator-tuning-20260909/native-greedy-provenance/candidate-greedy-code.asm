
/home/erg/factor-allocator-tuning-greedy-probe-20260909/reference/allocator-tuning-20260909/greedy-code.bin:     file format binary


Disassembly of section .data:

0000000000000000 <.data>:
   0:	89 05 4a ee bf 12    	mov    %eax,0x12bfee4a(%rip)        # 0x12bfee50
   6:	48 81 ec e8 00 00 00 	sub    $0xe8,%rsp
   d:	49 8b 06             	mov    (%r14),%rax
  10:	48 c1 f8 04          	sar    $0x4,%rax
  14:	48 8d 58 01          	lea    0x1(%rax),%rbx
  18:	48 8d 48 02          	lea    0x2(%rax),%rcx
  1c:	48 89 8c 24 e0 00 00 	mov    %rcx,0xe0(%rsp)
  23:	00 
  24:	48 8d 50 03          	lea    0x3(%rax),%rdx
  28:	48 8d 68 04          	lea    0x4(%rax),%rbp
  2c:	48 8d 70 05          	lea    0x5(%rax),%rsi
  30:	48 8d 78 06          	lea    0x6(%rax),%rdi
  34:	4c 8d 40 07          	lea    0x7(%rax),%r8
  38:	4c 8d 48 08          	lea    0x8(%rax),%r9
  3c:	4c 8d 50 09          	lea    0x9(%rax),%r10
  40:	4c 8d 58 0a          	lea    0xa(%rax),%r11
  44:	4c 8d 60 0b          	lea    0xb(%rax),%r12
  48:	48 8d 48 0c          	lea    0xc(%rax),%rcx
  4c:	48 89 0c 24          	mov    %rcx,(%rsp)
  50:	48 8d 48 0d          	lea    0xd(%rax),%rcx
  54:	48 89 4c 24 08       	mov    %rcx,0x8(%rsp)
  59:	48 8d 48 0e          	lea    0xe(%rax),%rcx
  5d:	48 89 4c 24 10       	mov    %rcx,0x10(%rsp)
  62:	48 8d 48 0f          	lea    0xf(%rax),%rcx
  66:	48 89 4c 24 18       	mov    %rcx,0x18(%rsp)
  6b:	48 8d 48 10          	lea    0x10(%rax),%rcx
  6f:	48 89 4c 24 20       	mov    %rcx,0x20(%rsp)
  74:	48 8d 48 11          	lea    0x11(%rax),%rcx
  78:	48 89 4c 24 28       	mov    %rcx,0x28(%rsp)
  7d:	48 8d 48 12          	lea    0x12(%rax),%rcx
  81:	48 89 4c 24 30       	mov    %rcx,0x30(%rsp)
  86:	48 8d 48 13          	lea    0x13(%rax),%rcx
  8a:	48 89 4c 24 38       	mov    %rcx,0x38(%rsp)
  8f:	48 8d 48 14          	lea    0x14(%rax),%rcx
  93:	48 89 4c 24 40       	mov    %rcx,0x40(%rsp)
  98:	48 8d 48 15          	lea    0x15(%rax),%rcx
  9c:	48 89 4c 24 48       	mov    %rcx,0x48(%rsp)
  a1:	48 8d 48 16          	lea    0x16(%rax),%rcx
  a5:	48 89 4c 24 50       	mov    %rcx,0x50(%rsp)
  aa:	48 8d 48 17          	lea    0x17(%rax),%rcx
  ae:	48 89 4c 24 58       	mov    %rcx,0x58(%rsp)
  b3:	48 8d 48 18          	lea    0x18(%rax),%rcx
  b7:	48 89 4c 24 60       	mov    %rcx,0x60(%rsp)
  bc:	48 8d 48 19          	lea    0x19(%rax),%rcx
  c0:	48 89 4c 24 68       	mov    %rcx,0x68(%rsp)
  c5:	48 8d 48 1a          	lea    0x1a(%rax),%rcx
  c9:	48 89 4c 24 70       	mov    %rcx,0x70(%rsp)
  ce:	48 8d 48 1b          	lea    0x1b(%rax),%rcx
  d2:	48 89 4c 24 78       	mov    %rcx,0x78(%rsp)
  d7:	48 8d 48 1c          	lea    0x1c(%rax),%rcx
  db:	48 89 8c 24 80 00 00 	mov    %rcx,0x80(%rsp)
  e2:	00 
  e3:	48 8d 48 1d          	lea    0x1d(%rax),%rcx
  e7:	48 89 8c 24 88 00 00 	mov    %rcx,0x88(%rsp)
  ee:	00 
  ef:	48 8d 48 1e          	lea    0x1e(%rax),%rcx
  f3:	48 89 8c 24 90 00 00 	mov    %rcx,0x90(%rsp)
  fa:	00 
  fb:	48 8d 48 1f          	lea    0x1f(%rax),%rcx
  ff:	48 89 8c 24 98 00 00 	mov    %rcx,0x98(%rsp)
 106:	00 
 107:	48 8d 48 20          	lea    0x20(%rax),%rcx
 10b:	48 89 8c 24 a0 00 00 	mov    %rcx,0xa0(%rsp)
 112:	00 
 113:	48 8d 48 21          	lea    0x21(%rax),%rcx
 117:	48 89 8c 24 a8 00 00 	mov    %rcx,0xa8(%rsp)
 11e:	00 
 11f:	48 8d 48 22          	lea    0x22(%rax),%rcx
 123:	48 89 8c 24 b0 00 00 	mov    %rcx,0xb0(%rsp)
 12a:	00 
 12b:	48 8d 48 23          	lea    0x23(%rax),%rcx
 12f:	48 89 8c 24 b8 00 00 	mov    %rcx,0xb8(%rsp)
 136:	00 
 137:	48 8d 48 24          	lea    0x24(%rax),%rcx
 13b:	48 89 8c 24 c0 00 00 	mov    %rcx,0xc0(%rsp)
 142:	00 
 143:	48 8d 48 25          	lea    0x25(%rax),%rcx
 147:	48 89 8c 24 c8 00 00 	mov    %rcx,0xc8(%rsp)
 14e:	00 
 14f:	48 8d 48 26          	lea    0x26(%rax),%rcx
 153:	48 89 8c 24 d0 00 00 	mov    %rcx,0xd0(%rsp)
 15a:	00 
 15b:	48 8d 48 27          	lea    0x27(%rax),%rcx
 15f:	48 89 8c 24 d8 00 00 	mov    %rcx,0xd8(%rsp)
 166:	00 
 167:	48 83 c0 28          	add    $0x28,%rax
 16b:	48 8b 8c 24 e0 00 00 	mov    0xe0(%rsp),%rcx
 172:	00 
 173:	48 01 cb             	add    %rcx,%rbx
 176:	48 01 d3             	add    %rdx,%rbx
 179:	48 01 eb             	add    %rbp,%rbx
 17c:	48 01 f3             	add    %rsi,%rbx
 17f:	48 01 fb             	add    %rdi,%rbx
 182:	4c 01 c3             	add    %r8,%rbx
 185:	4c 01 cb             	add    %r9,%rbx
 188:	4c 01 d3             	add    %r10,%rbx
 18b:	4c 01 db             	add    %r11,%rbx
 18e:	4c 01 e3             	add    %r12,%rbx
 191:	48 8b 0c 24          	mov    (%rsp),%rcx
 195:	48 01 cb             	add    %rcx,%rbx
 198:	48 8b 4c 24 08       	mov    0x8(%rsp),%rcx
 19d:	48 01 cb             	add    %rcx,%rbx
 1a0:	48 8b 4c 24 10       	mov    0x10(%rsp),%rcx
 1a5:	48 01 cb             	add    %rcx,%rbx
 1a8:	48 8b 4c 24 18       	mov    0x18(%rsp),%rcx
 1ad:	48 01 cb             	add    %rcx,%rbx
 1b0:	48 8b 4c 24 20       	mov    0x20(%rsp),%rcx
 1b5:	48 01 cb             	add    %rcx,%rbx
 1b8:	48 8b 4c 24 28       	mov    0x28(%rsp),%rcx
 1bd:	48 01 cb             	add    %rcx,%rbx
 1c0:	48 8b 4c 24 30       	mov    0x30(%rsp),%rcx
 1c5:	48 01 cb             	add    %rcx,%rbx
 1c8:	48 8b 4c 24 38       	mov    0x38(%rsp),%rcx
 1cd:	48 01 cb             	add    %rcx,%rbx
 1d0:	48 8b 4c 24 40       	mov    0x40(%rsp),%rcx
 1d5:	48 01 cb             	add    %rcx,%rbx
 1d8:	48 8b 4c 24 48       	mov    0x48(%rsp),%rcx
 1dd:	48 01 cb             	add    %rcx,%rbx
 1e0:	48 8b 4c 24 50       	mov    0x50(%rsp),%rcx
 1e5:	48 01 cb             	add    %rcx,%rbx
 1e8:	48 8b 4c 24 58       	mov    0x58(%rsp),%rcx
 1ed:	48 01 cb             	add    %rcx,%rbx
 1f0:	48 8b 4c 24 60       	mov    0x60(%rsp),%rcx
 1f5:	48 01 cb             	add    %rcx,%rbx
 1f8:	48 8b 4c 24 68       	mov    0x68(%rsp),%rcx
 1fd:	48 01 cb             	add    %rcx,%rbx
 200:	48 8b 4c 24 70       	mov    0x70(%rsp),%rcx
 205:	48 01 cb             	add    %rcx,%rbx
 208:	48 8b 4c 24 78       	mov    0x78(%rsp),%rcx
 20d:	48 01 cb             	add    %rcx,%rbx
 210:	48 8b 8c 24 80 00 00 	mov    0x80(%rsp),%rcx
 217:	00 
 218:	48 01 cb             	add    %rcx,%rbx
 21b:	48 8b 8c 24 88 00 00 	mov    0x88(%rsp),%rcx
 222:	00 
 223:	48 01 cb             	add    %rcx,%rbx
 226:	48 8b 8c 24 90 00 00 	mov    0x90(%rsp),%rcx
 22d:	00 
 22e:	48 01 cb             	add    %rcx,%rbx
 231:	48 8b 8c 24 98 00 00 	mov    0x98(%rsp),%rcx
 238:	00 
 239:	48 01 cb             	add    %rcx,%rbx
 23c:	48 8b 8c 24 a0 00 00 	mov    0xa0(%rsp),%rcx
 243:	00 
 244:	48 01 cb             	add    %rcx,%rbx
 247:	48 8b 8c 24 a8 00 00 	mov    0xa8(%rsp),%rcx
 24e:	00 
 24f:	48 01 cb             	add    %rcx,%rbx
 252:	48 8b 8c 24 b0 00 00 	mov    0xb0(%rsp),%rcx
 259:	00 
 25a:	48 01 cb             	add    %rcx,%rbx
 25d:	48 8b 8c 24 b8 00 00 	mov    0xb8(%rsp),%rcx
 264:	00 
 265:	48 01 cb             	add    %rcx,%rbx
 268:	48 8b 8c 24 c0 00 00 	mov    0xc0(%rsp),%rcx
 26f:	00 
 270:	48 01 cb             	add    %rcx,%rbx
 273:	48 8b 8c 24 c8 00 00 	mov    0xc8(%rsp),%rcx
 27a:	00 
 27b:	48 01 cb             	add    %rcx,%rbx
 27e:	48 8b 8c 24 d0 00 00 	mov    0xd0(%rsp),%rcx
 285:	00 
 286:	48 01 cb             	add    %rcx,%rbx
 289:	48 8b 8c 24 d8 00 00 	mov    0xd8(%rsp),%rcx
 290:	00 
 291:	48 01 cb             	add    %rcx,%rbx
 294:	48 01 c3             	add    %rax,%rbx
 297:	48 c1 e3 04          	shl    $0x4,%rbx
 29b:	49 89 1e             	mov    %rbx,(%r14)
 29e:	89 05 ac eb bf 12    	mov    %eax,0x12bfebac(%rip)        # 0x12bfee50
 2a4:	48 81 c4 e8 00 00 00 	add    $0xe8,%rsp
 2ab:	c3                   	ret
 2ac:	00 00                	add    %al,(%rax)
	...
