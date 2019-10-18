#include "factor.h"

void primitive_arithmetic_type(void)
{
	CELL obj1 = dpeek();
	CELL obj2 = get(ds - CELLS);

	CELL type1 = TAG(obj1);
	CELL type2 = TAG(obj2);

	CELL type;

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
		type = type1;
		break;
	case BIGNUM_TYPE:
		switch(type1)
		{
		case FIXNUM_TYPE:
			drepl(tag_bignum(to_bignum(obj1)));
			type = type2;
			break;
		case FLOAT_TYPE:
			put(ds - CELLS,tag_float(to_float((obj2))));
			type = type1;
			break;
		default:
			type = type1;
			break;
		}
		break;
	case RATIO_TYPE:
		switch(type1)
		{
		case FIXNUM_TYPE:
		case BIGNUM_TYPE:
			type = type2;
			break;
		case FLOAT_TYPE:
			put(ds - CELLS,tag_float(to_float((obj2))));
			type = type1;
			break;
		default:
			type = type1;
			break;
		}
		break;
	case FLOAT_TYPE:
		switch(type1)
		{
		case FIXNUM_TYPE:
		case BIGNUM_TYPE:
		case RATIO_TYPE:
			drepl(tag_float(to_float(obj1)));
			type = type2;
			break;
		default:
			type = type1;
			break;
		}
		break;
	case COMPLEX_TYPE:
		switch(type1)
		{
		case FIXNUM_TYPE:
		case BIGNUM_TYPE:
		case RATIO_TYPE:
		case FLOAT_TYPE:
			type = type2;
			break;
		default:
			type = type1;
			break;
		}
		break;
	default:
		type = type2;
		break;
	}
	
	dpush(tag_fixnum(type));
}
