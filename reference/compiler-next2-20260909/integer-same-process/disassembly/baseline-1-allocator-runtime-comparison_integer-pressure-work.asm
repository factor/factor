
/home/erg/compiler-next2-integer-20260909/disassembly/baseline-1-allocator-runtime-comparison_integer-pressure-work.bin:     file format binary


Disassembly of section .data:

000075da27154040 <.data>:
    75da27154040:	mov    %eax,0x13335fba(%rip)        # 0x75da3a48a000
    75da27154046:	push   %rbx
    75da27154047:	xor    %eax,%eax
    75da27154049:	mov    $0x3e80,%ecx
    75da2715404e:	add    $0x18,%r14
    75da27154052:	movq   $0x0,-0x10(%r14)
    75da2715405a:	jmp    0x75da2715407c
    75da2715405f:	mov    (%r15),%rax
    75da27154062:	mov    -0x8(%r15),%rcx
    75da27154066:	sub    $0x10,%r14
    75da2715406a:	add    $0x10,%rax
    75da2715406e:	mov    %eax,0x13335f8c(%rip)        # 0x75da3a48a000
    75da27154074:	add    $0x10,%r14
    75da27154078:	sub    $0x10,%r15
    75da2715407c:	cmp    %rcx,%rax
    75da2715407f:	jge    0x75da271540df
    75da27154085:	xor    %ebx,%ebx
    75da27154087:	mov    $0x200,%edx
    75da2715408c:	add    $0x10,%r15
    75da27154090:	mov    %rax,(%r15)
    75da27154093:	mov    %rcx,-0x8(%r15)
    75da27154097:	jmp    0x75da271540d1
    75da2715409c:	sub    $0x8,%r14
    75da271540a0:	add    $0x10,%r15
    75da271540a4:	mov    %rbx,(%r15)
    75da271540a7:	mov    %rbx,(%r14)
    75da271540aa:	mov    %rdx,-0x8(%r15)
    75da271540ae:	call   0x75da273c7f90
    75da271540b3:	call   0x75da27365860
    75da271540b8:	mov    (%r15),%rbx
    75da271540bb:	mov    -0x8(%r15),%rdx
    75da271540bf:	add    $0x10,%rbx
    75da271540c3:	mov    %eax,0x13335f37(%rip)        # 0x75da3a48a000
    75da271540c9:	add    $0x10,%r14
    75da271540cd:	sub    $0x10,%r15
    75da271540d1:	cmp    %rdx,%rbx
    75da271540d4:	jge    0x75da2715405f
    75da271540da:	jmp    0x75da2715409c
    75da271540df:	sub    $0x10,%r14
    75da271540e3:	add    $0x8,%r14
    75da271540e7:	movq   $0x2bf20000,(%r14)
    75da271540ee:	mov    %eax,0x13335f0c(%rip)        # 0x75da3a48a000
    75da271540f4:	pop    %rbx
    75da271540f5:	lea    0x5(%rip),%rbx        # 0x75da27154101
    75da271540fc:	jmp    0x75da27693570
	...
