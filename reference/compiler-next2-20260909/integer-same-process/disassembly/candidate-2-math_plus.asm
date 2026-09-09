
/home/erg/compiler-next2-integer-20260909/disassembly/candidate-2-math_plus.bin:     file format binary


Disassembly of section .data:

000073b7260a38d0 <.data>:
    73b7260a38d0:	mov    %eax,0x1314772a(%rip)        # 0x73b7391eb000
    73b7260a38d6:	sub    $0xa8,%rsp
    73b7260a38dd:	mov    (%r14),%rax
    73b7260a38e0:	mov    -0x8(%r14),%rbx
    73b7260a38e4:	mov    %rbx,%rcx
    73b7260a38e7:	mov    %rax,%rdx
    73b7260a38ea:	or     %rdx,%rcx
    73b7260a38ed:	test   $0xf,%ecx
    73b7260a38f3:	jne    0x73b7260a3930
    73b7260a38f9:	add    %rax,%rbx
    73b7260a38fc:	jo     0x73b7260a3917
    73b7260a3902:	sub    $0x8,%r14
    73b7260a3906:	mov    %rbx,(%r14)
    73b7260a3909:	mov    %eax,0x131476f1(%rip)        # 0x73b7391eb000
    73b7260a390f:	add    $0xa8,%rsp
    73b7260a3916:	ret
    73b7260a3917:	mov    %eax,0x131476e3(%rip)        # 0x73b7391eb000
    73b7260a391d:	add    $0xa8,%rsp
    73b7260a3924:	lea    0x5(%rip),%rbx        # 0x73b7260a3930
    73b7260a392b:	jmp    0x73b72500a130
    73b7260a3930:	mov    %rbx,%rcx
    73b7260a3933:	test   $0xf,%ecx
    73b7260a3939:	jne    0x73b7260a3be9
    73b7260a393f:	mov    %rax,%rcx
    73b7260a3942:	and    $0xf,%ecx
    73b7260a3945:	cmp    $0x3,%rcx
    73b7260a3949:	jne    0x73b7260a39c2
    73b7260a394f:	lea    0x10(%r13),%rdx
    73b7260a3953:	mov    (%rdx),%rcx
    73b7260a3956:	add    $0x10,%rcx
    73b7260a395a:	cmp    0x10(%rdx),%rcx
    73b7260a395e:	jle    0x73b7260a397b
    73b7260a3964:	mov    %rbx,(%rsp)
    73b7260a3968:	mov    %rax,0x8(%rsp)
    73b7260a396d:	call   0x73b72610ca00
    73b7260a3972:	mov    (%rsp),%rbx
    73b7260a3976:	mov    0x8(%rsp),%rax
    73b7260a397b:	sar    $0x4,%rbx
    73b7260a397f:	xorps  %xmm0,%xmm0
    73b7260a3982:	cvtsi2sd %rbx,%xmm0
    73b7260a3987:	rex.W movsd 0x5(%rax),%xmm1
    73b7260a398d:	addsd  %xmm1,%xmm0
    73b7260a3991:	lea    0x10(%r13),%rbx
    73b7260a3995:	mov    (%rbx),%rax
    73b7260a3998:	movq   $0xc,(%rax)
    73b7260a399f:	or     $0x3,%rax
    73b7260a39a3:	addq   $0x10,(%rbx)
    73b7260a39a7:	rex.W movsd %xmm0,0x5(%rax)
    73b7260a39ad:	sub    $0x8,%r14
    73b7260a39b1:	mov    %rax,(%r14)
    73b7260a39b4:	mov    %eax,0x13147646(%rip)        # 0x73b7391eb000
    73b7260a39ba:	add    $0xa8,%rsp
    73b7260a39c1:	ret
    73b7260a39c2:	mov    %rax,%rbx
    73b7260a39c5:	and    $0xf,%ebx
    73b7260a39c8:	cmp    $0x5,%rbx
    73b7260a39cc:	jne    0x73b7260a3a09
    73b7260a39d2:	sub    $0x8,%r14
    73b7260a39d6:	add    $0x8,%r15
    73b7260a39da:	mov    %rax,(%r15)
    73b7260a39dd:	call   0x73b7264e1340
    73b7260a39e2:	mov    (%r15),%rax
    73b7260a39e5:	add    $0x8,%r14
    73b7260a39e9:	sub    $0x8,%r15
    73b7260a39ed:	mov    %rax,(%r14)
    73b7260a39f0:	mov    %eax,0x1314760a(%rip)        # 0x73b7391eb000
    73b7260a39f6:	add    $0xa8,%rsp
    73b7260a39fd:	lea    0x5(%rip),%rbx        # 0x73b7260a3a09
    73b7260a3a04:	jmp    0x73b72640f620
    73b7260a3a09:	mov    %rax,%rbx
    73b7260a3a0c:	and    $0xf,%ebx
    73b7260a3a0f:	cmp    $0x7,%rbx
    73b7260a3a13:	jne    0x73b7260a3bd3
    73b7260a3a19:	mov    0x1(%rax),%rbx
    73b7260a3a1d:	mov    0xe(%rbx),%rbx
    73b7260a3a21:	movabs $0x73b72b688fdc,%rcx
    73b7260a3a2b:	cmp    %rcx,%rbx
    73b7260a3a2e:	jne    0x73b7260a3b89
    73b7260a3a34:	mov    0x9(%rax),%rbx
    73b7260a3a38:	mov    0x11(%rax),%rax
    73b7260a3a3c:	add    $0x10,%r15
    73b7260a3a40:	mov    %rax,-0x8(%r15)
    73b7260a3a44:	mov    %rbx,(%r14)
    73b7260a3a47:	movq   $0x0,(%r15)
    73b7260a3a4e:	call   0x73b7260a38d0
    73b7260a3a53:	mov    (%r15),%rbx
    73b7260a3a56:	mov    -0x8(%r15),%rax
    73b7260a3a5a:	add    $0x10,%r14
    73b7260a3a5e:	sub    $0x10,%r15
    73b7260a3a62:	mov    %rbx,-0x8(%r14)
    73b7260a3a66:	mov    %rax,(%r14)
    73b7260a3a69:	call   0x73b7260a38d0
    73b7260a3a6e:	mov    (%r14),%rax
    73b7260a3a71:	add    $0x8,%r14
    73b7260a3a75:	cmp    $0x0,%rax
    73b7260a3a79:	jne    0x73b7260a3a95
    73b7260a3a7f:	sub    $0x8,%r14
    73b7260a3a83:	sub    $0x8,%r14
    73b7260a3a87:	mov    %eax,0x13147573(%rip)        # 0x73b7391eb000
    73b7260a3a8d:	add    $0xa8,%rsp
    73b7260a3a94:	ret
    73b7260a3a95:	mov    %rax,%rbx
    73b7260a3a98:	test   $0xf,%ebx
    73b7260a3a9e:	jne    0x73b7260a3ab4
    73b7260a3aa4:	sub    $0x8,%r14
    73b7260a3aa8:	mov    (%r14),%rax
    73b7260a3aab:	mov    -0x8(%r14),%rbx
    73b7260a3aaf:	jmp    0x73b7260a3b18
    73b7260a3ab4:	mov    %rax,%rbx
    73b7260a3ab7:	and    $0xf,%ebx
    73b7260a3aba:	cmp    $0x5,%rbx
    73b7260a3abe:	jne    0x73b7260a3b0d
    73b7260a3ac4:	movabs $0x73b72b717005,%rbx
    73b7260a3ace:	add    $0x8,%r14
    73b7260a3ad2:	mov    %rax,-0x8(%r14)
    73b7260a3ad6:	mov    %rbx,(%r14)
    73b7260a3ad9:	call   0x73b7264082e0
    73b7260a3ade:	mov    (%r14),%rax
    73b7260a3ae1:	sub    $0x8,%r14
    73b7260a3ae5:	cmp    $0x1,%rax
    73b7260a3ae9:	je     0x73b7260a3b01
    73b7260a3aef:	sub    $0x8,%r14
    73b7260a3af3:	mov    %eax,0x13147507(%rip)        # 0x73b7391eb000
    73b7260a3af9:	add    $0xa8,%rsp
    73b7260a3b00:	ret
    73b7260a3b01:	mov    (%r14),%rax
    73b7260a3b04:	mov    -0x8(%r14),%rbx
    73b7260a3b08:	jmp    0x73b7260a3b18
    73b7260a3b0d:	sub    $0x8,%r14
    73b7260a3b11:	mov    (%r14),%rax
    73b7260a3b14:	mov    -0x8(%r14),%rbx
    73b7260a3b18:	lea    0x10(%r13),%rdx
    73b7260a3b1c:	mov    (%rdx),%rcx
    73b7260a3b1f:	add    $0x20,%rcx
    73b7260a3b23:	cmp    0x10(%rdx),%rcx
    73b7260a3b27:	jle    0x73b7260a3b46
    73b7260a3b2d:	mov    %rbx,0x10(%rsp)
    73b7260a3b32:	mov    %rax,0x18(%rsp)
    73b7260a3b37:	call   0x73b72610ca00
    73b7260a3b3c:	mov    0x10(%rsp),%rbx
    73b7260a3b41:	mov    0x18(%rsp),%rax
    73b7260a3b46:	movabs $0x73b72b688ba2,%rdx
    73b7260a3b50:	lea    0x10(%r13),%rbp
    73b7260a3b54:	mov    0x0(%rbp),%rcx
    73b7260a3b58:	movq   $0x1c,(%rcx)
    73b7260a3b5f:	or     $0x7,%rcx
    73b7260a3b63:	addq   $0x20,0x0(%rbp)
    73b7260a3b68:	mov    %rdx,0x1(%rcx)
    73b7260a3b6c:	mov    %rbx,0x9(%rcx)
    73b7260a3b70:	mov    %rax,0x11(%rcx)
    73b7260a3b74:	sub    $0x8,%r14
    73b7260a3b78:	mov    %rcx,(%r14)
    73b7260a3b7b:	mov    %eax,0x1314747f(%rip)        # 0x73b7391eb000
    73b7260a3b81:	add    $0xa8,%rsp
    73b7260a3b88:	ret
    73b7260a3b89:	mov    0x1(%rax),%rax
    73b7260a3b8d:	mov    0xe(%rax),%rax
    73b7260a3b91:	movabs $0x73b72b67617c,%rbx
    73b7260a3b9b:	cmp    %rbx,%rax
    73b7260a3b9e:	jne    0x73b7260a3bbd
    73b7260a3ba4:	mov    %eax,0x13147456(%rip)        # 0x73b7391eb000
    73b7260a3baa:	add    $0xa8,%rsp
    73b7260a3bb1:	lea    0x5(%rip),%rbx        # 0x73b7260a3bbd
    73b7260a3bb8:	jmp    0x73b726293960
    73b7260a3bbd:	movabs $0x73b72b663d9c,%rax
    73b7260a3bc7:	add    $0x8,%r14
    73b7260a3bcb:	mov    %rax,(%r14)
    73b7260a3bce:	call   0x73b7264dc3d0
    73b7260a3bd3:	movabs $0x73b72b663d9c,%rax
    73b7260a3bdd:	add    $0x8,%r14
    73b7260a3be1:	mov    %rax,(%r14)
    73b7260a3be4:	call   0x73b7264dc3d0
    73b7260a3be9:	mov    %rbx,%rcx
    73b7260a3bec:	and    $0xf,%ecx
    73b7260a3bef:	cmp    $0x3,%rcx
    73b7260a3bf3:	jne    0x73b7260a3fee
    73b7260a3bf9:	mov    %rax,%rcx
    73b7260a3bfc:	test   $0xf,%ecx
    73b7260a3c02:	jne    0x73b7260a3c7b
    73b7260a3c08:	lea    0x10(%r13),%rcx
    73b7260a3c0c:	mov    (%rcx),%rdx
    73b7260a3c0f:	add    $0x10,%rdx
    73b7260a3c13:	cmp    0x10(%rcx),%rdx
    73b7260a3c17:	jle    0x73b7260a3c34
    73b7260a3c1d:	mov    %rbx,(%rsp)
    73b7260a3c21:	mov    %rax,0x8(%rsp)
    73b7260a3c26:	call   0x73b72610ca00
    73b7260a3c2b:	mov    (%rsp),%rbx
    73b7260a3c2f:	mov    0x8(%rsp),%rax
    73b7260a3c34:	sar    $0x4,%rax
    73b7260a3c38:	xorps  %xmm1,%xmm1
    73b7260a3c3b:	cvtsi2sd %rax,%xmm1
    73b7260a3c40:	rex.W movsd 0x5(%rbx),%xmm0
    73b7260a3c46:	addsd  %xmm1,%xmm0
    73b7260a3c4a:	lea    0x10(%r13),%rbx
    73b7260a3c4e:	mov    (%rbx),%rax
    73b7260a3c51:	movq   $0xc,(%rax)
    73b7260a3c58:	or     $0x3,%rax
    73b7260a3c5c:	addq   $0x10,(%rbx)
    73b7260a3c60:	rex.W movsd %xmm0,0x5(%rax)
    73b7260a3c66:	sub    $0x8,%r14
    73b7260a3c6a:	mov    %rax,(%r14)
    73b7260a3c6d:	mov    %eax,0x1314738d(%rip)        # 0x73b7391eb000
    73b7260a3c73:	add    $0xa8,%rsp
    73b7260a3c7a:	ret
    73b7260a3c7b:	mov    %rax,%rcx
    73b7260a3c7e:	and    $0xf,%ecx
    73b7260a3c81:	cmp    $0x3,%rcx
    73b7260a3c85:	jne    0x73b7260a3cf8
    73b7260a3c8b:	lea    0x10(%r13),%rcx
    73b7260a3c8f:	mov    (%rcx),%rdx
    73b7260a3c92:	add    $0x10,%rdx
    73b7260a3c96:	cmp    0x10(%rcx),%rdx
    73b7260a3c9a:	jle    0x73b7260a3cb7
    73b7260a3ca0:	mov    %rbx,(%rsp)
    73b7260a3ca4:	mov    %rax,0x8(%rsp)
    73b7260a3ca9:	call   0x73b72610ca00
    73b7260a3cae:	mov    (%rsp),%rbx
    73b7260a3cb2:	mov    0x8(%rsp),%rax
    73b7260a3cb7:	rex.W movsd 0x5(%rbx),%xmm0
    73b7260a3cbd:	rex.W movsd 0x5(%rax),%xmm1
    73b7260a3cc3:	addsd  %xmm1,%xmm0
    73b7260a3cc7:	lea    0x10(%r13),%rbx
    73b7260a3ccb:	mov    (%rbx),%rax
    73b7260a3cce:	movq   $0xc,(%rax)
    73b7260a3cd5:	or     $0x3,%rax
    73b7260a3cd9:	addq   $0x10,(%rbx)
    73b7260a3cdd:	rex.W movsd %xmm0,0x5(%rax)
    73b7260a3ce3:	sub    $0x8,%r14
    73b7260a3ce7:	mov    %rax,(%r14)
    73b7260a3cea:	mov    %eax,0x13147310(%rip)        # 0x73b7391eb000
    73b7260a3cf0:	add    $0xa8,%rsp
    73b7260a3cf7:	ret
    73b7260a3cf8:	mov    %rax,%rbx
    73b7260a3cfb:	and    $0xf,%ebx
    73b7260a3cfe:	cmp    $0x5,%rbx
    73b7260a3d02:	jne    0x73b7260a3d6f
    73b7260a3d08:	call   0x73b725edb310
    73b7260a3d0d:	lea    0x10(%r13),%rbx
    73b7260a3d11:	mov    (%rbx),%rax
    73b7260a3d14:	add    $0x10,%rax
    73b7260a3d18:	cmp    0x10(%rbx),%rax
    73b7260a3d1c:	jle    0x73b7260a3d27
    73b7260a3d22:	call   0x73b72610ca00
    73b7260a3d27:	mov    (%r14),%rax
    73b7260a3d2a:	mov    -0x8(%r14),%rbx
    73b7260a3d2e:	rex.W movsd 0x5(%rbx),%xmm0
    73b7260a3d34:	rex.W movsd 0x5(%rax),%xmm1
    73b7260a3d3a:	addsd  %xmm1,%xmm0
    73b7260a3d3e:	lea    0x10(%r13),%rbx
    73b7260a3d42:	mov    (%rbx),%rax
    73b7260a3d45:	movq   $0xc,(%rax)
    73b7260a3d4c:	or     $0x3,%rax
    73b7260a3d50:	addq   $0x10,(%rbx)
    73b7260a3d54:	rex.W movsd %xmm0,0x5(%rax)
    73b7260a3d5a:	sub    $0x8,%r14
    73b7260a3d5e:	mov    %rax,(%r14)
    73b7260a3d61:	mov    %eax,0x13147299(%rip)        # 0x73b7391eb000
    73b7260a3d67:	add    $0xa8,%rsp
    73b7260a3d6e:	ret
    73b7260a3d6f:	mov    %rax,%rbx
    73b7260a3d72:	and    $0xf,%ebx
    73b7260a3d75:	cmp    $0x7,%rbx
    73b7260a3d79:	jne    0x73b7260a3fd8
    73b7260a3d7f:	mov    0x1(%rax),%rbx
    73b7260a3d83:	mov    0xe(%rbx),%rbx
    73b7260a3d87:	movabs $0x73b72b688fdc,%rcx
    73b7260a3d91:	cmp    %rcx,%rbx
    73b7260a3d94:	jne    0x73b7260a3f40
    73b7260a3d9a:	mov    0x9(%rax),%rbx
    73b7260a3d9e:	mov    0x11(%rax),%rax
    73b7260a3da2:	add    $0x10,%r15
    73b7260a3da6:	mov    %rax,-0x8(%r15)
    73b7260a3daa:	mov    %rbx,(%r14)
    73b7260a3dad:	movq   $0x0,(%r15)
    73b7260a3db4:	call   0x73b724ee7d20
    73b7260a3db9:	lea    0x10(%r13),%rbx
    73b7260a3dbd:	mov    (%rbx),%rax
    73b7260a3dc0:	add    $0x10,%rax
    73b7260a3dc4:	cmp    0x10(%rbx),%rax
    73b7260a3dc8:	jle    0x73b7260a3dd3
    73b7260a3dce:	call   0x73b72610ca00
    73b7260a3dd3:	mov    (%r14),%rcx
    73b7260a3dd6:	mov    (%r15),%rax
    73b7260a3dd9:	mov    -0x8(%r14),%rdx
    73b7260a3ddd:	mov    -0x8(%r15),%rbx
    73b7260a3de1:	rex.W movsd 0x5(%rdx),%xmm0
    73b7260a3de7:	rex.W movsd 0x5(%rcx),%xmm1
    73b7260a3ded:	addsd  %xmm1,%xmm0
    73b7260a3df1:	lea    0x10(%r13),%rdx
    73b7260a3df5:	mov    (%rdx),%rcx
    73b7260a3df8:	movq   $0xc,(%rcx)
    73b7260a3dff:	or     $0x3,%rcx
    73b7260a3e03:	addq   $0x10,(%rdx)
    73b7260a3e07:	rex.W movsd %xmm0,0x5(%rcx)
    73b7260a3e0d:	add    $0x8,%r14
    73b7260a3e11:	sub    $0x10,%r15
    73b7260a3e15:	mov    %rax,-0x8(%r14)
    73b7260a3e19:	mov    %rbx,(%r14)
    73b7260a3e1c:	mov    %rcx,-0x10(%r14)
    73b7260a3e20:	call   0x73b7260a38d0
    73b7260a3e25:	mov    (%r14),%rax
    73b7260a3e28:	add    $0x8,%r14
    73b7260a3e2c:	cmp    $0x0,%rax
    73b7260a3e30:	jne    0x73b7260a3e4c
    73b7260a3e36:	sub    $0x8,%r14
    73b7260a3e3a:	sub    $0x8,%r14
    73b7260a3e3e:	mov    %eax,0x131471bc(%rip)        # 0x73b7391eb000
    73b7260a3e44:	add    $0xa8,%rsp
    73b7260a3e4b:	ret
    73b7260a3e4c:	mov    %rax,%rbx
    73b7260a3e4f:	test   $0xf,%ebx
    73b7260a3e55:	jne    0x73b7260a3e6b
    73b7260a3e5b:	sub    $0x8,%r14
    73b7260a3e5f:	mov    (%r14),%rax
    73b7260a3e62:	mov    -0x8(%r14),%rbx
    73b7260a3e66:	jmp    0x73b7260a3ecf
    73b7260a3e6b:	mov    %rax,%rbx
    73b7260a3e6e:	and    $0xf,%ebx
    73b7260a3e71:	cmp    $0x5,%rbx
    73b7260a3e75:	jne    0x73b7260a3ec4
    73b7260a3e7b:	movabs $0x73b72b717005,%rbx
    73b7260a3e85:	add    $0x8,%r14
    73b7260a3e89:	mov    %rax,-0x8(%r14)
    73b7260a3e8d:	mov    %rbx,(%r14)
    73b7260a3e90:	call   0x73b7264082e0
    73b7260a3e95:	mov    (%r14),%rax
    73b7260a3e98:	sub    $0x8,%r14
    73b7260a3e9c:	cmp    $0x1,%rax
    73b7260a3ea0:	je     0x73b7260a3eb8
    73b7260a3ea6:	sub    $0x8,%r14
    73b7260a3eaa:	mov    %eax,0x13147150(%rip)        # 0x73b7391eb000
    73b7260a3eb0:	add    $0xa8,%rsp
    73b7260a3eb7:	ret
    73b7260a3eb8:	mov    (%r14),%rax
    73b7260a3ebb:	mov    -0x8(%r14),%rbx
    73b7260a3ebf:	jmp    0x73b7260a3ecf
    73b7260a3ec4:	sub    $0x8,%r14
    73b7260a3ec8:	mov    (%r14),%rax
    73b7260a3ecb:	mov    -0x8(%r14),%rbx
    73b7260a3ecf:	lea    0x10(%r13),%rcx
    73b7260a3ed3:	mov    (%rcx),%rdx
    73b7260a3ed6:	add    $0x20,%rdx
    73b7260a3eda:	cmp    0x10(%rcx),%rdx
    73b7260a3ede:	jle    0x73b7260a3efd
    73b7260a3ee4:	mov    %rbx,0x20(%rsp)
    73b7260a3ee9:	mov    %rax,0x28(%rsp)
    73b7260a3eee:	call   0x73b72610ca00
    73b7260a3ef3:	mov    0x20(%rsp),%rbx
    73b7260a3ef8:	mov    0x28(%rsp),%rax
    73b7260a3efd:	movabs $0x73b72b688ba2,%rdx
    73b7260a3f07:	lea    0x10(%r13),%rbp
    73b7260a3f0b:	mov    0x0(%rbp),%rcx
    73b7260a3f0f:	movq   $0x1c,(%rcx)
    73b7260a3f16:	or     $0x7,%rcx
    73b7260a3f1a:	addq   $0x20,0x0(%rbp)
    73b7260a3f1f:	mov    %rdx,0x1(%rcx)
    73b7260a3f23:	mov    %rbx,0x9(%rcx)
    73b7260a3f27:	mov    %rax,0x11(%rcx)
    73b7260a3f2b:	sub    $0x8,%r14
    73b7260a3f2f:	mov    %rcx,(%r14)
    73b7260a3f32:	mov    %eax,0x131470c8(%rip)        # 0x73b7391eb000
    73b7260a3f38:	add    $0xa8,%rsp
    73b7260a3f3f:	ret
    73b7260a3f40:	mov    0x1(%rax),%rax
    73b7260a3f44:	mov    0xe(%rax),%rax
    73b7260a3f48:	movabs $0x73b72b67617c,%rbx
    73b7260a3f52:	cmp    %rbx,%rax
    73b7260a3f55:	jne    0x73b7260a3fc2
    73b7260a3f5b:	call   0x73b725e2da60
    73b7260a3f60:	lea    0x10(%r13),%rbx
    73b7260a3f64:	mov    (%rbx),%rax
    73b7260a3f67:	add    $0x10,%rax
    73b7260a3f6b:	cmp    0x10(%rbx),%rax
    73b7260a3f6f:	jle    0x73b7260a3f7a
    73b7260a3f75:	call   0x73b72610ca00
    73b7260a3f7a:	mov    (%r14),%rax
    73b7260a3f7d:	mov    -0x8(%r14),%rbx
    73b7260a3f81:	rex.W movsd 0x5(%rbx),%xmm0
    73b7260a3f87:	rex.W movsd 0x5(%rax),%xmm1
    73b7260a3f8d:	addsd  %xmm1,%xmm0
    73b7260a3f91:	lea    0x10(%r13),%rbx
    73b7260a3f95:	mov    (%rbx),%rax
    73b7260a3f98:	movq   $0xc,(%rax)
    73b7260a3f9f:	or     $0x3,%rax
    73b7260a3fa3:	addq   $0x10,(%rbx)
    73b7260a3fa7:	rex.W movsd %xmm0,0x5(%rax)
    73b7260a3fad:	sub    $0x8,%r14
    73b7260a3fb1:	mov    %rax,(%r14)
    73b7260a3fb4:	mov    %eax,0x13147046(%rip)        # 0x73b7391eb000
    73b7260a3fba:	add    $0xa8,%rsp
    73b7260a3fc1:	ret
    73b7260a3fc2:	movabs $0x73b72b663d9c,%rax
    73b7260a3fcc:	add    $0x8,%r14
    73b7260a3fd0:	mov    %rax,(%r14)
    73b7260a3fd3:	call   0x73b7264dc3d0
    73b7260a3fd8:	movabs $0x73b72b663d9c,%rax
    73b7260a3fe2:	add    $0x8,%r14
    73b7260a3fe6:	mov    %rax,(%r14)
    73b7260a3fe9:	call   0x73b7264dc3d0
    73b7260a3fee:	mov    %rbx,%rcx
    73b7260a3ff1:	and    $0xf,%ecx
    73b7260a3ff4:	cmp    $0x5,%rcx
    73b7260a3ff8:	jne    0x73b7260a42b5
    73b7260a3ffe:	mov    %rax,%rbx
    73b7260a4001:	test   $0xf,%ebx
    73b7260a4007:	jne    0x73b7260a402b
    73b7260a400d:	call   0x73b7264e1340
    73b7260a4012:	mov    %eax,0x13146fe8(%rip)        # 0x73b7391eb000
    73b7260a4018:	add    $0xa8,%rsp
    73b7260a401f:	lea    0x5(%rip),%rbx        # 0x73b7260a402b
    73b7260a4026:	jmp    0x73b72640f620
    73b7260a402b:	mov    %rax,%rbx
    73b7260a402e:	and    $0xf,%ebx
    73b7260a4031:	cmp    $0x3,%rbx
    73b7260a4035:	jne    0x73b7260a40ac
    73b7260a403b:	sub    $0x8,%r14
    73b7260a403f:	add    $0x8,%r15
    73b7260a4043:	mov    %rax,(%r15)
    73b7260a4046:	call   0x73b725edb310
    73b7260a404b:	lea    0x10(%r13),%rax
    73b7260a404f:	mov    (%rax),%rbx
    73b7260a4052:	add    $0x10,%rbx
    73b7260a4056:	cmp    0x10(%rax),%rbx
    73b7260a405a:	jle    0x73b7260a4065
    73b7260a4060:	call   0x73b72610ca00
    73b7260a4065:	mov    (%r15),%rax
    73b7260a4068:	mov    (%r14),%rbx
    73b7260a406b:	rex.W movsd 0x5(%rbx),%xmm0
    73b7260a4071:	rex.W movsd 0x5(%rax),%xmm1
    73b7260a4077:	addsd  %xmm1,%xmm0
    73b7260a407b:	lea    0x10(%r13),%rbx
    73b7260a407f:	mov    (%rbx),%rax
    73b7260a4082:	movq   $0xc,(%rax)
    73b7260a4089:	or     $0x3,%rax
    73b7260a408d:	addq   $0x10,(%rbx)
    73b7260a4091:	rex.W movsd %xmm0,0x5(%rax)
    73b7260a4097:	sub    $0x8,%r15
    73b7260a409b:	mov    %rax,(%r14)
    73b7260a409e:	mov    %eax,0x13146f5c(%rip)        # 0x73b7391eb000
    73b7260a40a4:	add    $0xa8,%rsp
    73b7260a40ab:	ret
    73b7260a40ac:	mov    %rax,%rbx
    73b7260a40af:	and    $0xf,%ebx
    73b7260a40b2:	cmp    $0x5,%rbx
    73b7260a40b6:	jne    0x73b7260a40d5
    73b7260a40bc:	mov    %eax,0x13146f3e(%rip)        # 0x73b7391eb000
    73b7260a40c2:	add    $0xa8,%rsp
    73b7260a40c9:	lea    0x5(%rip),%rbx        # 0x73b7260a40d5
    73b7260a40d0:	jmp    0x73b72640f620
    73b7260a40d5:	mov    %rax,%rbx
    73b7260a40d8:	and    $0xf,%ebx
    73b7260a40db:	cmp    $0x7,%rbx
    73b7260a40df:	jne    0x73b7260a429f
    73b7260a40e5:	mov    0x1(%rax),%rbx
    73b7260a40e9:	mov    0xe(%rbx),%rbx
    73b7260a40ed:	movabs $0x73b72b688fdc,%rcx
    73b7260a40f7:	cmp    %rcx,%rbx
    73b7260a40fa:	jne    0x73b7260a4255
    73b7260a4100:	mov    0x9(%rax),%rbx
    73b7260a4104:	mov    0x11(%rax),%rax
    73b7260a4108:	add    $0x10,%r15
    73b7260a410c:	mov    %rax,-0x8(%r15)
    73b7260a4110:	mov    %rbx,(%r14)
    73b7260a4113:	movq   $0x0,(%r15)
    73b7260a411a:	call   0x73b7260a38d0
    73b7260a411f:	mov    (%r15),%rbx
    73b7260a4122:	mov    -0x8(%r15),%rax
    73b7260a4126:	add    $0x10,%r14
    73b7260a412a:	sub    $0x10,%r15
    73b7260a412e:	mov    %rbx,-0x8(%r14)
    73b7260a4132:	mov    %rax,(%r14)
    73b7260a4135:	call   0x73b7260a38d0
    73b7260a413a:	mov    (%r14),%rax
    73b7260a413d:	add    $0x8,%r14
    73b7260a4141:	cmp    $0x0,%rax
    73b7260a4145:	jne    0x73b7260a4161
    73b7260a414b:	sub    $0x8,%r14
    73b7260a414f:	sub    $0x8,%r14
    73b7260a4153:	mov    %eax,0x13146ea7(%rip)        # 0x73b7391eb000
    73b7260a4159:	add    $0xa8,%rsp
    73b7260a4160:	ret
    73b7260a4161:	mov    %rax,%rbx
    73b7260a4164:	test   $0xf,%ebx
    73b7260a416a:	jne    0x73b7260a4180
    73b7260a4170:	sub    $0x8,%r14
    73b7260a4174:	mov    (%r14),%rax
    73b7260a4177:	mov    -0x8(%r14),%rbx
    73b7260a417b:	jmp    0x73b7260a41e4
    73b7260a4180:	mov    %rax,%rbx
    73b7260a4183:	and    $0xf,%ebx
    73b7260a4186:	cmp    $0x5,%rbx
    73b7260a418a:	jne    0x73b7260a41d9
    73b7260a4190:	movabs $0x73b72b717005,%rbx
    73b7260a419a:	add    $0x8,%r14
    73b7260a419e:	mov    %rax,-0x8(%r14)
    73b7260a41a2:	mov    %rbx,(%r14)
    73b7260a41a5:	call   0x73b7264082e0
    73b7260a41aa:	mov    (%r14),%rax
    73b7260a41ad:	sub    $0x8,%r14
    73b7260a41b1:	cmp    $0x1,%rax
    73b7260a41b5:	je     0x73b7260a41cd
    73b7260a41bb:	sub    $0x8,%r14
    73b7260a41bf:	mov    %eax,0x13146e3b(%rip)        # 0x73b7391eb000
    73b7260a41c5:	add    $0xa8,%rsp
    73b7260a41cc:	ret
    73b7260a41cd:	mov    (%r14),%rax
    73b7260a41d0:	mov    -0x8(%r14),%rbx
    73b7260a41d4:	jmp    0x73b7260a41e4
    73b7260a41d9:	sub    $0x8,%r14
    73b7260a41dd:	mov    (%r14),%rax
    73b7260a41e0:	mov    -0x8(%r14),%rbx
    73b7260a41e4:	lea    0x10(%r13),%rcx
    73b7260a41e8:	mov    (%rcx),%rdx
    73b7260a41eb:	add    $0x20,%rdx
    73b7260a41ef:	cmp    0x10(%rcx),%rdx
    73b7260a41f3:	jle    0x73b7260a4212
    73b7260a41f9:	mov    %rbx,0x30(%rsp)
    73b7260a41fe:	mov    %rax,0x38(%rsp)
    73b7260a4203:	call   0x73b72610ca00
    73b7260a4208:	mov    0x30(%rsp),%rbx
    73b7260a420d:	mov    0x38(%rsp),%rax
    73b7260a4212:	movabs $0x73b72b688ba2,%rdx
    73b7260a421c:	lea    0x10(%r13),%rbp
    73b7260a4220:	mov    0x0(%rbp),%rcx
    73b7260a4224:	movq   $0x1c,(%rcx)
    73b7260a422b:	or     $0x7,%rcx
    73b7260a422f:	addq   $0x20,0x0(%rbp)
    73b7260a4234:	mov    %rdx,0x1(%rcx)
    73b7260a4238:	mov    %rbx,0x9(%rcx)
    73b7260a423c:	mov    %rax,0x11(%rcx)
    73b7260a4240:	sub    $0x8,%r14
    73b7260a4244:	mov    %rcx,(%r14)
    73b7260a4247:	mov    %eax,0x13146db3(%rip)        # 0x73b7391eb000
    73b7260a424d:	add    $0xa8,%rsp
    73b7260a4254:	ret
    73b7260a4255:	mov    0x1(%rax),%rax
    73b7260a4259:	mov    0xe(%rax),%rax
    73b7260a425d:	movabs $0x73b72b67617c,%rbx
    73b7260a4267:	cmp    %rbx,%rax
    73b7260a426a:	jne    0x73b7260a4289
    73b7260a4270:	mov    %eax,0x13146d8a(%rip)        # 0x73b7391eb000
    73b7260a4276:	add    $0xa8,%rsp
    73b7260a427d:	lea    0x5(%rip),%rbx        # 0x73b7260a4289
    73b7260a4284:	jmp    0x73b726293960
    73b7260a4289:	movabs $0x73b72b663d9c,%rax
    73b7260a4293:	add    $0x8,%r14
    73b7260a4297:	mov    %rax,(%r14)
    73b7260a429a:	call   0x73b7264dc3d0
    73b7260a429f:	movabs $0x73b72b663d9c,%rax
    73b7260a42a9:	add    $0x8,%r14
    73b7260a42ad:	mov    %rax,(%r14)
    73b7260a42b0:	call   0x73b7264dc3d0
    73b7260a42b5:	mov    %rbx,%rcx
    73b7260a42b8:	and    $0xf,%ecx
    73b7260a42bb:	cmp    $0x7,%rcx
    73b7260a42bf:	jne    0x73b7260a4d69
    73b7260a42c5:	mov    0x1(%rbx),%rcx
    73b7260a42c9:	mov    0xe(%rcx),%rcx
    73b7260a42cd:	movabs $0x73b72b688fdc,%rdx
    73b7260a42d7:	cmp    %rdx,%rcx
    73b7260a42da:	jne    0x73b7260a4a7a
    73b7260a42e0:	mov    %rax,%rcx
    73b7260a42e3:	test   $0xf,%ecx
    73b7260a42e9:	jne    0x73b7260a443d
    73b7260a42ef:	mov    0x9(%rbx),%rax
    73b7260a42f3:	mov    0x11(%rbx),%rbx
    73b7260a42f7:	add    $0x8,%r15
    73b7260a42fb:	mov    %rbx,(%r15)
    73b7260a42fe:	mov    %rax,-0x8(%r14)
    73b7260a4302:	call   0x73b7260a38d0
    73b7260a4307:	mov    (%r15),%rax
    73b7260a430a:	add    $0x10,%r14
    73b7260a430e:	sub    $0x8,%r15
    73b7260a4312:	mov    %rax,-0x8(%r14)
    73b7260a4316:	movq   $0x0,(%r14)
    73b7260a431d:	call   0x73b7260a38d0
    73b7260a4322:	mov    (%r14),%rax
    73b7260a4325:	add    $0x8,%r14
    73b7260a4329:	cmp    $0x0,%rax
    73b7260a432d:	jne    0x73b7260a4349
    73b7260a4333:	sub    $0x8,%r14
    73b7260a4337:	sub    $0x8,%r14
    73b7260a433b:	mov    %eax,0x13146cbf(%rip)        # 0x73b7391eb000
    73b7260a4341:	add    $0xa8,%rsp
    73b7260a4348:	ret
    73b7260a4349:	mov    %rax,%rbx
    73b7260a434c:	test   $0xf,%ebx
    73b7260a4352:	jne    0x73b7260a4368
    73b7260a4358:	sub    $0x8,%r14
    73b7260a435c:	mov    (%r14),%rax
    73b7260a435f:	mov    -0x8(%r14),%rbx
    73b7260a4363:	jmp    0x73b7260a43cc
    73b7260a4368:	mov    %rax,%rbx
    73b7260a436b:	and    $0xf,%ebx
    73b7260a436e:	cmp    $0x5,%rbx
    73b7260a4372:	jne    0x73b7260a43c1
    73b7260a4378:	movabs $0x73b72b717005,%rbx
    73b7260a4382:	add    $0x8,%r14
    73b7260a4386:	mov    %rax,-0x8(%r14)
    73b7260a438a:	mov    %rbx,(%r14)
    73b7260a438d:	call   0x73b7264082e0
    73b7260a4392:	mov    (%r14),%rax
    73b7260a4395:	sub    $0x8,%r14
    73b7260a4399:	cmp    $0x1,%rax
    73b7260a439d:	je     0x73b7260a43b5
    73b7260a43a3:	sub    $0x8,%r14
    73b7260a43a7:	mov    %eax,0x13146c53(%rip)        # 0x73b7391eb000
    73b7260a43ad:	add    $0xa8,%rsp
    73b7260a43b4:	ret
    73b7260a43b5:	mov    (%r14),%rax
    73b7260a43b8:	mov    -0x8(%r14),%rbx
    73b7260a43bc:	jmp    0x73b7260a43cc
    73b7260a43c1:	sub    $0x8,%r14
    73b7260a43c5:	mov    (%r14),%rax
    73b7260a43c8:	mov    -0x8(%r14),%rbx
    73b7260a43cc:	lea    0x10(%r13),%rcx
    73b7260a43d0:	mov    (%rcx),%rdx
    73b7260a43d3:	add    $0x20,%rdx
    73b7260a43d7:	cmp    0x10(%rcx),%rdx
    73b7260a43db:	jle    0x73b7260a43fa
    73b7260a43e1:	mov    %rbx,0x40(%rsp)
    73b7260a43e6:	mov    %rax,0x48(%rsp)
    73b7260a43eb:	call   0x73b72610ca00
    73b7260a43f0:	mov    0x40(%rsp),%rbx
    73b7260a43f5:	mov    0x48(%rsp),%rax
    73b7260a43fa:	movabs $0x73b72b688ba2,%rdx
    73b7260a4404:	lea    0x10(%r13),%rbp
    73b7260a4408:	mov    0x0(%rbp),%rcx
    73b7260a440c:	movq   $0x1c,(%rcx)
    73b7260a4413:	or     $0x7,%rcx
    73b7260a4417:	addq   $0x20,0x0(%rbp)
    73b7260a441c:	mov    %rdx,0x1(%rcx)
    73b7260a4420:	mov    %rbx,0x9(%rcx)
    73b7260a4424:	mov    %rax,0x11(%rcx)
    73b7260a4428:	sub    $0x8,%r14
    73b7260a442c:	mov    %rcx,(%r14)
    73b7260a442f:	mov    %eax,0x13146bcb(%rip)        # 0x73b7391eb000
    73b7260a4435:	add    $0xa8,%rsp
    73b7260a443c:	ret
    73b7260a443d:	mov    %rax,%rcx
    73b7260a4440:	and    $0xf,%ecx
    73b7260a4443:	cmp    $0x3,%rcx
    73b7260a4447:	jne    0x73b7260a45f3
    73b7260a444d:	mov    0x9(%rbx),%rcx
    73b7260a4451:	mov    0x11(%rbx),%rbx
    73b7260a4455:	sub    $0x8,%r14
    73b7260a4459:	add    $0x10,%r15
    73b7260a445d:	mov    %rax,(%r15)
    73b7260a4460:	mov    %rbx,-0x8(%r15)
    73b7260a4464:	mov    %rcx,(%r14)
    73b7260a4467:	call   0x73b724ee7d20
    73b7260a446c:	lea    0x10(%r13),%rbx
    73b7260a4470:	mov    (%rbx),%rax
    73b7260a4473:	add    $0x10,%rax
    73b7260a4477:	cmp    0x10(%rbx),%rax
    73b7260a447b:	jle    0x73b7260a4486
    73b7260a4481:	call   0x73b72610ca00
    73b7260a4486:	mov    (%r15),%rbx
    73b7260a4489:	mov    (%r14),%rcx
    73b7260a448c:	mov    -0x8(%r15),%rax
    73b7260a4490:	rex.W movsd 0x5(%rcx),%xmm0
    73b7260a4496:	rex.W movsd 0x5(%rbx),%xmm1
    73b7260a449c:	addsd  %xmm1,%xmm0
    73b7260a44a0:	lea    0x10(%r13),%rcx
    73b7260a44a4:	mov    (%rcx),%rbx
    73b7260a44a7:	movq   $0xc,(%rbx)
    73b7260a44ae:	or     $0x3,%rbx
    73b7260a44b2:	addq   $0x10,(%rcx)
    73b7260a44b6:	rex.W movsd %xmm0,0x5(%rbx)
    73b7260a44bc:	add    $0x10,%r14
    73b7260a44c0:	sub    $0x10,%r15
    73b7260a44c4:	mov    %rax,-0x8(%r14)
    73b7260a44c8:	movq   $0x0,(%r14)
    73b7260a44cf:	mov    %rbx,-0x10(%r14)
    73b7260a44d3:	call   0x73b7260a38d0
    73b7260a44d8:	mov    (%r14),%rax
    73b7260a44db:	add    $0x8,%r14
    73b7260a44df:	cmp    $0x0,%rax
    73b7260a44e3:	jne    0x73b7260a44ff
    73b7260a44e9:	sub    $0x8,%r14
    73b7260a44ed:	sub    $0x8,%r14
    73b7260a44f1:	mov    %eax,0x13146b09(%rip)        # 0x73b7391eb000
    73b7260a44f7:	add    $0xa8,%rsp
    73b7260a44fe:	ret
    73b7260a44ff:	mov    %rax,%rbx
    73b7260a4502:	test   $0xf,%ebx
    73b7260a4508:	jne    0x73b7260a451e
    73b7260a450e:	sub    $0x8,%r14
    73b7260a4512:	mov    (%r14),%rax
    73b7260a4515:	mov    -0x8(%r14),%rbx
    73b7260a4519:	jmp    0x73b7260a4582
    73b7260a451e:	mov    %rax,%rbx
    73b7260a4521:	and    $0xf,%ebx
    73b7260a4524:	cmp    $0x5,%rbx
    73b7260a4528:	jne    0x73b7260a4577
    73b7260a452e:	movabs $0x73b72b717005,%rbx
    73b7260a4538:	add    $0x8,%r14
    73b7260a453c:	mov    %rax,-0x8(%r14)
    73b7260a4540:	mov    %rbx,(%r14)
    73b7260a4543:	call   0x73b7264082e0
    73b7260a4548:	mov    (%r14),%rax
    73b7260a454b:	sub    $0x8,%r14
    73b7260a454f:	cmp    $0x1,%rax
    73b7260a4553:	je     0x73b7260a456b
    73b7260a4559:	sub    $0x8,%r14
    73b7260a455d:	mov    %eax,0x13146a9d(%rip)        # 0x73b7391eb000
    73b7260a4563:	add    $0xa8,%rsp
    73b7260a456a:	ret
    73b7260a456b:	mov    (%r14),%rax
    73b7260a456e:	mov    -0x8(%r14),%rbx
    73b7260a4572:	jmp    0x73b7260a4582
    73b7260a4577:	sub    $0x8,%r14
    73b7260a457b:	mov    (%r14),%rax
    73b7260a457e:	mov    -0x8(%r14),%rbx
    73b7260a4582:	lea    0x10(%r13),%rcx
    73b7260a4586:	mov    (%rcx),%rdx
    73b7260a4589:	add    $0x20,%rdx
    73b7260a458d:	cmp    0x10(%rcx),%rdx
    73b7260a4591:	jle    0x73b7260a45b0
    73b7260a4597:	mov    %rbx,0x50(%rsp)
    73b7260a459c:	mov    %rax,0x58(%rsp)
    73b7260a45a1:	call   0x73b72610ca00
    73b7260a45a6:	mov    0x50(%rsp),%rbx
    73b7260a45ab:	mov    0x58(%rsp),%rax
    73b7260a45b0:	movabs $0x73b72b688ba2,%rdx
    73b7260a45ba:	lea    0x10(%r13),%rbp
    73b7260a45be:	mov    0x0(%rbp),%rcx
    73b7260a45c2:	movq   $0x1c,(%rcx)
    73b7260a45c9:	or     $0x7,%rcx
    73b7260a45cd:	addq   $0x20,0x0(%rbp)
    73b7260a45d2:	mov    %rdx,0x1(%rcx)
    73b7260a45d6:	mov    %rbx,0x9(%rcx)
    73b7260a45da:	mov    %rax,0x11(%rcx)
    73b7260a45de:	sub    $0x8,%r14
    73b7260a45e2:	mov    %rcx,(%r14)
    73b7260a45e5:	mov    %eax,0x13146a15(%rip)        # 0x73b7391eb000
    73b7260a45eb:	add    $0xa8,%rsp
    73b7260a45f2:	ret
    73b7260a45f3:	mov    %rax,%rcx
    73b7260a45f6:	and    $0xf,%ecx
    73b7260a45f9:	cmp    $0x5,%rcx
    73b7260a45fd:	jne    0x73b7260a4751
    73b7260a4603:	mov    0x9(%rbx),%rax
    73b7260a4607:	mov    0x11(%rbx),%rbx
    73b7260a460b:	add    $0x8,%r15
    73b7260a460f:	mov    %rbx,(%r15)
    73b7260a4612:	mov    %rax,-0x8(%r14)
    73b7260a4616:	call   0x73b7260a38d0
    73b7260a461b:	mov    (%r15),%rax
    73b7260a461e:	add    $0x10,%r14
    73b7260a4622:	sub    $0x8,%r15
    73b7260a4626:	mov    %rax,-0x8(%r14)
    73b7260a462a:	movq   $0x0,(%r14)
    73b7260a4631:	call   0x73b7260a38d0
    73b7260a4636:	mov    (%r14),%rax
    73b7260a4639:	add    $0x8,%r14
    73b7260a463d:	cmp    $0x0,%rax
    73b7260a4641:	jne    0x73b7260a465d
    73b7260a4647:	sub    $0x8,%r14
    73b7260a464b:	sub    $0x8,%r14
    73b7260a464f:	mov    %eax,0x131469ab(%rip)        # 0x73b7391eb000
    73b7260a4655:	add    $0xa8,%rsp
    73b7260a465c:	ret
    73b7260a465d:	mov    %rax,%rbx
    73b7260a4660:	test   $0xf,%ebx
    73b7260a4666:	jne    0x73b7260a467c
    73b7260a466c:	sub    $0x8,%r14
    73b7260a4670:	mov    (%r14),%rax
    73b7260a4673:	mov    -0x8(%r14),%rbx
    73b7260a4677:	jmp    0x73b7260a46e0
    73b7260a467c:	mov    %rax,%rbx
    73b7260a467f:	and    $0xf,%ebx
    73b7260a4682:	cmp    $0x5,%rbx
    73b7260a4686:	jne    0x73b7260a46d5
    73b7260a468c:	movabs $0x73b72b717005,%rbx
    73b7260a4696:	add    $0x8,%r14
    73b7260a469a:	mov    %rax,-0x8(%r14)
    73b7260a469e:	mov    %rbx,(%r14)
    73b7260a46a1:	call   0x73b7264082e0
    73b7260a46a6:	mov    (%r14),%rax
    73b7260a46a9:	sub    $0x8,%r14
    73b7260a46ad:	cmp    $0x1,%rax
    73b7260a46b1:	je     0x73b7260a46c9
    73b7260a46b7:	sub    $0x8,%r14
    73b7260a46bb:	mov    %eax,0x1314693f(%rip)        # 0x73b7391eb000
    73b7260a46c1:	add    $0xa8,%rsp
    73b7260a46c8:	ret
    73b7260a46c9:	mov    (%r14),%rax
    73b7260a46cc:	mov    -0x8(%r14),%rbx
    73b7260a46d0:	jmp    0x73b7260a46e0
    73b7260a46d5:	sub    $0x8,%r14
    73b7260a46d9:	mov    (%r14),%rax
    73b7260a46dc:	mov    -0x8(%r14),%rbx
    73b7260a46e0:	lea    0x10(%r13),%rdx
    73b7260a46e4:	mov    (%rdx),%rcx
    73b7260a46e7:	add    $0x20,%rcx
    73b7260a46eb:	cmp    0x10(%rdx),%rcx
    73b7260a46ef:	jle    0x73b7260a470e
    73b7260a46f5:	mov    %rbx,0x60(%rsp)
    73b7260a46fa:	mov    %rax,0x68(%rsp)
    73b7260a46ff:	call   0x73b72610ca00
    73b7260a4704:	mov    0x60(%rsp),%rbx
    73b7260a4709:	mov    0x68(%rsp),%rax
    73b7260a470e:	movabs $0x73b72b688ba2,%rdx
    73b7260a4718:	lea    0x10(%r13),%rbp
    73b7260a471c:	mov    0x0(%rbp),%rcx
    73b7260a4720:	movq   $0x1c,(%rcx)
    73b7260a4727:	or     $0x7,%rcx
    73b7260a472b:	addq   $0x20,0x0(%rbp)
    73b7260a4730:	mov    %rdx,0x1(%rcx)
    73b7260a4734:	mov    %rbx,0x9(%rcx)
    73b7260a4738:	mov    %rax,0x11(%rcx)
    73b7260a473c:	sub    $0x8,%r14
    73b7260a4740:	mov    %rcx,(%r14)
    73b7260a4743:	mov    %eax,0x131468b7(%rip)        # 0x73b7391eb000
    73b7260a4749:	add    $0xa8,%rsp
    73b7260a4750:	ret
    73b7260a4751:	mov    %rax,%rcx
    73b7260a4754:	and    $0xf,%ecx
    73b7260a4757:	cmp    $0x7,%rcx
    73b7260a475b:	jne    0x73b7260a4a64
    73b7260a4761:	mov    0x1(%rax),%rcx
    73b7260a4765:	mov    0xe(%rcx),%rcx
    73b7260a4769:	movabs $0x73b72b688fdc,%rdx
    73b7260a4773:	cmp    %rdx,%rcx
    73b7260a4776:	jne    0x73b7260a48d9
    73b7260a477c:	mov    0x9(%rbx),%rcx
    73b7260a4780:	mov    0x11(%rbx),%rbx
    73b7260a4784:	mov    0x9(%rax),%rdx
    73b7260a4788:	mov    0x11(%rax),%rax
    73b7260a478c:	add    $0x10,%r15
    73b7260a4790:	mov    %rax,-0x8(%r15)
    73b7260a4794:	mov    %rcx,-0x8(%r14)
    73b7260a4798:	mov    %rdx,(%r14)
    73b7260a479b:	mov    %rbx,(%r15)
    73b7260a479e:	call   0x73b7260a38d0
    73b7260a47a3:	mov    (%r15),%rax
    73b7260a47a6:	mov    -0x8(%r15),%rbx
    73b7260a47aa:	add    $0x10,%r14
    73b7260a47ae:	sub    $0x10,%r15
    73b7260a47b2:	mov    %rax,-0x8(%r14)
    73b7260a47b6:	mov    %rbx,(%r14)
    73b7260a47b9:	call   0x73b7260a38d0
    73b7260a47be:	mov    (%r14),%rax
    73b7260a47c1:	add    $0x8,%r14
    73b7260a47c5:	cmp    $0x0,%rax
    73b7260a47c9:	jne    0x73b7260a47e5
    73b7260a47cf:	sub    $0x8,%r14
    73b7260a47d3:	sub    $0x8,%r14
    73b7260a47d7:	mov    %eax,0x13146823(%rip)        # 0x73b7391eb000
    73b7260a47dd:	add    $0xa8,%rsp
    73b7260a47e4:	ret
    73b7260a47e5:	mov    %rax,%rbx
    73b7260a47e8:	test   $0xf,%ebx
    73b7260a47ee:	jne    0x73b7260a4804
    73b7260a47f4:	sub    $0x8,%r14
    73b7260a47f8:	mov    (%r14),%rax
    73b7260a47fb:	mov    -0x8(%r14),%rbx
    73b7260a47ff:	jmp    0x73b7260a4868
    73b7260a4804:	mov    %rax,%rbx
    73b7260a4807:	and    $0xf,%ebx
    73b7260a480a:	cmp    $0x5,%rbx
    73b7260a480e:	jne    0x73b7260a485d
    73b7260a4814:	movabs $0x73b72b717005,%rbx
    73b7260a481e:	add    $0x8,%r14
    73b7260a4822:	mov    %rax,-0x8(%r14)
    73b7260a4826:	mov    %rbx,(%r14)
    73b7260a4829:	call   0x73b7264082e0
    73b7260a482e:	mov    (%r14),%rax
    73b7260a4831:	sub    $0x8,%r14
    73b7260a4835:	cmp    $0x1,%rax
    73b7260a4839:	je     0x73b7260a4851
    73b7260a483f:	sub    $0x8,%r14
    73b7260a4843:	mov    %eax,0x131467b7(%rip)        # 0x73b7391eb000
    73b7260a4849:	add    $0xa8,%rsp
    73b7260a4850:	ret
    73b7260a4851:	mov    (%r14),%rax
    73b7260a4854:	mov    -0x8(%r14),%rbx
    73b7260a4858:	jmp    0x73b7260a4868
    73b7260a485d:	sub    $0x8,%r14
    73b7260a4861:	mov    (%r14),%rax
    73b7260a4864:	mov    -0x8(%r14),%rbx
    73b7260a4868:	lea    0x10(%r13),%rcx
    73b7260a486c:	mov    (%rcx),%rdx
    73b7260a486f:	add    $0x20,%rdx
    73b7260a4873:	cmp    0x10(%rcx),%rdx
    73b7260a4877:	jle    0x73b7260a4896
    73b7260a487d:	mov    %rbx,0x70(%rsp)
    73b7260a4882:	mov    %rax,0x78(%rsp)
    73b7260a4887:	call   0x73b72610ca00
    73b7260a488c:	mov    0x70(%rsp),%rbx
    73b7260a4891:	mov    0x78(%rsp),%rax
    73b7260a4896:	movabs $0x73b72b688ba2,%rdx
    73b7260a48a0:	lea    0x10(%r13),%rbp
    73b7260a48a4:	mov    0x0(%rbp),%rcx
    73b7260a48a8:	movq   $0x1c,(%rcx)
    73b7260a48af:	or     $0x7,%rcx
    73b7260a48b3:	addq   $0x20,0x0(%rbp)
    73b7260a48b8:	mov    %rdx,0x1(%rcx)
    73b7260a48bc:	mov    %rbx,0x9(%rcx)
    73b7260a48c0:	mov    %rax,0x11(%rcx)
    73b7260a48c4:	sub    $0x8,%r14
    73b7260a48c8:	mov    %rcx,(%r14)
    73b7260a48cb:	mov    %eax,0x1314672f(%rip)        # 0x73b7391eb000
    73b7260a48d1:	add    $0xa8,%rsp
    73b7260a48d8:	ret
    73b7260a48d9:	mov    0x1(%rax),%rax
    73b7260a48dd:	mov    0xe(%rax),%rax
    73b7260a48e1:	movabs $0x73b72b67617c,%rcx
    73b7260a48eb:	cmp    %rcx,%rax
    73b7260a48ee:	jne    0x73b7260a4a4e
    73b7260a48f4:	mov    0x9(%rbx),%rax
    73b7260a48f8:	mov    0x11(%rbx),%rbx
    73b7260a48fc:	add    $0x8,%r15
    73b7260a4900:	mov    %rbx,(%r15)
    73b7260a4903:	mov    %rax,-0x8(%r14)
    73b7260a4907:	call   0x73b7260a38d0
    73b7260a490c:	mov    (%r15),%rax
    73b7260a490f:	add    $0x10,%r14
    73b7260a4913:	sub    $0x8,%r15
    73b7260a4917:	mov    %rax,-0x8(%r14)
    73b7260a491b:	movq   $0x0,(%r14)
    73b7260a4922:	call   0x73b7260a38d0
    73b7260a4927:	mov    (%r14),%rax
    73b7260a492a:	add    $0x8,%r14
    73b7260a492e:	cmp    $0x0,%rax
    73b7260a4932:	jne    0x73b7260a494e
    73b7260a4938:	sub    $0x8,%r14
    73b7260a493c:	sub    $0x8,%r14
    73b7260a4940:	mov    %eax,0x131466ba(%rip)        # 0x73b7391eb000
    73b7260a4946:	add    $0xa8,%rsp
    73b7260a494d:	ret
    73b7260a494e:	mov    %rax,%rbx
    73b7260a4951:	test   $0xf,%ebx
    73b7260a4957:	jne    0x73b7260a496d
    73b7260a495d:	sub    $0x8,%r14
    73b7260a4961:	mov    (%r14),%rax
    73b7260a4964:	mov    -0x8(%r14),%rbx
    73b7260a4968:	jmp    0x73b7260a49d1
    73b7260a496d:	mov    %rax,%rbx
    73b7260a4970:	and    $0xf,%ebx
    73b7260a4973:	cmp    $0x5,%rbx
    73b7260a4977:	jne    0x73b7260a49c6
    73b7260a497d:	movabs $0x73b72b717005,%rbx
    73b7260a4987:	add    $0x8,%r14
    73b7260a498b:	mov    %rax,-0x8(%r14)
    73b7260a498f:	mov    %rbx,(%r14)
    73b7260a4992:	call   0x73b7264082e0
    73b7260a4997:	mov    (%r14),%rax
    73b7260a499a:	sub    $0x8,%r14
    73b7260a499e:	cmp    $0x1,%rax
    73b7260a49a2:	je     0x73b7260a49ba
    73b7260a49a8:	sub    $0x8,%r14
    73b7260a49ac:	mov    %eax,0x1314664e(%rip)        # 0x73b7391eb000
    73b7260a49b2:	add    $0xa8,%rsp
    73b7260a49b9:	ret
    73b7260a49ba:	mov    (%r14),%rax
    73b7260a49bd:	mov    -0x8(%r14),%rbx
    73b7260a49c1:	jmp    0x73b7260a49d1
    73b7260a49c6:	sub    $0x8,%r14
    73b7260a49ca:	mov    (%r14),%rax
    73b7260a49cd:	mov    -0x8(%r14),%rbx
    73b7260a49d1:	lea    0x10(%r13),%rcx
    73b7260a49d5:	mov    (%rcx),%rdx
    73b7260a49d8:	add    $0x20,%rdx
    73b7260a49dc:	cmp    0x10(%rcx),%rdx
    73b7260a49e0:	jle    0x73b7260a4a0b
    73b7260a49e6:	mov    %rbx,0x80(%rsp)
    73b7260a49ee:	mov    %rax,0x88(%rsp)
    73b7260a49f6:	call   0x73b72610ca00
    73b7260a49fb:	mov    0x80(%rsp),%rbx
    73b7260a4a03:	mov    0x88(%rsp),%rax
    73b7260a4a0b:	movabs $0x73b72b688ba2,%rdx
    73b7260a4a15:	lea    0x10(%r13),%rbp
    73b7260a4a19:	mov    0x0(%rbp),%rcx
    73b7260a4a1d:	movq   $0x1c,(%rcx)
    73b7260a4a24:	or     $0x7,%rcx
    73b7260a4a28:	addq   $0x20,0x0(%rbp)
    73b7260a4a2d:	mov    %rdx,0x1(%rcx)
    73b7260a4a31:	mov    %rbx,0x9(%rcx)
    73b7260a4a35:	mov    %rax,0x11(%rcx)
    73b7260a4a39:	sub    $0x8,%r14
    73b7260a4a3d:	mov    %rcx,(%r14)
    73b7260a4a40:	mov    %eax,0x131465ba(%rip)        # 0x73b7391eb000
    73b7260a4a46:	add    $0xa8,%rsp
    73b7260a4a4d:	ret
    73b7260a4a4e:	movabs $0x73b72b663d9c,%rax
    73b7260a4a58:	add    $0x8,%r14
    73b7260a4a5c:	mov    %rax,(%r14)
    73b7260a4a5f:	call   0x73b7264dc3d0
    73b7260a4a64:	movabs $0x73b72b663d9c,%rax
    73b7260a4a6e:	add    $0x8,%r14
    73b7260a4a72:	mov    %rax,(%r14)
    73b7260a4a75:	call   0x73b7264dc3d0
    73b7260a4a7a:	mov    0x1(%rbx),%rbx
    73b7260a4a7e:	mov    0xe(%rbx),%rbx
    73b7260a4a82:	movabs $0x73b72b67617c,%rcx
    73b7260a4a8c:	cmp    %rcx,%rbx
    73b7260a4a8f:	jne    0x73b7260a4d53
    73b7260a4a95:	mov    %rax,%rbx
    73b7260a4a98:	test   $0xf,%ebx
    73b7260a4a9e:	jne    0x73b7260a4abd
    73b7260a4aa4:	mov    %eax,0x13146556(%rip)        # 0x73b7391eb000
    73b7260a4aaa:	add    $0xa8,%rsp
    73b7260a4ab1:	lea    0x5(%rip),%rbx        # 0x73b7260a4abd
    73b7260a4ab8:	jmp    0x73b726293960
    73b7260a4abd:	mov    %rax,%rbx
    73b7260a4ac0:	and    $0xf,%ebx
    73b7260a4ac3:	cmp    $0x3,%rbx
    73b7260a4ac7:	jne    0x73b7260a4b3e
    73b7260a4acd:	sub    $0x8,%r14
    73b7260a4ad1:	add    $0x8,%r15
    73b7260a4ad5:	mov    %rax,(%r15)
    73b7260a4ad8:	call   0x73b725e2da60
    73b7260a4add:	lea    0x10(%r13),%rax
    73b7260a4ae1:	mov    (%rax),%rbx
    73b7260a4ae4:	add    $0x10,%rbx
    73b7260a4ae8:	cmp    0x10(%rax),%rbx
    73b7260a4aec:	jle    0x73b7260a4af7
    73b7260a4af2:	call   0x73b72610ca00
    73b7260a4af7:	mov    (%r15),%rax
    73b7260a4afa:	mov    (%r14),%rbx
    73b7260a4afd:	rex.W movsd 0x5(%rbx),%xmm0
    73b7260a4b03:	rex.W movsd 0x5(%rax),%xmm1
    73b7260a4b09:	addsd  %xmm1,%xmm0
    73b7260a4b0d:	lea    0x10(%r13),%rbx
    73b7260a4b11:	mov    (%rbx),%rax
    73b7260a4b14:	movq   $0xc,(%rax)
    73b7260a4b1b:	or     $0x3,%rax
    73b7260a4b1f:	addq   $0x10,(%rbx)
    73b7260a4b23:	rex.W movsd %xmm0,0x5(%rax)
    73b7260a4b29:	sub    $0x8,%r15
    73b7260a4b2d:	mov    %rax,(%r14)
    73b7260a4b30:	mov    %eax,0x131464ca(%rip)        # 0x73b7391eb000
    73b7260a4b36:	add    $0xa8,%rsp
    73b7260a4b3d:	ret
    73b7260a4b3e:	mov    %rax,%rbx
    73b7260a4b41:	and    $0xf,%ebx
    73b7260a4b44:	cmp    $0x5,%rbx
    73b7260a4b48:	jne    0x73b7260a4b67
    73b7260a4b4e:	mov    %eax,0x131464ac(%rip)        # 0x73b7391eb000
    73b7260a4b54:	add    $0xa8,%rsp
    73b7260a4b5b:	lea    0x5(%rip),%rbx        # 0x73b7260a4b67
    73b7260a4b62:	jmp    0x73b726293960
    73b7260a4b67:	mov    %rax,%rbx
    73b7260a4b6a:	and    $0xf,%ebx
    73b7260a4b6d:	cmp    $0x7,%rbx
    73b7260a4b71:	jne    0x73b7260a4d3d
    73b7260a4b77:	mov    0x1(%rax),%rbx
    73b7260a4b7b:	mov    0xe(%rbx),%rbx
    73b7260a4b7f:	movabs $0x73b72b688fdc,%rcx
    73b7260a4b89:	cmp    %rcx,%rbx
    73b7260a4b8c:	jne    0x73b7260a4cf3
    73b7260a4b92:	mov    0x9(%rax),%rbx
    73b7260a4b96:	mov    0x11(%rax),%rax
    73b7260a4b9a:	add    $0x10,%r15
    73b7260a4b9e:	mov    %rax,-0x8(%r15)
    73b7260a4ba2:	mov    %rbx,(%r14)
    73b7260a4ba5:	movq   $0x0,(%r15)
    73b7260a4bac:	call   0x73b7260a38d0
    73b7260a4bb1:	mov    (%r15),%rax
    73b7260a4bb4:	mov    -0x8(%r15),%rbx
    73b7260a4bb8:	add    $0x10,%r14
    73b7260a4bbc:	sub    $0x10,%r15
    73b7260a4bc0:	mov    %rax,-0x8(%r14)
    73b7260a4bc4:	mov    %rbx,(%r14)
    73b7260a4bc7:	call   0x73b7260a38d0
    73b7260a4bcc:	mov    (%r14),%rax
    73b7260a4bcf:	add    $0x8,%r14
    73b7260a4bd3:	cmp    $0x0,%rax
    73b7260a4bd7:	jne    0x73b7260a4bf3
    73b7260a4bdd:	sub    $0x8,%r14
    73b7260a4be1:	sub    $0x8,%r14
    73b7260a4be5:	mov    %eax,0x13146415(%rip)        # 0x73b7391eb000
    73b7260a4beb:	add    $0xa8,%rsp
    73b7260a4bf2:	ret
    73b7260a4bf3:	mov    %rax,%rbx
    73b7260a4bf6:	test   $0xf,%ebx
    73b7260a4bfc:	jne    0x73b7260a4c12
    73b7260a4c02:	sub    $0x8,%r14
    73b7260a4c06:	mov    (%r14),%rax
    73b7260a4c09:	mov    -0x8(%r14),%rbx
    73b7260a4c0d:	jmp    0x73b7260a4c76
    73b7260a4c12:	mov    %rax,%rbx
    73b7260a4c15:	and    $0xf,%ebx
    73b7260a4c18:	cmp    $0x5,%rbx
    73b7260a4c1c:	jne    0x73b7260a4c6b
    73b7260a4c22:	movabs $0x73b72b717005,%rbx
    73b7260a4c2c:	add    $0x8,%r14
    73b7260a4c30:	mov    %rax,-0x8(%r14)
    73b7260a4c34:	mov    %rbx,(%r14)
    73b7260a4c37:	call   0x73b7264082e0
    73b7260a4c3c:	mov    (%r14),%rax
    73b7260a4c3f:	sub    $0x8,%r14
    73b7260a4c43:	cmp    $0x1,%rax
    73b7260a4c47:	je     0x73b7260a4c5f
    73b7260a4c4d:	sub    $0x8,%r14
    73b7260a4c51:	mov    %eax,0x131463a9(%rip)        # 0x73b7391eb000
    73b7260a4c57:	add    $0xa8,%rsp
    73b7260a4c5e:	ret
    73b7260a4c5f:	mov    (%r14),%rax
    73b7260a4c62:	mov    -0x8(%r14),%rbx
    73b7260a4c66:	jmp    0x73b7260a4c76
    73b7260a4c6b:	sub    $0x8,%r14
    73b7260a4c6f:	mov    (%r14),%rax
    73b7260a4c72:	mov    -0x8(%r14),%rbx
    73b7260a4c76:	lea    0x10(%r13),%rdx
    73b7260a4c7a:	mov    (%rdx),%rcx
    73b7260a4c7d:	add    $0x20,%rcx
    73b7260a4c81:	cmp    0x10(%rdx),%rcx
    73b7260a4c85:	jle    0x73b7260a4cb0
    73b7260a4c8b:	mov    %rbx,0x90(%rsp)
    73b7260a4c93:	mov    %rax,0x98(%rsp)
    73b7260a4c9b:	call   0x73b72610ca00
    73b7260a4ca0:	mov    0x90(%rsp),%rbx
    73b7260a4ca8:	mov    0x98(%rsp),%rax
    73b7260a4cb0:	movabs $0x73b72b688ba2,%rdx
    73b7260a4cba:	lea    0x10(%r13),%rbp
    73b7260a4cbe:	mov    0x0(%rbp),%rcx
    73b7260a4cc2:	movq   $0x1c,(%rcx)
    73b7260a4cc9:	or     $0x7,%rcx
    73b7260a4ccd:	addq   $0x20,0x0(%rbp)
    73b7260a4cd2:	mov    %rdx,0x1(%rcx)
    73b7260a4cd6:	mov    %rbx,0x9(%rcx)
    73b7260a4cda:	mov    %rax,0x11(%rcx)
    73b7260a4cde:	sub    $0x8,%r14
    73b7260a4ce2:	mov    %rcx,(%r14)
    73b7260a4ce5:	mov    %eax,0x13146315(%rip)        # 0x73b7391eb000
    73b7260a4ceb:	add    $0xa8,%rsp
    73b7260a4cf2:	ret
    73b7260a4cf3:	mov    0x1(%rax),%rax
    73b7260a4cf7:	mov    0xe(%rax),%rax
    73b7260a4cfb:	movabs $0x73b72b67617c,%rbx
    73b7260a4d05:	cmp    %rbx,%rax
    73b7260a4d08:	jne    0x73b7260a4d27
    73b7260a4d0e:	mov    %eax,0x131462ec(%rip)        # 0x73b7391eb000
    73b7260a4d14:	add    $0xa8,%rsp
    73b7260a4d1b:	lea    0x5(%rip),%rbx        # 0x73b7260a4d27
    73b7260a4d22:	jmp    0x73b726293960
    73b7260a4d27:	movabs $0x73b72b663d9c,%rax
    73b7260a4d31:	add    $0x8,%r14
    73b7260a4d35:	mov    %rax,(%r14)
    73b7260a4d38:	call   0x73b7264dc3d0
    73b7260a4d3d:	movabs $0x73b72b663d9c,%rax
    73b7260a4d47:	add    $0x8,%r14
    73b7260a4d4b:	mov    %rax,(%r14)
    73b7260a4d4e:	call   0x73b7264dc3d0
    73b7260a4d53:	movabs $0x73b72b663d9c,%rax
    73b7260a4d5d:	add    $0x8,%r14
    73b7260a4d61:	mov    %rax,(%r14)
    73b7260a4d64:	call   0x73b7264dc3d0
    73b7260a4d69:	movabs $0x73b72b663d9c,%rax
    73b7260a4d73:	add    $0x8,%r14
    73b7260a4d77:	mov    %rax,(%r14)
    73b7260a4d7a:	call   0x73b7264dc3d0
    73b7260a4d7f:	add    %al,(%rax)
    73b7260a4d81:	add    %al,(%rax)
    73b7260a4d83:	add    %al,(%rsi)
    73b7260a4d85:	add    %al,(%rax)
    73b7260a4d87:	add    (%rax),%eax
    73b7260a4d89:	sbb    %al,(%rax)
    73b7260a4d8b:	add    %al,(%rbx)
    73b7260a4d8d:	add    %al,(%rax)
    73b7260a4d8f:	(bad)
    73b7260a4d90:	add    %al,(%rax)
    73b7260a4d92:	add    (%rax),%eax
    73b7260a4d94:	addb   $0x0,(%rcx)
    73b7260a4d97:	rolb   $0x0,(%rax)
    73b7260a4d9a:	(bad)
    73b7260a4d9b:	add    %al,(%rax)
    73b7260a4d9d:	xor    %al,(%rax)
    73b7260a4d9f:	add    %bl,(%rax)
    73b7260a4da1:	add    %al,(%rax)
    73b7260a4da3:	or     $0xa2,%al
    73b7260a4da5:	add    %al,(%rax)
    73b7260a4da7:	add    %ch,0x0(%rdx,%rax,1)
    73b7260a4dab:	add    %bl,0x3(%rbx)
    73b7260a4dae:	add    %al,(%rax)
    73b7260a4db0:	fiadds (%rbx)
    73b7260a4db2:	add    %al,(%rax)
    73b7260a4db4:	and    (%rsi),%eax
    73b7260a4db6:	add    %al,(%rax)
    73b7260a4db8:	cmp    %cl,(%rcx)
    73b7260a4dba:	add    %al,(%rax)
    73b7260a4dbc:	and    %cl,(%rbx)
    73b7260a4dbe:	add    %al,(%rax)
    73b7260a4dc0:	udb
    73b7260a4dc1:	or     $0x0,%al
    73b7260a4dc3:	add    %dh,(%rsi,%rcx,1)
    73b7260a4dc6:	add    %al,(%rax)
    73b7260a4dc8:	mov    $0x2b00000f,%esp
    73b7260a4dcd:	adc    %eax,(%rax)
    73b7260a4dcf:	add    %dl,%al
    73b7260a4dd1:	adc    (%rax),%eax
    73b7260a4dd3:	add    %dl,0x0(%rip)        # 0x73b7260a4dd9
    73b7260a4dd9:	add    %al,(%rax)
    73b7260a4ddb:	add    %cl,(%rax,%rax,1)
	...
