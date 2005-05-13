#include "factor.h"

/* Implements some Factor library words in C, to dump a stack in a semi-human-readable
form without any Factor code executing.. This is not used during normal execution, only
when the runtime dies. */
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
	if(alist == F)
		return F;

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

CELL hash(CELL hash, CELL key)
{
	if(type_of(hash) != HASHTABLE_TYPE)
	{
		fprintf(stderr,"Not a hash: %ld\n",hash);
		return F;
	}

	{
		int i;

		CELL array = ((F_HASHTABLE*)UNTAG(hash))->array;
		F_ARRAY* a;

		if(type_of(array) != ARRAY_TYPE)
		{
			fprintf(stderr,"Not an array: %ld\n",hash);
			return F;
		}

		a = untag_array_fast(array);

		for(i = 0; i < array_capacity(a); i++)
		{
			CELL value = assoc(get(AREF(a,i)),key);
			if(value != F)
				return value;
		}
		
		return F;
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
	CELL name = hash(word->props,tag_object(from_c_string("name")));
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
	case FIXNUM_TYPE:
		fprintf(stderr,"%ld",untag_fixnum_fast(obj));
		break;
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
		fprintf(stderr,"#<type %ld @ %lx>",type_of(obj),obj);
		break;
	}
}

void print_objects(CELL start, CELL end)
{
	for(; start <= end; start += CELLS)
	{
		print_obj(get(start));
		fprintf(stderr,"\n");
	}
}

void dump_cell(CELL cell)
{
	fprintf(stderr,"%08lx: ",cell);

	cell = get(cell);

	fprintf(stderr,"%08lx tag %ld",cell,TAG(cell));

	switch(TAG(cell))
	{
	case OBJECT_TYPE:
	case BIGNUM_TYPE:
	case FLOAT_TYPE:
		if(cell == F)
			fprintf(stderr," -- F");
		else if(cell < TYPE_COUNT<<TAG_BITS)
			fprintf(stderr," -- header: %ld",cell>>TAG_BITS);
		else if(cell >= heap_start && cell < heap_end)
		{
			CELL header = get(UNTAG(cell));
			CELL type = header>>TAG_BITS;
			fprintf(stderr," -- object; ");
			if(TAG(header) == OBJECT_TYPE && type < TYPE_COUNT)
				fprintf(stderr," type %ld",type);
			else
				fprintf(stderr," header corrupt");
		}
		break;
	case GC_COLLECTED:
		fprintf(stderr," -- forwarding pointer");
		break;
	}
	
	fprintf(stderr,"\n");
}

void dump_memory(CELL from, CELL to)
{
	for(; from <= to; from += CELLS)
		dump_cell(from);
}

void dump_generation(ZONE *z)
{
	fprintf(stderr,"base=%lx, size=%lx, here=%lx, alarm=%lx\n",
		z->base,
		z->limit - z->base,
		z->here - z->base,
		z->alarm - z->base);
}

void dump_generations(void)
{
	int i;
	for(i = 0; i < GC_GENERATIONS; i++)
	{
		fprintf(stderr,"Generation %d: ",i);
		dump_generation(&generations[i]);
	}

	fprintf(stderr,"Semispace: ");
	dump_generation(&prior);

	fprintf(stderr,"Cards: base=%lx, size=%lx\n",(CELL)cards,
		(CELL)(cards_end - cards));
}

void factorbug(void)
{
	fprintf(stderr,"Factor low-level debugger\n");
	fprintf(stderr,"d <addr> <count> -- dump memory\n");
	fprintf(stderr,". <addr>         -- print object at <addr>\n");
	fprintf(stderr,"sz <addr>        -- print size of object at <addr>\n");
	fprintf(stderr,"s r              -- dump data and return stacks\n");
	fprintf(stderr,".s .r            -- print data and return stacks\n");
	fprintf(stderr,"i                -- dump interpreter state\n");
	fprintf(stderr,"e                -- dump environment\n");
	fprintf(stderr,"g                -- dump generations\n");
	fprintf(stderr,"card <addr>      -- print card containing address\n");
	fprintf(stderr,"addr <card>      -- print address containing card\n");
	fprintf(stderr,"c <gen>          -- force garbage collection\n");
	fprintf(stderr,"t                -- throw t\n");
	fprintf(stderr,"x                -- exit debugger\n");
	fprintf(stderr,"im               -- save factor.crash.image\n");
	
	for(;;)
	{
		char cmd[1024];

		fprintf(stderr,"ldb ");
		fflush(stdout);

		if(scanf("%s",cmd) <= 0)
			exit(1);

		if(strcmp(cmd,"d") == 0)
		{
			CELL addr, count;
			scanf("%lx %lx",&addr,&count);
			dump_memory(addr,addr+count);
		}
		else if(strcmp(cmd,".") == 0)
		{
			CELL addr;
			scanf("%lx",&addr);
			print_obj(addr);
			fprintf(stderr,"\n");
		}
		else if(strcmp(cmd,"sz") == 0)
		{
			CELL addr;
			scanf("%lx",&addr);
			fprintf(stderr,"%ld\n",object_size(addr));
		}
		else if(strcmp(cmd,"s") == 0)
			dump_memory(ds_bot,(ds + CELLS));
		else if(strcmp(cmd,"r") == 0)
			dump_memory(cs_bot,(cs + CELLS));
		else if(strcmp(cmd,".s") == 0)
			print_objects(ds_bot,(ds + CELLS));
		else if(strcmp(cmd,".r") == 0)
			print_objects(cs_bot,(cs + CELLS));
		else if(strcmp(cmd,"i") == 0)
		{
			fprintf(stderr,"Call frame:\n");
			print_obj(callframe);
			fprintf(stderr,"\n");
			fprintf(stderr,"Executing:\n");
			print_obj(executing);
			fprintf(stderr,"\n");
		}
		else if(strcmp(cmd,"e") == 0)
		{
			int i;
			for(i = 0; i < USER_ENV; i++)
				dump_cell(userenv[i]);
		}
		else if(strcmp(cmd,"g") == 0)
			dump_generations();
		else if(strcmp(cmd,"c") == 0)
		{
			CELL gen;
			scanf("%lu",&gen);
			garbage_collection(gen);
		}
		else if(strcmp(cmd,"card") == 0)
		{
			CELL addr;
			scanf("%lx",&addr);
			fprintf(stderr,"%lx\n",(CELL)ADDR_TO_CARD(addr));
		}
		else if(strcmp(cmd,"addr") == 0)
		{
			CELL card;
			scanf("%lx",&card);
			fprintf(stderr,"%lx\n",(CELL)CARD_TO_ADDR(card));
		}
		else if(strcmp(cmd,"t") == 0)
			throw_error(T,true);
		else if(strcmp(cmd,"x") == 0)
			return;
		else if(strcmp(cmd,"y") == 0)
			save_image("factor.crash.image");
		else
			fprintf(stderr,"unknown command\n");
	}
}
