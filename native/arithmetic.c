#include "factor.h"

/* This function is called by the compiler. It returns an untagged fixnum. */
F_FIXNUM arithmetic_type(void)
{
	CELL obj1 = dpeek(), obj2 = get(ds - CELLS);
	CELL type1 = TAG(obj1), type2 = TAG(obj2);

	switch(type2)
	{
	case FIXNUM_TYPE:
		switch(type1)
		{
		case BIGNUM_TYPE:
			put(ds - CELLS,tag_bignum(to_bignum(obj2)));
			break;
		case FLOAT_TYPE:
			put(ds - CELLS,tag_float(to_float((obj2))));
			break;
		}
		return type1;
	case BIGNUM_TYPE:
		switch(type1)
		{
		case FIXNUM_TYPE:
			drepl(tag_bignum(to_bignum(obj1)));
			return type2;
		case FLOAT_TYPE:
			put(ds - CELLS,tag_float(to_float((obj2))));
			return type1;
		default:
			return type1;
		}
	case RATIO_TYPE:
		switch(type1)
		{
		case FIXNUM_TYPE: case BIGNUM_TYPE:
			return type2;
		case FLOAT_TYPE:
			put(ds - CELLS,tag_float(to_float((obj2))));
			return type1;
		default:
			return type1;
		}
	case FLOAT_TYPE:
		switch(type1)
		{
		case FIXNUM_TYPE: case BIGNUM_TYPE: case RATIO_TYPE:
			drepl(tag_float(to_float(obj1)));
			return type2;
		default:
			return type1;
		}
	case COMPLEX_TYPE:
		switch(type1)
		{
		case FIXNUM_TYPE: case BIGNUM_TYPE: case RATIO_TYPE: case FLOAT_TYPE:
			return type2;
		default:
			return type1;
		}
	default:
		return type2;
	}
}

void primitive_arithmetic_type(void)
{
	dpush(tag_fixnum(arithmetic_type()));
}
