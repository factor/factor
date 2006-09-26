#include "factor.h"

void print_word(F_WORD* word)
{
	if(type_of(word->name) == STRING_TYPE)
		fprintf(stderr,"%s",to_char_string(untag_string(word->name),true));
	else
	{
		fprintf(stderr,"#<not a string: ");
		print_obj(word->name);
		fprintf(stderr,">");
	}

	fprintf(stderr," (#%ld)",untag_fixnum_fast(word->primitive));
}

void print_string(F_STRING* str)
{
	fprintf(stderr,"\"%s\"",to_char_string(str,true));
}

void print_array(F_ARRAY* array)
{
	CELL length = array_capacity(array);
	CELL i;

	for(i = 0; i < length; i++)
	{
		fprintf(stderr," ");
		print_obj(get(AREF(array,i)));
	}
}

void print_obj(CELL obj)
{
	switch(type_of(obj))
	{
	case FIXNUM_TYPE:
		fprintf(stderr,"%ld",untag_fixnum_fast(obj));
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
	case TUPLE_TYPE:
		fprintf(stderr,"T{");
		print_array((F_ARRAY*)UNTAG(obj));
		fprintf(stderr," }");
		break;
	case ARRAY_TYPE:
		fprintf(stderr,"{");
		print_array((F_ARRAY*)UNTAG(obj));
		fprintf(stderr," }");
		break;
	case QUOTATION_TYPE:
		fprintf(stderr,"[");
		print_array((F_ARRAY*)UNTAG(obj));
		fprintf(stderr," ]");
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
		else if(cell >= data_heap_start && cell < data_heap_end)
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
	}
	
	fprintf(stderr,"\n");
}

void dump_memory(CELL from, CELL to)
{
	from = UNTAG(from);

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
	for(i = 0; i < gen_count; i++)
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
	reset_stdio();

	fprintf(stderr,"A fatal error has occurred and Factor cannot continue.\n");
	fprintf(stderr,"The low-level debugger has been started to help diagnose the problem.\n");
	fprintf(stderr,"  Basic commands:\n");
	fprintf(stderr,"t                -- throw exception in Factor\n");
	fprintf(stderr,"q                -- continue executing Factor\n");
	fprintf(stderr,"im               -- save image to fep.image\n");
	fprintf(stderr,"x                -- exit Factor\n");
	fprintf(stderr,"  Advanced commands:\n");
	fprintf(stderr,"d <addr> <count> -- dump memory\n");
	fprintf(stderr,"u <addr>         -- dump object at tagged <addr>\n");
	fprintf(stderr,". <addr>         -- print object at tagged <addr>\n");
	fprintf(stderr,"s r c            -- dump data, retain, call stacks\n");
	fprintf(stderr,".s .r .c         -- print data, retain, call stacks\n");
	fprintf(stderr,"i                -- dump interpreter state\n");
	fprintf(stderr,"e                -- dump environment\n");
	fprintf(stderr,"g                -- dump generations\n");
	fprintf(stderr,"card <addr>      -- print card containing address\n");
	fprintf(stderr,"addr <card>      -- print address containing card\n");
	fprintf(stderr,"c <gen>          -- force garbage collection\n");
	
	for(;;)
	{
		char cmd[1024];

		fprintf(stderr,"READY\n");
		fflush(stdout);

		if(scanf("%1000s",cmd) <= 0)
			exit(1);

		if(strcmp(cmd,"d") == 0)
		{
			CELL addr, count;
			scanf("%lx %lx",&addr,&count);
			dump_memory(addr,addr+count);
		}
		if(strcmp(cmd,"u") == 0)
		{
			CELL addr, count;
			scanf("%lx",&addr);
			count = object_size(addr);
			dump_memory(addr,addr+count);
		}
		else if(strcmp(cmd,".") == 0)
		{
			CELL addr;
			scanf("%lx",&addr);
			print_obj(addr);
			fprintf(stderr,"\n");
		}
		else if(strcmp(cmd,"s") == 0)
			dump_memory(ds_bot,ds);
		else if(strcmp(cmd,"r") == 0)
			dump_memory(rs_bot,rs);
		else if(strcmp(cmd,"c") == 0)
			dump_memory(cs_bot,cs);
		else if(strcmp(cmd,".s") == 0)
			print_objects(ds_bot,ds);
		else if(strcmp(cmd,".r") == 0)
			print_objects(rs_bot,rs);
		else if(strcmp(cmd,".c") == 0)
			print_objects(cs_bot,cs);
		else if(strcmp(cmd,"i") == 0)
		{
			fprintf(stderr,"Call frame:\n");
			print_obj(callframe);
			fprintf(stderr,"\n");
		}
		else if(strcmp(cmd,"e") == 0)
		{
			int i;
			for(i = 0; i < USER_ENV; i++)
				dump_cell((CELL)&userenv[i]);
		}
		else if(strcmp(cmd,"g") == 0)
			dump_generations();
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
			general_error(ERROR_USER_INTERRUPT,F,F,true);
		else if(strcmp(cmd,"q") == 0)
			return;
		else if(strcmp(cmd,"x") == 0)
			exit(1);
		else if(strcmp(cmd,"im") == 0)
			save_image("fep.image");
		else
			fprintf(stderr,"unknown command\n");
	}
}
