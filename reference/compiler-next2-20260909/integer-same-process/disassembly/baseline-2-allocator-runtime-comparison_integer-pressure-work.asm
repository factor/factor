
/home/erg/compiler-next2-integer-20260909/disassembly/baseline-2-allocator-runtime-comparison_integer-pressure-work.bin:     file format binary


Disassembly of section .data:

00007b39b9c43040 <.data>:
    7b39b9c43040:	mov    %eax,0x13376fba(%rip)        # 0x7b39ccfba000
    7b39b9c43046:	push   %rbx
    7b39b9c43047:	xor    %eax,%eax
    7b39b9c43049:	mov    $0x3e80,%ecx
    7b39b9c4304e:	add    $0x18,%r14
    7b39b9c43052:	movq   $0x0,-0x10(%r14)
    7b39b9c4305a:	jmp    0x7b39b9c4307c
    7b39b9c4305f:	mov    (%r15),%rax
    7b39b9c43062:	mov    -0x8(%r15),%rcx
    7b39b9c43066:	sub    $0x10,%r14
    7b39b9c4306a:	add    $0x10,%rax
    7b39b9c4306e:	mov    %eax,0x13376f8c(%rip)        # 0x7b39ccfba000
    7b39b9c43074:	add    $0x10,%r14
    7b39b9c43078:	sub    $0x10,%r15
    7b39b9c4307c:	cmp    %rcx,%rax
    7b39b9c4307f:	jge    0x7b39b9c430df
    7b39b9c43085:	xor    %ebx,%ebx
    7b39b9c43087:	mov    $0x200,%edx
    7b39b9c4308c:	add    $0x10,%r15
    7b39b9c43090:	mov    %rax,(%r15)
    7b39b9c43093:	mov    %rcx,-0x8(%r15)
    7b39b9c43097:	jmp    0x7b39b9c430d1
    7b39b9c4309c:	sub    $0x8,%r14
    7b39b9c430a0:	add    $0x10,%r15
    7b39b9c430a4:	mov    %rbx,(%r15)
    7b39b9c430a7:	mov    %rbx,(%r14)
    7b39b9c430aa:	mov    %rdx,-0x8(%r15)
    7b39b9c430ae:	call   0x7b39b9eb6f90
    7b39b9c430b3:	call   0x7b39b9e54860
    7b39b9c430b8:	mov    (%r15),%rbx
    7b39b9c430bb:	mov    -0x8(%r15),%rdx
    7b39b9c430bf:	add    $0x10,%rbx
    7b39b9c430c3:	mov    %eax,0x13376f37(%rip)        # 0x7b39ccfba000
    7b39b9c430c9:	add    $0x10,%r14
    7b39b9c430cd:	sub    $0x10,%r15
    7b39b9c430d1:	cmp    %rdx,%rbx
    7b39b9c430d4:	jge    0x7b39b9c4305f
    7b39b9c430da:	jmp    0x7b39b9c4309c
    7b39b9c430df:	sub    $0x10,%r14
    7b39b9c430e3:	add    $0x8,%r14
    7b39b9c430e7:	movq   $0x2bf20000,(%r14)
    7b39b9c430ee:	mov    %eax,0x13376f0c(%rip)        # 0x7b39ccfba000
    7b39b9c430f4:	pop    %rbx
    7b39b9c430f5:	lea    0x5(%rip),%rbx        # 0x7b39b9c43101
    7b39b9c430fc:	jmp    0x7b39ba182570
	...
