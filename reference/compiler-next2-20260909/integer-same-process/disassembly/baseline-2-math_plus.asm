
/home/erg/compiler-next2-integer-20260909/disassembly/baseline-2-math_plus.bin:     file format binary


Disassembly of section .data:

00007b39b9e54860 <.data>:
    7b39b9e54860:	mov    %eax,0x1316579a(%rip)        # 0x7b39ccfba000
    7b39b9e54866:	sub    $0xa8,%rsp
    7b39b9e5486d:	mov    (%r14),%rax
    7b39b9e54870:	mov    -0x8(%r14),%rbx
    7b39b9e54874:	mov    %rbx,%rcx
    7b39b9e54877:	mov    %rax,%rdx
    7b39b9e5487a:	or     %rdx,%rcx
    7b39b9e5487d:	test   $0xf,%ecx
    7b39b9e54883:	jne    0x7b39b9e548c0
    7b39b9e54889:	add    %rax,%rbx
    7b39b9e5488c:	jo     0x7b39b9e548a7
    7b39b9e54892:	sub    $0x8,%r14
    7b39b9e54896:	mov    %rbx,(%r14)
    7b39b9e54899:	mov    %eax,0x13165761(%rip)        # 0x7b39ccfba000
    7b39b9e5489f:	add    $0xa8,%rsp
    7b39b9e548a6:	ret
    7b39b9e548a7:	mov    %eax,0x13165753(%rip)        # 0x7b39ccfba000
    7b39b9e548ad:	add    $0xa8,%rsp
    7b39b9e548b4:	lea    0x5(%rip),%rbx        # 0x7b39b9e548c0
    7b39b9e548bb:	jmp    0x7b39b8dc17a0
    7b39b9e548c0:	mov    %rbx,%rcx
    7b39b9e548c3:	test   $0xf,%ecx
    7b39b9e548c9:	jne    0x7b39b9e54b79
    7b39b9e548cf:	mov    %rax,%rcx
    7b39b9e548d2:	and    $0xf,%ecx
    7b39b9e548d5:	cmp    $0x3,%rcx
    7b39b9e548d9:	jne    0x7b39b9e54952
    7b39b9e548df:	lea    0x10(%r13),%rcx
    7b39b9e548e3:	mov    (%rcx),%rdx
    7b39b9e548e6:	add    $0x10,%rdx
    7b39b9e548ea:	cmp    0x10(%rcx),%rdx
    7b39b9e548ee:	jle    0x7b39b9e5490b
    7b39b9e548f4:	mov    %rbx,(%rsp)
    7b39b9e548f8:	mov    %rax,0x8(%rsp)
    7b39b9e548fd:	call   0x7b39b9ebe060
    7b39b9e54902:	mov    (%rsp),%rbx
    7b39b9e54906:	mov    0x8(%rsp),%rax
    7b39b9e5490b:	sar    $0x4,%rbx
    7b39b9e5490f:	xorps  %xmm0,%xmm0
    7b39b9e54912:	cvtsi2sd %rbx,%xmm0
    7b39b9e54917:	rex.W movsd 0x5(%rax),%xmm1
    7b39b9e5491d:	addsd  %xmm1,%xmm0
    7b39b9e54921:	lea    0x10(%r13),%rbx
    7b39b9e54925:	mov    (%rbx),%rax
    7b39b9e54928:	movq   $0xc,(%rax)
    7b39b9e5492f:	or     $0x3,%rax
    7b39b9e54933:	addq   $0x10,(%rbx)
    7b39b9e54937:	rex.W movsd %xmm0,0x5(%rax)
    7b39b9e5493d:	sub    $0x8,%r14
    7b39b9e54941:	mov    %rax,(%r14)
    7b39b9e54944:	mov    %eax,0x131656b6(%rip)        # 0x7b39ccfba000
    7b39b9e5494a:	add    $0xa8,%rsp
    7b39b9e54951:	ret
    7b39b9e54952:	mov    %rax,%rbx
    7b39b9e54955:	and    $0xf,%ebx
    7b39b9e54958:	cmp    $0x5,%rbx
    7b39b9e5495c:	jne    0x7b39b9e54999
    7b39b9e54962:	sub    $0x8,%r14
    7b39b9e54966:	add    $0x8,%r15
    7b39b9e5496a:	mov    %rax,(%r15)
    7b39b9e5496d:	call   0x7b39ba2934d0
    7b39b9e54972:	mov    (%r15),%rax
    7b39b9e54975:	add    $0x8,%r14
    7b39b9e54979:	sub    $0x8,%r15
    7b39b9e5497d:	mov    %rax,(%r14)
    7b39b9e54980:	mov    %eax,0x1316567a(%rip)        # 0x7b39ccfba000
    7b39b9e54986:	add    $0xa8,%rsp
    7b39b9e5498d:	lea    0x5(%rip),%rbx        # 0x7b39b9e54999
    7b39b9e54994:	jmp    0x7b39ba1c1070
    7b39b9e54999:	mov    %rax,%rbx
    7b39b9e5499c:	and    $0xf,%ebx
    7b39b9e5499f:	cmp    $0x7,%rbx
    7b39b9e549a3:	jne    0x7b39b9e54b63
    7b39b9e549a9:	mov    0x1(%rax),%rbx
    7b39b9e549ad:	mov    0xe(%rbx),%rbx
    7b39b9e549b1:	movabs $0x7b39bf44cedc,%rcx
    7b39b9e549bb:	cmp    %rcx,%rbx
    7b39b9e549be:	jne    0x7b39b9e54b19
    7b39b9e549c4:	mov    0x9(%rax),%rbx
    7b39b9e549c8:	mov    0x11(%rax),%rax
    7b39b9e549cc:	add    $0x10,%r15
    7b39b9e549d0:	mov    %rax,-0x8(%r15)
    7b39b9e549d4:	mov    %rbx,(%r14)
    7b39b9e549d7:	movq   $0x0,(%r15)
    7b39b9e549de:	call   0x7b39b9e54860
    7b39b9e549e3:	mov    (%r15),%rax
    7b39b9e549e6:	mov    -0x8(%r15),%rbx
    7b39b9e549ea:	add    $0x10,%r14
    7b39b9e549ee:	sub    $0x10,%r15
    7b39b9e549f2:	mov    %rax,-0x8(%r14)
    7b39b9e549f6:	mov    %rbx,(%r14)
    7b39b9e549f9:	call   0x7b39b9e54860
    7b39b9e549fe:	mov    (%r14),%rax
    7b39b9e54a01:	add    $0x8,%r14
    7b39b9e54a05:	cmp    $0x0,%rax
    7b39b9e54a09:	jne    0x7b39b9e54a25
    7b39b9e54a0f:	sub    $0x8,%r14
    7b39b9e54a13:	sub    $0x8,%r14
    7b39b9e54a17:	mov    %eax,0x131655e3(%rip)        # 0x7b39ccfba000
    7b39b9e54a1d:	add    $0xa8,%rsp
    7b39b9e54a24:	ret
    7b39b9e54a25:	mov    %rax,%rbx
    7b39b9e54a28:	test   $0xf,%ebx
    7b39b9e54a2e:	jne    0x7b39b9e54a44
    7b39b9e54a34:	sub    $0x8,%r14
    7b39b9e54a38:	mov    (%r14),%rax
    7b39b9e54a3b:	mov    -0x8(%r14),%rbx
    7b39b9e54a3f:	jmp    0x7b39b9e54aa8
    7b39b9e54a44:	mov    %rax,%rbx
    7b39b9e54a47:	and    $0xf,%ebx
    7b39b9e54a4a:	cmp    $0x5,%rbx
    7b39b9e54a4e:	jne    0x7b39b9e54a9d
    7b39b9e54a54:	movabs $0x7b39bf4dc455,%rbx
    7b39b9e54a5e:	add    $0x8,%r14
    7b39b9e54a62:	mov    %rax,-0x8(%r14)
    7b39b9e54a66:	mov    %rbx,(%r14)
    7b39b9e54a69:	call   0x7b39ba1b9440
    7b39b9e54a6e:	mov    (%r14),%rax
    7b39b9e54a71:	sub    $0x8,%r14
    7b39b9e54a75:	cmp    $0x1,%rax
    7b39b9e54a79:	je     0x7b39b9e54a91
    7b39b9e54a7f:	sub    $0x8,%r14
    7b39b9e54a83:	mov    %eax,0x13165577(%rip)        # 0x7b39ccfba000
    7b39b9e54a89:	add    $0xa8,%rsp
    7b39b9e54a90:	ret
    7b39b9e54a91:	mov    (%r14),%rax
    7b39b9e54a94:	mov    -0x8(%r14),%rbx
    7b39b9e54a98:	jmp    0x7b39b9e54aa8
    7b39b9e54a9d:	sub    $0x8,%r14
    7b39b9e54aa1:	mov    (%r14),%rax
    7b39b9e54aa4:	mov    -0x8(%r14),%rbx
    7b39b9e54aa8:	lea    0x10(%r13),%rdx
    7b39b9e54aac:	mov    (%rdx),%rcx
    7b39b9e54aaf:	add    $0x20,%rcx
    7b39b9e54ab3:	cmp    0x10(%rdx),%rcx
    7b39b9e54ab7:	jle    0x7b39b9e54ad6
    7b39b9e54abd:	mov    %rbx,0x10(%rsp)
    7b39b9e54ac2:	mov    %rax,0x18(%rsp)
    7b39b9e54ac7:	call   0x7b39b9ebe060
    7b39b9e54acc:	mov    0x10(%rsp),%rbx
    7b39b9e54ad1:	mov    0x18(%rsp),%rax
    7b39b9e54ad6:	movabs $0x7b39bf44caa2,%rdx
    7b39b9e54ae0:	lea    0x10(%r13),%rbp
    7b39b9e54ae4:	mov    0x0(%rbp),%rcx
    7b39b9e54ae8:	movq   $0x1c,(%rcx)
    7b39b9e54aef:	or     $0x7,%rcx
    7b39b9e54af3:	addq   $0x20,0x0(%rbp)
    7b39b9e54af8:	mov    %rdx,0x1(%rcx)
    7b39b9e54afc:	mov    %rbx,0x9(%rcx)
    7b39b9e54b00:	mov    %rax,0x11(%rcx)
    7b39b9e54b04:	sub    $0x8,%r14
    7b39b9e54b08:	mov    %rcx,(%r14)
    7b39b9e54b0b:	mov    %eax,0x131654ef(%rip)        # 0x7b39ccfba000
    7b39b9e54b11:	add    $0xa8,%rsp
    7b39b9e54b18:	ret
    7b39b9e54b19:	mov    0x1(%rax),%rax
    7b39b9e54b1d:	mov    0xe(%rax),%rax
    7b39b9e54b21:	movabs $0x7b39bf43a07c,%rbx
    7b39b9e54b2b:	cmp    %rbx,%rax
    7b39b9e54b2e:	jne    0x7b39b9e54b4d
    7b39b9e54b34:	mov    %eax,0x131654c6(%rip)        # 0x7b39ccfba000
    7b39b9e54b3a:	add    $0xa8,%rsp
    7b39b9e54b41:	lea    0x5(%rip),%rbx        # 0x7b39b9e54b4d
    7b39b9e54b48:	jmp    0x7b39ba046010
    7b39b9e54b4d:	movabs $0x7b39bf427c9c,%rax
    7b39b9e54b57:	add    $0x8,%r14
    7b39b9e54b5b:	mov    %rax,(%r14)
    7b39b9e54b5e:	call   0x7b39ba28e600
    7b39b9e54b63:	movabs $0x7b39bf427c9c,%rax
    7b39b9e54b6d:	add    $0x8,%r14
    7b39b9e54b71:	mov    %rax,(%r14)
    7b39b9e54b74:	call   0x7b39ba28e600
    7b39b9e54b79:	mov    %rbx,%rcx
    7b39b9e54b7c:	and    $0xf,%ecx
    7b39b9e54b7f:	cmp    $0x3,%rcx
    7b39b9e54b83:	jne    0x7b39b9e54f7e
    7b39b9e54b89:	mov    %rax,%rcx
    7b39b9e54b8c:	test   $0xf,%ecx
    7b39b9e54b92:	jne    0x7b39b9e54c0b
    7b39b9e54b98:	lea    0x10(%r13),%rdx
    7b39b9e54b9c:	mov    (%rdx),%rcx
    7b39b9e54b9f:	add    $0x10,%rcx
    7b39b9e54ba3:	cmp    0x10(%rdx),%rcx
    7b39b9e54ba7:	jle    0x7b39b9e54bc4
    7b39b9e54bad:	mov    %rbx,(%rsp)
    7b39b9e54bb1:	mov    %rax,0x8(%rsp)
    7b39b9e54bb6:	call   0x7b39b9ebe060
    7b39b9e54bbb:	mov    (%rsp),%rbx
    7b39b9e54bbf:	mov    0x8(%rsp),%rax
    7b39b9e54bc4:	sar    $0x4,%rax
    7b39b9e54bc8:	xorps  %xmm1,%xmm1
    7b39b9e54bcb:	cvtsi2sd %rax,%xmm1
    7b39b9e54bd0:	rex.W movsd 0x5(%rbx),%xmm0
    7b39b9e54bd6:	addsd  %xmm1,%xmm0
    7b39b9e54bda:	lea    0x10(%r13),%rbx
    7b39b9e54bde:	mov    (%rbx),%rax
    7b39b9e54be1:	movq   $0xc,(%rax)
    7b39b9e54be8:	or     $0x3,%rax
    7b39b9e54bec:	addq   $0x10,(%rbx)
    7b39b9e54bf0:	rex.W movsd %xmm0,0x5(%rax)
    7b39b9e54bf6:	sub    $0x8,%r14
    7b39b9e54bfa:	mov    %rax,(%r14)
    7b39b9e54bfd:	mov    %eax,0x131653fd(%rip)        # 0x7b39ccfba000
    7b39b9e54c03:	add    $0xa8,%rsp
    7b39b9e54c0a:	ret
    7b39b9e54c0b:	mov    %rax,%rcx
    7b39b9e54c0e:	and    $0xf,%ecx
    7b39b9e54c11:	cmp    $0x3,%rcx
    7b39b9e54c15:	jne    0x7b39b9e54c88
    7b39b9e54c1b:	lea    0x10(%r13),%rdx
    7b39b9e54c1f:	mov    (%rdx),%rcx
    7b39b9e54c22:	add    $0x10,%rcx
    7b39b9e54c26:	cmp    0x10(%rdx),%rcx
    7b39b9e54c2a:	jle    0x7b39b9e54c47
    7b39b9e54c30:	mov    %rbx,(%rsp)
    7b39b9e54c34:	mov    %rax,0x8(%rsp)
    7b39b9e54c39:	call   0x7b39b9ebe060
    7b39b9e54c3e:	mov    (%rsp),%rbx
    7b39b9e54c42:	mov    0x8(%rsp),%rax
    7b39b9e54c47:	rex.W movsd 0x5(%rbx),%xmm0
    7b39b9e54c4d:	rex.W movsd 0x5(%rax),%xmm1
    7b39b9e54c53:	addsd  %xmm1,%xmm0
    7b39b9e54c57:	lea    0x10(%r13),%rbx
    7b39b9e54c5b:	mov    (%rbx),%rax
    7b39b9e54c5e:	movq   $0xc,(%rax)
    7b39b9e54c65:	or     $0x3,%rax
    7b39b9e54c69:	addq   $0x10,(%rbx)
    7b39b9e54c6d:	rex.W movsd %xmm0,0x5(%rax)
    7b39b9e54c73:	sub    $0x8,%r14
    7b39b9e54c77:	mov    %rax,(%r14)
    7b39b9e54c7a:	mov    %eax,0x13165380(%rip)        # 0x7b39ccfba000
    7b39b9e54c80:	add    $0xa8,%rsp
    7b39b9e54c87:	ret
    7b39b9e54c88:	mov    %rax,%rbx
    7b39b9e54c8b:	and    $0xf,%ebx
    7b39b9e54c8e:	cmp    $0x5,%rbx
    7b39b9e54c92:	jne    0x7b39b9e54cff
    7b39b9e54c98:	call   0x7b39b9c8da50
    7b39b9e54c9d:	lea    0x10(%r13),%rax
    7b39b9e54ca1:	mov    (%rax),%rbx
    7b39b9e54ca4:	add    $0x10,%rbx
    7b39b9e54ca8:	cmp    0x10(%rax),%rbx
    7b39b9e54cac:	jle    0x7b39b9e54cb7
    7b39b9e54cb2:	call   0x7b39b9ebe060
    7b39b9e54cb7:	mov    (%r14),%rax
    7b39b9e54cba:	mov    -0x8(%r14),%rbx
    7b39b9e54cbe:	rex.W movsd 0x5(%rbx),%xmm0
    7b39b9e54cc4:	rex.W movsd 0x5(%rax),%xmm1
    7b39b9e54cca:	addsd  %xmm1,%xmm0
    7b39b9e54cce:	lea    0x10(%r13),%rbx
    7b39b9e54cd2:	mov    (%rbx),%rax
    7b39b9e54cd5:	movq   $0xc,(%rax)
    7b39b9e54cdc:	or     $0x3,%rax
    7b39b9e54ce0:	addq   $0x10,(%rbx)
    7b39b9e54ce4:	rex.W movsd %xmm0,0x5(%rax)
    7b39b9e54cea:	sub    $0x8,%r14
    7b39b9e54cee:	mov    %rax,(%r14)
    7b39b9e54cf1:	mov    %eax,0x13165309(%rip)        # 0x7b39ccfba000
    7b39b9e54cf7:	add    $0xa8,%rsp
    7b39b9e54cfe:	ret
    7b39b9e54cff:	mov    %rax,%rbx
    7b39b9e54d02:	and    $0xf,%ebx
    7b39b9e54d05:	cmp    $0x7,%rbx
    7b39b9e54d09:	jne    0x7b39b9e54f68
    7b39b9e54d0f:	mov    0x1(%rax),%rbx
    7b39b9e54d13:	mov    0xe(%rbx),%rbx
    7b39b9e54d17:	movabs $0x7b39bf44cedc,%rcx
    7b39b9e54d21:	cmp    %rcx,%rbx
    7b39b9e54d24:	jne    0x7b39b9e54ed0
    7b39b9e54d2a:	mov    0x9(%rax),%rbx
    7b39b9e54d2e:	mov    0x11(%rax),%rax
    7b39b9e54d32:	add    $0x10,%r15
    7b39b9e54d36:	mov    %rax,-0x8(%r15)
    7b39b9e54d3a:	mov    %rbx,(%r14)
    7b39b9e54d3d:	movq   $0x0,(%r15)
    7b39b9e54d44:	call   0x7b39b8c9dfc0
    7b39b9e54d49:	lea    0x10(%r13),%rbx
    7b39b9e54d4d:	mov    (%rbx),%rax
    7b39b9e54d50:	add    $0x10,%rax
    7b39b9e54d54:	cmp    0x10(%rbx),%rax
    7b39b9e54d58:	jle    0x7b39b9e54d63
    7b39b9e54d5e:	call   0x7b39b9ebe060
    7b39b9e54d63:	mov    (%r14),%rcx
    7b39b9e54d66:	mov    (%r15),%rax
    7b39b9e54d69:	mov    -0x8(%r14),%rdx
    7b39b9e54d6d:	mov    -0x8(%r15),%rbx
    7b39b9e54d71:	rex.W movsd 0x5(%rdx),%xmm0
    7b39b9e54d77:	rex.W movsd 0x5(%rcx),%xmm1
    7b39b9e54d7d:	addsd  %xmm1,%xmm0
    7b39b9e54d81:	lea    0x10(%r13),%rdx
    7b39b9e54d85:	mov    (%rdx),%rcx
    7b39b9e54d88:	movq   $0xc,(%rcx)
    7b39b9e54d8f:	or     $0x3,%rcx
    7b39b9e54d93:	addq   $0x10,(%rdx)
    7b39b9e54d97:	rex.W movsd %xmm0,0x5(%rcx)
    7b39b9e54d9d:	add    $0x8,%r14
    7b39b9e54da1:	sub    $0x10,%r15
    7b39b9e54da5:	mov    %rax,-0x8(%r14)
    7b39b9e54da9:	mov    %rbx,(%r14)
    7b39b9e54dac:	mov    %rcx,-0x10(%r14)
    7b39b9e54db0:	call   0x7b39b9e54860
    7b39b9e54db5:	mov    (%r14),%rax
    7b39b9e54db8:	add    $0x8,%r14
    7b39b9e54dbc:	cmp    $0x0,%rax
    7b39b9e54dc0:	jne    0x7b39b9e54ddc
    7b39b9e54dc6:	sub    $0x8,%r14
    7b39b9e54dca:	sub    $0x8,%r14
    7b39b9e54dce:	mov    %eax,0x1316522c(%rip)        # 0x7b39ccfba000
    7b39b9e54dd4:	add    $0xa8,%rsp
    7b39b9e54ddb:	ret
    7b39b9e54ddc:	mov    %rax,%rbx
    7b39b9e54ddf:	test   $0xf,%ebx
    7b39b9e54de5:	jne    0x7b39b9e54dfb
    7b39b9e54deb:	sub    $0x8,%r14
    7b39b9e54def:	mov    (%r14),%rax
    7b39b9e54df2:	mov    -0x8(%r14),%rbx
    7b39b9e54df6:	jmp    0x7b39b9e54e5f
    7b39b9e54dfb:	mov    %rax,%rbx
    7b39b9e54dfe:	and    $0xf,%ebx
    7b39b9e54e01:	cmp    $0x5,%rbx
    7b39b9e54e05:	jne    0x7b39b9e54e54
    7b39b9e54e0b:	movabs $0x7b39bf4dc455,%rbx
    7b39b9e54e15:	add    $0x8,%r14
    7b39b9e54e19:	mov    %rax,-0x8(%r14)
    7b39b9e54e1d:	mov    %rbx,(%r14)
    7b39b9e54e20:	call   0x7b39ba1b9440
    7b39b9e54e25:	mov    (%r14),%rax
    7b39b9e54e28:	sub    $0x8,%r14
    7b39b9e54e2c:	cmp    $0x1,%rax
    7b39b9e54e30:	je     0x7b39b9e54e48
    7b39b9e54e36:	sub    $0x8,%r14
    7b39b9e54e3a:	mov    %eax,0x131651c0(%rip)        # 0x7b39ccfba000
    7b39b9e54e40:	add    $0xa8,%rsp
    7b39b9e54e47:	ret
    7b39b9e54e48:	mov    (%r14),%rax
    7b39b9e54e4b:	mov    -0x8(%r14),%rbx
    7b39b9e54e4f:	jmp    0x7b39b9e54e5f
    7b39b9e54e54:	sub    $0x8,%r14
    7b39b9e54e58:	mov    (%r14),%rax
    7b39b9e54e5b:	mov    -0x8(%r14),%rbx
    7b39b9e54e5f:	lea    0x10(%r13),%rdx
    7b39b9e54e63:	mov    (%rdx),%rcx
    7b39b9e54e66:	add    $0x20,%rcx
    7b39b9e54e6a:	cmp    0x10(%rdx),%rcx
    7b39b9e54e6e:	jle    0x7b39b9e54e8d
    7b39b9e54e74:	mov    %rbx,0x20(%rsp)
    7b39b9e54e79:	mov    %rax,0x28(%rsp)
    7b39b9e54e7e:	call   0x7b39b9ebe060
    7b39b9e54e83:	mov    0x20(%rsp),%rbx
    7b39b9e54e88:	mov    0x28(%rsp),%rax
    7b39b9e54e8d:	movabs $0x7b39bf44caa2,%rdx
    7b39b9e54e97:	lea    0x10(%r13),%rbp
    7b39b9e54e9b:	mov    0x0(%rbp),%rcx
    7b39b9e54e9f:	movq   $0x1c,(%rcx)
    7b39b9e54ea6:	or     $0x7,%rcx
    7b39b9e54eaa:	addq   $0x20,0x0(%rbp)
    7b39b9e54eaf:	mov    %rdx,0x1(%rcx)
    7b39b9e54eb3:	mov    %rbx,0x9(%rcx)
    7b39b9e54eb7:	mov    %rax,0x11(%rcx)
    7b39b9e54ebb:	sub    $0x8,%r14
    7b39b9e54ebf:	mov    %rcx,(%r14)
    7b39b9e54ec2:	mov    %eax,0x13165138(%rip)        # 0x7b39ccfba000
    7b39b9e54ec8:	add    $0xa8,%rsp
    7b39b9e54ecf:	ret
    7b39b9e54ed0:	mov    0x1(%rax),%rax
    7b39b9e54ed4:	mov    0xe(%rax),%rax
    7b39b9e54ed8:	movabs $0x7b39bf43a07c,%rbx
    7b39b9e54ee2:	cmp    %rbx,%rax
    7b39b9e54ee5:	jne    0x7b39b9e54f52
    7b39b9e54eeb:	call   0x7b39b9be0070
    7b39b9e54ef0:	lea    0x10(%r13),%rax
    7b39b9e54ef4:	mov    (%rax),%rbx
    7b39b9e54ef7:	add    $0x10,%rbx
    7b39b9e54efb:	cmp    0x10(%rax),%rbx
    7b39b9e54eff:	jle    0x7b39b9e54f0a
    7b39b9e54f05:	call   0x7b39b9ebe060
    7b39b9e54f0a:	mov    (%r14),%rax
    7b39b9e54f0d:	mov    -0x8(%r14),%rbx
    7b39b9e54f11:	rex.W movsd 0x5(%rbx),%xmm0
    7b39b9e54f17:	rex.W movsd 0x5(%rax),%xmm1
    7b39b9e54f1d:	addsd  %xmm1,%xmm0
    7b39b9e54f21:	lea    0x10(%r13),%rbx
    7b39b9e54f25:	mov    (%rbx),%rax
    7b39b9e54f28:	movq   $0xc,(%rax)
    7b39b9e54f2f:	or     $0x3,%rax
    7b39b9e54f33:	addq   $0x10,(%rbx)
    7b39b9e54f37:	rex.W movsd %xmm0,0x5(%rax)
    7b39b9e54f3d:	sub    $0x8,%r14
    7b39b9e54f41:	mov    %rax,(%r14)
    7b39b9e54f44:	mov    %eax,0x131650b6(%rip)        # 0x7b39ccfba000
    7b39b9e54f4a:	add    $0xa8,%rsp
    7b39b9e54f51:	ret
    7b39b9e54f52:	movabs $0x7b39bf427c9c,%rax
    7b39b9e54f5c:	add    $0x8,%r14
    7b39b9e54f60:	mov    %rax,(%r14)
    7b39b9e54f63:	call   0x7b39ba28e600
    7b39b9e54f68:	movabs $0x7b39bf427c9c,%rax
    7b39b9e54f72:	add    $0x8,%r14
    7b39b9e54f76:	mov    %rax,(%r14)
    7b39b9e54f79:	call   0x7b39ba28e600
    7b39b9e54f7e:	mov    %rbx,%rcx
    7b39b9e54f81:	and    $0xf,%ecx
    7b39b9e54f84:	cmp    $0x5,%rcx
    7b39b9e54f88:	jne    0x7b39b9e55245
    7b39b9e54f8e:	mov    %rax,%rbx
    7b39b9e54f91:	test   $0xf,%ebx
    7b39b9e54f97:	jne    0x7b39b9e54fbb
    7b39b9e54f9d:	call   0x7b39ba2934d0
    7b39b9e54fa2:	mov    %eax,0x13165058(%rip)        # 0x7b39ccfba000
    7b39b9e54fa8:	add    $0xa8,%rsp
    7b39b9e54faf:	lea    0x5(%rip),%rbx        # 0x7b39b9e54fbb
    7b39b9e54fb6:	jmp    0x7b39ba1c1070
    7b39b9e54fbb:	mov    %rax,%rbx
    7b39b9e54fbe:	and    $0xf,%ebx
    7b39b9e54fc1:	cmp    $0x3,%rbx
    7b39b9e54fc5:	jne    0x7b39b9e5503c
    7b39b9e54fcb:	sub    $0x8,%r14
    7b39b9e54fcf:	add    $0x8,%r15
    7b39b9e54fd3:	mov    %rax,(%r15)
    7b39b9e54fd6:	call   0x7b39b9c8da50
    7b39b9e54fdb:	lea    0x10(%r13),%rax
    7b39b9e54fdf:	mov    (%rax),%rbx
    7b39b9e54fe2:	add    $0x10,%rbx
    7b39b9e54fe6:	cmp    0x10(%rax),%rbx
    7b39b9e54fea:	jle    0x7b39b9e54ff5
    7b39b9e54ff0:	call   0x7b39b9ebe060
    7b39b9e54ff5:	mov    (%r15),%rax
    7b39b9e54ff8:	mov    (%r14),%rbx
    7b39b9e54ffb:	rex.W movsd 0x5(%rbx),%xmm0
    7b39b9e55001:	rex.W movsd 0x5(%rax),%xmm1
    7b39b9e55007:	addsd  %xmm1,%xmm0
    7b39b9e5500b:	lea    0x10(%r13),%rbx
    7b39b9e5500f:	mov    (%rbx),%rax
    7b39b9e55012:	movq   $0xc,(%rax)
    7b39b9e55019:	or     $0x3,%rax
    7b39b9e5501d:	addq   $0x10,(%rbx)
    7b39b9e55021:	rex.W movsd %xmm0,0x5(%rax)
    7b39b9e55027:	sub    $0x8,%r15
    7b39b9e5502b:	mov    %rax,(%r14)
    7b39b9e5502e:	mov    %eax,0x13164fcc(%rip)        # 0x7b39ccfba000
    7b39b9e55034:	add    $0xa8,%rsp
    7b39b9e5503b:	ret
    7b39b9e5503c:	mov    %rax,%rbx
    7b39b9e5503f:	and    $0xf,%ebx
    7b39b9e55042:	cmp    $0x5,%rbx
    7b39b9e55046:	jne    0x7b39b9e55065
    7b39b9e5504c:	mov    %eax,0x13164fae(%rip)        # 0x7b39ccfba000
    7b39b9e55052:	add    $0xa8,%rsp
    7b39b9e55059:	lea    0x5(%rip),%rbx        # 0x7b39b9e55065
    7b39b9e55060:	jmp    0x7b39ba1c1070
    7b39b9e55065:	mov    %rax,%rbx
    7b39b9e55068:	and    $0xf,%ebx
    7b39b9e5506b:	cmp    $0x7,%rbx
    7b39b9e5506f:	jne    0x7b39b9e5522f
    7b39b9e55075:	mov    0x1(%rax),%rbx
    7b39b9e55079:	mov    0xe(%rbx),%rbx
    7b39b9e5507d:	movabs $0x7b39bf44cedc,%rcx
    7b39b9e55087:	cmp    %rcx,%rbx
    7b39b9e5508a:	jne    0x7b39b9e551e5
    7b39b9e55090:	mov    0x9(%rax),%rbx
    7b39b9e55094:	mov    0x11(%rax),%rax
    7b39b9e55098:	add    $0x10,%r15
    7b39b9e5509c:	mov    %rax,-0x8(%r15)
    7b39b9e550a0:	mov    %rbx,(%r14)
    7b39b9e550a3:	movq   $0x0,(%r15)
    7b39b9e550aa:	call   0x7b39b9e54860
    7b39b9e550af:	mov    (%r15),%rax
    7b39b9e550b2:	mov    -0x8(%r15),%rbx
    7b39b9e550b6:	add    $0x10,%r14
    7b39b9e550ba:	sub    $0x10,%r15
    7b39b9e550be:	mov    %rax,-0x8(%r14)
    7b39b9e550c2:	mov    %rbx,(%r14)
    7b39b9e550c5:	call   0x7b39b9e54860
    7b39b9e550ca:	mov    (%r14),%rax
    7b39b9e550cd:	add    $0x8,%r14
    7b39b9e550d1:	cmp    $0x0,%rax
    7b39b9e550d5:	jne    0x7b39b9e550f1
    7b39b9e550db:	sub    $0x8,%r14
    7b39b9e550df:	sub    $0x8,%r14
    7b39b9e550e3:	mov    %eax,0x13164f17(%rip)        # 0x7b39ccfba000
    7b39b9e550e9:	add    $0xa8,%rsp
    7b39b9e550f0:	ret
    7b39b9e550f1:	mov    %rax,%rbx
    7b39b9e550f4:	test   $0xf,%ebx
    7b39b9e550fa:	jne    0x7b39b9e55110
    7b39b9e55100:	sub    $0x8,%r14
    7b39b9e55104:	mov    (%r14),%rax
    7b39b9e55107:	mov    -0x8(%r14),%rbx
    7b39b9e5510b:	jmp    0x7b39b9e55174
    7b39b9e55110:	mov    %rax,%rbx
    7b39b9e55113:	and    $0xf,%ebx
    7b39b9e55116:	cmp    $0x5,%rbx
    7b39b9e5511a:	jne    0x7b39b9e55169
    7b39b9e55120:	movabs $0x7b39bf4dc455,%rbx
    7b39b9e5512a:	add    $0x8,%r14
    7b39b9e5512e:	mov    %rax,-0x8(%r14)
    7b39b9e55132:	mov    %rbx,(%r14)
    7b39b9e55135:	call   0x7b39ba1b9440
    7b39b9e5513a:	mov    (%r14),%rax
    7b39b9e5513d:	sub    $0x8,%r14
    7b39b9e55141:	cmp    $0x1,%rax
    7b39b9e55145:	je     0x7b39b9e5515d
    7b39b9e5514b:	sub    $0x8,%r14
    7b39b9e5514f:	mov    %eax,0x13164eab(%rip)        # 0x7b39ccfba000
    7b39b9e55155:	add    $0xa8,%rsp
    7b39b9e5515c:	ret
    7b39b9e5515d:	mov    (%r14),%rax
    7b39b9e55160:	mov    -0x8(%r14),%rbx
    7b39b9e55164:	jmp    0x7b39b9e55174
    7b39b9e55169:	sub    $0x8,%r14
    7b39b9e5516d:	mov    (%r14),%rax
    7b39b9e55170:	mov    -0x8(%r14),%rbx
    7b39b9e55174:	lea    0x10(%r13),%rcx
    7b39b9e55178:	mov    (%rcx),%rdx
    7b39b9e5517b:	add    $0x20,%rdx
    7b39b9e5517f:	cmp    0x10(%rcx),%rdx
    7b39b9e55183:	jle    0x7b39b9e551a2
    7b39b9e55189:	mov    %rbx,0x30(%rsp)
    7b39b9e5518e:	mov    %rax,0x38(%rsp)
    7b39b9e55193:	call   0x7b39b9ebe060
    7b39b9e55198:	mov    0x30(%rsp),%rbx
    7b39b9e5519d:	mov    0x38(%rsp),%rax
    7b39b9e551a2:	movabs $0x7b39bf44caa2,%rdx
    7b39b9e551ac:	lea    0x10(%r13),%rbp
    7b39b9e551b0:	mov    0x0(%rbp),%rcx
    7b39b9e551b4:	movq   $0x1c,(%rcx)
    7b39b9e551bb:	or     $0x7,%rcx
    7b39b9e551bf:	addq   $0x20,0x0(%rbp)
    7b39b9e551c4:	mov    %rdx,0x1(%rcx)
    7b39b9e551c8:	mov    %rbx,0x9(%rcx)
    7b39b9e551cc:	mov    %rax,0x11(%rcx)
    7b39b9e551d0:	sub    $0x8,%r14
    7b39b9e551d4:	mov    %rcx,(%r14)
    7b39b9e551d7:	mov    %eax,0x13164e23(%rip)        # 0x7b39ccfba000
    7b39b9e551dd:	add    $0xa8,%rsp
    7b39b9e551e4:	ret
    7b39b9e551e5:	mov    0x1(%rax),%rax
    7b39b9e551e9:	mov    0xe(%rax),%rax
    7b39b9e551ed:	movabs $0x7b39bf43a07c,%rbx
    7b39b9e551f7:	cmp    %rbx,%rax
    7b39b9e551fa:	jne    0x7b39b9e55219
    7b39b9e55200:	mov    %eax,0x13164dfa(%rip)        # 0x7b39ccfba000
    7b39b9e55206:	add    $0xa8,%rsp
    7b39b9e5520d:	lea    0x5(%rip),%rbx        # 0x7b39b9e55219
    7b39b9e55214:	jmp    0x7b39ba046010
    7b39b9e55219:	movabs $0x7b39bf427c9c,%rax
    7b39b9e55223:	add    $0x8,%r14
    7b39b9e55227:	mov    %rax,(%r14)
    7b39b9e5522a:	call   0x7b39ba28e600
    7b39b9e5522f:	movabs $0x7b39bf427c9c,%rax
    7b39b9e55239:	add    $0x8,%r14
    7b39b9e5523d:	mov    %rax,(%r14)
    7b39b9e55240:	call   0x7b39ba28e600
    7b39b9e55245:	mov    %rbx,%rcx
    7b39b9e55248:	and    $0xf,%ecx
    7b39b9e5524b:	cmp    $0x7,%rcx
    7b39b9e5524f:	jne    0x7b39b9e55cf9
    7b39b9e55255:	mov    0x1(%rbx),%rcx
    7b39b9e55259:	mov    0xe(%rcx),%rcx
    7b39b9e5525d:	movabs $0x7b39bf44cedc,%rdx
    7b39b9e55267:	cmp    %rdx,%rcx
    7b39b9e5526a:	jne    0x7b39b9e55a0a
    7b39b9e55270:	mov    %rax,%rcx
    7b39b9e55273:	test   $0xf,%ecx
    7b39b9e55279:	jne    0x7b39b9e553cd
    7b39b9e5527f:	mov    0x9(%rbx),%rax
    7b39b9e55283:	mov    0x11(%rbx),%rbx
    7b39b9e55287:	add    $0x8,%r15
    7b39b9e5528b:	mov    %rbx,(%r15)
    7b39b9e5528e:	mov    %rax,-0x8(%r14)
    7b39b9e55292:	call   0x7b39b9e54860
    7b39b9e55297:	mov    (%r15),%rax
    7b39b9e5529a:	add    $0x10,%r14
    7b39b9e5529e:	sub    $0x8,%r15
    7b39b9e552a2:	mov    %rax,-0x8(%r14)
    7b39b9e552a6:	movq   $0x0,(%r14)
    7b39b9e552ad:	call   0x7b39b9e54860
    7b39b9e552b2:	mov    (%r14),%rax
    7b39b9e552b5:	add    $0x8,%r14
    7b39b9e552b9:	cmp    $0x0,%rax
    7b39b9e552bd:	jne    0x7b39b9e552d9
    7b39b9e552c3:	sub    $0x8,%r14
    7b39b9e552c7:	sub    $0x8,%r14
    7b39b9e552cb:	mov    %eax,0x13164d2f(%rip)        # 0x7b39ccfba000
    7b39b9e552d1:	add    $0xa8,%rsp
    7b39b9e552d8:	ret
    7b39b9e552d9:	mov    %rax,%rbx
    7b39b9e552dc:	test   $0xf,%ebx
    7b39b9e552e2:	jne    0x7b39b9e552f8
    7b39b9e552e8:	sub    $0x8,%r14
    7b39b9e552ec:	mov    (%r14),%rax
    7b39b9e552ef:	mov    -0x8(%r14),%rbx
    7b39b9e552f3:	jmp    0x7b39b9e5535c
    7b39b9e552f8:	mov    %rax,%rbx
    7b39b9e552fb:	and    $0xf,%ebx
    7b39b9e552fe:	cmp    $0x5,%rbx
    7b39b9e55302:	jne    0x7b39b9e55351
    7b39b9e55308:	movabs $0x7b39bf4dc455,%rbx
    7b39b9e55312:	add    $0x8,%r14
    7b39b9e55316:	mov    %rax,-0x8(%r14)
    7b39b9e5531a:	mov    %rbx,(%r14)
    7b39b9e5531d:	call   0x7b39ba1b9440
    7b39b9e55322:	mov    (%r14),%rax
    7b39b9e55325:	sub    $0x8,%r14
    7b39b9e55329:	cmp    $0x1,%rax
    7b39b9e5532d:	je     0x7b39b9e55345
    7b39b9e55333:	sub    $0x8,%r14
    7b39b9e55337:	mov    %eax,0x13164cc3(%rip)        # 0x7b39ccfba000
    7b39b9e5533d:	add    $0xa8,%rsp
    7b39b9e55344:	ret
    7b39b9e55345:	mov    (%r14),%rax
    7b39b9e55348:	mov    -0x8(%r14),%rbx
    7b39b9e5534c:	jmp    0x7b39b9e5535c
    7b39b9e55351:	sub    $0x8,%r14
    7b39b9e55355:	mov    (%r14),%rax
    7b39b9e55358:	mov    -0x8(%r14),%rbx
    7b39b9e5535c:	lea    0x10(%r13),%rdx
    7b39b9e55360:	mov    (%rdx),%rcx
    7b39b9e55363:	add    $0x20,%rcx
    7b39b9e55367:	cmp    0x10(%rdx),%rcx
    7b39b9e5536b:	jle    0x7b39b9e5538a
    7b39b9e55371:	mov    %rbx,0x40(%rsp)
    7b39b9e55376:	mov    %rax,0x48(%rsp)
    7b39b9e5537b:	call   0x7b39b9ebe060
    7b39b9e55380:	mov    0x40(%rsp),%rbx
    7b39b9e55385:	mov    0x48(%rsp),%rax
    7b39b9e5538a:	movabs $0x7b39bf44caa2,%rdx
    7b39b9e55394:	lea    0x10(%r13),%rbp
    7b39b9e55398:	mov    0x0(%rbp),%rcx
    7b39b9e5539c:	movq   $0x1c,(%rcx)
    7b39b9e553a3:	or     $0x7,%rcx
    7b39b9e553a7:	addq   $0x20,0x0(%rbp)
    7b39b9e553ac:	mov    %rdx,0x1(%rcx)
    7b39b9e553b0:	mov    %rbx,0x9(%rcx)
    7b39b9e553b4:	mov    %rax,0x11(%rcx)
    7b39b9e553b8:	sub    $0x8,%r14
    7b39b9e553bc:	mov    %rcx,(%r14)
    7b39b9e553bf:	mov    %eax,0x13164c3b(%rip)        # 0x7b39ccfba000
    7b39b9e553c5:	add    $0xa8,%rsp
    7b39b9e553cc:	ret
    7b39b9e553cd:	mov    %rax,%rcx
    7b39b9e553d0:	and    $0xf,%ecx
    7b39b9e553d3:	cmp    $0x3,%rcx
    7b39b9e553d7:	jne    0x7b39b9e55583
    7b39b9e553dd:	mov    0x9(%rbx),%rcx
    7b39b9e553e1:	mov    0x11(%rbx),%rbx
    7b39b9e553e5:	sub    $0x8,%r14
    7b39b9e553e9:	add    $0x10,%r15
    7b39b9e553ed:	mov    %rax,(%r15)
    7b39b9e553f0:	mov    %rbx,-0x8(%r15)
    7b39b9e553f4:	mov    %rcx,(%r14)
    7b39b9e553f7:	call   0x7b39b8c9dfc0
    7b39b9e553fc:	lea    0x10(%r13),%rax
    7b39b9e55400:	mov    (%rax),%rbx
    7b39b9e55403:	add    $0x10,%rbx
    7b39b9e55407:	cmp    0x10(%rax),%rbx
    7b39b9e5540b:	jle    0x7b39b9e55416
    7b39b9e55411:	call   0x7b39b9ebe060
    7b39b9e55416:	mov    (%r15),%rbx
    7b39b9e55419:	mov    (%r14),%rcx
    7b39b9e5541c:	mov    -0x8(%r15),%rax
    7b39b9e55420:	rex.W movsd 0x5(%rcx),%xmm0
    7b39b9e55426:	rex.W movsd 0x5(%rbx),%xmm1
    7b39b9e5542c:	addsd  %xmm1,%xmm0
    7b39b9e55430:	lea    0x10(%r13),%rcx
    7b39b9e55434:	mov    (%rcx),%rbx
    7b39b9e55437:	movq   $0xc,(%rbx)
    7b39b9e5543e:	or     $0x3,%rbx
    7b39b9e55442:	addq   $0x10,(%rcx)
    7b39b9e55446:	rex.W movsd %xmm0,0x5(%rbx)
    7b39b9e5544c:	add    $0x10,%r14
    7b39b9e55450:	sub    $0x10,%r15
    7b39b9e55454:	mov    %rax,-0x8(%r14)
    7b39b9e55458:	movq   $0x0,(%r14)
    7b39b9e5545f:	mov    %rbx,-0x10(%r14)
    7b39b9e55463:	call   0x7b39b9e54860
    7b39b9e55468:	mov    (%r14),%rax
    7b39b9e5546b:	add    $0x8,%r14
    7b39b9e5546f:	cmp    $0x0,%rax
    7b39b9e55473:	jne    0x7b39b9e5548f
    7b39b9e55479:	sub    $0x8,%r14
    7b39b9e5547d:	sub    $0x8,%r14
    7b39b9e55481:	mov    %eax,0x13164b79(%rip)        # 0x7b39ccfba000
    7b39b9e55487:	add    $0xa8,%rsp
    7b39b9e5548e:	ret
    7b39b9e5548f:	mov    %rax,%rbx
    7b39b9e55492:	test   $0xf,%ebx
    7b39b9e55498:	jne    0x7b39b9e554ae
    7b39b9e5549e:	sub    $0x8,%r14
    7b39b9e554a2:	mov    (%r14),%rax
    7b39b9e554a5:	mov    -0x8(%r14),%rbx
    7b39b9e554a9:	jmp    0x7b39b9e55512
    7b39b9e554ae:	mov    %rax,%rbx
    7b39b9e554b1:	and    $0xf,%ebx
    7b39b9e554b4:	cmp    $0x5,%rbx
    7b39b9e554b8:	jne    0x7b39b9e55507
    7b39b9e554be:	movabs $0x7b39bf4dc455,%rbx
    7b39b9e554c8:	add    $0x8,%r14
    7b39b9e554cc:	mov    %rax,-0x8(%r14)
    7b39b9e554d0:	mov    %rbx,(%r14)
    7b39b9e554d3:	call   0x7b39ba1b9440
    7b39b9e554d8:	mov    (%r14),%rax
    7b39b9e554db:	sub    $0x8,%r14
    7b39b9e554df:	cmp    $0x1,%rax
    7b39b9e554e3:	je     0x7b39b9e554fb
    7b39b9e554e9:	sub    $0x8,%r14
    7b39b9e554ed:	mov    %eax,0x13164b0d(%rip)        # 0x7b39ccfba000
    7b39b9e554f3:	add    $0xa8,%rsp
    7b39b9e554fa:	ret
    7b39b9e554fb:	mov    (%r14),%rax
    7b39b9e554fe:	mov    -0x8(%r14),%rbx
    7b39b9e55502:	jmp    0x7b39b9e55512
    7b39b9e55507:	sub    $0x8,%r14
    7b39b9e5550b:	mov    (%r14),%rax
    7b39b9e5550e:	mov    -0x8(%r14),%rbx
    7b39b9e55512:	lea    0x10(%r13),%rdx
    7b39b9e55516:	mov    (%rdx),%rcx
    7b39b9e55519:	add    $0x20,%rcx
    7b39b9e5551d:	cmp    0x10(%rdx),%rcx
    7b39b9e55521:	jle    0x7b39b9e55540
    7b39b9e55527:	mov    %rbx,0x50(%rsp)
    7b39b9e5552c:	mov    %rax,0x58(%rsp)
    7b39b9e55531:	call   0x7b39b9ebe060
    7b39b9e55536:	mov    0x50(%rsp),%rbx
    7b39b9e5553b:	mov    0x58(%rsp),%rax
    7b39b9e55540:	movabs $0x7b39bf44caa2,%rdx
    7b39b9e5554a:	lea    0x10(%r13),%rbp
    7b39b9e5554e:	mov    0x0(%rbp),%rcx
    7b39b9e55552:	movq   $0x1c,(%rcx)
    7b39b9e55559:	or     $0x7,%rcx
    7b39b9e5555d:	addq   $0x20,0x0(%rbp)
    7b39b9e55562:	mov    %rdx,0x1(%rcx)
    7b39b9e55566:	mov    %rbx,0x9(%rcx)
    7b39b9e5556a:	mov    %rax,0x11(%rcx)
    7b39b9e5556e:	sub    $0x8,%r14
    7b39b9e55572:	mov    %rcx,(%r14)
    7b39b9e55575:	mov    %eax,0x13164a85(%rip)        # 0x7b39ccfba000
    7b39b9e5557b:	add    $0xa8,%rsp
    7b39b9e55582:	ret
    7b39b9e55583:	mov    %rax,%rcx
    7b39b9e55586:	and    $0xf,%ecx
    7b39b9e55589:	cmp    $0x5,%rcx
    7b39b9e5558d:	jne    0x7b39b9e556e1
    7b39b9e55593:	mov    0x9(%rbx),%rax
    7b39b9e55597:	mov    0x11(%rbx),%rbx
    7b39b9e5559b:	add    $0x8,%r15
    7b39b9e5559f:	mov    %rbx,(%r15)
    7b39b9e555a2:	mov    %rax,-0x8(%r14)
    7b39b9e555a6:	call   0x7b39b9e54860
    7b39b9e555ab:	mov    (%r15),%rax
    7b39b9e555ae:	add    $0x10,%r14
    7b39b9e555b2:	sub    $0x8,%r15
    7b39b9e555b6:	mov    %rax,-0x8(%r14)
    7b39b9e555ba:	movq   $0x0,(%r14)
    7b39b9e555c1:	call   0x7b39b9e54860
    7b39b9e555c6:	mov    (%r14),%rax
    7b39b9e555c9:	add    $0x8,%r14
    7b39b9e555cd:	cmp    $0x0,%rax
    7b39b9e555d1:	jne    0x7b39b9e555ed
    7b39b9e555d7:	sub    $0x8,%r14
    7b39b9e555db:	sub    $0x8,%r14
    7b39b9e555df:	mov    %eax,0x13164a1b(%rip)        # 0x7b39ccfba000
    7b39b9e555e5:	add    $0xa8,%rsp
    7b39b9e555ec:	ret
    7b39b9e555ed:	mov    %rax,%rbx
    7b39b9e555f0:	test   $0xf,%ebx
    7b39b9e555f6:	jne    0x7b39b9e5560c
    7b39b9e555fc:	sub    $0x8,%r14
    7b39b9e55600:	mov    (%r14),%rax
    7b39b9e55603:	mov    -0x8(%r14),%rbx
    7b39b9e55607:	jmp    0x7b39b9e55670
    7b39b9e5560c:	mov    %rax,%rbx
    7b39b9e5560f:	and    $0xf,%ebx
    7b39b9e55612:	cmp    $0x5,%rbx
    7b39b9e55616:	jne    0x7b39b9e55665
    7b39b9e5561c:	movabs $0x7b39bf4dc455,%rbx
    7b39b9e55626:	add    $0x8,%r14
    7b39b9e5562a:	mov    %rax,-0x8(%r14)
    7b39b9e5562e:	mov    %rbx,(%r14)
    7b39b9e55631:	call   0x7b39ba1b9440
    7b39b9e55636:	mov    (%r14),%rax
    7b39b9e55639:	sub    $0x8,%r14
    7b39b9e5563d:	cmp    $0x1,%rax
    7b39b9e55641:	je     0x7b39b9e55659
    7b39b9e55647:	sub    $0x8,%r14
    7b39b9e5564b:	mov    %eax,0x131649af(%rip)        # 0x7b39ccfba000
    7b39b9e55651:	add    $0xa8,%rsp
    7b39b9e55658:	ret
    7b39b9e55659:	mov    (%r14),%rax
    7b39b9e5565c:	mov    -0x8(%r14),%rbx
    7b39b9e55660:	jmp    0x7b39b9e55670
    7b39b9e55665:	sub    $0x8,%r14
    7b39b9e55669:	mov    (%r14),%rax
    7b39b9e5566c:	mov    -0x8(%r14),%rbx
    7b39b9e55670:	lea    0x10(%r13),%rdx
    7b39b9e55674:	mov    (%rdx),%rcx
    7b39b9e55677:	add    $0x20,%rcx
    7b39b9e5567b:	cmp    0x10(%rdx),%rcx
    7b39b9e5567f:	jle    0x7b39b9e5569e
    7b39b9e55685:	mov    %rbx,0x60(%rsp)
    7b39b9e5568a:	mov    %rax,0x68(%rsp)
    7b39b9e5568f:	call   0x7b39b9ebe060
    7b39b9e55694:	mov    0x60(%rsp),%rbx
    7b39b9e55699:	mov    0x68(%rsp),%rax
    7b39b9e5569e:	movabs $0x7b39bf44caa2,%rdx
    7b39b9e556a8:	lea    0x10(%r13),%rbp
    7b39b9e556ac:	mov    0x0(%rbp),%rcx
    7b39b9e556b0:	movq   $0x1c,(%rcx)
    7b39b9e556b7:	or     $0x7,%rcx
    7b39b9e556bb:	addq   $0x20,0x0(%rbp)
    7b39b9e556c0:	mov    %rdx,0x1(%rcx)
    7b39b9e556c4:	mov    %rbx,0x9(%rcx)
    7b39b9e556c8:	mov    %rax,0x11(%rcx)
    7b39b9e556cc:	sub    $0x8,%r14
    7b39b9e556d0:	mov    %rcx,(%r14)
    7b39b9e556d3:	mov    %eax,0x13164927(%rip)        # 0x7b39ccfba000
    7b39b9e556d9:	add    $0xa8,%rsp
    7b39b9e556e0:	ret
    7b39b9e556e1:	mov    %rax,%rcx
    7b39b9e556e4:	and    $0xf,%ecx
    7b39b9e556e7:	cmp    $0x7,%rcx
    7b39b9e556eb:	jne    0x7b39b9e559f4
    7b39b9e556f1:	mov    0x1(%rax),%rcx
    7b39b9e556f5:	mov    0xe(%rcx),%rcx
    7b39b9e556f9:	movabs $0x7b39bf44cedc,%rdx
    7b39b9e55703:	cmp    %rdx,%rcx
    7b39b9e55706:	jne    0x7b39b9e55869
    7b39b9e5570c:	mov    0x9(%rbx),%rcx
    7b39b9e55710:	mov    0x11(%rbx),%rbx
    7b39b9e55714:	mov    0x9(%rax),%rdx
    7b39b9e55718:	mov    0x11(%rax),%rax
    7b39b9e5571c:	add    $0x10,%r15
    7b39b9e55720:	mov    %rax,-0x8(%r15)
    7b39b9e55724:	mov    %rcx,-0x8(%r14)
    7b39b9e55728:	mov    %rdx,(%r14)
    7b39b9e5572b:	mov    %rbx,(%r15)
    7b39b9e5572e:	call   0x7b39b9e54860
    7b39b9e55733:	mov    (%r15),%rax
    7b39b9e55736:	mov    -0x8(%r15),%rbx
    7b39b9e5573a:	add    $0x10,%r14
    7b39b9e5573e:	sub    $0x10,%r15
    7b39b9e55742:	mov    %rax,-0x8(%r14)
    7b39b9e55746:	mov    %rbx,(%r14)
    7b39b9e55749:	call   0x7b39b9e54860
    7b39b9e5574e:	mov    (%r14),%rax
    7b39b9e55751:	add    $0x8,%r14
    7b39b9e55755:	cmp    $0x0,%rax
    7b39b9e55759:	jne    0x7b39b9e55775
    7b39b9e5575f:	sub    $0x8,%r14
    7b39b9e55763:	sub    $0x8,%r14
    7b39b9e55767:	mov    %eax,0x13164893(%rip)        # 0x7b39ccfba000
    7b39b9e5576d:	add    $0xa8,%rsp
    7b39b9e55774:	ret
    7b39b9e55775:	mov    %rax,%rbx
    7b39b9e55778:	test   $0xf,%ebx
    7b39b9e5577e:	jne    0x7b39b9e55794
    7b39b9e55784:	sub    $0x8,%r14
    7b39b9e55788:	mov    (%r14),%rax
    7b39b9e5578b:	mov    -0x8(%r14),%rbx
    7b39b9e5578f:	jmp    0x7b39b9e557f8
    7b39b9e55794:	mov    %rax,%rbx
    7b39b9e55797:	and    $0xf,%ebx
    7b39b9e5579a:	cmp    $0x5,%rbx
    7b39b9e5579e:	jne    0x7b39b9e557ed
    7b39b9e557a4:	movabs $0x7b39bf4dc455,%rbx
    7b39b9e557ae:	add    $0x8,%r14
    7b39b9e557b2:	mov    %rax,-0x8(%r14)
    7b39b9e557b6:	mov    %rbx,(%r14)
    7b39b9e557b9:	call   0x7b39ba1b9440
    7b39b9e557be:	mov    (%r14),%rax
    7b39b9e557c1:	sub    $0x8,%r14
    7b39b9e557c5:	cmp    $0x1,%rax
    7b39b9e557c9:	je     0x7b39b9e557e1
    7b39b9e557cf:	sub    $0x8,%r14
    7b39b9e557d3:	mov    %eax,0x13164827(%rip)        # 0x7b39ccfba000
    7b39b9e557d9:	add    $0xa8,%rsp
    7b39b9e557e0:	ret
    7b39b9e557e1:	mov    (%r14),%rax
    7b39b9e557e4:	mov    -0x8(%r14),%rbx
    7b39b9e557e8:	jmp    0x7b39b9e557f8
    7b39b9e557ed:	sub    $0x8,%r14
    7b39b9e557f1:	mov    (%r14),%rax
    7b39b9e557f4:	mov    -0x8(%r14),%rbx
    7b39b9e557f8:	lea    0x10(%r13),%rcx
    7b39b9e557fc:	mov    (%rcx),%rdx
    7b39b9e557ff:	add    $0x20,%rdx
    7b39b9e55803:	cmp    0x10(%rcx),%rdx
    7b39b9e55807:	jle    0x7b39b9e55826
    7b39b9e5580d:	mov    %rbx,0x70(%rsp)
    7b39b9e55812:	mov    %rax,0x78(%rsp)
    7b39b9e55817:	call   0x7b39b9ebe060
    7b39b9e5581c:	mov    0x70(%rsp),%rbx
    7b39b9e55821:	mov    0x78(%rsp),%rax
    7b39b9e55826:	movabs $0x7b39bf44caa2,%rdx
    7b39b9e55830:	lea    0x10(%r13),%rbp
    7b39b9e55834:	mov    0x0(%rbp),%rcx
    7b39b9e55838:	movq   $0x1c,(%rcx)
    7b39b9e5583f:	or     $0x7,%rcx
    7b39b9e55843:	addq   $0x20,0x0(%rbp)
    7b39b9e55848:	mov    %rdx,0x1(%rcx)
    7b39b9e5584c:	mov    %rbx,0x9(%rcx)
    7b39b9e55850:	mov    %rax,0x11(%rcx)
    7b39b9e55854:	sub    $0x8,%r14
    7b39b9e55858:	mov    %rcx,(%r14)
    7b39b9e5585b:	mov    %eax,0x1316479f(%rip)        # 0x7b39ccfba000
    7b39b9e55861:	add    $0xa8,%rsp
    7b39b9e55868:	ret
    7b39b9e55869:	mov    0x1(%rax),%rax
    7b39b9e5586d:	mov    0xe(%rax),%rax
    7b39b9e55871:	movabs $0x7b39bf43a07c,%rcx
    7b39b9e5587b:	cmp    %rcx,%rax
    7b39b9e5587e:	jne    0x7b39b9e559de
    7b39b9e55884:	mov    0x9(%rbx),%rax
    7b39b9e55888:	mov    0x11(%rbx),%rbx
    7b39b9e5588c:	add    $0x8,%r15
    7b39b9e55890:	mov    %rbx,(%r15)
    7b39b9e55893:	mov    %rax,-0x8(%r14)
    7b39b9e55897:	call   0x7b39b9e54860
    7b39b9e5589c:	mov    (%r15),%rax
    7b39b9e5589f:	add    $0x10,%r14
    7b39b9e558a3:	sub    $0x8,%r15
    7b39b9e558a7:	mov    %rax,-0x8(%r14)
    7b39b9e558ab:	movq   $0x0,(%r14)
    7b39b9e558b2:	call   0x7b39b9e54860
    7b39b9e558b7:	mov    (%r14),%rax
    7b39b9e558ba:	add    $0x8,%r14
    7b39b9e558be:	cmp    $0x0,%rax
    7b39b9e558c2:	jne    0x7b39b9e558de
    7b39b9e558c8:	sub    $0x8,%r14
    7b39b9e558cc:	sub    $0x8,%r14
    7b39b9e558d0:	mov    %eax,0x1316472a(%rip)        # 0x7b39ccfba000
    7b39b9e558d6:	add    $0xa8,%rsp
    7b39b9e558dd:	ret
    7b39b9e558de:	mov    %rax,%rbx
    7b39b9e558e1:	test   $0xf,%ebx
    7b39b9e558e7:	jne    0x7b39b9e558fd
    7b39b9e558ed:	sub    $0x8,%r14
    7b39b9e558f1:	mov    (%r14),%rax
    7b39b9e558f4:	mov    -0x8(%r14),%rbx
    7b39b9e558f8:	jmp    0x7b39b9e55961
    7b39b9e558fd:	mov    %rax,%rbx
    7b39b9e55900:	and    $0xf,%ebx
    7b39b9e55903:	cmp    $0x5,%rbx
    7b39b9e55907:	jne    0x7b39b9e55956
    7b39b9e5590d:	movabs $0x7b39bf4dc455,%rbx
    7b39b9e55917:	add    $0x8,%r14
    7b39b9e5591b:	mov    %rax,-0x8(%r14)
    7b39b9e5591f:	mov    %rbx,(%r14)
    7b39b9e55922:	call   0x7b39ba1b9440
    7b39b9e55927:	mov    (%r14),%rax
    7b39b9e5592a:	sub    $0x8,%r14
    7b39b9e5592e:	cmp    $0x1,%rax
    7b39b9e55932:	je     0x7b39b9e5594a
    7b39b9e55938:	sub    $0x8,%r14
    7b39b9e5593c:	mov    %eax,0x131646be(%rip)        # 0x7b39ccfba000
    7b39b9e55942:	add    $0xa8,%rsp
    7b39b9e55949:	ret
    7b39b9e5594a:	mov    (%r14),%rax
    7b39b9e5594d:	mov    -0x8(%r14),%rbx
    7b39b9e55951:	jmp    0x7b39b9e55961
    7b39b9e55956:	sub    $0x8,%r14
    7b39b9e5595a:	mov    (%r14),%rax
    7b39b9e5595d:	mov    -0x8(%r14),%rbx
    7b39b9e55961:	lea    0x10(%r13),%rcx
    7b39b9e55965:	mov    (%rcx),%rdx
    7b39b9e55968:	add    $0x20,%rdx
    7b39b9e5596c:	cmp    0x10(%rcx),%rdx
    7b39b9e55970:	jle    0x7b39b9e5599b
    7b39b9e55976:	mov    %rbx,0x80(%rsp)
    7b39b9e5597e:	mov    %rax,0x88(%rsp)
    7b39b9e55986:	call   0x7b39b9ebe060
    7b39b9e5598b:	mov    0x80(%rsp),%rbx
    7b39b9e55993:	mov    0x88(%rsp),%rax
    7b39b9e5599b:	movabs $0x7b39bf44caa2,%rdx
    7b39b9e559a5:	lea    0x10(%r13),%rbp
    7b39b9e559a9:	mov    0x0(%rbp),%rcx
    7b39b9e559ad:	movq   $0x1c,(%rcx)
    7b39b9e559b4:	or     $0x7,%rcx
    7b39b9e559b8:	addq   $0x20,0x0(%rbp)
    7b39b9e559bd:	mov    %rdx,0x1(%rcx)
    7b39b9e559c1:	mov    %rbx,0x9(%rcx)
    7b39b9e559c5:	mov    %rax,0x11(%rcx)
    7b39b9e559c9:	sub    $0x8,%r14
    7b39b9e559cd:	mov    %rcx,(%r14)
    7b39b9e559d0:	mov    %eax,0x1316462a(%rip)        # 0x7b39ccfba000
    7b39b9e559d6:	add    $0xa8,%rsp
    7b39b9e559dd:	ret
    7b39b9e559de:	movabs $0x7b39bf427c9c,%rax
    7b39b9e559e8:	add    $0x8,%r14
    7b39b9e559ec:	mov    %rax,(%r14)
    7b39b9e559ef:	call   0x7b39ba28e600
    7b39b9e559f4:	movabs $0x7b39bf427c9c,%rax
    7b39b9e559fe:	add    $0x8,%r14
    7b39b9e55a02:	mov    %rax,(%r14)
    7b39b9e55a05:	call   0x7b39ba28e600
    7b39b9e55a0a:	mov    0x1(%rbx),%rbx
    7b39b9e55a0e:	mov    0xe(%rbx),%rbx
    7b39b9e55a12:	movabs $0x7b39bf43a07c,%rcx
    7b39b9e55a1c:	cmp    %rcx,%rbx
    7b39b9e55a1f:	jne    0x7b39b9e55ce3
    7b39b9e55a25:	mov    %rax,%rbx
    7b39b9e55a28:	test   $0xf,%ebx
    7b39b9e55a2e:	jne    0x7b39b9e55a4d
    7b39b9e55a34:	mov    %eax,0x131645c6(%rip)        # 0x7b39ccfba000
    7b39b9e55a3a:	add    $0xa8,%rsp
    7b39b9e55a41:	lea    0x5(%rip),%rbx        # 0x7b39b9e55a4d
    7b39b9e55a48:	jmp    0x7b39ba046010
    7b39b9e55a4d:	mov    %rax,%rbx
    7b39b9e55a50:	and    $0xf,%ebx
    7b39b9e55a53:	cmp    $0x3,%rbx
    7b39b9e55a57:	jne    0x7b39b9e55ace
    7b39b9e55a5d:	sub    $0x8,%r14
    7b39b9e55a61:	add    $0x8,%r15
    7b39b9e55a65:	mov    %rax,(%r15)
    7b39b9e55a68:	call   0x7b39b9be0070
    7b39b9e55a6d:	lea    0x10(%r13),%rbx
    7b39b9e55a71:	mov    (%rbx),%rax
    7b39b9e55a74:	add    $0x10,%rax
    7b39b9e55a78:	cmp    0x10(%rbx),%rax
    7b39b9e55a7c:	jle    0x7b39b9e55a87
    7b39b9e55a82:	call   0x7b39b9ebe060
    7b39b9e55a87:	mov    (%r15),%rax
    7b39b9e55a8a:	mov    (%r14),%rbx
    7b39b9e55a8d:	rex.W movsd 0x5(%rbx),%xmm0
    7b39b9e55a93:	rex.W movsd 0x5(%rax),%xmm1
    7b39b9e55a99:	addsd  %xmm1,%xmm0
    7b39b9e55a9d:	lea    0x10(%r13),%rbx
    7b39b9e55aa1:	mov    (%rbx),%rax
    7b39b9e55aa4:	movq   $0xc,(%rax)
    7b39b9e55aab:	or     $0x3,%rax
    7b39b9e55aaf:	addq   $0x10,(%rbx)
    7b39b9e55ab3:	rex.W movsd %xmm0,0x5(%rax)
    7b39b9e55ab9:	sub    $0x8,%r15
    7b39b9e55abd:	mov    %rax,(%r14)
    7b39b9e55ac0:	mov    %eax,0x1316453a(%rip)        # 0x7b39ccfba000
    7b39b9e55ac6:	add    $0xa8,%rsp
    7b39b9e55acd:	ret
    7b39b9e55ace:	mov    %rax,%rbx
    7b39b9e55ad1:	and    $0xf,%ebx
    7b39b9e55ad4:	cmp    $0x5,%rbx
    7b39b9e55ad8:	jne    0x7b39b9e55af7
    7b39b9e55ade:	mov    %eax,0x1316451c(%rip)        # 0x7b39ccfba000
    7b39b9e55ae4:	add    $0xa8,%rsp
    7b39b9e55aeb:	lea    0x5(%rip),%rbx        # 0x7b39b9e55af7
    7b39b9e55af2:	jmp    0x7b39ba046010
    7b39b9e55af7:	mov    %rax,%rbx
    7b39b9e55afa:	and    $0xf,%ebx
    7b39b9e55afd:	cmp    $0x7,%rbx
    7b39b9e55b01:	jne    0x7b39b9e55ccd
    7b39b9e55b07:	mov    0x1(%rax),%rbx
    7b39b9e55b0b:	mov    0xe(%rbx),%rbx
    7b39b9e55b0f:	movabs $0x7b39bf44cedc,%rcx
    7b39b9e55b19:	cmp    %rcx,%rbx
    7b39b9e55b1c:	jne    0x7b39b9e55c83
    7b39b9e55b22:	mov    0x9(%rax),%rbx
    7b39b9e55b26:	mov    0x11(%rax),%rax
    7b39b9e55b2a:	add    $0x10,%r15
    7b39b9e55b2e:	mov    %rax,-0x8(%r15)
    7b39b9e55b32:	mov    %rbx,(%r14)
    7b39b9e55b35:	movq   $0x0,(%r15)
    7b39b9e55b3c:	call   0x7b39b9e54860
    7b39b9e55b41:	mov    (%r15),%rbx
    7b39b9e55b44:	mov    -0x8(%r15),%rax
    7b39b9e55b48:	add    $0x10,%r14
    7b39b9e55b4c:	sub    $0x10,%r15
    7b39b9e55b50:	mov    %rbx,-0x8(%r14)
    7b39b9e55b54:	mov    %rax,(%r14)
    7b39b9e55b57:	call   0x7b39b9e54860
    7b39b9e55b5c:	mov    (%r14),%rax
    7b39b9e55b5f:	add    $0x8,%r14
    7b39b9e55b63:	cmp    $0x0,%rax
    7b39b9e55b67:	jne    0x7b39b9e55b83
    7b39b9e55b6d:	sub    $0x8,%r14
    7b39b9e55b71:	sub    $0x8,%r14
    7b39b9e55b75:	mov    %eax,0x13164485(%rip)        # 0x7b39ccfba000
    7b39b9e55b7b:	add    $0xa8,%rsp
    7b39b9e55b82:	ret
    7b39b9e55b83:	mov    %rax,%rbx
    7b39b9e55b86:	test   $0xf,%ebx
    7b39b9e55b8c:	jne    0x7b39b9e55ba2
    7b39b9e55b92:	sub    $0x8,%r14
    7b39b9e55b96:	mov    (%r14),%rax
    7b39b9e55b99:	mov    -0x8(%r14),%rbx
    7b39b9e55b9d:	jmp    0x7b39b9e55c06
    7b39b9e55ba2:	mov    %rax,%rbx
    7b39b9e55ba5:	and    $0xf,%ebx
    7b39b9e55ba8:	cmp    $0x5,%rbx
    7b39b9e55bac:	jne    0x7b39b9e55bfb
    7b39b9e55bb2:	movabs $0x7b39bf4dc455,%rbx
    7b39b9e55bbc:	add    $0x8,%r14
    7b39b9e55bc0:	mov    %rax,-0x8(%r14)
    7b39b9e55bc4:	mov    %rbx,(%r14)
    7b39b9e55bc7:	call   0x7b39ba1b9440
    7b39b9e55bcc:	mov    (%r14),%rax
    7b39b9e55bcf:	sub    $0x8,%r14
    7b39b9e55bd3:	cmp    $0x1,%rax
    7b39b9e55bd7:	je     0x7b39b9e55bef
    7b39b9e55bdd:	sub    $0x8,%r14
    7b39b9e55be1:	mov    %eax,0x13164419(%rip)        # 0x7b39ccfba000
    7b39b9e55be7:	add    $0xa8,%rsp
    7b39b9e55bee:	ret
    7b39b9e55bef:	mov    (%r14),%rax
    7b39b9e55bf2:	mov    -0x8(%r14),%rbx
    7b39b9e55bf6:	jmp    0x7b39b9e55c06
    7b39b9e55bfb:	sub    $0x8,%r14
    7b39b9e55bff:	mov    (%r14),%rax
    7b39b9e55c02:	mov    -0x8(%r14),%rbx
    7b39b9e55c06:	lea    0x10(%r13),%rdx
    7b39b9e55c0a:	mov    (%rdx),%rcx
    7b39b9e55c0d:	add    $0x20,%rcx
    7b39b9e55c11:	cmp    0x10(%rdx),%rcx
    7b39b9e55c15:	jle    0x7b39b9e55c40
    7b39b9e55c1b:	mov    %rbx,0x90(%rsp)
    7b39b9e55c23:	mov    %rax,0x98(%rsp)
    7b39b9e55c2b:	call   0x7b39b9ebe060
    7b39b9e55c30:	mov    0x90(%rsp),%rbx
    7b39b9e55c38:	mov    0x98(%rsp),%rax
    7b39b9e55c40:	movabs $0x7b39bf44caa2,%rdx
    7b39b9e55c4a:	lea    0x10(%r13),%rbp
    7b39b9e55c4e:	mov    0x0(%rbp),%rcx
    7b39b9e55c52:	movq   $0x1c,(%rcx)
    7b39b9e55c59:	or     $0x7,%rcx
    7b39b9e55c5d:	addq   $0x20,0x0(%rbp)
    7b39b9e55c62:	mov    %rdx,0x1(%rcx)
    7b39b9e55c66:	mov    %rbx,0x9(%rcx)
    7b39b9e55c6a:	mov    %rax,0x11(%rcx)
    7b39b9e55c6e:	sub    $0x8,%r14
    7b39b9e55c72:	mov    %rcx,(%r14)
    7b39b9e55c75:	mov    %eax,0x13164385(%rip)        # 0x7b39ccfba000
    7b39b9e55c7b:	add    $0xa8,%rsp
    7b39b9e55c82:	ret
    7b39b9e55c83:	mov    0x1(%rax),%rax
    7b39b9e55c87:	mov    0xe(%rax),%rax
    7b39b9e55c8b:	movabs $0x7b39bf43a07c,%rbx
    7b39b9e55c95:	cmp    %rbx,%rax
    7b39b9e55c98:	jne    0x7b39b9e55cb7
    7b39b9e55c9e:	mov    %eax,0x1316435c(%rip)        # 0x7b39ccfba000
    7b39b9e55ca4:	add    $0xa8,%rsp
    7b39b9e55cab:	lea    0x5(%rip),%rbx        # 0x7b39b9e55cb7
    7b39b9e55cb2:	jmp    0x7b39ba046010
    7b39b9e55cb7:	movabs $0x7b39bf427c9c,%rax
    7b39b9e55cc1:	add    $0x8,%r14
    7b39b9e55cc5:	mov    %rax,(%r14)
    7b39b9e55cc8:	call   0x7b39ba28e600
    7b39b9e55ccd:	movabs $0x7b39bf427c9c,%rax
    7b39b9e55cd7:	add    $0x8,%r14
    7b39b9e55cdb:	mov    %rax,(%r14)
    7b39b9e55cde:	call   0x7b39ba28e600
    7b39b9e55ce3:	movabs $0x7b39bf427c9c,%rax
    7b39b9e55ced:	add    $0x8,%r14
    7b39b9e55cf1:	mov    %rax,(%r14)
    7b39b9e55cf4:	call   0x7b39ba28e600
    7b39b9e55cf9:	movabs $0x7b39bf427c9c,%rax
    7b39b9e55d03:	add    $0x8,%r14
    7b39b9e55d07:	mov    %rax,(%r14)
    7b39b9e55d0a:	call   0x7b39ba28e600
    7b39b9e55d0f:	add    %al,(%rax)
    7b39b9e55d11:	add    %al,(%rax)
    7b39b9e55d13:	add    %al,(%rsi)
    7b39b9e55d15:	add    %al,(%rax)
    7b39b9e55d17:	add    (%rax),%eax
    7b39b9e55d19:	sbb    %al,(%rax)
    7b39b9e55d1b:	add    %al,(%rbx)
    7b39b9e55d1d:	add    %al,(%rax)
    7b39b9e55d1f:	(bad)
    7b39b9e55d20:	add    %al,(%rax)
    7b39b9e55d22:	add    (%rax),%eax
    7b39b9e55d24:	addb   $0x0,(%rcx)
    7b39b9e55d27:	rolb   $0x0,(%rax)
    7b39b9e55d2a:	(bad)
    7b39b9e55d2b:	add    %al,(%rax)
    7b39b9e55d2d:	xor    %al,(%rax)
    7b39b9e55d2f:	add    %bl,(%rax)
    7b39b9e55d31:	add    %al,(%rax)
    7b39b9e55d33:	or     $0xa2,%al
    7b39b9e55d35:	add    %al,(%rax)
    7b39b9e55d37:	add    %ch,0x0(%rdx,%rax,1)
    7b39b9e55d3b:	add    %bl,0x3(%rbx)
    7b39b9e55d3e:	add    %al,(%rax)
    7b39b9e55d40:	fiadds (%rbx)
    7b39b9e55d42:	add    %al,(%rax)
    7b39b9e55d44:	and    (%rsi),%eax
    7b39b9e55d46:	add    %al,(%rax)
    7b39b9e55d48:	cmp    %cl,(%rcx)
    7b39b9e55d4a:	add    %al,(%rax)
    7b39b9e55d4c:	and    %cl,(%rbx)
    7b39b9e55d4e:	add    %al,(%rax)
    7b39b9e55d50:	udb
    7b39b9e55d51:	or     $0x0,%al
    7b39b9e55d53:	add    %dh,(%rsi,%rcx,1)
    7b39b9e55d56:	add    %al,(%rax)
    7b39b9e55d58:	mov    $0x2b00000f,%esp
    7b39b9e55d5d:	adc    %eax,(%rax)
    7b39b9e55d5f:	add    %dl,%al
    7b39b9e55d61:	adc    (%rax),%eax
    7b39b9e55d63:	add    %dl,0x0(%rip)        # 0x7b39b9e55d69
    7b39b9e55d69:	add    %al,(%rax)
    7b39b9e55d6b:	add    %cl,(%rax,%rax,1)
	...
