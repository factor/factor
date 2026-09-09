
/home/erg/compiler-next2-integer-20260909/disassembly/candidate-1-math_plus.bin:     file format binary


Disassembly of section .data:

000077d34dee58d0 <.data>:
    77d34dee58d0:	mov    %eax,0x1313372a(%rip)        # 0x77d361019000
    77d34dee58d6:	sub    $0xa8,%rsp
    77d34dee58dd:	mov    (%r14),%rax
    77d34dee58e0:	mov    -0x8(%r14),%rbx
    77d34dee58e4:	mov    %rbx,%rcx
    77d34dee58e7:	mov    %rax,%rdx
    77d34dee58ea:	or     %rdx,%rcx
    77d34dee58ed:	test   $0xf,%ecx
    77d34dee58f3:	jne    0x77d34dee5930
    77d34dee58f9:	add    %rax,%rbx
    77d34dee58fc:	jo     0x77d34dee5917
    77d34dee5902:	sub    $0x8,%r14
    77d34dee5906:	mov    %rbx,(%r14)
    77d34dee5909:	mov    %eax,0x131336f1(%rip)        # 0x77d361019000
    77d34dee590f:	add    $0xa8,%rsp
    77d34dee5916:	ret
    77d34dee5917:	mov    %eax,0x131336e3(%rip)        # 0x77d361019000
    77d34dee591d:	add    $0xa8,%rsp
    77d34dee5924:	lea    0x5(%rip),%rbx        # 0x77d34dee5930
    77d34dee592b:	jmp    0x77d34ce4c130
    77d34dee5930:	mov    %rbx,%rcx
    77d34dee5933:	test   $0xf,%ecx
    77d34dee5939:	jne    0x77d34dee5be9
    77d34dee593f:	mov    %rax,%rcx
    77d34dee5942:	and    $0xf,%ecx
    77d34dee5945:	cmp    $0x3,%rcx
    77d34dee5949:	jne    0x77d34dee59c2
    77d34dee594f:	lea    0x10(%r13),%rdx
    77d34dee5953:	mov    (%rdx),%rcx
    77d34dee5956:	add    $0x10,%rcx
    77d34dee595a:	cmp    0x10(%rdx),%rcx
    77d34dee595e:	jle    0x77d34dee597b
    77d34dee5964:	mov    %rbx,(%rsp)
    77d34dee5968:	mov    %rax,0x8(%rsp)
    77d34dee596d:	call   0x77d34df4ea00
    77d34dee5972:	mov    (%rsp),%rbx
    77d34dee5976:	mov    0x8(%rsp),%rax
    77d34dee597b:	sar    $0x4,%rbx
    77d34dee597f:	xorps  %xmm0,%xmm0
    77d34dee5982:	cvtsi2sd %rbx,%xmm0
    77d34dee5987:	rex.W movsd 0x5(%rax),%xmm1
    77d34dee598d:	addsd  %xmm1,%xmm0
    77d34dee5991:	lea    0x10(%r13),%rbx
    77d34dee5995:	mov    (%rbx),%rax
    77d34dee5998:	movq   $0xc,(%rax)
    77d34dee599f:	or     $0x3,%rax
    77d34dee59a3:	addq   $0x10,(%rbx)
    77d34dee59a7:	rex.W movsd %xmm0,0x5(%rax)
    77d34dee59ad:	sub    $0x8,%r14
    77d34dee59b1:	mov    %rax,(%r14)
    77d34dee59b4:	mov    %eax,0x13133646(%rip)        # 0x77d361019000
    77d34dee59ba:	add    $0xa8,%rsp
    77d34dee59c1:	ret
    77d34dee59c2:	mov    %rax,%rbx
    77d34dee59c5:	and    $0xf,%ebx
    77d34dee59c8:	cmp    $0x5,%rbx
    77d34dee59cc:	jne    0x77d34dee5a09
    77d34dee59d2:	sub    $0x8,%r14
    77d34dee59d6:	add    $0x8,%r15
    77d34dee59da:	mov    %rax,(%r15)
    77d34dee59dd:	call   0x77d34e323340
    77d34dee59e2:	mov    (%r15),%rax
    77d34dee59e5:	add    $0x8,%r14
    77d34dee59e9:	sub    $0x8,%r15
    77d34dee59ed:	mov    %rax,(%r14)
    77d34dee59f0:	mov    %eax,0x1313360a(%rip)        # 0x77d361019000
    77d34dee59f6:	add    $0xa8,%rsp
    77d34dee59fd:	lea    0x5(%rip),%rbx        # 0x77d34dee5a09
    77d34dee5a04:	jmp    0x77d34e251620
    77d34dee5a09:	mov    %rax,%rbx
    77d34dee5a0c:	and    $0xf,%ebx
    77d34dee5a0f:	cmp    $0x7,%rbx
    77d34dee5a13:	jne    0x77d34dee5bd3
    77d34dee5a19:	mov    0x1(%rax),%rbx
    77d34dee5a1d:	mov    0xe(%rbx),%rbx
    77d34dee5a21:	movabs $0x77d3534c8fdc,%rcx
    77d34dee5a2b:	cmp    %rcx,%rbx
    77d34dee5a2e:	jne    0x77d34dee5b89
    77d34dee5a34:	mov    0x9(%rax),%rbx
    77d34dee5a38:	mov    0x11(%rax),%rax
    77d34dee5a3c:	add    $0x10,%r15
    77d34dee5a40:	mov    %rax,-0x8(%r15)
    77d34dee5a44:	mov    %rbx,(%r14)
    77d34dee5a47:	movq   $0x0,(%r15)
    77d34dee5a4e:	call   0x77d34dee58d0
    77d34dee5a53:	mov    (%r15),%rbx
    77d34dee5a56:	mov    -0x8(%r15),%rax
    77d34dee5a5a:	add    $0x10,%r14
    77d34dee5a5e:	sub    $0x10,%r15
    77d34dee5a62:	mov    %rbx,-0x8(%r14)
    77d34dee5a66:	mov    %rax,(%r14)
    77d34dee5a69:	call   0x77d34dee58d0
    77d34dee5a6e:	mov    (%r14),%rax
    77d34dee5a71:	add    $0x8,%r14
    77d34dee5a75:	cmp    $0x0,%rax
    77d34dee5a79:	jne    0x77d34dee5a95
    77d34dee5a7f:	sub    $0x8,%r14
    77d34dee5a83:	sub    $0x8,%r14
    77d34dee5a87:	mov    %eax,0x13133573(%rip)        # 0x77d361019000
    77d34dee5a8d:	add    $0xa8,%rsp
    77d34dee5a94:	ret
    77d34dee5a95:	mov    %rax,%rbx
    77d34dee5a98:	test   $0xf,%ebx
    77d34dee5a9e:	jne    0x77d34dee5ab4
    77d34dee5aa4:	sub    $0x8,%r14
    77d34dee5aa8:	mov    (%r14),%rax
    77d34dee5aab:	mov    -0x8(%r14),%rbx
    77d34dee5aaf:	jmp    0x77d34dee5b18
    77d34dee5ab4:	mov    %rax,%rbx
    77d34dee5ab7:	and    $0xf,%ebx
    77d34dee5aba:	cmp    $0x5,%rbx
    77d34dee5abe:	jne    0x77d34dee5b0d
    77d34dee5ac4:	movabs $0x77d353557005,%rbx
    77d34dee5ace:	add    $0x8,%r14
    77d34dee5ad2:	mov    %rax,-0x8(%r14)
    77d34dee5ad6:	mov    %rbx,(%r14)
    77d34dee5ad9:	call   0x77d34e24a2e0
    77d34dee5ade:	mov    (%r14),%rax
    77d34dee5ae1:	sub    $0x8,%r14
    77d34dee5ae5:	cmp    $0x1,%rax
    77d34dee5ae9:	je     0x77d34dee5b01
    77d34dee5aef:	sub    $0x8,%r14
    77d34dee5af3:	mov    %eax,0x13133507(%rip)        # 0x77d361019000
    77d34dee5af9:	add    $0xa8,%rsp
    77d34dee5b00:	ret
    77d34dee5b01:	mov    (%r14),%rax
    77d34dee5b04:	mov    -0x8(%r14),%rbx
    77d34dee5b08:	jmp    0x77d34dee5b18
    77d34dee5b0d:	sub    $0x8,%r14
    77d34dee5b11:	mov    (%r14),%rax
    77d34dee5b14:	mov    -0x8(%r14),%rbx
    77d34dee5b18:	lea    0x10(%r13),%rdx
    77d34dee5b1c:	mov    (%rdx),%rcx
    77d34dee5b1f:	add    $0x20,%rcx
    77d34dee5b23:	cmp    0x10(%rdx),%rcx
    77d34dee5b27:	jle    0x77d34dee5b46
    77d34dee5b2d:	mov    %rbx,0x10(%rsp)
    77d34dee5b32:	mov    %rax,0x18(%rsp)
    77d34dee5b37:	call   0x77d34df4ea00
    77d34dee5b3c:	mov    0x10(%rsp),%rbx
    77d34dee5b41:	mov    0x18(%rsp),%rax
    77d34dee5b46:	movabs $0x77d3534c8ba2,%rdx
    77d34dee5b50:	lea    0x10(%r13),%rbp
    77d34dee5b54:	mov    0x0(%rbp),%rcx
    77d34dee5b58:	movq   $0x1c,(%rcx)
    77d34dee5b5f:	or     $0x7,%rcx
    77d34dee5b63:	addq   $0x20,0x0(%rbp)
    77d34dee5b68:	mov    %rdx,0x1(%rcx)
    77d34dee5b6c:	mov    %rbx,0x9(%rcx)
    77d34dee5b70:	mov    %rax,0x11(%rcx)
    77d34dee5b74:	sub    $0x8,%r14
    77d34dee5b78:	mov    %rcx,(%r14)
    77d34dee5b7b:	mov    %eax,0x1313347f(%rip)        # 0x77d361019000
    77d34dee5b81:	add    $0xa8,%rsp
    77d34dee5b88:	ret
    77d34dee5b89:	mov    0x1(%rax),%rax
    77d34dee5b8d:	mov    0xe(%rax),%rax
    77d34dee5b91:	movabs $0x77d3534b617c,%rbx
    77d34dee5b9b:	cmp    %rbx,%rax
    77d34dee5b9e:	jne    0x77d34dee5bbd
    77d34dee5ba4:	mov    %eax,0x13133456(%rip)        # 0x77d361019000
    77d34dee5baa:	add    $0xa8,%rsp
    77d34dee5bb1:	lea    0x5(%rip),%rbx        # 0x77d34dee5bbd
    77d34dee5bb8:	jmp    0x77d34e0d5960
    77d34dee5bbd:	movabs $0x77d3534a3d9c,%rax
    77d34dee5bc7:	add    $0x8,%r14
    77d34dee5bcb:	mov    %rax,(%r14)
    77d34dee5bce:	call   0x77d34e31e3d0
    77d34dee5bd3:	movabs $0x77d3534a3d9c,%rax
    77d34dee5bdd:	add    $0x8,%r14
    77d34dee5be1:	mov    %rax,(%r14)
    77d34dee5be4:	call   0x77d34e31e3d0
    77d34dee5be9:	mov    %rbx,%rcx
    77d34dee5bec:	and    $0xf,%ecx
    77d34dee5bef:	cmp    $0x3,%rcx
    77d34dee5bf3:	jne    0x77d34dee5fee
    77d34dee5bf9:	mov    %rax,%rcx
    77d34dee5bfc:	test   $0xf,%ecx
    77d34dee5c02:	jne    0x77d34dee5c7b
    77d34dee5c08:	lea    0x10(%r13),%rcx
    77d34dee5c0c:	mov    (%rcx),%rdx
    77d34dee5c0f:	add    $0x10,%rdx
    77d34dee5c13:	cmp    0x10(%rcx),%rdx
    77d34dee5c17:	jle    0x77d34dee5c34
    77d34dee5c1d:	mov    %rbx,(%rsp)
    77d34dee5c21:	mov    %rax,0x8(%rsp)
    77d34dee5c26:	call   0x77d34df4ea00
    77d34dee5c2b:	mov    (%rsp),%rbx
    77d34dee5c2f:	mov    0x8(%rsp),%rax
    77d34dee5c34:	sar    $0x4,%rax
    77d34dee5c38:	xorps  %xmm1,%xmm1
    77d34dee5c3b:	cvtsi2sd %rax,%xmm1
    77d34dee5c40:	rex.W movsd 0x5(%rbx),%xmm0
    77d34dee5c46:	addsd  %xmm1,%xmm0
    77d34dee5c4a:	lea    0x10(%r13),%rbx
    77d34dee5c4e:	mov    (%rbx),%rax
    77d34dee5c51:	movq   $0xc,(%rax)
    77d34dee5c58:	or     $0x3,%rax
    77d34dee5c5c:	addq   $0x10,(%rbx)
    77d34dee5c60:	rex.W movsd %xmm0,0x5(%rax)
    77d34dee5c66:	sub    $0x8,%r14
    77d34dee5c6a:	mov    %rax,(%r14)
    77d34dee5c6d:	mov    %eax,0x1313338d(%rip)        # 0x77d361019000
    77d34dee5c73:	add    $0xa8,%rsp
    77d34dee5c7a:	ret
    77d34dee5c7b:	mov    %rax,%rcx
    77d34dee5c7e:	and    $0xf,%ecx
    77d34dee5c81:	cmp    $0x3,%rcx
    77d34dee5c85:	jne    0x77d34dee5cf8
    77d34dee5c8b:	lea    0x10(%r13),%rcx
    77d34dee5c8f:	mov    (%rcx),%rdx
    77d34dee5c92:	add    $0x10,%rdx
    77d34dee5c96:	cmp    0x10(%rcx),%rdx
    77d34dee5c9a:	jle    0x77d34dee5cb7
    77d34dee5ca0:	mov    %rbx,(%rsp)
    77d34dee5ca4:	mov    %rax,0x8(%rsp)
    77d34dee5ca9:	call   0x77d34df4ea00
    77d34dee5cae:	mov    (%rsp),%rbx
    77d34dee5cb2:	mov    0x8(%rsp),%rax
    77d34dee5cb7:	rex.W movsd 0x5(%rbx),%xmm0
    77d34dee5cbd:	rex.W movsd 0x5(%rax),%xmm1
    77d34dee5cc3:	addsd  %xmm1,%xmm0
    77d34dee5cc7:	lea    0x10(%r13),%rbx
    77d34dee5ccb:	mov    (%rbx),%rax
    77d34dee5cce:	movq   $0xc,(%rax)
    77d34dee5cd5:	or     $0x3,%rax
    77d34dee5cd9:	addq   $0x10,(%rbx)
    77d34dee5cdd:	rex.W movsd %xmm0,0x5(%rax)
    77d34dee5ce3:	sub    $0x8,%r14
    77d34dee5ce7:	mov    %rax,(%r14)
    77d34dee5cea:	mov    %eax,0x13133310(%rip)        # 0x77d361019000
    77d34dee5cf0:	add    $0xa8,%rsp
    77d34dee5cf7:	ret
    77d34dee5cf8:	mov    %rax,%rbx
    77d34dee5cfb:	and    $0xf,%ebx
    77d34dee5cfe:	cmp    $0x5,%rbx
    77d34dee5d02:	jne    0x77d34dee5d6f
    77d34dee5d08:	call   0x77d34dd1d310
    77d34dee5d0d:	lea    0x10(%r13),%rbx
    77d34dee5d11:	mov    (%rbx),%rax
    77d34dee5d14:	add    $0x10,%rax
    77d34dee5d18:	cmp    0x10(%rbx),%rax
    77d34dee5d1c:	jle    0x77d34dee5d27
    77d34dee5d22:	call   0x77d34df4ea00
    77d34dee5d27:	mov    (%r14),%rax
    77d34dee5d2a:	mov    -0x8(%r14),%rbx
    77d34dee5d2e:	rex.W movsd 0x5(%rbx),%xmm0
    77d34dee5d34:	rex.W movsd 0x5(%rax),%xmm1
    77d34dee5d3a:	addsd  %xmm1,%xmm0
    77d34dee5d3e:	lea    0x10(%r13),%rbx
    77d34dee5d42:	mov    (%rbx),%rax
    77d34dee5d45:	movq   $0xc,(%rax)
    77d34dee5d4c:	or     $0x3,%rax
    77d34dee5d50:	addq   $0x10,(%rbx)
    77d34dee5d54:	rex.W movsd %xmm0,0x5(%rax)
    77d34dee5d5a:	sub    $0x8,%r14
    77d34dee5d5e:	mov    %rax,(%r14)
    77d34dee5d61:	mov    %eax,0x13133299(%rip)        # 0x77d361019000
    77d34dee5d67:	add    $0xa8,%rsp
    77d34dee5d6e:	ret
    77d34dee5d6f:	mov    %rax,%rbx
    77d34dee5d72:	and    $0xf,%ebx
    77d34dee5d75:	cmp    $0x7,%rbx
    77d34dee5d79:	jne    0x77d34dee5fd8
    77d34dee5d7f:	mov    0x1(%rax),%rbx
    77d34dee5d83:	mov    0xe(%rbx),%rbx
    77d34dee5d87:	movabs $0x77d3534c8fdc,%rcx
    77d34dee5d91:	cmp    %rcx,%rbx
    77d34dee5d94:	jne    0x77d34dee5f40
    77d34dee5d9a:	mov    0x9(%rax),%rbx
    77d34dee5d9e:	mov    0x11(%rax),%rax
    77d34dee5da2:	add    $0x10,%r15
    77d34dee5da6:	mov    %rax,-0x8(%r15)
    77d34dee5daa:	mov    %rbx,(%r14)
    77d34dee5dad:	movq   $0x0,(%r15)
    77d34dee5db4:	call   0x77d34cd29d20
    77d34dee5db9:	lea    0x10(%r13),%rbx
    77d34dee5dbd:	mov    (%rbx),%rax
    77d34dee5dc0:	add    $0x10,%rax
    77d34dee5dc4:	cmp    0x10(%rbx),%rax
    77d34dee5dc8:	jle    0x77d34dee5dd3
    77d34dee5dce:	call   0x77d34df4ea00
    77d34dee5dd3:	mov    (%r14),%rcx
    77d34dee5dd6:	mov    (%r15),%rax
    77d34dee5dd9:	mov    -0x8(%r14),%rdx
    77d34dee5ddd:	mov    -0x8(%r15),%rbx
    77d34dee5de1:	rex.W movsd 0x5(%rdx),%xmm0
    77d34dee5de7:	rex.W movsd 0x5(%rcx),%xmm1
    77d34dee5ded:	addsd  %xmm1,%xmm0
    77d34dee5df1:	lea    0x10(%r13),%rdx
    77d34dee5df5:	mov    (%rdx),%rcx
    77d34dee5df8:	movq   $0xc,(%rcx)
    77d34dee5dff:	or     $0x3,%rcx
    77d34dee5e03:	addq   $0x10,(%rdx)
    77d34dee5e07:	rex.W movsd %xmm0,0x5(%rcx)
    77d34dee5e0d:	add    $0x8,%r14
    77d34dee5e11:	sub    $0x10,%r15
    77d34dee5e15:	mov    %rax,-0x8(%r14)
    77d34dee5e19:	mov    %rbx,(%r14)
    77d34dee5e1c:	mov    %rcx,-0x10(%r14)
    77d34dee5e20:	call   0x77d34dee58d0
    77d34dee5e25:	mov    (%r14),%rax
    77d34dee5e28:	add    $0x8,%r14
    77d34dee5e2c:	cmp    $0x0,%rax
    77d34dee5e30:	jne    0x77d34dee5e4c
    77d34dee5e36:	sub    $0x8,%r14
    77d34dee5e3a:	sub    $0x8,%r14
    77d34dee5e3e:	mov    %eax,0x131331bc(%rip)        # 0x77d361019000
    77d34dee5e44:	add    $0xa8,%rsp
    77d34dee5e4b:	ret
    77d34dee5e4c:	mov    %rax,%rbx
    77d34dee5e4f:	test   $0xf,%ebx
    77d34dee5e55:	jne    0x77d34dee5e6b
    77d34dee5e5b:	sub    $0x8,%r14
    77d34dee5e5f:	mov    (%r14),%rax
    77d34dee5e62:	mov    -0x8(%r14),%rbx
    77d34dee5e66:	jmp    0x77d34dee5ecf
    77d34dee5e6b:	mov    %rax,%rbx
    77d34dee5e6e:	and    $0xf,%ebx
    77d34dee5e71:	cmp    $0x5,%rbx
    77d34dee5e75:	jne    0x77d34dee5ec4
    77d34dee5e7b:	movabs $0x77d353557005,%rbx
    77d34dee5e85:	add    $0x8,%r14
    77d34dee5e89:	mov    %rax,-0x8(%r14)
    77d34dee5e8d:	mov    %rbx,(%r14)
    77d34dee5e90:	call   0x77d34e24a2e0
    77d34dee5e95:	mov    (%r14),%rax
    77d34dee5e98:	sub    $0x8,%r14
    77d34dee5e9c:	cmp    $0x1,%rax
    77d34dee5ea0:	je     0x77d34dee5eb8
    77d34dee5ea6:	sub    $0x8,%r14
    77d34dee5eaa:	mov    %eax,0x13133150(%rip)        # 0x77d361019000
    77d34dee5eb0:	add    $0xa8,%rsp
    77d34dee5eb7:	ret
    77d34dee5eb8:	mov    (%r14),%rax
    77d34dee5ebb:	mov    -0x8(%r14),%rbx
    77d34dee5ebf:	jmp    0x77d34dee5ecf
    77d34dee5ec4:	sub    $0x8,%r14
    77d34dee5ec8:	mov    (%r14),%rax
    77d34dee5ecb:	mov    -0x8(%r14),%rbx
    77d34dee5ecf:	lea    0x10(%r13),%rcx
    77d34dee5ed3:	mov    (%rcx),%rdx
    77d34dee5ed6:	add    $0x20,%rdx
    77d34dee5eda:	cmp    0x10(%rcx),%rdx
    77d34dee5ede:	jle    0x77d34dee5efd
    77d34dee5ee4:	mov    %rbx,0x20(%rsp)
    77d34dee5ee9:	mov    %rax,0x28(%rsp)
    77d34dee5eee:	call   0x77d34df4ea00
    77d34dee5ef3:	mov    0x20(%rsp),%rbx
    77d34dee5ef8:	mov    0x28(%rsp),%rax
    77d34dee5efd:	movabs $0x77d3534c8ba2,%rdx
    77d34dee5f07:	lea    0x10(%r13),%rbp
    77d34dee5f0b:	mov    0x0(%rbp),%rcx
    77d34dee5f0f:	movq   $0x1c,(%rcx)
    77d34dee5f16:	or     $0x7,%rcx
    77d34dee5f1a:	addq   $0x20,0x0(%rbp)
    77d34dee5f1f:	mov    %rdx,0x1(%rcx)
    77d34dee5f23:	mov    %rbx,0x9(%rcx)
    77d34dee5f27:	mov    %rax,0x11(%rcx)
    77d34dee5f2b:	sub    $0x8,%r14
    77d34dee5f2f:	mov    %rcx,(%r14)
    77d34dee5f32:	mov    %eax,0x131330c8(%rip)        # 0x77d361019000
    77d34dee5f38:	add    $0xa8,%rsp
    77d34dee5f3f:	ret
    77d34dee5f40:	mov    0x1(%rax),%rax
    77d34dee5f44:	mov    0xe(%rax),%rax
    77d34dee5f48:	movabs $0x77d3534b617c,%rbx
    77d34dee5f52:	cmp    %rbx,%rax
    77d34dee5f55:	jne    0x77d34dee5fc2
    77d34dee5f5b:	call   0x77d34dc6fa60
    77d34dee5f60:	lea    0x10(%r13),%rbx
    77d34dee5f64:	mov    (%rbx),%rax
    77d34dee5f67:	add    $0x10,%rax
    77d34dee5f6b:	cmp    0x10(%rbx),%rax
    77d34dee5f6f:	jle    0x77d34dee5f7a
    77d34dee5f75:	call   0x77d34df4ea00
    77d34dee5f7a:	mov    (%r14),%rax
    77d34dee5f7d:	mov    -0x8(%r14),%rbx
    77d34dee5f81:	rex.W movsd 0x5(%rbx),%xmm0
    77d34dee5f87:	rex.W movsd 0x5(%rax),%xmm1
    77d34dee5f8d:	addsd  %xmm1,%xmm0
    77d34dee5f91:	lea    0x10(%r13),%rbx
    77d34dee5f95:	mov    (%rbx),%rax
    77d34dee5f98:	movq   $0xc,(%rax)
    77d34dee5f9f:	or     $0x3,%rax
    77d34dee5fa3:	addq   $0x10,(%rbx)
    77d34dee5fa7:	rex.W movsd %xmm0,0x5(%rax)
    77d34dee5fad:	sub    $0x8,%r14
    77d34dee5fb1:	mov    %rax,(%r14)
    77d34dee5fb4:	mov    %eax,0x13133046(%rip)        # 0x77d361019000
    77d34dee5fba:	add    $0xa8,%rsp
    77d34dee5fc1:	ret
    77d34dee5fc2:	movabs $0x77d3534a3d9c,%rax
    77d34dee5fcc:	add    $0x8,%r14
    77d34dee5fd0:	mov    %rax,(%r14)
    77d34dee5fd3:	call   0x77d34e31e3d0
    77d34dee5fd8:	movabs $0x77d3534a3d9c,%rax
    77d34dee5fe2:	add    $0x8,%r14
    77d34dee5fe6:	mov    %rax,(%r14)
    77d34dee5fe9:	call   0x77d34e31e3d0
    77d34dee5fee:	mov    %rbx,%rcx
    77d34dee5ff1:	and    $0xf,%ecx
    77d34dee5ff4:	cmp    $0x5,%rcx
    77d34dee5ff8:	jne    0x77d34dee62b5
    77d34dee5ffe:	mov    %rax,%rbx
    77d34dee6001:	test   $0xf,%ebx
    77d34dee6007:	jne    0x77d34dee602b
    77d34dee600d:	call   0x77d34e323340
    77d34dee6012:	mov    %eax,0x13132fe8(%rip)        # 0x77d361019000
    77d34dee6018:	add    $0xa8,%rsp
    77d34dee601f:	lea    0x5(%rip),%rbx        # 0x77d34dee602b
    77d34dee6026:	jmp    0x77d34e251620
    77d34dee602b:	mov    %rax,%rbx
    77d34dee602e:	and    $0xf,%ebx
    77d34dee6031:	cmp    $0x3,%rbx
    77d34dee6035:	jne    0x77d34dee60ac
    77d34dee603b:	sub    $0x8,%r14
    77d34dee603f:	add    $0x8,%r15
    77d34dee6043:	mov    %rax,(%r15)
    77d34dee6046:	call   0x77d34dd1d310
    77d34dee604b:	lea    0x10(%r13),%rax
    77d34dee604f:	mov    (%rax),%rbx
    77d34dee6052:	add    $0x10,%rbx
    77d34dee6056:	cmp    0x10(%rax),%rbx
    77d34dee605a:	jle    0x77d34dee6065
    77d34dee6060:	call   0x77d34df4ea00
    77d34dee6065:	mov    (%r15),%rax
    77d34dee6068:	mov    (%r14),%rbx
    77d34dee606b:	rex.W movsd 0x5(%rbx),%xmm0
    77d34dee6071:	rex.W movsd 0x5(%rax),%xmm1
    77d34dee6077:	addsd  %xmm1,%xmm0
    77d34dee607b:	lea    0x10(%r13),%rbx
    77d34dee607f:	mov    (%rbx),%rax
    77d34dee6082:	movq   $0xc,(%rax)
    77d34dee6089:	or     $0x3,%rax
    77d34dee608d:	addq   $0x10,(%rbx)
    77d34dee6091:	rex.W movsd %xmm0,0x5(%rax)
    77d34dee6097:	sub    $0x8,%r15
    77d34dee609b:	mov    %rax,(%r14)
    77d34dee609e:	mov    %eax,0x13132f5c(%rip)        # 0x77d361019000
    77d34dee60a4:	add    $0xa8,%rsp
    77d34dee60ab:	ret
    77d34dee60ac:	mov    %rax,%rbx
    77d34dee60af:	and    $0xf,%ebx
    77d34dee60b2:	cmp    $0x5,%rbx
    77d34dee60b6:	jne    0x77d34dee60d5
    77d34dee60bc:	mov    %eax,0x13132f3e(%rip)        # 0x77d361019000
    77d34dee60c2:	add    $0xa8,%rsp
    77d34dee60c9:	lea    0x5(%rip),%rbx        # 0x77d34dee60d5
    77d34dee60d0:	jmp    0x77d34e251620
    77d34dee60d5:	mov    %rax,%rbx
    77d34dee60d8:	and    $0xf,%ebx
    77d34dee60db:	cmp    $0x7,%rbx
    77d34dee60df:	jne    0x77d34dee629f
    77d34dee60e5:	mov    0x1(%rax),%rbx
    77d34dee60e9:	mov    0xe(%rbx),%rbx
    77d34dee60ed:	movabs $0x77d3534c8fdc,%rcx
    77d34dee60f7:	cmp    %rcx,%rbx
    77d34dee60fa:	jne    0x77d34dee6255
    77d34dee6100:	mov    0x9(%rax),%rbx
    77d34dee6104:	mov    0x11(%rax),%rax
    77d34dee6108:	add    $0x10,%r15
    77d34dee610c:	mov    %rax,-0x8(%r15)
    77d34dee6110:	mov    %rbx,(%r14)
    77d34dee6113:	movq   $0x0,(%r15)
    77d34dee611a:	call   0x77d34dee58d0
    77d34dee611f:	mov    (%r15),%rbx
    77d34dee6122:	mov    -0x8(%r15),%rax
    77d34dee6126:	add    $0x10,%r14
    77d34dee612a:	sub    $0x10,%r15
    77d34dee612e:	mov    %rbx,-0x8(%r14)
    77d34dee6132:	mov    %rax,(%r14)
    77d34dee6135:	call   0x77d34dee58d0
    77d34dee613a:	mov    (%r14),%rax
    77d34dee613d:	add    $0x8,%r14
    77d34dee6141:	cmp    $0x0,%rax
    77d34dee6145:	jne    0x77d34dee6161
    77d34dee614b:	sub    $0x8,%r14
    77d34dee614f:	sub    $0x8,%r14
    77d34dee6153:	mov    %eax,0x13132ea7(%rip)        # 0x77d361019000
    77d34dee6159:	add    $0xa8,%rsp
    77d34dee6160:	ret
    77d34dee6161:	mov    %rax,%rbx
    77d34dee6164:	test   $0xf,%ebx
    77d34dee616a:	jne    0x77d34dee6180
    77d34dee6170:	sub    $0x8,%r14
    77d34dee6174:	mov    (%r14),%rax
    77d34dee6177:	mov    -0x8(%r14),%rbx
    77d34dee617b:	jmp    0x77d34dee61e4
    77d34dee6180:	mov    %rax,%rbx
    77d34dee6183:	and    $0xf,%ebx
    77d34dee6186:	cmp    $0x5,%rbx
    77d34dee618a:	jne    0x77d34dee61d9
    77d34dee6190:	movabs $0x77d353557005,%rbx
    77d34dee619a:	add    $0x8,%r14
    77d34dee619e:	mov    %rax,-0x8(%r14)
    77d34dee61a2:	mov    %rbx,(%r14)
    77d34dee61a5:	call   0x77d34e24a2e0
    77d34dee61aa:	mov    (%r14),%rax
    77d34dee61ad:	sub    $0x8,%r14
    77d34dee61b1:	cmp    $0x1,%rax
    77d34dee61b5:	je     0x77d34dee61cd
    77d34dee61bb:	sub    $0x8,%r14
    77d34dee61bf:	mov    %eax,0x13132e3b(%rip)        # 0x77d361019000
    77d34dee61c5:	add    $0xa8,%rsp
    77d34dee61cc:	ret
    77d34dee61cd:	mov    (%r14),%rax
    77d34dee61d0:	mov    -0x8(%r14),%rbx
    77d34dee61d4:	jmp    0x77d34dee61e4
    77d34dee61d9:	sub    $0x8,%r14
    77d34dee61dd:	mov    (%r14),%rax
    77d34dee61e0:	mov    -0x8(%r14),%rbx
    77d34dee61e4:	lea    0x10(%r13),%rcx
    77d34dee61e8:	mov    (%rcx),%rdx
    77d34dee61eb:	add    $0x20,%rdx
    77d34dee61ef:	cmp    0x10(%rcx),%rdx
    77d34dee61f3:	jle    0x77d34dee6212
    77d34dee61f9:	mov    %rbx,0x30(%rsp)
    77d34dee61fe:	mov    %rax,0x38(%rsp)
    77d34dee6203:	call   0x77d34df4ea00
    77d34dee6208:	mov    0x30(%rsp),%rbx
    77d34dee620d:	mov    0x38(%rsp),%rax
    77d34dee6212:	movabs $0x77d3534c8ba2,%rdx
    77d34dee621c:	lea    0x10(%r13),%rbp
    77d34dee6220:	mov    0x0(%rbp),%rcx
    77d34dee6224:	movq   $0x1c,(%rcx)
    77d34dee622b:	or     $0x7,%rcx
    77d34dee622f:	addq   $0x20,0x0(%rbp)
    77d34dee6234:	mov    %rdx,0x1(%rcx)
    77d34dee6238:	mov    %rbx,0x9(%rcx)
    77d34dee623c:	mov    %rax,0x11(%rcx)
    77d34dee6240:	sub    $0x8,%r14
    77d34dee6244:	mov    %rcx,(%r14)
    77d34dee6247:	mov    %eax,0x13132db3(%rip)        # 0x77d361019000
    77d34dee624d:	add    $0xa8,%rsp
    77d34dee6254:	ret
    77d34dee6255:	mov    0x1(%rax),%rax
    77d34dee6259:	mov    0xe(%rax),%rax
    77d34dee625d:	movabs $0x77d3534b617c,%rbx
    77d34dee6267:	cmp    %rbx,%rax
    77d34dee626a:	jne    0x77d34dee6289
    77d34dee6270:	mov    %eax,0x13132d8a(%rip)        # 0x77d361019000
    77d34dee6276:	add    $0xa8,%rsp
    77d34dee627d:	lea    0x5(%rip),%rbx        # 0x77d34dee6289
    77d34dee6284:	jmp    0x77d34e0d5960
    77d34dee6289:	movabs $0x77d3534a3d9c,%rax
    77d34dee6293:	add    $0x8,%r14
    77d34dee6297:	mov    %rax,(%r14)
    77d34dee629a:	call   0x77d34e31e3d0
    77d34dee629f:	movabs $0x77d3534a3d9c,%rax
    77d34dee62a9:	add    $0x8,%r14
    77d34dee62ad:	mov    %rax,(%r14)
    77d34dee62b0:	call   0x77d34e31e3d0
    77d34dee62b5:	mov    %rbx,%rcx
    77d34dee62b8:	and    $0xf,%ecx
    77d34dee62bb:	cmp    $0x7,%rcx
    77d34dee62bf:	jne    0x77d34dee6d69
    77d34dee62c5:	mov    0x1(%rbx),%rcx
    77d34dee62c9:	mov    0xe(%rcx),%rcx
    77d34dee62cd:	movabs $0x77d3534c8fdc,%rdx
    77d34dee62d7:	cmp    %rdx,%rcx
    77d34dee62da:	jne    0x77d34dee6a7a
    77d34dee62e0:	mov    %rax,%rcx
    77d34dee62e3:	test   $0xf,%ecx
    77d34dee62e9:	jne    0x77d34dee643d
    77d34dee62ef:	mov    0x9(%rbx),%rax
    77d34dee62f3:	mov    0x11(%rbx),%rbx
    77d34dee62f7:	add    $0x8,%r15
    77d34dee62fb:	mov    %rbx,(%r15)
    77d34dee62fe:	mov    %rax,-0x8(%r14)
    77d34dee6302:	call   0x77d34dee58d0
    77d34dee6307:	mov    (%r15),%rax
    77d34dee630a:	add    $0x10,%r14
    77d34dee630e:	sub    $0x8,%r15
    77d34dee6312:	mov    %rax,-0x8(%r14)
    77d34dee6316:	movq   $0x0,(%r14)
    77d34dee631d:	call   0x77d34dee58d0
    77d34dee6322:	mov    (%r14),%rax
    77d34dee6325:	add    $0x8,%r14
    77d34dee6329:	cmp    $0x0,%rax
    77d34dee632d:	jne    0x77d34dee6349
    77d34dee6333:	sub    $0x8,%r14
    77d34dee6337:	sub    $0x8,%r14
    77d34dee633b:	mov    %eax,0x13132cbf(%rip)        # 0x77d361019000
    77d34dee6341:	add    $0xa8,%rsp
    77d34dee6348:	ret
    77d34dee6349:	mov    %rax,%rbx
    77d34dee634c:	test   $0xf,%ebx
    77d34dee6352:	jne    0x77d34dee6368
    77d34dee6358:	sub    $0x8,%r14
    77d34dee635c:	mov    (%r14),%rax
    77d34dee635f:	mov    -0x8(%r14),%rbx
    77d34dee6363:	jmp    0x77d34dee63cc
    77d34dee6368:	mov    %rax,%rbx
    77d34dee636b:	and    $0xf,%ebx
    77d34dee636e:	cmp    $0x5,%rbx
    77d34dee6372:	jne    0x77d34dee63c1
    77d34dee6378:	movabs $0x77d353557005,%rbx
    77d34dee6382:	add    $0x8,%r14
    77d34dee6386:	mov    %rax,-0x8(%r14)
    77d34dee638a:	mov    %rbx,(%r14)
    77d34dee638d:	call   0x77d34e24a2e0
    77d34dee6392:	mov    (%r14),%rax
    77d34dee6395:	sub    $0x8,%r14
    77d34dee6399:	cmp    $0x1,%rax
    77d34dee639d:	je     0x77d34dee63b5
    77d34dee63a3:	sub    $0x8,%r14
    77d34dee63a7:	mov    %eax,0x13132c53(%rip)        # 0x77d361019000
    77d34dee63ad:	add    $0xa8,%rsp
    77d34dee63b4:	ret
    77d34dee63b5:	mov    (%r14),%rax
    77d34dee63b8:	mov    -0x8(%r14),%rbx
    77d34dee63bc:	jmp    0x77d34dee63cc
    77d34dee63c1:	sub    $0x8,%r14
    77d34dee63c5:	mov    (%r14),%rax
    77d34dee63c8:	mov    -0x8(%r14),%rbx
    77d34dee63cc:	lea    0x10(%r13),%rcx
    77d34dee63d0:	mov    (%rcx),%rdx
    77d34dee63d3:	add    $0x20,%rdx
    77d34dee63d7:	cmp    0x10(%rcx),%rdx
    77d34dee63db:	jle    0x77d34dee63fa
    77d34dee63e1:	mov    %rbx,0x40(%rsp)
    77d34dee63e6:	mov    %rax,0x48(%rsp)
    77d34dee63eb:	call   0x77d34df4ea00
    77d34dee63f0:	mov    0x40(%rsp),%rbx
    77d34dee63f5:	mov    0x48(%rsp),%rax
    77d34dee63fa:	movabs $0x77d3534c8ba2,%rdx
    77d34dee6404:	lea    0x10(%r13),%rbp
    77d34dee6408:	mov    0x0(%rbp),%rcx
    77d34dee640c:	movq   $0x1c,(%rcx)
    77d34dee6413:	or     $0x7,%rcx
    77d34dee6417:	addq   $0x20,0x0(%rbp)
    77d34dee641c:	mov    %rdx,0x1(%rcx)
    77d34dee6420:	mov    %rbx,0x9(%rcx)
    77d34dee6424:	mov    %rax,0x11(%rcx)
    77d34dee6428:	sub    $0x8,%r14
    77d34dee642c:	mov    %rcx,(%r14)
    77d34dee642f:	mov    %eax,0x13132bcb(%rip)        # 0x77d361019000
    77d34dee6435:	add    $0xa8,%rsp
    77d34dee643c:	ret
    77d34dee643d:	mov    %rax,%rcx
    77d34dee6440:	and    $0xf,%ecx
    77d34dee6443:	cmp    $0x3,%rcx
    77d34dee6447:	jne    0x77d34dee65f3
    77d34dee644d:	mov    0x9(%rbx),%rcx
    77d34dee6451:	mov    0x11(%rbx),%rbx
    77d34dee6455:	sub    $0x8,%r14
    77d34dee6459:	add    $0x10,%r15
    77d34dee645d:	mov    %rax,(%r15)
    77d34dee6460:	mov    %rbx,-0x8(%r15)
    77d34dee6464:	mov    %rcx,(%r14)
    77d34dee6467:	call   0x77d34cd29d20
    77d34dee646c:	lea    0x10(%r13),%rbx
    77d34dee6470:	mov    (%rbx),%rax
    77d34dee6473:	add    $0x10,%rax
    77d34dee6477:	cmp    0x10(%rbx),%rax
    77d34dee647b:	jle    0x77d34dee6486
    77d34dee6481:	call   0x77d34df4ea00
    77d34dee6486:	mov    (%r15),%rbx
    77d34dee6489:	mov    (%r14),%rcx
    77d34dee648c:	mov    -0x8(%r15),%rax
    77d34dee6490:	rex.W movsd 0x5(%rcx),%xmm0
    77d34dee6496:	rex.W movsd 0x5(%rbx),%xmm1
    77d34dee649c:	addsd  %xmm1,%xmm0
    77d34dee64a0:	lea    0x10(%r13),%rcx
    77d34dee64a4:	mov    (%rcx),%rbx
    77d34dee64a7:	movq   $0xc,(%rbx)
    77d34dee64ae:	or     $0x3,%rbx
    77d34dee64b2:	addq   $0x10,(%rcx)
    77d34dee64b6:	rex.W movsd %xmm0,0x5(%rbx)
    77d34dee64bc:	add    $0x10,%r14
    77d34dee64c0:	sub    $0x10,%r15
    77d34dee64c4:	mov    %rax,-0x8(%r14)
    77d34dee64c8:	movq   $0x0,(%r14)
    77d34dee64cf:	mov    %rbx,-0x10(%r14)
    77d34dee64d3:	call   0x77d34dee58d0
    77d34dee64d8:	mov    (%r14),%rax
    77d34dee64db:	add    $0x8,%r14
    77d34dee64df:	cmp    $0x0,%rax
    77d34dee64e3:	jne    0x77d34dee64ff
    77d34dee64e9:	sub    $0x8,%r14
    77d34dee64ed:	sub    $0x8,%r14
    77d34dee64f1:	mov    %eax,0x13132b09(%rip)        # 0x77d361019000
    77d34dee64f7:	add    $0xa8,%rsp
    77d34dee64fe:	ret
    77d34dee64ff:	mov    %rax,%rbx
    77d34dee6502:	test   $0xf,%ebx
    77d34dee6508:	jne    0x77d34dee651e
    77d34dee650e:	sub    $0x8,%r14
    77d34dee6512:	mov    (%r14),%rax
    77d34dee6515:	mov    -0x8(%r14),%rbx
    77d34dee6519:	jmp    0x77d34dee6582
    77d34dee651e:	mov    %rax,%rbx
    77d34dee6521:	and    $0xf,%ebx
    77d34dee6524:	cmp    $0x5,%rbx
    77d34dee6528:	jne    0x77d34dee6577
    77d34dee652e:	movabs $0x77d353557005,%rbx
    77d34dee6538:	add    $0x8,%r14
    77d34dee653c:	mov    %rax,-0x8(%r14)
    77d34dee6540:	mov    %rbx,(%r14)
    77d34dee6543:	call   0x77d34e24a2e0
    77d34dee6548:	mov    (%r14),%rax
    77d34dee654b:	sub    $0x8,%r14
    77d34dee654f:	cmp    $0x1,%rax
    77d34dee6553:	je     0x77d34dee656b
    77d34dee6559:	sub    $0x8,%r14
    77d34dee655d:	mov    %eax,0x13132a9d(%rip)        # 0x77d361019000
    77d34dee6563:	add    $0xa8,%rsp
    77d34dee656a:	ret
    77d34dee656b:	mov    (%r14),%rax
    77d34dee656e:	mov    -0x8(%r14),%rbx
    77d34dee6572:	jmp    0x77d34dee6582
    77d34dee6577:	sub    $0x8,%r14
    77d34dee657b:	mov    (%r14),%rax
    77d34dee657e:	mov    -0x8(%r14),%rbx
    77d34dee6582:	lea    0x10(%r13),%rcx
    77d34dee6586:	mov    (%rcx),%rdx
    77d34dee6589:	add    $0x20,%rdx
    77d34dee658d:	cmp    0x10(%rcx),%rdx
    77d34dee6591:	jle    0x77d34dee65b0
    77d34dee6597:	mov    %rbx,0x50(%rsp)
    77d34dee659c:	mov    %rax,0x58(%rsp)
    77d34dee65a1:	call   0x77d34df4ea00
    77d34dee65a6:	mov    0x50(%rsp),%rbx
    77d34dee65ab:	mov    0x58(%rsp),%rax
    77d34dee65b0:	movabs $0x77d3534c8ba2,%rdx
    77d34dee65ba:	lea    0x10(%r13),%rbp
    77d34dee65be:	mov    0x0(%rbp),%rcx
    77d34dee65c2:	movq   $0x1c,(%rcx)
    77d34dee65c9:	or     $0x7,%rcx
    77d34dee65cd:	addq   $0x20,0x0(%rbp)
    77d34dee65d2:	mov    %rdx,0x1(%rcx)
    77d34dee65d6:	mov    %rbx,0x9(%rcx)
    77d34dee65da:	mov    %rax,0x11(%rcx)
    77d34dee65de:	sub    $0x8,%r14
    77d34dee65e2:	mov    %rcx,(%r14)
    77d34dee65e5:	mov    %eax,0x13132a15(%rip)        # 0x77d361019000
    77d34dee65eb:	add    $0xa8,%rsp
    77d34dee65f2:	ret
    77d34dee65f3:	mov    %rax,%rcx
    77d34dee65f6:	and    $0xf,%ecx
    77d34dee65f9:	cmp    $0x5,%rcx
    77d34dee65fd:	jne    0x77d34dee6751
    77d34dee6603:	mov    0x9(%rbx),%rax
    77d34dee6607:	mov    0x11(%rbx),%rbx
    77d34dee660b:	add    $0x8,%r15
    77d34dee660f:	mov    %rbx,(%r15)
    77d34dee6612:	mov    %rax,-0x8(%r14)
    77d34dee6616:	call   0x77d34dee58d0
    77d34dee661b:	mov    (%r15),%rax
    77d34dee661e:	add    $0x10,%r14
    77d34dee6622:	sub    $0x8,%r15
    77d34dee6626:	mov    %rax,-0x8(%r14)
    77d34dee662a:	movq   $0x0,(%r14)
    77d34dee6631:	call   0x77d34dee58d0
    77d34dee6636:	mov    (%r14),%rax
    77d34dee6639:	add    $0x8,%r14
    77d34dee663d:	cmp    $0x0,%rax
    77d34dee6641:	jne    0x77d34dee665d
    77d34dee6647:	sub    $0x8,%r14
    77d34dee664b:	sub    $0x8,%r14
    77d34dee664f:	mov    %eax,0x131329ab(%rip)        # 0x77d361019000
    77d34dee6655:	add    $0xa8,%rsp
    77d34dee665c:	ret
    77d34dee665d:	mov    %rax,%rbx
    77d34dee6660:	test   $0xf,%ebx
    77d34dee6666:	jne    0x77d34dee667c
    77d34dee666c:	sub    $0x8,%r14
    77d34dee6670:	mov    (%r14),%rax
    77d34dee6673:	mov    -0x8(%r14),%rbx
    77d34dee6677:	jmp    0x77d34dee66e0
    77d34dee667c:	mov    %rax,%rbx
    77d34dee667f:	and    $0xf,%ebx
    77d34dee6682:	cmp    $0x5,%rbx
    77d34dee6686:	jne    0x77d34dee66d5
    77d34dee668c:	movabs $0x77d353557005,%rbx
    77d34dee6696:	add    $0x8,%r14
    77d34dee669a:	mov    %rax,-0x8(%r14)
    77d34dee669e:	mov    %rbx,(%r14)
    77d34dee66a1:	call   0x77d34e24a2e0
    77d34dee66a6:	mov    (%r14),%rax
    77d34dee66a9:	sub    $0x8,%r14
    77d34dee66ad:	cmp    $0x1,%rax
    77d34dee66b1:	je     0x77d34dee66c9
    77d34dee66b7:	sub    $0x8,%r14
    77d34dee66bb:	mov    %eax,0x1313293f(%rip)        # 0x77d361019000
    77d34dee66c1:	add    $0xa8,%rsp
    77d34dee66c8:	ret
    77d34dee66c9:	mov    (%r14),%rax
    77d34dee66cc:	mov    -0x8(%r14),%rbx
    77d34dee66d0:	jmp    0x77d34dee66e0
    77d34dee66d5:	sub    $0x8,%r14
    77d34dee66d9:	mov    (%r14),%rax
    77d34dee66dc:	mov    -0x8(%r14),%rbx
    77d34dee66e0:	lea    0x10(%r13),%rdx
    77d34dee66e4:	mov    (%rdx),%rcx
    77d34dee66e7:	add    $0x20,%rcx
    77d34dee66eb:	cmp    0x10(%rdx),%rcx
    77d34dee66ef:	jle    0x77d34dee670e
    77d34dee66f5:	mov    %rbx,0x60(%rsp)
    77d34dee66fa:	mov    %rax,0x68(%rsp)
    77d34dee66ff:	call   0x77d34df4ea00
    77d34dee6704:	mov    0x60(%rsp),%rbx
    77d34dee6709:	mov    0x68(%rsp),%rax
    77d34dee670e:	movabs $0x77d3534c8ba2,%rdx
    77d34dee6718:	lea    0x10(%r13),%rbp
    77d34dee671c:	mov    0x0(%rbp),%rcx
    77d34dee6720:	movq   $0x1c,(%rcx)
    77d34dee6727:	or     $0x7,%rcx
    77d34dee672b:	addq   $0x20,0x0(%rbp)
    77d34dee6730:	mov    %rdx,0x1(%rcx)
    77d34dee6734:	mov    %rbx,0x9(%rcx)
    77d34dee6738:	mov    %rax,0x11(%rcx)
    77d34dee673c:	sub    $0x8,%r14
    77d34dee6740:	mov    %rcx,(%r14)
    77d34dee6743:	mov    %eax,0x131328b7(%rip)        # 0x77d361019000
    77d34dee6749:	add    $0xa8,%rsp
    77d34dee6750:	ret
    77d34dee6751:	mov    %rax,%rcx
    77d34dee6754:	and    $0xf,%ecx
    77d34dee6757:	cmp    $0x7,%rcx
    77d34dee675b:	jne    0x77d34dee6a64
    77d34dee6761:	mov    0x1(%rax),%rcx
    77d34dee6765:	mov    0xe(%rcx),%rcx
    77d34dee6769:	movabs $0x77d3534c8fdc,%rdx
    77d34dee6773:	cmp    %rdx,%rcx
    77d34dee6776:	jne    0x77d34dee68d9
    77d34dee677c:	mov    0x9(%rbx),%rcx
    77d34dee6780:	mov    0x11(%rbx),%rbx
    77d34dee6784:	mov    0x9(%rax),%rdx
    77d34dee6788:	mov    0x11(%rax),%rax
    77d34dee678c:	add    $0x10,%r15
    77d34dee6790:	mov    %rax,-0x8(%r15)
    77d34dee6794:	mov    %rcx,-0x8(%r14)
    77d34dee6798:	mov    %rdx,(%r14)
    77d34dee679b:	mov    %rbx,(%r15)
    77d34dee679e:	call   0x77d34dee58d0
    77d34dee67a3:	mov    (%r15),%rax
    77d34dee67a6:	mov    -0x8(%r15),%rbx
    77d34dee67aa:	add    $0x10,%r14
    77d34dee67ae:	sub    $0x10,%r15
    77d34dee67b2:	mov    %rax,-0x8(%r14)
    77d34dee67b6:	mov    %rbx,(%r14)
    77d34dee67b9:	call   0x77d34dee58d0
    77d34dee67be:	mov    (%r14),%rax
    77d34dee67c1:	add    $0x8,%r14
    77d34dee67c5:	cmp    $0x0,%rax
    77d34dee67c9:	jne    0x77d34dee67e5
    77d34dee67cf:	sub    $0x8,%r14
    77d34dee67d3:	sub    $0x8,%r14
    77d34dee67d7:	mov    %eax,0x13132823(%rip)        # 0x77d361019000
    77d34dee67dd:	add    $0xa8,%rsp
    77d34dee67e4:	ret
    77d34dee67e5:	mov    %rax,%rbx
    77d34dee67e8:	test   $0xf,%ebx
    77d34dee67ee:	jne    0x77d34dee6804
    77d34dee67f4:	sub    $0x8,%r14
    77d34dee67f8:	mov    (%r14),%rax
    77d34dee67fb:	mov    -0x8(%r14),%rbx
    77d34dee67ff:	jmp    0x77d34dee6868
    77d34dee6804:	mov    %rax,%rbx
    77d34dee6807:	and    $0xf,%ebx
    77d34dee680a:	cmp    $0x5,%rbx
    77d34dee680e:	jne    0x77d34dee685d
    77d34dee6814:	movabs $0x77d353557005,%rbx
    77d34dee681e:	add    $0x8,%r14
    77d34dee6822:	mov    %rax,-0x8(%r14)
    77d34dee6826:	mov    %rbx,(%r14)
    77d34dee6829:	call   0x77d34e24a2e0
    77d34dee682e:	mov    (%r14),%rax
    77d34dee6831:	sub    $0x8,%r14
    77d34dee6835:	cmp    $0x1,%rax
    77d34dee6839:	je     0x77d34dee6851
    77d34dee683f:	sub    $0x8,%r14
    77d34dee6843:	mov    %eax,0x131327b7(%rip)        # 0x77d361019000
    77d34dee6849:	add    $0xa8,%rsp
    77d34dee6850:	ret
    77d34dee6851:	mov    (%r14),%rax
    77d34dee6854:	mov    -0x8(%r14),%rbx
    77d34dee6858:	jmp    0x77d34dee6868
    77d34dee685d:	sub    $0x8,%r14
    77d34dee6861:	mov    (%r14),%rax
    77d34dee6864:	mov    -0x8(%r14),%rbx
    77d34dee6868:	lea    0x10(%r13),%rcx
    77d34dee686c:	mov    (%rcx),%rdx
    77d34dee686f:	add    $0x20,%rdx
    77d34dee6873:	cmp    0x10(%rcx),%rdx
    77d34dee6877:	jle    0x77d34dee6896
    77d34dee687d:	mov    %rbx,0x70(%rsp)
    77d34dee6882:	mov    %rax,0x78(%rsp)
    77d34dee6887:	call   0x77d34df4ea00
    77d34dee688c:	mov    0x70(%rsp),%rbx
    77d34dee6891:	mov    0x78(%rsp),%rax
    77d34dee6896:	movabs $0x77d3534c8ba2,%rdx
    77d34dee68a0:	lea    0x10(%r13),%rbp
    77d34dee68a4:	mov    0x0(%rbp),%rcx
    77d34dee68a8:	movq   $0x1c,(%rcx)
    77d34dee68af:	or     $0x7,%rcx
    77d34dee68b3:	addq   $0x20,0x0(%rbp)
    77d34dee68b8:	mov    %rdx,0x1(%rcx)
    77d34dee68bc:	mov    %rbx,0x9(%rcx)
    77d34dee68c0:	mov    %rax,0x11(%rcx)
    77d34dee68c4:	sub    $0x8,%r14
    77d34dee68c8:	mov    %rcx,(%r14)
    77d34dee68cb:	mov    %eax,0x1313272f(%rip)        # 0x77d361019000
    77d34dee68d1:	add    $0xa8,%rsp
    77d34dee68d8:	ret
    77d34dee68d9:	mov    0x1(%rax),%rax
    77d34dee68dd:	mov    0xe(%rax),%rax
    77d34dee68e1:	movabs $0x77d3534b617c,%rcx
    77d34dee68eb:	cmp    %rcx,%rax
    77d34dee68ee:	jne    0x77d34dee6a4e
    77d34dee68f4:	mov    0x9(%rbx),%rax
    77d34dee68f8:	mov    0x11(%rbx),%rbx
    77d34dee68fc:	add    $0x8,%r15
    77d34dee6900:	mov    %rbx,(%r15)
    77d34dee6903:	mov    %rax,-0x8(%r14)
    77d34dee6907:	call   0x77d34dee58d0
    77d34dee690c:	mov    (%r15),%rax
    77d34dee690f:	add    $0x10,%r14
    77d34dee6913:	sub    $0x8,%r15
    77d34dee6917:	mov    %rax,-0x8(%r14)
    77d34dee691b:	movq   $0x0,(%r14)
    77d34dee6922:	call   0x77d34dee58d0
    77d34dee6927:	mov    (%r14),%rax
    77d34dee692a:	add    $0x8,%r14
    77d34dee692e:	cmp    $0x0,%rax
    77d34dee6932:	jne    0x77d34dee694e
    77d34dee6938:	sub    $0x8,%r14
    77d34dee693c:	sub    $0x8,%r14
    77d34dee6940:	mov    %eax,0x131326ba(%rip)        # 0x77d361019000
    77d34dee6946:	add    $0xa8,%rsp
    77d34dee694d:	ret
    77d34dee694e:	mov    %rax,%rbx
    77d34dee6951:	test   $0xf,%ebx
    77d34dee6957:	jne    0x77d34dee696d
    77d34dee695d:	sub    $0x8,%r14
    77d34dee6961:	mov    (%r14),%rax
    77d34dee6964:	mov    -0x8(%r14),%rbx
    77d34dee6968:	jmp    0x77d34dee69d1
    77d34dee696d:	mov    %rax,%rbx
    77d34dee6970:	and    $0xf,%ebx
    77d34dee6973:	cmp    $0x5,%rbx
    77d34dee6977:	jne    0x77d34dee69c6
    77d34dee697d:	movabs $0x77d353557005,%rbx
    77d34dee6987:	add    $0x8,%r14
    77d34dee698b:	mov    %rax,-0x8(%r14)
    77d34dee698f:	mov    %rbx,(%r14)
    77d34dee6992:	call   0x77d34e24a2e0
    77d34dee6997:	mov    (%r14),%rax
    77d34dee699a:	sub    $0x8,%r14
    77d34dee699e:	cmp    $0x1,%rax
    77d34dee69a2:	je     0x77d34dee69ba
    77d34dee69a8:	sub    $0x8,%r14
    77d34dee69ac:	mov    %eax,0x1313264e(%rip)        # 0x77d361019000
    77d34dee69b2:	add    $0xa8,%rsp
    77d34dee69b9:	ret
    77d34dee69ba:	mov    (%r14),%rax
    77d34dee69bd:	mov    -0x8(%r14),%rbx
    77d34dee69c1:	jmp    0x77d34dee69d1
    77d34dee69c6:	sub    $0x8,%r14
    77d34dee69ca:	mov    (%r14),%rax
    77d34dee69cd:	mov    -0x8(%r14),%rbx
    77d34dee69d1:	lea    0x10(%r13),%rcx
    77d34dee69d5:	mov    (%rcx),%rdx
    77d34dee69d8:	add    $0x20,%rdx
    77d34dee69dc:	cmp    0x10(%rcx),%rdx
    77d34dee69e0:	jle    0x77d34dee6a0b
    77d34dee69e6:	mov    %rbx,0x80(%rsp)
    77d34dee69ee:	mov    %rax,0x88(%rsp)
    77d34dee69f6:	call   0x77d34df4ea00
    77d34dee69fb:	mov    0x80(%rsp),%rbx
    77d34dee6a03:	mov    0x88(%rsp),%rax
    77d34dee6a0b:	movabs $0x77d3534c8ba2,%rdx
    77d34dee6a15:	lea    0x10(%r13),%rbp
    77d34dee6a19:	mov    0x0(%rbp),%rcx
    77d34dee6a1d:	movq   $0x1c,(%rcx)
    77d34dee6a24:	or     $0x7,%rcx
    77d34dee6a28:	addq   $0x20,0x0(%rbp)
    77d34dee6a2d:	mov    %rdx,0x1(%rcx)
    77d34dee6a31:	mov    %rbx,0x9(%rcx)
    77d34dee6a35:	mov    %rax,0x11(%rcx)
    77d34dee6a39:	sub    $0x8,%r14
    77d34dee6a3d:	mov    %rcx,(%r14)
    77d34dee6a40:	mov    %eax,0x131325ba(%rip)        # 0x77d361019000
    77d34dee6a46:	add    $0xa8,%rsp
    77d34dee6a4d:	ret
    77d34dee6a4e:	movabs $0x77d3534a3d9c,%rax
    77d34dee6a58:	add    $0x8,%r14
    77d34dee6a5c:	mov    %rax,(%r14)
    77d34dee6a5f:	call   0x77d34e31e3d0
    77d34dee6a64:	movabs $0x77d3534a3d9c,%rax
    77d34dee6a6e:	add    $0x8,%r14
    77d34dee6a72:	mov    %rax,(%r14)
    77d34dee6a75:	call   0x77d34e31e3d0
    77d34dee6a7a:	mov    0x1(%rbx),%rbx
    77d34dee6a7e:	mov    0xe(%rbx),%rbx
    77d34dee6a82:	movabs $0x77d3534b617c,%rcx
    77d34dee6a8c:	cmp    %rcx,%rbx
    77d34dee6a8f:	jne    0x77d34dee6d53
    77d34dee6a95:	mov    %rax,%rbx
    77d34dee6a98:	test   $0xf,%ebx
    77d34dee6a9e:	jne    0x77d34dee6abd
    77d34dee6aa4:	mov    %eax,0x13132556(%rip)        # 0x77d361019000
    77d34dee6aaa:	add    $0xa8,%rsp
    77d34dee6ab1:	lea    0x5(%rip),%rbx        # 0x77d34dee6abd
    77d34dee6ab8:	jmp    0x77d34e0d5960
    77d34dee6abd:	mov    %rax,%rbx
    77d34dee6ac0:	and    $0xf,%ebx
    77d34dee6ac3:	cmp    $0x3,%rbx
    77d34dee6ac7:	jne    0x77d34dee6b3e
    77d34dee6acd:	sub    $0x8,%r14
    77d34dee6ad1:	add    $0x8,%r15
    77d34dee6ad5:	mov    %rax,(%r15)
    77d34dee6ad8:	call   0x77d34dc6fa60
    77d34dee6add:	lea    0x10(%r13),%rax
    77d34dee6ae1:	mov    (%rax),%rbx
    77d34dee6ae4:	add    $0x10,%rbx
    77d34dee6ae8:	cmp    0x10(%rax),%rbx
    77d34dee6aec:	jle    0x77d34dee6af7
    77d34dee6af2:	call   0x77d34df4ea00
    77d34dee6af7:	mov    (%r15),%rax
    77d34dee6afa:	mov    (%r14),%rbx
    77d34dee6afd:	rex.W movsd 0x5(%rbx),%xmm0
    77d34dee6b03:	rex.W movsd 0x5(%rax),%xmm1
    77d34dee6b09:	addsd  %xmm1,%xmm0
    77d34dee6b0d:	lea    0x10(%r13),%rbx
    77d34dee6b11:	mov    (%rbx),%rax
    77d34dee6b14:	movq   $0xc,(%rax)
    77d34dee6b1b:	or     $0x3,%rax
    77d34dee6b1f:	addq   $0x10,(%rbx)
    77d34dee6b23:	rex.W movsd %xmm0,0x5(%rax)
    77d34dee6b29:	sub    $0x8,%r15
    77d34dee6b2d:	mov    %rax,(%r14)
    77d34dee6b30:	mov    %eax,0x131324ca(%rip)        # 0x77d361019000
    77d34dee6b36:	add    $0xa8,%rsp
    77d34dee6b3d:	ret
    77d34dee6b3e:	mov    %rax,%rbx
    77d34dee6b41:	and    $0xf,%ebx
    77d34dee6b44:	cmp    $0x5,%rbx
    77d34dee6b48:	jne    0x77d34dee6b67
    77d34dee6b4e:	mov    %eax,0x131324ac(%rip)        # 0x77d361019000
    77d34dee6b54:	add    $0xa8,%rsp
    77d34dee6b5b:	lea    0x5(%rip),%rbx        # 0x77d34dee6b67
    77d34dee6b62:	jmp    0x77d34e0d5960
    77d34dee6b67:	mov    %rax,%rbx
    77d34dee6b6a:	and    $0xf,%ebx
    77d34dee6b6d:	cmp    $0x7,%rbx
    77d34dee6b71:	jne    0x77d34dee6d3d
    77d34dee6b77:	mov    0x1(%rax),%rbx
    77d34dee6b7b:	mov    0xe(%rbx),%rbx
    77d34dee6b7f:	movabs $0x77d3534c8fdc,%rcx
    77d34dee6b89:	cmp    %rcx,%rbx
    77d34dee6b8c:	jne    0x77d34dee6cf3
    77d34dee6b92:	mov    0x9(%rax),%rbx
    77d34dee6b96:	mov    0x11(%rax),%rax
    77d34dee6b9a:	add    $0x10,%r15
    77d34dee6b9e:	mov    %rax,-0x8(%r15)
    77d34dee6ba2:	mov    %rbx,(%r14)
    77d34dee6ba5:	movq   $0x0,(%r15)
    77d34dee6bac:	call   0x77d34dee58d0
    77d34dee6bb1:	mov    (%r15),%rax
    77d34dee6bb4:	mov    -0x8(%r15),%rbx
    77d34dee6bb8:	add    $0x10,%r14
    77d34dee6bbc:	sub    $0x10,%r15
    77d34dee6bc0:	mov    %rax,-0x8(%r14)
    77d34dee6bc4:	mov    %rbx,(%r14)
    77d34dee6bc7:	call   0x77d34dee58d0
    77d34dee6bcc:	mov    (%r14),%rax
    77d34dee6bcf:	add    $0x8,%r14
    77d34dee6bd3:	cmp    $0x0,%rax
    77d34dee6bd7:	jne    0x77d34dee6bf3
    77d34dee6bdd:	sub    $0x8,%r14
    77d34dee6be1:	sub    $0x8,%r14
    77d34dee6be5:	mov    %eax,0x13132415(%rip)        # 0x77d361019000
    77d34dee6beb:	add    $0xa8,%rsp
    77d34dee6bf2:	ret
    77d34dee6bf3:	mov    %rax,%rbx
    77d34dee6bf6:	test   $0xf,%ebx
    77d34dee6bfc:	jne    0x77d34dee6c12
    77d34dee6c02:	sub    $0x8,%r14
    77d34dee6c06:	mov    (%r14),%rax
    77d34dee6c09:	mov    -0x8(%r14),%rbx
    77d34dee6c0d:	jmp    0x77d34dee6c76
    77d34dee6c12:	mov    %rax,%rbx
    77d34dee6c15:	and    $0xf,%ebx
    77d34dee6c18:	cmp    $0x5,%rbx
    77d34dee6c1c:	jne    0x77d34dee6c6b
    77d34dee6c22:	movabs $0x77d353557005,%rbx
    77d34dee6c2c:	add    $0x8,%r14
    77d34dee6c30:	mov    %rax,-0x8(%r14)
    77d34dee6c34:	mov    %rbx,(%r14)
    77d34dee6c37:	call   0x77d34e24a2e0
    77d34dee6c3c:	mov    (%r14),%rax
    77d34dee6c3f:	sub    $0x8,%r14
    77d34dee6c43:	cmp    $0x1,%rax
    77d34dee6c47:	je     0x77d34dee6c5f
    77d34dee6c4d:	sub    $0x8,%r14
    77d34dee6c51:	mov    %eax,0x131323a9(%rip)        # 0x77d361019000
    77d34dee6c57:	add    $0xa8,%rsp
    77d34dee6c5e:	ret
    77d34dee6c5f:	mov    (%r14),%rax
    77d34dee6c62:	mov    -0x8(%r14),%rbx
    77d34dee6c66:	jmp    0x77d34dee6c76
    77d34dee6c6b:	sub    $0x8,%r14
    77d34dee6c6f:	mov    (%r14),%rax
    77d34dee6c72:	mov    -0x8(%r14),%rbx
    77d34dee6c76:	lea    0x10(%r13),%rdx
    77d34dee6c7a:	mov    (%rdx),%rcx
    77d34dee6c7d:	add    $0x20,%rcx
    77d34dee6c81:	cmp    0x10(%rdx),%rcx
    77d34dee6c85:	jle    0x77d34dee6cb0
    77d34dee6c8b:	mov    %rbx,0x90(%rsp)
    77d34dee6c93:	mov    %rax,0x98(%rsp)
    77d34dee6c9b:	call   0x77d34df4ea00
    77d34dee6ca0:	mov    0x90(%rsp),%rbx
    77d34dee6ca8:	mov    0x98(%rsp),%rax
    77d34dee6cb0:	movabs $0x77d3534c8ba2,%rdx
    77d34dee6cba:	lea    0x10(%r13),%rbp
    77d34dee6cbe:	mov    0x0(%rbp),%rcx
    77d34dee6cc2:	movq   $0x1c,(%rcx)
    77d34dee6cc9:	or     $0x7,%rcx
    77d34dee6ccd:	addq   $0x20,0x0(%rbp)
    77d34dee6cd2:	mov    %rdx,0x1(%rcx)
    77d34dee6cd6:	mov    %rbx,0x9(%rcx)
    77d34dee6cda:	mov    %rax,0x11(%rcx)
    77d34dee6cde:	sub    $0x8,%r14
    77d34dee6ce2:	mov    %rcx,(%r14)
    77d34dee6ce5:	mov    %eax,0x13132315(%rip)        # 0x77d361019000
    77d34dee6ceb:	add    $0xa8,%rsp
    77d34dee6cf2:	ret
    77d34dee6cf3:	mov    0x1(%rax),%rax
    77d34dee6cf7:	mov    0xe(%rax),%rax
    77d34dee6cfb:	movabs $0x77d3534b617c,%rbx
    77d34dee6d05:	cmp    %rbx,%rax
    77d34dee6d08:	jne    0x77d34dee6d27
    77d34dee6d0e:	mov    %eax,0x131322ec(%rip)        # 0x77d361019000
    77d34dee6d14:	add    $0xa8,%rsp
    77d34dee6d1b:	lea    0x5(%rip),%rbx        # 0x77d34dee6d27
    77d34dee6d22:	jmp    0x77d34e0d5960
    77d34dee6d27:	movabs $0x77d3534a3d9c,%rax
    77d34dee6d31:	add    $0x8,%r14
    77d34dee6d35:	mov    %rax,(%r14)
    77d34dee6d38:	call   0x77d34e31e3d0
    77d34dee6d3d:	movabs $0x77d3534a3d9c,%rax
    77d34dee6d47:	add    $0x8,%r14
    77d34dee6d4b:	mov    %rax,(%r14)
    77d34dee6d4e:	call   0x77d34e31e3d0
    77d34dee6d53:	movabs $0x77d3534a3d9c,%rax
    77d34dee6d5d:	add    $0x8,%r14
    77d34dee6d61:	mov    %rax,(%r14)
    77d34dee6d64:	call   0x77d34e31e3d0
    77d34dee6d69:	movabs $0x77d3534a3d9c,%rax
    77d34dee6d73:	add    $0x8,%r14
    77d34dee6d77:	mov    %rax,(%r14)
    77d34dee6d7a:	call   0x77d34e31e3d0
    77d34dee6d7f:	add    %al,(%rax)
    77d34dee6d81:	add    %al,(%rax)
    77d34dee6d83:	add    %al,(%rsi)
    77d34dee6d85:	add    %al,(%rax)
    77d34dee6d87:	add    (%rax),%eax
    77d34dee6d89:	sbb    %al,(%rax)
    77d34dee6d8b:	add    %al,(%rbx)
    77d34dee6d8d:	add    %al,(%rax)
    77d34dee6d8f:	(bad)
    77d34dee6d90:	add    %al,(%rax)
    77d34dee6d92:	add    (%rax),%eax
    77d34dee6d94:	addb   $0x0,(%rcx)
    77d34dee6d97:	rolb   $0x0,(%rax)
    77d34dee6d9a:	(bad)
    77d34dee6d9b:	add    %al,(%rax)
    77d34dee6d9d:	xor    %al,(%rax)
    77d34dee6d9f:	add    %bl,(%rax)
    77d34dee6da1:	add    %al,(%rax)
    77d34dee6da3:	or     $0xa2,%al
    77d34dee6da5:	add    %al,(%rax)
    77d34dee6da7:	add    %ch,0x0(%rdx,%rax,1)
    77d34dee6dab:	add    %bl,0x3(%rbx)
    77d34dee6dae:	add    %al,(%rax)
    77d34dee6db0:	fiadds (%rbx)
    77d34dee6db2:	add    %al,(%rax)
    77d34dee6db4:	and    (%rsi),%eax
    77d34dee6db6:	add    %al,(%rax)
    77d34dee6db8:	cmp    %cl,(%rcx)
    77d34dee6dba:	add    %al,(%rax)
    77d34dee6dbc:	and    %cl,(%rbx)
    77d34dee6dbe:	add    %al,(%rax)
    77d34dee6dc0:	udb
    77d34dee6dc1:	or     $0x0,%al
    77d34dee6dc3:	add    %dh,(%rsi,%rcx,1)
    77d34dee6dc6:	add    %al,(%rax)
    77d34dee6dc8:	mov    $0x2b00000f,%esp
    77d34dee6dcd:	adc    %eax,(%rax)
    77d34dee6dcf:	add    %dl,%al
    77d34dee6dd1:	adc    (%rax),%eax
    77d34dee6dd3:	add    %dl,0x0(%rip)        # 0x77d34dee6dd9
    77d34dee6dd9:	add    %al,(%rax)
    77d34dee6ddb:	add    %cl,(%rax,%rax,1)
	...
