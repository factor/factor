#define FIXNUM_MAX (((F_FIXNUM)1 << (WORD_SIZE - TAG_BITS - 1)) - 1)
#define FIXNUM_MIN (-((F_FIXNUM)1 << (WORD_SIZE - TAG_BITS - 1)))

INLINE F_FIXNUM untag_fixnum_fast(CELL tagged)
{
	return ((F_FIXNUM)tagged) >> TAG_BITS;
}

INLINE CELL tag_fixnum(F_FIXNUM untagged)
{
	return RETAG(untagged << TAG_BITS,FIXNUM_TYPE);
}

F_FIXNUM to_fixnum(CELL tagged);
void primitive_to_fixnum(void);

void primitive_fixnum_add(void);
void primitive_fixnum_subtract(void);
void primitive_fixnum_add_fast(void);
void primitive_fixnum_subtract_fast(void);
void primitive_fixnum_multiply(void);
void primitive_fixnum_divint(void);
void primitive_fixnum_divfloat(void);
void primitive_fixnum_divmod(void);
void primitive_fixnum_mod(void);
void primitive_fixnum_and(void);
void primitive_fixnum_or(void);
void primitive_fixnum_xor(void);
void primitive_fixnum_shift(void);
void primitive_fixnum_less(void);
void primitive_fixnum_lesseq(void);
void primitive_fixnum_greater(void);
void primitive_fixnum_greatereq(void);
void primitive_fixnum_not(void);
DLLEXPORT void box_signed_1(signed char integer);
DLLEXPORT void box_signed_2(signed short integer);
DLLEXPORT void box_unsigned_1(unsigned char integer);
DLLEXPORT void box_unsigned_2(unsigned short integer);
DLLEXPORT signed char unbox_signed_1(void);
DLLEXPORT signed short unbox_signed_2(void);
DLLEXPORT unsigned char unbox_unsigned_1(void);
DLLEXPORT unsigned short unbox_unsigned_2(void);

CELL bignum_zero;
CELL bignum_pos_one;
CELL bignum_neg_one;

INLINE F_ARRAY* untag_bignum_fast(CELL tagged)
{
	return (F_ARRAY*)UNTAG(tagged);
}

INLINE CELL tag_bignum(F_ARRAY* bignum)
{
	return RETAG(bignum,BIGNUM_TYPE);
}

CELL to_cell(CELL x);
F_ARRAY* to_bignum(CELL tagged);
void primitive_to_bignum(void);
void primitive_bignum_eq(void);
void primitive_bignum_add(void);
void primitive_bignum_subtract(void);
void primitive_bignum_multiply(void);
void primitive_bignum_divint(void);
void primitive_bignum_divfloat(void);
void primitive_bignum_divmod(void);
void primitive_bignum_mod(void);
void primitive_bignum_and(void);
void primitive_bignum_or(void);
void primitive_bignum_xor(void);
void primitive_bignum_shift(void);
void primitive_bignum_less(void);
void primitive_bignum_lesseq(void);
void primitive_bignum_greater(void);
void primitive_bignum_greatereq(void);
void primitive_bignum_not(void);

INLINE CELL allot_integer(F_FIXNUM x)
{
	if(x < FIXNUM_MIN || x > FIXNUM_MAX)
		return tag_bignum(s48_fixnum_to_bignum(x));
	else
		return tag_fixnum(x);
}

INLINE CELL allot_cell(CELL x)
{
	if(x > FIXNUM_MAX)
		return tag_bignum(s48_cell_to_bignum(x));
	else
		return tag_fixnum(x);
}

/* FFI calls this */
DLLEXPORT void box_signed_cell(F_FIXNUM integer);
DLLEXPORT F_FIXNUM unbox_signed_cell(void);

DLLEXPORT void box_unsigned_cell(CELL cell);
DLLEXPORT F_FIXNUM unbox_unsigned_cell(void);

DLLEXPORT void box_signed_4(s32 n);
DLLEXPORT s32 unbox_signed_4(void);

DLLEXPORT void box_unsigned_4(u32 n);
DLLEXPORT u32 unbox_unsigned_4(void);

DLLEXPORT void box_signed_8(s64 n);
DLLEXPORT s64 unbox_signed_8(void);

DLLEXPORT void box_unsigned_8(u64 n);
DLLEXPORT u64 unbox_unsigned_8(void);

void primitive_from_fraction(void);

/* for punning */
typedef union {
    double x;
    u64 y;
} DOUBLE_BITS;

typedef union {
    float x;
    u32 y;
} FLOAT_BITS;

INLINE double untag_float_fast(CELL tagged)
{
	return ((F_FLOAT*)UNTAG(tagged))->n;
}

INLINE CELL allot_float(double n)
{
	F_FLOAT* flo = allot_object(FLOAT_TYPE,sizeof(F_FLOAT));
	flo->n = n;
	return RETAG(flo,FLOAT_TYPE);
}

double to_float(CELL tagged);
void primitive_to_float(void);
void primitive_str_to_float(void);
void primitive_float_to_str(void);
void primitive_float_to_bits(void);

void primitive_float_add(void);
void primitive_float_subtract(void);
void primitive_float_multiply(void);
void primitive_float_divfloat(void);
void primitive_float_mod(void);
void primitive_float_less(void);
void primitive_float_lesseq(void);
void primitive_float_greater(void);
void primitive_float_greatereq(void);

void primitive_float_bits(void);
void primitive_bits_float(void);
void primitive_double_bits(void);
void primitive_bits_double(void);

DLLEXPORT void box_float(float flo);
DLLEXPORT float unbox_float(void);
DLLEXPORT void box_double(double flo);
DLLEXPORT double unbox_double(void);

void primitive_from_rect(void);
