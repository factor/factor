#include "factor.h"

void primitive_arithmetic_type(void)
{
	CELL obj1 = dpeek();
	CELL obj2 = get(ds - CELLS);

	CELL type1 = type_of(obj1);
	CELL type2 = type_of(obj2);

	CELL type;

	switch(type2)
	{
	case FIXNUM_TYPE:
		switch(type1)
		{
		case BIGNUM_TYPE:
			put(ds - CELLS,tag_object(to_bignum(obj2)));
			break;
		case FLOAT_TYPE:
			put(ds - CELLS,tag_object(make_float(to_float((obj2)))));
			break;
		}
		type = type1;
		break;
	case BIGNUM_TYPE:
		switch(type1)
		{
		case FIXNUM_TYPE:
			drepl(tag_object(to_bignum(obj1)));
			type = type2;
			break;
		case FLOAT_TYPE:
			put(ds - CELLS,tag_object(make_float(to_float((obj2)))));
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
			put(ds - CELLS,tag_object(make_float(to_float((obj2)))));
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
			drepl(tag_object(make_float(to_float(obj1))));
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

bool realp(CELL tagged)
{
	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
	case BIGNUM_TYPE:
	case RATIO_TYPE:
	case FLOAT_TYPE:
		return true;
		break;
	default:
		return false;
		break;
	}
}

bool zerop(CELL tagged)
{
	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return tagged == 0;
	case BIGNUM_TYPE:
		return BIGNUM_ZERO_P((F_ARRAY*)UNTAG(tagged));
	case FLOAT_TYPE:
		return ((F_FLOAT*)UNTAG(tagged))->n == 0.0;
	case RATIO_TYPE:
	case COMPLEX_TYPE:
		return false;
	default:
		type_error(NUMBER_TYPE,tagged);
		return false; /* Can't happen */
	}
}

bool onep(CELL tagged)
{
	switch(type_of(tagged))
	{
	case FIXNUM_TYPE:
		return tagged == tag_fixnum(1);
	case BIGNUM_TYPE:
		return BIGNUM_ONE_P((F_ARRAY*)UNTAG(tagged),0);
	case FLOAT_TYPE:
		return ((F_FLOAT*)UNTAG(tagged))->n == 1.0;
	case RATIO_TYPE:
	case COMPLEX_TYPE:
		return false;
	default:
		type_error(NUMBER_TYPE,tagged);
		return false; /* Can't happen */
	}
}
