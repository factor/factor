
/home/erg/compiler-next2-integer-20260909/disassembly/baseline-1-math_plus.bin:     file format binary


Disassembly of section .data:

000075da27365860 <.data>:
    75da27365860:	mov    %eax,0x1312479a(%rip)        # 0x75da3a48a000
    75da27365866:	sub    $0xa8,%rsp
    75da2736586d:	mov    (%r14),%rax
    75da27365870:	mov    -0x8(%r14),%rbx
    75da27365874:	mov    %rbx,%rcx
    75da27365877:	mov    %rax,%rdx
    75da2736587a:	or     %rdx,%rcx
    75da2736587d:	test   $0xf,%ecx
    75da27365883:	jne    0x75da273658c0
    75da27365889:	add    %rax,%rbx
    75da2736588c:	jo     0x75da273658a7
    75da27365892:	sub    $0x8,%r14
    75da27365896:	mov    %rbx,(%r14)
    75da27365899:	mov    %eax,0x13124761(%rip)        # 0x75da3a48a000
    75da2736589f:	add    $0xa8,%rsp
    75da273658a6:	ret
    75da273658a7:	mov    %eax,0x13124753(%rip)        # 0x75da3a48a000
    75da273658ad:	add    $0xa8,%rsp
    75da273658b4:	lea    0x5(%rip),%rbx        # 0x75da273658c0
    75da273658bb:	jmp    0x75da262d27a0
    75da273658c0:	mov    %rbx,%rcx
    75da273658c3:	test   $0xf,%ecx
    75da273658c9:	jne    0x75da27365b79
    75da273658cf:	mov    %rax,%rcx
    75da273658d2:	and    $0xf,%ecx
    75da273658d5:	cmp    $0x3,%rcx
    75da273658d9:	jne    0x75da27365952
    75da273658df:	lea    0x10(%r13),%rcx
    75da273658e3:	mov    (%rcx),%rdx
    75da273658e6:	add    $0x10,%rdx
    75da273658ea:	cmp    0x10(%rcx),%rdx
    75da273658ee:	jle    0x75da2736590b
    75da273658f4:	mov    %rbx,(%rsp)
    75da273658f8:	mov    %rax,0x8(%rsp)
    75da273658fd:	call   0x75da273cf060
    75da27365902:	mov    (%rsp),%rbx
    75da27365906:	mov    0x8(%rsp),%rax
    75da2736590b:	sar    $0x4,%rbx
    75da2736590f:	xorps  %xmm0,%xmm0
    75da27365912:	cvtsi2sd %rbx,%xmm0
    75da27365917:	rex.W movsd 0x5(%rax),%xmm1
    75da2736591d:	addsd  %xmm1,%xmm0
    75da27365921:	lea    0x10(%r13),%rbx
    75da27365925:	mov    (%rbx),%rax
    75da27365928:	movq   $0xc,(%rax)
    75da2736592f:	or     $0x3,%rax
    75da27365933:	addq   $0x10,(%rbx)
    75da27365937:	rex.W movsd %xmm0,0x5(%rax)
    75da2736593d:	sub    $0x8,%r14
    75da27365941:	mov    %rax,(%r14)
    75da27365944:	mov    %eax,0x131246b6(%rip)        # 0x75da3a48a000
    75da2736594a:	add    $0xa8,%rsp
    75da27365951:	ret
    75da27365952:	mov    %rax,%rbx
    75da27365955:	and    $0xf,%ebx
    75da27365958:	cmp    $0x5,%rbx
    75da2736595c:	jne    0x75da27365999
    75da27365962:	sub    $0x8,%r14
    75da27365966:	add    $0x8,%r15
    75da2736596a:	mov    %rax,(%r15)
    75da2736596d:	call   0x75da277a44d0
    75da27365972:	mov    (%r15),%rax
    75da27365975:	add    $0x8,%r14
    75da27365979:	sub    $0x8,%r15
    75da2736597d:	mov    %rax,(%r14)
    75da27365980:	mov    %eax,0x1312467a(%rip)        # 0x75da3a48a000
    75da27365986:	add    $0xa8,%rsp
    75da2736598d:	lea    0x5(%rip),%rbx        # 0x75da27365999
    75da27365994:	jmp    0x75da276d2070
    75da27365999:	mov    %rax,%rbx
    75da2736599c:	and    $0xf,%ebx
    75da2736599f:	cmp    $0x7,%rbx
    75da273659a3:	jne    0x75da27365b63
    75da273659a9:	mov    0x1(%rax),%rbx
    75da273659ad:	mov    0xe(%rbx),%rbx
    75da273659b1:	movabs $0x75da2c94e1dc,%rcx
    75da273659bb:	cmp    %rcx,%rbx
    75da273659be:	jne    0x75da27365b19
    75da273659c4:	mov    0x9(%rax),%rbx
    75da273659c8:	mov    0x11(%rax),%rax
    75da273659cc:	add    $0x10,%r15
    75da273659d0:	mov    %rax,-0x8(%r15)
    75da273659d4:	mov    %rbx,(%r14)
    75da273659d7:	movq   $0x0,(%r15)
    75da273659de:	call   0x75da27365860
    75da273659e3:	mov    (%r15),%rax
    75da273659e6:	mov    -0x8(%r15),%rbx
    75da273659ea:	add    $0x10,%r14
    75da273659ee:	sub    $0x10,%r15
    75da273659f2:	mov    %rax,-0x8(%r14)
    75da273659f6:	mov    %rbx,(%r14)
    75da273659f9:	call   0x75da27365860
    75da273659fe:	mov    (%r14),%rax
    75da27365a01:	add    $0x8,%r14
    75da27365a05:	cmp    $0x0,%rax
    75da27365a09:	jne    0x75da27365a25
    75da27365a0f:	sub    $0x8,%r14
    75da27365a13:	sub    $0x8,%r14
    75da27365a17:	mov    %eax,0x131245e3(%rip)        # 0x75da3a48a000
    75da27365a1d:	add    $0xa8,%rsp
    75da27365a24:	ret
    75da27365a25:	mov    %rax,%rbx
    75da27365a28:	test   $0xf,%ebx
    75da27365a2e:	jne    0x75da27365a44
    75da27365a34:	sub    $0x8,%r14
    75da27365a38:	mov    (%r14),%rax
    75da27365a3b:	mov    -0x8(%r14),%rbx
    75da27365a3f:	jmp    0x75da27365aa8
    75da27365a44:	mov    %rax,%rbx
    75da27365a47:	and    $0xf,%ebx
    75da27365a4a:	cmp    $0x5,%rbx
    75da27365a4e:	jne    0x75da27365a9d
    75da27365a54:	movabs $0x75da2c9dd9e5,%rbx
    75da27365a5e:	add    $0x8,%r14
    75da27365a62:	mov    %rax,-0x8(%r14)
    75da27365a66:	mov    %rbx,(%r14)
    75da27365a69:	call   0x75da276ca440
    75da27365a6e:	mov    (%r14),%rax
    75da27365a71:	sub    $0x8,%r14
    75da27365a75:	cmp    $0x1,%rax
    75da27365a79:	je     0x75da27365a91
    75da27365a7f:	sub    $0x8,%r14
    75da27365a83:	mov    %eax,0x13124577(%rip)        # 0x75da3a48a000
    75da27365a89:	add    $0xa8,%rsp
    75da27365a90:	ret
    75da27365a91:	mov    (%r14),%rax
    75da27365a94:	mov    -0x8(%r14),%rbx
    75da27365a98:	jmp    0x75da27365aa8
    75da27365a9d:	sub    $0x8,%r14
    75da27365aa1:	mov    (%r14),%rax
    75da27365aa4:	mov    -0x8(%r14),%rbx
    75da27365aa8:	lea    0x10(%r13),%rdx
    75da27365aac:	mov    (%rdx),%rcx
    75da27365aaf:	add    $0x20,%rcx
    75da27365ab3:	cmp    0x10(%rdx),%rcx
    75da27365ab7:	jle    0x75da27365ad6
    75da27365abd:	mov    %rbx,0x10(%rsp)
    75da27365ac2:	mov    %rax,0x18(%rsp)
    75da27365ac7:	call   0x75da273cf060
    75da27365acc:	mov    0x10(%rsp),%rbx
    75da27365ad1:	mov    0x18(%rsp),%rax
    75da27365ad6:	movabs $0x75da2c94dda2,%rdx
    75da27365ae0:	lea    0x10(%r13),%rbp
    75da27365ae4:	mov    0x0(%rbp),%rcx
    75da27365ae8:	movq   $0x1c,(%rcx)
    75da27365aef:	or     $0x7,%rcx
    75da27365af3:	addq   $0x20,0x0(%rbp)
    75da27365af8:	mov    %rdx,0x1(%rcx)
    75da27365afc:	mov    %rbx,0x9(%rcx)
    75da27365b00:	mov    %rax,0x11(%rcx)
    75da27365b04:	sub    $0x8,%r14
    75da27365b08:	mov    %rcx,(%r14)
    75da27365b0b:	mov    %eax,0x131244ef(%rip)        # 0x75da3a48a000
    75da27365b11:	add    $0xa8,%rsp
    75da27365b18:	ret
    75da27365b19:	mov    0x1(%rax),%rax
    75da27365b1d:	mov    0xe(%rax),%rax
    75da27365b21:	movabs $0x75da2c93b37c,%rbx
    75da27365b2b:	cmp    %rbx,%rax
    75da27365b2e:	jne    0x75da27365b4d
    75da27365b34:	mov    %eax,0x131244c6(%rip)        # 0x75da3a48a000
    75da27365b3a:	add    $0xa8,%rsp
    75da27365b41:	lea    0x5(%rip),%rbx        # 0x75da27365b4d
    75da27365b48:	jmp    0x75da27557010
    75da27365b4d:	movabs $0x75da2c928f9c,%rax
    75da27365b57:	add    $0x8,%r14
    75da27365b5b:	mov    %rax,(%r14)
    75da27365b5e:	call   0x75da2779f600
    75da27365b63:	movabs $0x75da2c928f9c,%rax
    75da27365b6d:	add    $0x8,%r14
    75da27365b71:	mov    %rax,(%r14)
    75da27365b74:	call   0x75da2779f600
    75da27365b79:	mov    %rbx,%rcx
    75da27365b7c:	and    $0xf,%ecx
    75da27365b7f:	cmp    $0x3,%rcx
    75da27365b83:	jne    0x75da27365f7e
    75da27365b89:	mov    %rax,%rcx
    75da27365b8c:	test   $0xf,%ecx
    75da27365b92:	jne    0x75da27365c0b
    75da27365b98:	lea    0x10(%r13),%rdx
    75da27365b9c:	mov    (%rdx),%rcx
    75da27365b9f:	add    $0x10,%rcx
    75da27365ba3:	cmp    0x10(%rdx),%rcx
    75da27365ba7:	jle    0x75da27365bc4
    75da27365bad:	mov    %rbx,(%rsp)
    75da27365bb1:	mov    %rax,0x8(%rsp)
    75da27365bb6:	call   0x75da273cf060
    75da27365bbb:	mov    (%rsp),%rbx
    75da27365bbf:	mov    0x8(%rsp),%rax
    75da27365bc4:	sar    $0x4,%rax
    75da27365bc8:	xorps  %xmm1,%xmm1
    75da27365bcb:	cvtsi2sd %rax,%xmm1
    75da27365bd0:	rex.W movsd 0x5(%rbx),%xmm0
    75da27365bd6:	addsd  %xmm1,%xmm0
    75da27365bda:	lea    0x10(%r13),%rbx
    75da27365bde:	mov    (%rbx),%rax
    75da27365be1:	movq   $0xc,(%rax)
    75da27365be8:	or     $0x3,%rax
    75da27365bec:	addq   $0x10,(%rbx)
    75da27365bf0:	rex.W movsd %xmm0,0x5(%rax)
    75da27365bf6:	sub    $0x8,%r14
    75da27365bfa:	mov    %rax,(%r14)
    75da27365bfd:	mov    %eax,0x131243fd(%rip)        # 0x75da3a48a000
    75da27365c03:	add    $0xa8,%rsp
    75da27365c0a:	ret
    75da27365c0b:	mov    %rax,%rcx
    75da27365c0e:	and    $0xf,%ecx
    75da27365c11:	cmp    $0x3,%rcx
    75da27365c15:	jne    0x75da27365c88
    75da27365c1b:	lea    0x10(%r13),%rdx
    75da27365c1f:	mov    (%rdx),%rcx
    75da27365c22:	add    $0x10,%rcx
    75da27365c26:	cmp    0x10(%rdx),%rcx
    75da27365c2a:	jle    0x75da27365c47
    75da27365c30:	mov    %rbx,(%rsp)
    75da27365c34:	mov    %rax,0x8(%rsp)
    75da27365c39:	call   0x75da273cf060
    75da27365c3e:	mov    (%rsp),%rbx
    75da27365c42:	mov    0x8(%rsp),%rax
    75da27365c47:	rex.W movsd 0x5(%rbx),%xmm0
    75da27365c4d:	rex.W movsd 0x5(%rax),%xmm1
    75da27365c53:	addsd  %xmm1,%xmm0
    75da27365c57:	lea    0x10(%r13),%rbx
    75da27365c5b:	mov    (%rbx),%rax
    75da27365c5e:	movq   $0xc,(%rax)
    75da27365c65:	or     $0x3,%rax
    75da27365c69:	addq   $0x10,(%rbx)
    75da27365c6d:	rex.W movsd %xmm0,0x5(%rax)
    75da27365c73:	sub    $0x8,%r14
    75da27365c77:	mov    %rax,(%r14)
    75da27365c7a:	mov    %eax,0x13124380(%rip)        # 0x75da3a48a000
    75da27365c80:	add    $0xa8,%rsp
    75da27365c87:	ret
    75da27365c88:	mov    %rax,%rbx
    75da27365c8b:	and    $0xf,%ebx
    75da27365c8e:	cmp    $0x5,%rbx
    75da27365c92:	jne    0x75da27365cff
    75da27365c98:	call   0x75da2719ea50
    75da27365c9d:	lea    0x10(%r13),%rax
    75da27365ca1:	mov    (%rax),%rbx
    75da27365ca4:	add    $0x10,%rbx
    75da27365ca8:	cmp    0x10(%rax),%rbx
    75da27365cac:	jle    0x75da27365cb7
    75da27365cb2:	call   0x75da273cf060
    75da27365cb7:	mov    (%r14),%rax
    75da27365cba:	mov    -0x8(%r14),%rbx
    75da27365cbe:	rex.W movsd 0x5(%rbx),%xmm0
    75da27365cc4:	rex.W movsd 0x5(%rax),%xmm1
    75da27365cca:	addsd  %xmm1,%xmm0
    75da27365cce:	lea    0x10(%r13),%rbx
    75da27365cd2:	mov    (%rbx),%rax
    75da27365cd5:	movq   $0xc,(%rax)
    75da27365cdc:	or     $0x3,%rax
    75da27365ce0:	addq   $0x10,(%rbx)
    75da27365ce4:	rex.W movsd %xmm0,0x5(%rax)
    75da27365cea:	sub    $0x8,%r14
    75da27365cee:	mov    %rax,(%r14)
    75da27365cf1:	mov    %eax,0x13124309(%rip)        # 0x75da3a48a000
    75da27365cf7:	add    $0xa8,%rsp
    75da27365cfe:	ret
    75da27365cff:	mov    %rax,%rbx
    75da27365d02:	and    $0xf,%ebx
    75da27365d05:	cmp    $0x7,%rbx
    75da27365d09:	jne    0x75da27365f68
    75da27365d0f:	mov    0x1(%rax),%rbx
    75da27365d13:	mov    0xe(%rbx),%rbx
    75da27365d17:	movabs $0x75da2c94e1dc,%rcx
    75da27365d21:	cmp    %rcx,%rbx
    75da27365d24:	jne    0x75da27365ed0
    75da27365d2a:	mov    0x9(%rax),%rbx
    75da27365d2e:	mov    0x11(%rax),%rax
    75da27365d32:	add    $0x10,%r15
    75da27365d36:	mov    %rax,-0x8(%r15)
    75da27365d3a:	mov    %rbx,(%r14)
    75da27365d3d:	movq   $0x0,(%r15)
    75da27365d44:	call   0x75da261aefc0
    75da27365d49:	lea    0x10(%r13),%rbx
    75da27365d4d:	mov    (%rbx),%rax
    75da27365d50:	add    $0x10,%rax
    75da27365d54:	cmp    0x10(%rbx),%rax
    75da27365d58:	jle    0x75da27365d63
    75da27365d5e:	call   0x75da273cf060
    75da27365d63:	mov    (%r14),%rcx
    75da27365d66:	mov    (%r15),%rax
    75da27365d69:	mov    -0x8(%r14),%rdx
    75da27365d6d:	mov    -0x8(%r15),%rbx
    75da27365d71:	rex.W movsd 0x5(%rdx),%xmm0
    75da27365d77:	rex.W movsd 0x5(%rcx),%xmm1
    75da27365d7d:	addsd  %xmm1,%xmm0
    75da27365d81:	lea    0x10(%r13),%rdx
    75da27365d85:	mov    (%rdx),%rcx
    75da27365d88:	movq   $0xc,(%rcx)
    75da27365d8f:	or     $0x3,%rcx
    75da27365d93:	addq   $0x10,(%rdx)
    75da27365d97:	rex.W movsd %xmm0,0x5(%rcx)
    75da27365d9d:	add    $0x8,%r14
    75da27365da1:	sub    $0x10,%r15
    75da27365da5:	mov    %rax,-0x8(%r14)
    75da27365da9:	mov    %rbx,(%r14)
    75da27365dac:	mov    %rcx,-0x10(%r14)
    75da27365db0:	call   0x75da27365860
    75da27365db5:	mov    (%r14),%rax
    75da27365db8:	add    $0x8,%r14
    75da27365dbc:	cmp    $0x0,%rax
    75da27365dc0:	jne    0x75da27365ddc
    75da27365dc6:	sub    $0x8,%r14
    75da27365dca:	sub    $0x8,%r14
    75da27365dce:	mov    %eax,0x1312422c(%rip)        # 0x75da3a48a000
    75da27365dd4:	add    $0xa8,%rsp
    75da27365ddb:	ret
    75da27365ddc:	mov    %rax,%rbx
    75da27365ddf:	test   $0xf,%ebx
    75da27365de5:	jne    0x75da27365dfb
    75da27365deb:	sub    $0x8,%r14
    75da27365def:	mov    (%r14),%rax
    75da27365df2:	mov    -0x8(%r14),%rbx
    75da27365df6:	jmp    0x75da27365e5f
    75da27365dfb:	mov    %rax,%rbx
    75da27365dfe:	and    $0xf,%ebx
    75da27365e01:	cmp    $0x5,%rbx
    75da27365e05:	jne    0x75da27365e54
    75da27365e0b:	movabs $0x75da2c9dd9e5,%rbx
    75da27365e15:	add    $0x8,%r14
    75da27365e19:	mov    %rax,-0x8(%r14)
    75da27365e1d:	mov    %rbx,(%r14)
    75da27365e20:	call   0x75da276ca440
    75da27365e25:	mov    (%r14),%rax
    75da27365e28:	sub    $0x8,%r14
    75da27365e2c:	cmp    $0x1,%rax
    75da27365e30:	je     0x75da27365e48
    75da27365e36:	sub    $0x8,%r14
    75da27365e3a:	mov    %eax,0x131241c0(%rip)        # 0x75da3a48a000
    75da27365e40:	add    $0xa8,%rsp
    75da27365e47:	ret
    75da27365e48:	mov    (%r14),%rax
    75da27365e4b:	mov    -0x8(%r14),%rbx
    75da27365e4f:	jmp    0x75da27365e5f
    75da27365e54:	sub    $0x8,%r14
    75da27365e58:	mov    (%r14),%rax
    75da27365e5b:	mov    -0x8(%r14),%rbx
    75da27365e5f:	lea    0x10(%r13),%rdx
    75da27365e63:	mov    (%rdx),%rcx
    75da27365e66:	add    $0x20,%rcx
    75da27365e6a:	cmp    0x10(%rdx),%rcx
    75da27365e6e:	jle    0x75da27365e8d
    75da27365e74:	mov    %rbx,0x20(%rsp)
    75da27365e79:	mov    %rax,0x28(%rsp)
    75da27365e7e:	call   0x75da273cf060
    75da27365e83:	mov    0x20(%rsp),%rbx
    75da27365e88:	mov    0x28(%rsp),%rax
    75da27365e8d:	movabs $0x75da2c94dda2,%rdx
    75da27365e97:	lea    0x10(%r13),%rbp
    75da27365e9b:	mov    0x0(%rbp),%rcx
    75da27365e9f:	movq   $0x1c,(%rcx)
    75da27365ea6:	or     $0x7,%rcx
    75da27365eaa:	addq   $0x20,0x0(%rbp)
    75da27365eaf:	mov    %rdx,0x1(%rcx)
    75da27365eb3:	mov    %rbx,0x9(%rcx)
    75da27365eb7:	mov    %rax,0x11(%rcx)
    75da27365ebb:	sub    $0x8,%r14
    75da27365ebf:	mov    %rcx,(%r14)
    75da27365ec2:	mov    %eax,0x13124138(%rip)        # 0x75da3a48a000
    75da27365ec8:	add    $0xa8,%rsp
    75da27365ecf:	ret
    75da27365ed0:	mov    0x1(%rax),%rax
    75da27365ed4:	mov    0xe(%rax),%rax
    75da27365ed8:	movabs $0x75da2c93b37c,%rbx
    75da27365ee2:	cmp    %rbx,%rax
    75da27365ee5:	jne    0x75da27365f52
    75da27365eeb:	call   0x75da270f1070
    75da27365ef0:	lea    0x10(%r13),%rax
    75da27365ef4:	mov    (%rax),%rbx
    75da27365ef7:	add    $0x10,%rbx
    75da27365efb:	cmp    0x10(%rax),%rbx
    75da27365eff:	jle    0x75da27365f0a
    75da27365f05:	call   0x75da273cf060
    75da27365f0a:	mov    (%r14),%rax
    75da27365f0d:	mov    -0x8(%r14),%rbx
    75da27365f11:	rex.W movsd 0x5(%rbx),%xmm0
    75da27365f17:	rex.W movsd 0x5(%rax),%xmm1
    75da27365f1d:	addsd  %xmm1,%xmm0
    75da27365f21:	lea    0x10(%r13),%rbx
    75da27365f25:	mov    (%rbx),%rax
    75da27365f28:	movq   $0xc,(%rax)
    75da27365f2f:	or     $0x3,%rax
    75da27365f33:	addq   $0x10,(%rbx)
    75da27365f37:	rex.W movsd %xmm0,0x5(%rax)
    75da27365f3d:	sub    $0x8,%r14
    75da27365f41:	mov    %rax,(%r14)
    75da27365f44:	mov    %eax,0x131240b6(%rip)        # 0x75da3a48a000
    75da27365f4a:	add    $0xa8,%rsp
    75da27365f51:	ret
    75da27365f52:	movabs $0x75da2c928f9c,%rax
    75da27365f5c:	add    $0x8,%r14
    75da27365f60:	mov    %rax,(%r14)
    75da27365f63:	call   0x75da2779f600
    75da27365f68:	movabs $0x75da2c928f9c,%rax
    75da27365f72:	add    $0x8,%r14
    75da27365f76:	mov    %rax,(%r14)
    75da27365f79:	call   0x75da2779f600
    75da27365f7e:	mov    %rbx,%rcx
    75da27365f81:	and    $0xf,%ecx
    75da27365f84:	cmp    $0x5,%rcx
    75da27365f88:	jne    0x75da27366245
    75da27365f8e:	mov    %rax,%rbx
    75da27365f91:	test   $0xf,%ebx
    75da27365f97:	jne    0x75da27365fbb
    75da27365f9d:	call   0x75da277a44d0
    75da27365fa2:	mov    %eax,0x13124058(%rip)        # 0x75da3a48a000
    75da27365fa8:	add    $0xa8,%rsp
    75da27365faf:	lea    0x5(%rip),%rbx        # 0x75da27365fbb
    75da27365fb6:	jmp    0x75da276d2070
    75da27365fbb:	mov    %rax,%rbx
    75da27365fbe:	and    $0xf,%ebx
    75da27365fc1:	cmp    $0x3,%rbx
    75da27365fc5:	jne    0x75da2736603c
    75da27365fcb:	sub    $0x8,%r14
    75da27365fcf:	add    $0x8,%r15
    75da27365fd3:	mov    %rax,(%r15)
    75da27365fd6:	call   0x75da2719ea50
    75da27365fdb:	lea    0x10(%r13),%rax
    75da27365fdf:	mov    (%rax),%rbx
    75da27365fe2:	add    $0x10,%rbx
    75da27365fe6:	cmp    0x10(%rax),%rbx
    75da27365fea:	jle    0x75da27365ff5
    75da27365ff0:	call   0x75da273cf060
    75da27365ff5:	mov    (%r15),%rax
    75da27365ff8:	mov    (%r14),%rbx
    75da27365ffb:	rex.W movsd 0x5(%rbx),%xmm0
    75da27366001:	rex.W movsd 0x5(%rax),%xmm1
    75da27366007:	addsd  %xmm1,%xmm0
    75da2736600b:	lea    0x10(%r13),%rbx
    75da2736600f:	mov    (%rbx),%rax
    75da27366012:	movq   $0xc,(%rax)
    75da27366019:	or     $0x3,%rax
    75da2736601d:	addq   $0x10,(%rbx)
    75da27366021:	rex.W movsd %xmm0,0x5(%rax)
    75da27366027:	sub    $0x8,%r15
    75da2736602b:	mov    %rax,(%r14)
    75da2736602e:	mov    %eax,0x13123fcc(%rip)        # 0x75da3a48a000
    75da27366034:	add    $0xa8,%rsp
    75da2736603b:	ret
    75da2736603c:	mov    %rax,%rbx
    75da2736603f:	and    $0xf,%ebx
    75da27366042:	cmp    $0x5,%rbx
    75da27366046:	jne    0x75da27366065
    75da2736604c:	mov    %eax,0x13123fae(%rip)        # 0x75da3a48a000
    75da27366052:	add    $0xa8,%rsp
    75da27366059:	lea    0x5(%rip),%rbx        # 0x75da27366065
    75da27366060:	jmp    0x75da276d2070
    75da27366065:	mov    %rax,%rbx
    75da27366068:	and    $0xf,%ebx
    75da2736606b:	cmp    $0x7,%rbx
    75da2736606f:	jne    0x75da2736622f
    75da27366075:	mov    0x1(%rax),%rbx
    75da27366079:	mov    0xe(%rbx),%rbx
    75da2736607d:	movabs $0x75da2c94e1dc,%rcx
    75da27366087:	cmp    %rcx,%rbx
    75da2736608a:	jne    0x75da273661e5
    75da27366090:	mov    0x9(%rax),%rbx
    75da27366094:	mov    0x11(%rax),%rax
    75da27366098:	add    $0x10,%r15
    75da2736609c:	mov    %rax,-0x8(%r15)
    75da273660a0:	mov    %rbx,(%r14)
    75da273660a3:	movq   $0x0,(%r15)
    75da273660aa:	call   0x75da27365860
    75da273660af:	mov    (%r15),%rax
    75da273660b2:	mov    -0x8(%r15),%rbx
    75da273660b6:	add    $0x10,%r14
    75da273660ba:	sub    $0x10,%r15
    75da273660be:	mov    %rax,-0x8(%r14)
    75da273660c2:	mov    %rbx,(%r14)
    75da273660c5:	call   0x75da27365860
    75da273660ca:	mov    (%r14),%rax
    75da273660cd:	add    $0x8,%r14
    75da273660d1:	cmp    $0x0,%rax
    75da273660d5:	jne    0x75da273660f1
    75da273660db:	sub    $0x8,%r14
    75da273660df:	sub    $0x8,%r14
    75da273660e3:	mov    %eax,0x13123f17(%rip)        # 0x75da3a48a000
    75da273660e9:	add    $0xa8,%rsp
    75da273660f0:	ret
    75da273660f1:	mov    %rax,%rbx
    75da273660f4:	test   $0xf,%ebx
    75da273660fa:	jne    0x75da27366110
    75da27366100:	sub    $0x8,%r14
    75da27366104:	mov    (%r14),%rax
    75da27366107:	mov    -0x8(%r14),%rbx
    75da2736610b:	jmp    0x75da27366174
    75da27366110:	mov    %rax,%rbx
    75da27366113:	and    $0xf,%ebx
    75da27366116:	cmp    $0x5,%rbx
    75da2736611a:	jne    0x75da27366169
    75da27366120:	movabs $0x75da2c9dd9e5,%rbx
    75da2736612a:	add    $0x8,%r14
    75da2736612e:	mov    %rax,-0x8(%r14)
    75da27366132:	mov    %rbx,(%r14)
    75da27366135:	call   0x75da276ca440
    75da2736613a:	mov    (%r14),%rax
    75da2736613d:	sub    $0x8,%r14
    75da27366141:	cmp    $0x1,%rax
    75da27366145:	je     0x75da2736615d
    75da2736614b:	sub    $0x8,%r14
    75da2736614f:	mov    %eax,0x13123eab(%rip)        # 0x75da3a48a000
    75da27366155:	add    $0xa8,%rsp
    75da2736615c:	ret
    75da2736615d:	mov    (%r14),%rax
    75da27366160:	mov    -0x8(%r14),%rbx
    75da27366164:	jmp    0x75da27366174
    75da27366169:	sub    $0x8,%r14
    75da2736616d:	mov    (%r14),%rax
    75da27366170:	mov    -0x8(%r14),%rbx
    75da27366174:	lea    0x10(%r13),%rcx
    75da27366178:	mov    (%rcx),%rdx
    75da2736617b:	add    $0x20,%rdx
    75da2736617f:	cmp    0x10(%rcx),%rdx
    75da27366183:	jle    0x75da273661a2
    75da27366189:	mov    %rbx,0x30(%rsp)
    75da2736618e:	mov    %rax,0x38(%rsp)
    75da27366193:	call   0x75da273cf060
    75da27366198:	mov    0x30(%rsp),%rbx
    75da2736619d:	mov    0x38(%rsp),%rax
    75da273661a2:	movabs $0x75da2c94dda2,%rdx
    75da273661ac:	lea    0x10(%r13),%rbp
    75da273661b0:	mov    0x0(%rbp),%rcx
    75da273661b4:	movq   $0x1c,(%rcx)
    75da273661bb:	or     $0x7,%rcx
    75da273661bf:	addq   $0x20,0x0(%rbp)
    75da273661c4:	mov    %rdx,0x1(%rcx)
    75da273661c8:	mov    %rbx,0x9(%rcx)
    75da273661cc:	mov    %rax,0x11(%rcx)
    75da273661d0:	sub    $0x8,%r14
    75da273661d4:	mov    %rcx,(%r14)
    75da273661d7:	mov    %eax,0x13123e23(%rip)        # 0x75da3a48a000
    75da273661dd:	add    $0xa8,%rsp
    75da273661e4:	ret
    75da273661e5:	mov    0x1(%rax),%rax
    75da273661e9:	mov    0xe(%rax),%rax
    75da273661ed:	movabs $0x75da2c93b37c,%rbx
    75da273661f7:	cmp    %rbx,%rax
    75da273661fa:	jne    0x75da27366219
    75da27366200:	mov    %eax,0x13123dfa(%rip)        # 0x75da3a48a000
    75da27366206:	add    $0xa8,%rsp
    75da2736620d:	lea    0x5(%rip),%rbx        # 0x75da27366219
    75da27366214:	jmp    0x75da27557010
    75da27366219:	movabs $0x75da2c928f9c,%rax
    75da27366223:	add    $0x8,%r14
    75da27366227:	mov    %rax,(%r14)
    75da2736622a:	call   0x75da2779f600
    75da2736622f:	movabs $0x75da2c928f9c,%rax
    75da27366239:	add    $0x8,%r14
    75da2736623d:	mov    %rax,(%r14)
    75da27366240:	call   0x75da2779f600
    75da27366245:	mov    %rbx,%rcx
    75da27366248:	and    $0xf,%ecx
    75da2736624b:	cmp    $0x7,%rcx
    75da2736624f:	jne    0x75da27366cf9
    75da27366255:	mov    0x1(%rbx),%rcx
    75da27366259:	mov    0xe(%rcx),%rcx
    75da2736625d:	movabs $0x75da2c94e1dc,%rdx
    75da27366267:	cmp    %rdx,%rcx
    75da2736626a:	jne    0x75da27366a0a
    75da27366270:	mov    %rax,%rcx
    75da27366273:	test   $0xf,%ecx
    75da27366279:	jne    0x75da273663cd
    75da2736627f:	mov    0x9(%rbx),%rax
    75da27366283:	mov    0x11(%rbx),%rbx
    75da27366287:	add    $0x8,%r15
    75da2736628b:	mov    %rbx,(%r15)
    75da2736628e:	mov    %rax,-0x8(%r14)
    75da27366292:	call   0x75da27365860
    75da27366297:	mov    (%r15),%rax
    75da2736629a:	add    $0x10,%r14
    75da2736629e:	sub    $0x8,%r15
    75da273662a2:	mov    %rax,-0x8(%r14)
    75da273662a6:	movq   $0x0,(%r14)
    75da273662ad:	call   0x75da27365860
    75da273662b2:	mov    (%r14),%rax
    75da273662b5:	add    $0x8,%r14
    75da273662b9:	cmp    $0x0,%rax
    75da273662bd:	jne    0x75da273662d9
    75da273662c3:	sub    $0x8,%r14
    75da273662c7:	sub    $0x8,%r14
    75da273662cb:	mov    %eax,0x13123d2f(%rip)        # 0x75da3a48a000
    75da273662d1:	add    $0xa8,%rsp
    75da273662d8:	ret
    75da273662d9:	mov    %rax,%rbx
    75da273662dc:	test   $0xf,%ebx
    75da273662e2:	jne    0x75da273662f8
    75da273662e8:	sub    $0x8,%r14
    75da273662ec:	mov    (%r14),%rax
    75da273662ef:	mov    -0x8(%r14),%rbx
    75da273662f3:	jmp    0x75da2736635c
    75da273662f8:	mov    %rax,%rbx
    75da273662fb:	and    $0xf,%ebx
    75da273662fe:	cmp    $0x5,%rbx
    75da27366302:	jne    0x75da27366351
    75da27366308:	movabs $0x75da2c9dd9e5,%rbx
    75da27366312:	add    $0x8,%r14
    75da27366316:	mov    %rax,-0x8(%r14)
    75da2736631a:	mov    %rbx,(%r14)
    75da2736631d:	call   0x75da276ca440
    75da27366322:	mov    (%r14),%rax
    75da27366325:	sub    $0x8,%r14
    75da27366329:	cmp    $0x1,%rax
    75da2736632d:	je     0x75da27366345
    75da27366333:	sub    $0x8,%r14
    75da27366337:	mov    %eax,0x13123cc3(%rip)        # 0x75da3a48a000
    75da2736633d:	add    $0xa8,%rsp
    75da27366344:	ret
    75da27366345:	mov    (%r14),%rax
    75da27366348:	mov    -0x8(%r14),%rbx
    75da2736634c:	jmp    0x75da2736635c
    75da27366351:	sub    $0x8,%r14
    75da27366355:	mov    (%r14),%rax
    75da27366358:	mov    -0x8(%r14),%rbx
    75da2736635c:	lea    0x10(%r13),%rdx
    75da27366360:	mov    (%rdx),%rcx
    75da27366363:	add    $0x20,%rcx
    75da27366367:	cmp    0x10(%rdx),%rcx
    75da2736636b:	jle    0x75da2736638a
    75da27366371:	mov    %rbx,0x40(%rsp)
    75da27366376:	mov    %rax,0x48(%rsp)
    75da2736637b:	call   0x75da273cf060
    75da27366380:	mov    0x40(%rsp),%rbx
    75da27366385:	mov    0x48(%rsp),%rax
    75da2736638a:	movabs $0x75da2c94dda2,%rdx
    75da27366394:	lea    0x10(%r13),%rbp
    75da27366398:	mov    0x0(%rbp),%rcx
    75da2736639c:	movq   $0x1c,(%rcx)
    75da273663a3:	or     $0x7,%rcx
    75da273663a7:	addq   $0x20,0x0(%rbp)
    75da273663ac:	mov    %rdx,0x1(%rcx)
    75da273663b0:	mov    %rbx,0x9(%rcx)
    75da273663b4:	mov    %rax,0x11(%rcx)
    75da273663b8:	sub    $0x8,%r14
    75da273663bc:	mov    %rcx,(%r14)
    75da273663bf:	mov    %eax,0x13123c3b(%rip)        # 0x75da3a48a000
    75da273663c5:	add    $0xa8,%rsp
    75da273663cc:	ret
    75da273663cd:	mov    %rax,%rcx
    75da273663d0:	and    $0xf,%ecx
    75da273663d3:	cmp    $0x3,%rcx
    75da273663d7:	jne    0x75da27366583
    75da273663dd:	mov    0x9(%rbx),%rcx
    75da273663e1:	mov    0x11(%rbx),%rbx
    75da273663e5:	sub    $0x8,%r14
    75da273663e9:	add    $0x10,%r15
    75da273663ed:	mov    %rax,(%r15)
    75da273663f0:	mov    %rbx,-0x8(%r15)
    75da273663f4:	mov    %rcx,(%r14)
    75da273663f7:	call   0x75da261aefc0
    75da273663fc:	lea    0x10(%r13),%rax
    75da27366400:	mov    (%rax),%rbx
    75da27366403:	add    $0x10,%rbx
    75da27366407:	cmp    0x10(%rax),%rbx
    75da2736640b:	jle    0x75da27366416
    75da27366411:	call   0x75da273cf060
    75da27366416:	mov    (%r15),%rbx
    75da27366419:	mov    (%r14),%rcx
    75da2736641c:	mov    -0x8(%r15),%rax
    75da27366420:	rex.W movsd 0x5(%rcx),%xmm0
    75da27366426:	rex.W movsd 0x5(%rbx),%xmm1
    75da2736642c:	addsd  %xmm1,%xmm0
    75da27366430:	lea    0x10(%r13),%rcx
    75da27366434:	mov    (%rcx),%rbx
    75da27366437:	movq   $0xc,(%rbx)
    75da2736643e:	or     $0x3,%rbx
    75da27366442:	addq   $0x10,(%rcx)
    75da27366446:	rex.W movsd %xmm0,0x5(%rbx)
    75da2736644c:	add    $0x10,%r14
    75da27366450:	sub    $0x10,%r15
    75da27366454:	mov    %rax,-0x8(%r14)
    75da27366458:	movq   $0x0,(%r14)
    75da2736645f:	mov    %rbx,-0x10(%r14)
    75da27366463:	call   0x75da27365860
    75da27366468:	mov    (%r14),%rax
    75da2736646b:	add    $0x8,%r14
    75da2736646f:	cmp    $0x0,%rax
    75da27366473:	jne    0x75da2736648f
    75da27366479:	sub    $0x8,%r14
    75da2736647d:	sub    $0x8,%r14
    75da27366481:	mov    %eax,0x13123b79(%rip)        # 0x75da3a48a000
    75da27366487:	add    $0xa8,%rsp
    75da2736648e:	ret
    75da2736648f:	mov    %rax,%rbx
    75da27366492:	test   $0xf,%ebx
    75da27366498:	jne    0x75da273664ae
    75da2736649e:	sub    $0x8,%r14
    75da273664a2:	mov    (%r14),%rax
    75da273664a5:	mov    -0x8(%r14),%rbx
    75da273664a9:	jmp    0x75da27366512
    75da273664ae:	mov    %rax,%rbx
    75da273664b1:	and    $0xf,%ebx
    75da273664b4:	cmp    $0x5,%rbx
    75da273664b8:	jne    0x75da27366507
    75da273664be:	movabs $0x75da2c9dd9e5,%rbx
    75da273664c8:	add    $0x8,%r14
    75da273664cc:	mov    %rax,-0x8(%r14)
    75da273664d0:	mov    %rbx,(%r14)
    75da273664d3:	call   0x75da276ca440
    75da273664d8:	mov    (%r14),%rax
    75da273664db:	sub    $0x8,%r14
    75da273664df:	cmp    $0x1,%rax
    75da273664e3:	je     0x75da273664fb
    75da273664e9:	sub    $0x8,%r14
    75da273664ed:	mov    %eax,0x13123b0d(%rip)        # 0x75da3a48a000
    75da273664f3:	add    $0xa8,%rsp
    75da273664fa:	ret
    75da273664fb:	mov    (%r14),%rax
    75da273664fe:	mov    -0x8(%r14),%rbx
    75da27366502:	jmp    0x75da27366512
    75da27366507:	sub    $0x8,%r14
    75da2736650b:	mov    (%r14),%rax
    75da2736650e:	mov    -0x8(%r14),%rbx
    75da27366512:	lea    0x10(%r13),%rdx
    75da27366516:	mov    (%rdx),%rcx
    75da27366519:	add    $0x20,%rcx
    75da2736651d:	cmp    0x10(%rdx),%rcx
    75da27366521:	jle    0x75da27366540
    75da27366527:	mov    %rbx,0x50(%rsp)
    75da2736652c:	mov    %rax,0x58(%rsp)
    75da27366531:	call   0x75da273cf060
    75da27366536:	mov    0x50(%rsp),%rbx
    75da2736653b:	mov    0x58(%rsp),%rax
    75da27366540:	movabs $0x75da2c94dda2,%rdx
    75da2736654a:	lea    0x10(%r13),%rbp
    75da2736654e:	mov    0x0(%rbp),%rcx
    75da27366552:	movq   $0x1c,(%rcx)
    75da27366559:	or     $0x7,%rcx
    75da2736655d:	addq   $0x20,0x0(%rbp)
    75da27366562:	mov    %rdx,0x1(%rcx)
    75da27366566:	mov    %rbx,0x9(%rcx)
    75da2736656a:	mov    %rax,0x11(%rcx)
    75da2736656e:	sub    $0x8,%r14
    75da27366572:	mov    %rcx,(%r14)
    75da27366575:	mov    %eax,0x13123a85(%rip)        # 0x75da3a48a000
    75da2736657b:	add    $0xa8,%rsp
    75da27366582:	ret
    75da27366583:	mov    %rax,%rcx
    75da27366586:	and    $0xf,%ecx
    75da27366589:	cmp    $0x5,%rcx
    75da2736658d:	jne    0x75da273666e1
    75da27366593:	mov    0x9(%rbx),%rax
    75da27366597:	mov    0x11(%rbx),%rbx
    75da2736659b:	add    $0x8,%r15
    75da2736659f:	mov    %rbx,(%r15)
    75da273665a2:	mov    %rax,-0x8(%r14)
    75da273665a6:	call   0x75da27365860
    75da273665ab:	mov    (%r15),%rax
    75da273665ae:	add    $0x10,%r14
    75da273665b2:	sub    $0x8,%r15
    75da273665b6:	mov    %rax,-0x8(%r14)
    75da273665ba:	movq   $0x0,(%r14)
    75da273665c1:	call   0x75da27365860
    75da273665c6:	mov    (%r14),%rax
    75da273665c9:	add    $0x8,%r14
    75da273665cd:	cmp    $0x0,%rax
    75da273665d1:	jne    0x75da273665ed
    75da273665d7:	sub    $0x8,%r14
    75da273665db:	sub    $0x8,%r14
    75da273665df:	mov    %eax,0x13123a1b(%rip)        # 0x75da3a48a000
    75da273665e5:	add    $0xa8,%rsp
    75da273665ec:	ret
    75da273665ed:	mov    %rax,%rbx
    75da273665f0:	test   $0xf,%ebx
    75da273665f6:	jne    0x75da2736660c
    75da273665fc:	sub    $0x8,%r14
    75da27366600:	mov    (%r14),%rax
    75da27366603:	mov    -0x8(%r14),%rbx
    75da27366607:	jmp    0x75da27366670
    75da2736660c:	mov    %rax,%rbx
    75da2736660f:	and    $0xf,%ebx
    75da27366612:	cmp    $0x5,%rbx
    75da27366616:	jne    0x75da27366665
    75da2736661c:	movabs $0x75da2c9dd9e5,%rbx
    75da27366626:	add    $0x8,%r14
    75da2736662a:	mov    %rax,-0x8(%r14)
    75da2736662e:	mov    %rbx,(%r14)
    75da27366631:	call   0x75da276ca440
    75da27366636:	mov    (%r14),%rax
    75da27366639:	sub    $0x8,%r14
    75da2736663d:	cmp    $0x1,%rax
    75da27366641:	je     0x75da27366659
    75da27366647:	sub    $0x8,%r14
    75da2736664b:	mov    %eax,0x131239af(%rip)        # 0x75da3a48a000
    75da27366651:	add    $0xa8,%rsp
    75da27366658:	ret
    75da27366659:	mov    (%r14),%rax
    75da2736665c:	mov    -0x8(%r14),%rbx
    75da27366660:	jmp    0x75da27366670
    75da27366665:	sub    $0x8,%r14
    75da27366669:	mov    (%r14),%rax
    75da2736666c:	mov    -0x8(%r14),%rbx
    75da27366670:	lea    0x10(%r13),%rdx
    75da27366674:	mov    (%rdx),%rcx
    75da27366677:	add    $0x20,%rcx
    75da2736667b:	cmp    0x10(%rdx),%rcx
    75da2736667f:	jle    0x75da2736669e
    75da27366685:	mov    %rbx,0x60(%rsp)
    75da2736668a:	mov    %rax,0x68(%rsp)
    75da2736668f:	call   0x75da273cf060
    75da27366694:	mov    0x60(%rsp),%rbx
    75da27366699:	mov    0x68(%rsp),%rax
    75da2736669e:	movabs $0x75da2c94dda2,%rdx
    75da273666a8:	lea    0x10(%r13),%rbp
    75da273666ac:	mov    0x0(%rbp),%rcx
    75da273666b0:	movq   $0x1c,(%rcx)
    75da273666b7:	or     $0x7,%rcx
    75da273666bb:	addq   $0x20,0x0(%rbp)
    75da273666c0:	mov    %rdx,0x1(%rcx)
    75da273666c4:	mov    %rbx,0x9(%rcx)
    75da273666c8:	mov    %rax,0x11(%rcx)
    75da273666cc:	sub    $0x8,%r14
    75da273666d0:	mov    %rcx,(%r14)
    75da273666d3:	mov    %eax,0x13123927(%rip)        # 0x75da3a48a000
    75da273666d9:	add    $0xa8,%rsp
    75da273666e0:	ret
    75da273666e1:	mov    %rax,%rcx
    75da273666e4:	and    $0xf,%ecx
    75da273666e7:	cmp    $0x7,%rcx
    75da273666eb:	jne    0x75da273669f4
    75da273666f1:	mov    0x1(%rax),%rcx
    75da273666f5:	mov    0xe(%rcx),%rcx
    75da273666f9:	movabs $0x75da2c94e1dc,%rdx
    75da27366703:	cmp    %rdx,%rcx
    75da27366706:	jne    0x75da27366869
    75da2736670c:	mov    0x9(%rbx),%rcx
    75da27366710:	mov    0x11(%rbx),%rbx
    75da27366714:	mov    0x9(%rax),%rdx
    75da27366718:	mov    0x11(%rax),%rax
    75da2736671c:	add    $0x10,%r15
    75da27366720:	mov    %rax,-0x8(%r15)
    75da27366724:	mov    %rcx,-0x8(%r14)
    75da27366728:	mov    %rdx,(%r14)
    75da2736672b:	mov    %rbx,(%r15)
    75da2736672e:	call   0x75da27365860
    75da27366733:	mov    (%r15),%rax
    75da27366736:	mov    -0x8(%r15),%rbx
    75da2736673a:	add    $0x10,%r14
    75da2736673e:	sub    $0x10,%r15
    75da27366742:	mov    %rax,-0x8(%r14)
    75da27366746:	mov    %rbx,(%r14)
    75da27366749:	call   0x75da27365860
    75da2736674e:	mov    (%r14),%rax
    75da27366751:	add    $0x8,%r14
    75da27366755:	cmp    $0x0,%rax
    75da27366759:	jne    0x75da27366775
    75da2736675f:	sub    $0x8,%r14
    75da27366763:	sub    $0x8,%r14
    75da27366767:	mov    %eax,0x13123893(%rip)        # 0x75da3a48a000
    75da2736676d:	add    $0xa8,%rsp
    75da27366774:	ret
    75da27366775:	mov    %rax,%rbx
    75da27366778:	test   $0xf,%ebx
    75da2736677e:	jne    0x75da27366794
    75da27366784:	sub    $0x8,%r14
    75da27366788:	mov    (%r14),%rax
    75da2736678b:	mov    -0x8(%r14),%rbx
    75da2736678f:	jmp    0x75da273667f8
    75da27366794:	mov    %rax,%rbx
    75da27366797:	and    $0xf,%ebx
    75da2736679a:	cmp    $0x5,%rbx
    75da2736679e:	jne    0x75da273667ed
    75da273667a4:	movabs $0x75da2c9dd9e5,%rbx
    75da273667ae:	add    $0x8,%r14
    75da273667b2:	mov    %rax,-0x8(%r14)
    75da273667b6:	mov    %rbx,(%r14)
    75da273667b9:	call   0x75da276ca440
    75da273667be:	mov    (%r14),%rax
    75da273667c1:	sub    $0x8,%r14
    75da273667c5:	cmp    $0x1,%rax
    75da273667c9:	je     0x75da273667e1
    75da273667cf:	sub    $0x8,%r14
    75da273667d3:	mov    %eax,0x13123827(%rip)        # 0x75da3a48a000
    75da273667d9:	add    $0xa8,%rsp
    75da273667e0:	ret
    75da273667e1:	mov    (%r14),%rax
    75da273667e4:	mov    -0x8(%r14),%rbx
    75da273667e8:	jmp    0x75da273667f8
    75da273667ed:	sub    $0x8,%r14
    75da273667f1:	mov    (%r14),%rax
    75da273667f4:	mov    -0x8(%r14),%rbx
    75da273667f8:	lea    0x10(%r13),%rcx
    75da273667fc:	mov    (%rcx),%rdx
    75da273667ff:	add    $0x20,%rdx
    75da27366803:	cmp    0x10(%rcx),%rdx
    75da27366807:	jle    0x75da27366826
    75da2736680d:	mov    %rbx,0x70(%rsp)
    75da27366812:	mov    %rax,0x78(%rsp)
    75da27366817:	call   0x75da273cf060
    75da2736681c:	mov    0x70(%rsp),%rbx
    75da27366821:	mov    0x78(%rsp),%rax
    75da27366826:	movabs $0x75da2c94dda2,%rdx
    75da27366830:	lea    0x10(%r13),%rbp
    75da27366834:	mov    0x0(%rbp),%rcx
    75da27366838:	movq   $0x1c,(%rcx)
    75da2736683f:	or     $0x7,%rcx
    75da27366843:	addq   $0x20,0x0(%rbp)
    75da27366848:	mov    %rdx,0x1(%rcx)
    75da2736684c:	mov    %rbx,0x9(%rcx)
    75da27366850:	mov    %rax,0x11(%rcx)
    75da27366854:	sub    $0x8,%r14
    75da27366858:	mov    %rcx,(%r14)
    75da2736685b:	mov    %eax,0x1312379f(%rip)        # 0x75da3a48a000
    75da27366861:	add    $0xa8,%rsp
    75da27366868:	ret
    75da27366869:	mov    0x1(%rax),%rax
    75da2736686d:	mov    0xe(%rax),%rax
    75da27366871:	movabs $0x75da2c93b37c,%rcx
    75da2736687b:	cmp    %rcx,%rax
    75da2736687e:	jne    0x75da273669de
    75da27366884:	mov    0x9(%rbx),%rax
    75da27366888:	mov    0x11(%rbx),%rbx
    75da2736688c:	add    $0x8,%r15
    75da27366890:	mov    %rbx,(%r15)
    75da27366893:	mov    %rax,-0x8(%r14)
    75da27366897:	call   0x75da27365860
    75da2736689c:	mov    (%r15),%rax
    75da2736689f:	add    $0x10,%r14
    75da273668a3:	sub    $0x8,%r15
    75da273668a7:	mov    %rax,-0x8(%r14)
    75da273668ab:	movq   $0x0,(%r14)
    75da273668b2:	call   0x75da27365860
    75da273668b7:	mov    (%r14),%rax
    75da273668ba:	add    $0x8,%r14
    75da273668be:	cmp    $0x0,%rax
    75da273668c2:	jne    0x75da273668de
    75da273668c8:	sub    $0x8,%r14
    75da273668cc:	sub    $0x8,%r14
    75da273668d0:	mov    %eax,0x1312372a(%rip)        # 0x75da3a48a000
    75da273668d6:	add    $0xa8,%rsp
    75da273668dd:	ret
    75da273668de:	mov    %rax,%rbx
    75da273668e1:	test   $0xf,%ebx
    75da273668e7:	jne    0x75da273668fd
    75da273668ed:	sub    $0x8,%r14
    75da273668f1:	mov    (%r14),%rax
    75da273668f4:	mov    -0x8(%r14),%rbx
    75da273668f8:	jmp    0x75da27366961
    75da273668fd:	mov    %rax,%rbx
    75da27366900:	and    $0xf,%ebx
    75da27366903:	cmp    $0x5,%rbx
    75da27366907:	jne    0x75da27366956
    75da2736690d:	movabs $0x75da2c9dd9e5,%rbx
    75da27366917:	add    $0x8,%r14
    75da2736691b:	mov    %rax,-0x8(%r14)
    75da2736691f:	mov    %rbx,(%r14)
    75da27366922:	call   0x75da276ca440
    75da27366927:	mov    (%r14),%rax
    75da2736692a:	sub    $0x8,%r14
    75da2736692e:	cmp    $0x1,%rax
    75da27366932:	je     0x75da2736694a
    75da27366938:	sub    $0x8,%r14
    75da2736693c:	mov    %eax,0x131236be(%rip)        # 0x75da3a48a000
    75da27366942:	add    $0xa8,%rsp
    75da27366949:	ret
    75da2736694a:	mov    (%r14),%rax
    75da2736694d:	mov    -0x8(%r14),%rbx
    75da27366951:	jmp    0x75da27366961
    75da27366956:	sub    $0x8,%r14
    75da2736695a:	mov    (%r14),%rax
    75da2736695d:	mov    -0x8(%r14),%rbx
    75da27366961:	lea    0x10(%r13),%rcx
    75da27366965:	mov    (%rcx),%rdx
    75da27366968:	add    $0x20,%rdx
    75da2736696c:	cmp    0x10(%rcx),%rdx
    75da27366970:	jle    0x75da2736699b
    75da27366976:	mov    %rbx,0x80(%rsp)
    75da2736697e:	mov    %rax,0x88(%rsp)
    75da27366986:	call   0x75da273cf060
    75da2736698b:	mov    0x80(%rsp),%rbx
    75da27366993:	mov    0x88(%rsp),%rax
    75da2736699b:	movabs $0x75da2c94dda2,%rdx
    75da273669a5:	lea    0x10(%r13),%rbp
    75da273669a9:	mov    0x0(%rbp),%rcx
    75da273669ad:	movq   $0x1c,(%rcx)
    75da273669b4:	or     $0x7,%rcx
    75da273669b8:	addq   $0x20,0x0(%rbp)
    75da273669bd:	mov    %rdx,0x1(%rcx)
    75da273669c1:	mov    %rbx,0x9(%rcx)
    75da273669c5:	mov    %rax,0x11(%rcx)
    75da273669c9:	sub    $0x8,%r14
    75da273669cd:	mov    %rcx,(%r14)
    75da273669d0:	mov    %eax,0x1312362a(%rip)        # 0x75da3a48a000
    75da273669d6:	add    $0xa8,%rsp
    75da273669dd:	ret
    75da273669de:	movabs $0x75da2c928f9c,%rax
    75da273669e8:	add    $0x8,%r14
    75da273669ec:	mov    %rax,(%r14)
    75da273669ef:	call   0x75da2779f600
    75da273669f4:	movabs $0x75da2c928f9c,%rax
    75da273669fe:	add    $0x8,%r14
    75da27366a02:	mov    %rax,(%r14)
    75da27366a05:	call   0x75da2779f600
    75da27366a0a:	mov    0x1(%rbx),%rbx
    75da27366a0e:	mov    0xe(%rbx),%rbx
    75da27366a12:	movabs $0x75da2c93b37c,%rcx
    75da27366a1c:	cmp    %rcx,%rbx
    75da27366a1f:	jne    0x75da27366ce3
    75da27366a25:	mov    %rax,%rbx
    75da27366a28:	test   $0xf,%ebx
    75da27366a2e:	jne    0x75da27366a4d
    75da27366a34:	mov    %eax,0x131235c6(%rip)        # 0x75da3a48a000
    75da27366a3a:	add    $0xa8,%rsp
    75da27366a41:	lea    0x5(%rip),%rbx        # 0x75da27366a4d
    75da27366a48:	jmp    0x75da27557010
    75da27366a4d:	mov    %rax,%rbx
    75da27366a50:	and    $0xf,%ebx
    75da27366a53:	cmp    $0x3,%rbx
    75da27366a57:	jne    0x75da27366ace
    75da27366a5d:	sub    $0x8,%r14
    75da27366a61:	add    $0x8,%r15
    75da27366a65:	mov    %rax,(%r15)
    75da27366a68:	call   0x75da270f1070
    75da27366a6d:	lea    0x10(%r13),%rbx
    75da27366a71:	mov    (%rbx),%rax
    75da27366a74:	add    $0x10,%rax
    75da27366a78:	cmp    0x10(%rbx),%rax
    75da27366a7c:	jle    0x75da27366a87
    75da27366a82:	call   0x75da273cf060
    75da27366a87:	mov    (%r15),%rax
    75da27366a8a:	mov    (%r14),%rbx
    75da27366a8d:	rex.W movsd 0x5(%rbx),%xmm0
    75da27366a93:	rex.W movsd 0x5(%rax),%xmm1
    75da27366a99:	addsd  %xmm1,%xmm0
    75da27366a9d:	lea    0x10(%r13),%rbx
    75da27366aa1:	mov    (%rbx),%rax
    75da27366aa4:	movq   $0xc,(%rax)
    75da27366aab:	or     $0x3,%rax
    75da27366aaf:	addq   $0x10,(%rbx)
    75da27366ab3:	rex.W movsd %xmm0,0x5(%rax)
    75da27366ab9:	sub    $0x8,%r15
    75da27366abd:	mov    %rax,(%r14)
    75da27366ac0:	mov    %eax,0x1312353a(%rip)        # 0x75da3a48a000
    75da27366ac6:	add    $0xa8,%rsp
    75da27366acd:	ret
    75da27366ace:	mov    %rax,%rbx
    75da27366ad1:	and    $0xf,%ebx
    75da27366ad4:	cmp    $0x5,%rbx
    75da27366ad8:	jne    0x75da27366af7
    75da27366ade:	mov    %eax,0x1312351c(%rip)        # 0x75da3a48a000
    75da27366ae4:	add    $0xa8,%rsp
    75da27366aeb:	lea    0x5(%rip),%rbx        # 0x75da27366af7
    75da27366af2:	jmp    0x75da27557010
    75da27366af7:	mov    %rax,%rbx
    75da27366afa:	and    $0xf,%ebx
    75da27366afd:	cmp    $0x7,%rbx
    75da27366b01:	jne    0x75da27366ccd
    75da27366b07:	mov    0x1(%rax),%rbx
    75da27366b0b:	mov    0xe(%rbx),%rbx
    75da27366b0f:	movabs $0x75da2c94e1dc,%rcx
    75da27366b19:	cmp    %rcx,%rbx
    75da27366b1c:	jne    0x75da27366c83
    75da27366b22:	mov    0x9(%rax),%rbx
    75da27366b26:	mov    0x11(%rax),%rax
    75da27366b2a:	add    $0x10,%r15
    75da27366b2e:	mov    %rax,-0x8(%r15)
    75da27366b32:	mov    %rbx,(%r14)
    75da27366b35:	movq   $0x0,(%r15)
    75da27366b3c:	call   0x75da27365860
    75da27366b41:	mov    (%r15),%rbx
    75da27366b44:	mov    -0x8(%r15),%rax
    75da27366b48:	add    $0x10,%r14
    75da27366b4c:	sub    $0x10,%r15
    75da27366b50:	mov    %rbx,-0x8(%r14)
    75da27366b54:	mov    %rax,(%r14)
    75da27366b57:	call   0x75da27365860
    75da27366b5c:	mov    (%r14),%rax
    75da27366b5f:	add    $0x8,%r14
    75da27366b63:	cmp    $0x0,%rax
    75da27366b67:	jne    0x75da27366b83
    75da27366b6d:	sub    $0x8,%r14
    75da27366b71:	sub    $0x8,%r14
    75da27366b75:	mov    %eax,0x13123485(%rip)        # 0x75da3a48a000
    75da27366b7b:	add    $0xa8,%rsp
    75da27366b82:	ret
    75da27366b83:	mov    %rax,%rbx
    75da27366b86:	test   $0xf,%ebx
    75da27366b8c:	jne    0x75da27366ba2
    75da27366b92:	sub    $0x8,%r14
    75da27366b96:	mov    (%r14),%rax
    75da27366b99:	mov    -0x8(%r14),%rbx
    75da27366b9d:	jmp    0x75da27366c06
    75da27366ba2:	mov    %rax,%rbx
    75da27366ba5:	and    $0xf,%ebx
    75da27366ba8:	cmp    $0x5,%rbx
    75da27366bac:	jne    0x75da27366bfb
    75da27366bb2:	movabs $0x75da2c9dd9e5,%rbx
    75da27366bbc:	add    $0x8,%r14
    75da27366bc0:	mov    %rax,-0x8(%r14)
    75da27366bc4:	mov    %rbx,(%r14)
    75da27366bc7:	call   0x75da276ca440
    75da27366bcc:	mov    (%r14),%rax
    75da27366bcf:	sub    $0x8,%r14
    75da27366bd3:	cmp    $0x1,%rax
    75da27366bd7:	je     0x75da27366bef
    75da27366bdd:	sub    $0x8,%r14
    75da27366be1:	mov    %eax,0x13123419(%rip)        # 0x75da3a48a000
    75da27366be7:	add    $0xa8,%rsp
    75da27366bee:	ret
    75da27366bef:	mov    (%r14),%rax
    75da27366bf2:	mov    -0x8(%r14),%rbx
    75da27366bf6:	jmp    0x75da27366c06
    75da27366bfb:	sub    $0x8,%r14
    75da27366bff:	mov    (%r14),%rax
    75da27366c02:	mov    -0x8(%r14),%rbx
    75da27366c06:	lea    0x10(%r13),%rdx
    75da27366c0a:	mov    (%rdx),%rcx
    75da27366c0d:	add    $0x20,%rcx
    75da27366c11:	cmp    0x10(%rdx),%rcx
    75da27366c15:	jle    0x75da27366c40
    75da27366c1b:	mov    %rbx,0x90(%rsp)
    75da27366c23:	mov    %rax,0x98(%rsp)
    75da27366c2b:	call   0x75da273cf060
    75da27366c30:	mov    0x90(%rsp),%rbx
    75da27366c38:	mov    0x98(%rsp),%rax
    75da27366c40:	movabs $0x75da2c94dda2,%rdx
    75da27366c4a:	lea    0x10(%r13),%rbp
    75da27366c4e:	mov    0x0(%rbp),%rcx
    75da27366c52:	movq   $0x1c,(%rcx)
    75da27366c59:	or     $0x7,%rcx
    75da27366c5d:	addq   $0x20,0x0(%rbp)
    75da27366c62:	mov    %rdx,0x1(%rcx)
    75da27366c66:	mov    %rbx,0x9(%rcx)
    75da27366c6a:	mov    %rax,0x11(%rcx)
    75da27366c6e:	sub    $0x8,%r14
    75da27366c72:	mov    %rcx,(%r14)
    75da27366c75:	mov    %eax,0x13123385(%rip)        # 0x75da3a48a000
    75da27366c7b:	add    $0xa8,%rsp
    75da27366c82:	ret
    75da27366c83:	mov    0x1(%rax),%rax
    75da27366c87:	mov    0xe(%rax),%rax
    75da27366c8b:	movabs $0x75da2c93b37c,%rbx
    75da27366c95:	cmp    %rbx,%rax
    75da27366c98:	jne    0x75da27366cb7
    75da27366c9e:	mov    %eax,0x1312335c(%rip)        # 0x75da3a48a000
    75da27366ca4:	add    $0xa8,%rsp
    75da27366cab:	lea    0x5(%rip),%rbx        # 0x75da27366cb7
    75da27366cb2:	jmp    0x75da27557010
    75da27366cb7:	movabs $0x75da2c928f9c,%rax
    75da27366cc1:	add    $0x8,%r14
    75da27366cc5:	mov    %rax,(%r14)
    75da27366cc8:	call   0x75da2779f600
    75da27366ccd:	movabs $0x75da2c928f9c,%rax
    75da27366cd7:	add    $0x8,%r14
    75da27366cdb:	mov    %rax,(%r14)
    75da27366cde:	call   0x75da2779f600
    75da27366ce3:	movabs $0x75da2c928f9c,%rax
    75da27366ced:	add    $0x8,%r14
    75da27366cf1:	mov    %rax,(%r14)
    75da27366cf4:	call   0x75da2779f600
    75da27366cf9:	movabs $0x75da2c928f9c,%rax
    75da27366d03:	add    $0x8,%r14
    75da27366d07:	mov    %rax,(%r14)
    75da27366d0a:	call   0x75da2779f600
    75da27366d0f:	add    %al,(%rax)
    75da27366d11:	add    %al,(%rax)
    75da27366d13:	add    %al,(%rsi)
    75da27366d15:	add    %al,(%rax)
    75da27366d17:	add    (%rax),%eax
    75da27366d19:	sbb    %al,(%rax)
    75da27366d1b:	add    %al,(%rbx)
    75da27366d1d:	add    %al,(%rax)
    75da27366d1f:	(bad)
    75da27366d20:	add    %al,(%rax)
    75da27366d22:	add    (%rax),%eax
    75da27366d24:	addb   $0x0,(%rcx)
    75da27366d27:	rolb   $0x0,(%rax)
    75da27366d2a:	(bad)
    75da27366d2b:	add    %al,(%rax)
    75da27366d2d:	xor    %al,(%rax)
    75da27366d2f:	add    %bl,(%rax)
    75da27366d31:	add    %al,(%rax)
    75da27366d33:	or     $0xa2,%al
    75da27366d35:	add    %al,(%rax)
    75da27366d37:	add    %ch,0x0(%rdx,%rax,1)
    75da27366d3b:	add    %bl,0x3(%rbx)
    75da27366d3e:	add    %al,(%rax)
    75da27366d40:	fiadds (%rbx)
    75da27366d42:	add    %al,(%rax)
    75da27366d44:	and    (%rsi),%eax
    75da27366d46:	add    %al,(%rax)
    75da27366d48:	cmp    %cl,(%rcx)
    75da27366d4a:	add    %al,(%rax)
    75da27366d4c:	and    %cl,(%rbx)
    75da27366d4e:	add    %al,(%rax)
    75da27366d50:	udb
    75da27366d51:	or     $0x0,%al
    75da27366d53:	add    %dh,(%rsi,%rcx,1)
    75da27366d56:	add    %al,(%rax)
    75da27366d58:	mov    $0x2b00000f,%esp
    75da27366d5d:	adc    %eax,(%rax)
    75da27366d5f:	add    %dl,%al
    75da27366d61:	adc    (%rax),%eax
    75da27366d63:	add    %dl,0x0(%rip)        # 0x75da27366d69
    75da27366d69:	add    %al,(%rax)
    75da27366d6b:	add    %cl,(%rax,%rax,1)
	...
