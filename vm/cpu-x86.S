/* cpu.x86.features calls this */
DEF(bool,sse_version,(void)):
	mov $0x1,RETURN_REG
	cpuid
	test $0x100000,%ecx
	jnz sse_42
	test $0x80000,%ecx
	jnz sse_41
	test $0x200,%ecx
	jnz ssse_3
	test $0x1,%ecx
	jnz sse_3
	test $0x4000000,%edx
	jnz sse_2
	test $0x2000000,%edx
	jnz sse_1
	mov $0,%eax
	ret
sse_42:
	mov $42,RETURN_REG
	ret
sse_41:
	mov $41,RETURN_REG
	ret
ssse_3:
	mov $33,RETURN_REG
	ret
sse_3:
	mov $30,RETURN_REG
	ret
sse_2:
	mov $20,RETURN_REG
	ret
sse_1:
	mov $10,RETURN_REG
	ret

#ifdef WINDOWS
	.section .drectve
	.ascii " -export:sse_version"
	.ascii " -export:c_to_factor"
#endif
