#include "factor.h"

#ifdef F_DEBUG

bool equals(CELL obj1, CELL obj2)
{
	if(type_of(obj1) == STRING_TYPE
		&& type_of(obj2) == STRING_TYPE)
	{
		return string_compare(untag_string(obj1),untag_string(obj2)) == 0;
	}
	else
		return (obj1 == obj2);
}

CELL assoc(CELL alist, CELL key)
{
	if(TAG(alist) != CONS_TYPE)
	{
		fprintf(stderr,"Not an alist: %ld\n",alist);
		return F;
	}

	{
		CELL pair = untag_cons(alist)->car;
		if(TAG(pair) != CONS_TYPE)
		{
			fprintf(stderr,"Not a pair: %ld\n",alist);
			return F;
		}

		if(equals(untag_cons(pair)->car,key))
			return untag_cons(pair)->cdr;
		else
			return assoc(untag_cons(alist)->cdr,key);
	}
}

void print_cons(CELL cons)
{
	fprintf(stderr,"[ ");

	do
	{
		print_obj(untag_cons(cons)->car);
		fprintf(stderr," ");
		cons = untag_cons(cons)->cdr;
	}
	while(TAG(cons) == CONS_TYPE);

	if(cons != F)
	{
		fprintf(stderr,"| ");
		print_obj(cons);
		fprintf(stderr," ");
	}
	fprintf(stderr,"]");
}

void print_word(F_WORD* word)
{
	CELL name = assoc(word->plist,tag_object(from_c_string("name")));
	if(type_of(name) == STRING_TYPE)
		fprintf(stderr,"%s",to_c_string(untag_string(name)));
	else
	{
		fprintf(stderr,"#<not a string: ");
		print_obj(name);
		fprintf(stderr,">");
	}

	fprintf(stderr," (#%ld)",word->primitive);
}

void print_string(F_STRING* str)
{
	fprintf(stderr,"\"");
	fprintf(stderr,"%s",to_c_string(str));
	fprintf(stderr,"\"");
}

void print_obj(CELL obj)
{
	switch(type_of(obj))
	{
	case CONS_TYPE:
		print_cons(obj);
		break;
	case WORD_TYPE:
		print_word(untag_word(obj));
		break;
	case STRING_TYPE:
		print_string(untag_string(obj));
		break;
	case F_TYPE:
		fprintf(stderr,"f");
		break;
	default:
		fprintf(stderr,"#<type %ld @ %ld>",type_of(obj),obj);
		break;
	}
}

void print_stack(CELL* start, CELL* end)
{
	while(start < end)
	{
		print_obj(*start);
		fprintf(stderr,"\n");
		start++;
	}
}

void dump_stacks(void)
{
	fprintf(stderr,"*** Data stack:\n");
	print_stack((CELL*)ds_bot,(CELL*)(ds + CELLS));
	fprintf(stderr,"*** Call stack:\n");
	print_stack((CELL*)cs_bot,(CELL*)(cs + CELLS));
	fprintf(stderr,"*** Call frame:\n");
	print_obj(callframe);
	fprintf(stderr,"\n");
	fprintf(stderr,"*** Executing:\n");
	print_obj(executing);
	fprintf(stderr,"\n");
	fflush(stderr);
}

#else

void dump_stacks(void)
{
	fprintf(stderr,"Stack dumping disabled -- recompile with F_DEBUG\n");
}

#endif
