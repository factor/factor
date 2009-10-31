namespace factor
{

static const fixnum fixnum_max = (((fixnum)1 << (WORD_SIZE - TAG_BITS - 1)) - 1);
static const fixnum fixnum_min = (-((fixnum)1 << (WORD_SIZE - TAG_BITS - 1)));
static const fixnum array_size_max = ((cell)1 << (WORD_SIZE - TAG_BITS - 2));

inline cell factor_vm::allot_integer(fixnum x)
{
	if(x < fixnum_min || x > fixnum_max)
		return tag<bignum>(fixnum_to_bignum(x));
	else
		return tag_fixnum(x);
}

inline cell factor_vm::allot_cell(cell x)
{
	if(x > (cell)fixnum_max)
		return tag<bignum>(cell_to_bignum(x));
	else
		return tag_fixnum(x);
}

inline cell factor_vm::allot_float(double n)
{
	boxed_float *flo = allot<boxed_float>(sizeof(boxed_float));
	flo->n = n;
	return tag(flo);
}

inline bignum *factor_vm::float_to_bignum(cell tagged)
{
	return double_to_bignum(untag_float(tagged));
}

inline double factor_vm::bignum_to_float(cell tagged)
{
	return bignum_to_double(untag<bignum>(tagged));
}

inline double factor_vm::untag_float(cell tagged)
{
	return untag<boxed_float>(tagged)->n;
}

inline double factor_vm::untag_float_check(cell tagged)
{
	return untag_check<boxed_float>(tagged)->n;
}

inline fixnum factor_vm::float_to_fixnum(cell tagged)
{
	return (fixnum)untag_float(tagged);
}

inline double factor_vm::fixnum_to_float(cell tagged)
{
	return (double)untag_fixnum(tagged);
}

inline cell factor_vm::unbox_array_size()
{
	cell obj = dpeek();
	if(TAG(obj) == FIXNUM_TYPE)
	{
		fixnum n = untag_fixnum(obj);
		if(n >= 0 && n < (fixnum)array_size_max)
		{
			dpop();
			return n;
		}
	}

	return unbox_array_size_slow();
}

VM_C_API void box_float(float flo, factor_vm *vm);
VM_C_API float to_float(cell value, factor_vm *vm);
VM_C_API void box_double(double flo, factor_vm *vm);
VM_C_API double to_double(cell value, factor_vm *vm);

VM_C_API void box_signed_1(s8 n, factor_vm *vm);
VM_C_API void box_unsigned_1(u8 n, factor_vm *vm);
VM_C_API void box_signed_2(s16 n, factor_vm *vm);
VM_C_API void box_unsigned_2(u16 n, factor_vm *vm);
VM_C_API void box_signed_4(s32 n, factor_vm *vm);
VM_C_API void box_unsigned_4(u32 n, factor_vm *vm);
VM_C_API void box_signed_cell(fixnum integer, factor_vm *vm);
VM_C_API void box_unsigned_cell(cell cell, factor_vm *vm);
VM_C_API void box_signed_8(s64 n, factor_vm *vm);
VM_C_API void box_unsigned_8(u64 n, factor_vm *vm);

VM_C_API s64 to_signed_8(cell obj, factor_vm *vm);
VM_C_API u64 to_unsigned_8(cell obj, factor_vm *vm);

VM_C_API fixnum to_fixnum(cell tagged, factor_vm *vm);
VM_C_API cell to_cell(cell tagged, factor_vm *vm);

VM_ASM_API void overflow_fixnum_add(fixnum x, fixnum y, factor_vm *vm);
VM_ASM_API void overflow_fixnum_subtract(fixnum x, fixnum y, factor_vm *vm);
VM_ASM_API void overflow_fixnum_multiply(fixnum x, fixnum y, factor_vm *vm);

}
