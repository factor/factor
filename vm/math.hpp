namespace factor
{

static const fixnum fixnum_max = (((fixnum)1 << (WORD_SIZE - TAG_BITS - 1)) - 1);
static const fixnum fixnum_min = (-((fixnum)1 << (WORD_SIZE - TAG_BITS - 1)));
static const fixnum array_size_max = ((cell)1 << (WORD_SIZE - TAG_BITS - 2));

// defined in assembler





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
