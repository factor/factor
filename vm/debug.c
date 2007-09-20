#include "master.h"

void print_word(F_WORD* word, CELL nesting)
{
	if(type_of(word->name) == STRING_TYPE)
		printf("%s",to_char_string(untag_string(word->name),true));
	else
	{
		printf("#<not a string: ");
		print_nested_obj(word->name,nesting - 1);
		printf(">");
	}
}

void print_string(F_STRING* str)
{
	printf("\"%s\"",to_char_string(str,true));
}

void print_array(F_ARRAY* array, CELL nesting)
{
	CELL length = array_capacity(array);
	CELL i;

	for(i = 0; i < length; i++)
	{
		printf(" ");
		print_nested_obj(array_nth(array,i),nesting - 1);
	}
}

void print_nested_obj(CELL obj, CELL nesting)
{
	if(nesting == 0)
	{
		printf(" ... ");
		return;
	}

	F_QUOTATION *quot;

	switch(type_of(obj))
	{
	case FIXNUM_TYPE:
		printf("%ld",untag_fixnum_fast(obj));
		break;
	case WORD_TYPE:
		print_word(untag_word(obj),nesting - 1);
		break;
	case STRING_TYPE:
		print_string(untag_string(obj));
		break;
	case F_TYPE:
		printf("f");
		break;
	case TUPLE_TYPE:
		printf("T{");
		print_array(untag_object(obj),nesting - 1);
		printf(" }");
		break;
	case ARRAY_TYPE:
		printf("{");
		print_array(untag_object(obj),nesting - 1);
		printf(" }");
		break;
	case QUOTATION_TYPE:
		printf("[");
		quot = untag_object(obj);
		print_array(untag_object(quot->array),nesting - 1);
		printf(" ]");
		break;
	default:
		printf("#<type %ld @ %lx>",type_of(obj),obj);
		break;
	}
}

void print_obj(CELL obj)
{
	print_nested_obj(obj,10);
}

void print_objects(CELL start, CELL end)
{
	for(; start <= end; start += CELLS)
	{
		print_obj(get(start));
		printf("\n");
	}
}

void print_stack_frame(F_STACK_FRAME *frame)
{
	print_obj(frame_executing(frame));
	printf("\n");
}

void print_callstack(void)
{
	CELL bottom = (CELL)stack_chain->callstack_bottom;
	CELL top = (CELL)stack_chain->callstack_top;
	CELL base = bottom;
	iterate_callstack(top,bottom,base,print_stack_frame);
}

void dump_cell(CELL cell)
{
	printf("%08lx: ",cell);

	cell = get(cell);

	printf("%08lx tag %ld",cell,TAG(cell));

	switch(TAG(cell))
	{
	case OBJECT_TYPE:
	case BIGNUM_TYPE:
	case FLOAT_TYPE:
		if(cell == F)
			printf(" -- F");
		else if(cell < TYPE_COUNT<<TAG_BITS)
			printf(" -- possible header: %ld",cell>>TAG_BITS);
		else if(cell >= data_heap->segment->start
			&& cell < data_heap->segment->end)
		{
			CELL header = get(UNTAG(cell));
			CELL type = header>>TAG_BITS;
			printf(" -- object; ");
			if(TAG(header) == 0 && type < TYPE_COUNT)
				printf(" type %ld",type);
			else
				printf(" header corrupt");
		}
		break;
	}
	
	printf("\n");
}

void dump_memory(CELL from, CELL to)
{
	from = UNTAG(from);

	for(; from <= to; from += CELLS)
		dump_cell(from);
}

void dump_zone(F_ZONE z)
{
	printf("start=%lx, size=%lx, end=%lx, here=%lx\n",
		z.start,z.size,z.end,z.here - z.start);
}

void dump_generations(void)
{
	int i;
	for(i = 0; i < data_heap->gen_count; i++)
	{
		printf("Generation %d: ",i);
		dump_zone(data_heap->generations[i]);
	}

	for(i = 0; i < data_heap->gen_count; i++)
	{
		printf("Semispace %d: ",i);
		dump_zone(data_heap->semispaces[i]);
	}

	printf("Cards: base=%lx, size=%lx\n",
		(CELL)data_heap->cards,
		(CELL)(data_heap->cards_end - data_heap->cards));
}

void factorbug(void)
{
	reset_stdio();

	printf("Starting low level debugger...\n");
	printf("  Basic commands:\n");
	printf("q                -- continue executing Factor - NOT SAFE\n");
	printf("im               -- save image to fep.image\n");
	printf("x                -- exit Factor\n");
	printf("  Advanced commands:\n");
	printf("d <addr> <count> -- dump memory\n");
	printf("u <addr>         -- dump object at tagged <addr>\n");
	printf(". <addr>         -- print object at tagged <addr>\n");
	printf("s r              -- dump data, retain stacks\n");
	printf(".s .r .c         -- print data, retain, call stacks\n");
	printf("e                -- dump environment\n");
	printf("g                -- dump generations\n");
	printf("card <addr>      -- print card containing address\n");
	printf("addr <card>      -- print address containing card\n");
	printf("code             -- code heap dump\n");
	
	for(;;)
	{
		char cmd[1024];

		printf("READY\n");
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
			printf("\n");
		}
		else if(strcmp(cmd,"s") == 0)
			dump_memory(ds_bot,ds);
		else if(strcmp(cmd,"r") == 0)
			dump_memory(rs_bot,rs);
		else if(strcmp(cmd,".s") == 0)
			print_objects(ds_bot,ds);
		else if(strcmp(cmd,".r") == 0)
			print_objects(rs_bot,rs);
		else if(strcmp(cmd,".c") == 0)
			print_callstack();
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
			printf("%lx\n",(CELL)ADDR_TO_CARD(addr));
		}
		else if(strcmp(cmd,"addr") == 0)
		{
			CELL card;
			scanf("%lx",&card);
			printf("%lx\n",(CELL)CARD_TO_ADDR(card));
		}
		else if(strcmp(cmd,"q") == 0)
			return;
		else if(strcmp(cmd,"x") == 0)
			exit(1);
		else if(strcmp(cmd,"im") == 0)
			save_image(STR_FORMAT("fep.image"));
		else if(strcmp(cmd,"code") == 0)
			dump_heap(&code_heap);
		else
			printf("unknown command\n");
	}
}

DEFINE_PRIMITIVE(die)
{
	fprintf(stderr,"The die word was called by the library. Unless you called it yourself,\n");
	fprintf(stderr,"you have triggered a bug in Factor. Please report.\n");
	factorbug();
}
