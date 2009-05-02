#include "master.h"

static bool full_output;

void print_chars(F_STRING* str)
{
	CELL i;
	for(i = 0; i < string_capacity(str); i++)
		putchar(string_nth(str,i));
}

void print_word(F_WORD* word, CELL nesting)
{

	if(type_of(word->vocabulary) == STRING_TYPE)
	{
		print_chars(untag_string(word->vocabulary));
		print_string(":");
	}
	
	if(type_of(word->name) == STRING_TYPE)
		print_chars(untag_string(word->name));
	else
	{
		print_string("#<not a string: ");
		print_nested_obj(word->name,nesting);
		print_string(">");
	}
}

void print_factor_string(F_STRING* str)
{
	putchar('"');
	print_chars(str);
	putchar('"');
}

void print_array(F_ARRAY* array, CELL nesting)
{
	CELL length = array_capacity(array);
	CELL i;
	bool trimmed;

	if(length > 10 && !full_output)
	{
		trimmed = true;
		length = 10;
	}
	else
		trimmed = false;

	for(i = 0; i < length; i++)
	{
		print_string(" ");
		print_nested_obj(array_nth(array,i),nesting);
	}

	if(trimmed)
		print_string("...");
}

void print_tuple(F_TUPLE* tuple, CELL nesting)
{
	F_TUPLE_LAYOUT *layout = untag_object(tuple->layout);
	CELL length = to_fixnum(layout->size);

	print_string(" ");
	print_nested_obj(layout->class,nesting);

	CELL i;
	bool trimmed;

	if(length > 10 && !full_output)
	{
		trimmed = true;
		length = 10;
	}
	else
		trimmed = false;

	for(i = 0; i < length; i++)
	{
		print_string(" ");
		print_nested_obj(tuple_nth(tuple,i),nesting);
	}

	if(trimmed)
		print_string("...");
}

void print_nested_obj(CELL obj, F_FIXNUM nesting)
{
	if(nesting <= 0 && !full_output)
	{
		print_string(" ... ");
		return;
	}

	F_QUOTATION *quot;

	switch(type_of(obj))
	{
	case FIXNUM_TYPE:
		print_fixnum(untag_fixnum_fast(obj));
		break;
	case WORD_TYPE:
		print_word(untag_word(obj),nesting - 1);
		break;
	case STRING_TYPE:
		print_factor_string(untag_string(obj));
		break;
	case F_TYPE:
		print_string("f");
		break;
	case TUPLE_TYPE:
		print_string("T{");
		print_tuple(untag_object(obj),nesting - 1);
		print_string(" }");
		break;
	case ARRAY_TYPE:
		print_string("{");
		print_array(untag_object(obj),nesting - 1);
		print_string(" }");
		break;
	case QUOTATION_TYPE:
		print_string("[");
		quot = untag_object(obj);
		print_array(untag_object(quot->array),nesting - 1);
		print_string(" ]");
		break;
	default:
		print_string("#<type "); print_cell(type_of(obj)); print_string(" @ "); print_cell_hex(obj); print_string(">");
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
		nl();
	}
}

void print_datastack(void)
{
	print_string("==== DATA STACK:\n");
	print_objects(ds_bot,ds);
}

void print_retainstack(void)
{
	print_string("==== RETAIN STACK:\n");
	print_objects(rs_bot,rs);
}

void print_stack_frame(F_STACK_FRAME *frame)
{
	print_obj(frame_executing(frame));
	print_string("\n");
	print_obj(frame_scan(frame));
	print_string("\n");
	print_cell_hex((CELL)frame_executing(frame));
	print_string(" ");
	print_cell_hex((CELL)frame->xt);
	print_string("\n");
}

void print_callstack(void)
{
	print_string("==== CALL STACK:\n");
	CELL bottom = (CELL)stack_chain->callstack_bottom;
	CELL top = (CELL)stack_chain->callstack_top;
	iterate_callstack(top,bottom,print_stack_frame);
}

void dump_cell(CELL cell)
{
	print_cell_hex_pad(cell); print_string(": ");

	cell = get(cell);

	print_cell_hex_pad(cell); print_string(" tag "); print_cell(TAG(cell));

	switch(TAG(cell))
	{
	case OBJECT_TYPE:
	case BIGNUM_TYPE:
	case FLOAT_TYPE:
		if(cell == F)
			print_string(" -- F");
		else if(cell < TYPE_COUNT<<TAG_BITS)
		{
			print_string(" -- possible header: ");
			print_cell(cell>>TAG_BITS);
		}
		else if(cell >= data_heap->segment->start
			&& cell < data_heap->segment->end)
		{
			CELL header = get(UNTAG(cell));
			CELL type = header>>TAG_BITS;
			print_string(" -- object; ");
			if(TAG(header) == 0 && type < TYPE_COUNT)
			{
				print_string(" type "); print_cell(type);
			}
			else
				print_string(" header corrupt");
		}
		break;
	}
	
	nl();
}

void dump_memory(CELL from, CELL to)
{
	from = UNTAG(from);

	for(; from <= to; from += CELLS)
		dump_cell(from);
}

void dump_zone(F_ZONE *z)
{
	print_string("Start="); print_cell(z->start);
	print_string(", size="); print_cell(z->size);
	print_string(", here="); print_cell(z->here - z->start); nl();
}

void dump_generations(void)
{
	CELL i;

	print_string("Nursery: ");
	dump_zone(&nursery);
	
	for(i = 1; i < data_heap->gen_count; i++)
	{
		print_string("Generation "); print_cell(i); print_string(": ");
		dump_zone(&data_heap->generations[i]);
	}

	for(i = 0; i < data_heap->gen_count; i++)
	{
		print_string("Semispace "); print_cell(i); print_string(": ");
		dump_zone(&data_heap->semispaces[i]);
	}

	print_string("Cards: base=");
	print_cell((CELL)data_heap->cards);
	print_string(", size=");
	print_cell((CELL)(data_heap->cards_end - data_heap->cards));
	nl();
}

void dump_objects(F_FIXNUM type)
{
	gc();
	begin_scan();

	CELL obj;
	while((obj = next_object()) != F)
	{
		if(type == -1 || type_of(obj) == type)
		{
			print_cell_hex_pad(obj);
			print_string(" ");
			print_nested_obj(obj,2);
			nl();
		}
	}

	/* end scan */
	gc_off = false;
}

CELL look_for;
CELL obj;

void find_data_references_step(CELL *scan)
{
	if(look_for == *scan)
	{
		print_cell_hex_pad(obj);
		print_string(" ");
		print_nested_obj(obj,2);
		nl();
	}
}

void find_data_references(CELL look_for_)
{
	look_for = look_for_;

	begin_scan();

	while((obj = next_object()) != F)
		do_slots(UNTAG(obj),find_data_references_step);

	/* end scan */
	gc_off = false;
}

/* Dump all code blocks for debugging */
void dump_code_heap(void)
{
	CELL reloc_size = 0, literal_size = 0;

	F_BLOCK *scan = first_block(&code_heap);

	while(scan)
	{
		char *status;
		switch(scan->status)
		{
		case B_FREE:
			status = "free";
			break;
		case B_ALLOCATED:
			reloc_size += object_size(((F_CODE_BLOCK *)scan)->relocation);
			literal_size += object_size(((F_CODE_BLOCK *)scan)->literals);
			status = "allocated";
			break;
		case B_MARKED:
			reloc_size += object_size(((F_CODE_BLOCK *)scan)->relocation);
			literal_size += object_size(((F_CODE_BLOCK *)scan)->literals);
			status = "marked";
			break;
		default:
			status = "invalid";
			break;
		}

		print_cell_hex((CELL)scan); print_string(" ");
		print_cell_hex(scan->size); print_string(" ");
		print_string(status); print_string("\n");

		scan = next_block(&code_heap,scan);
	}
	
	print_cell(reloc_size); print_string(" bytes of relocation data\n");
	print_cell(literal_size); print_string(" bytes of literal data\n");
}

void factorbug(void)
{
	if(fep_disabled)
	{
		print_string("Low level debugger disabled\n");
		exit(1);
	}

	/* open_console(); */

	print_string("Starting low level debugger...\n");
	print_string("  Basic commands:\n");
	print_string("q                -- continue executing Factor - NOT SAFE\n");
	print_string("im               -- save image to fep.image\n");
	print_string("x                -- exit Factor\n");
	print_string("  Advanced commands:\n");
	print_string("d <addr> <count> -- dump memory\n");
	print_string("u <addr>         -- dump object at tagged <addr>\n");
	print_string(". <addr>         -- print object at tagged <addr>\n");
	print_string("t                -- toggle output trimming\n");
	print_string("s r              -- dump data, retain stacks\n");
	print_string(".s .r .c         -- print data, retain, call stacks\n");
	print_string("e                -- dump environment\n");
	print_string("g                -- dump generations\n");
	print_string("card <addr>      -- print card containing address\n");
	print_string("addr <card>      -- print address containing card\n");
	print_string("data             -- data heap dump\n");
	print_string("words            -- words dump\n");
	print_string("tuples           -- tuples dump\n");
	print_string("refs <addr>      -- find data heap references to object\n");
	print_string("push <addr>      -- push object on data stack - NOT SAFE\n");
	print_string("code             -- code heap dump\n");

	bool seen_command = false;

	for(;;)
	{
		char cmd[1024];

		print_string("READY\n");
		fflush(stdout);

		if(scanf("%1000s",cmd) <= 0)
		{
			if(!seen_command)
			{
				/* If we exit with an EOF immediately, then
				dump stacks. This is useful for builder and
				other cases where Factor is run with stdin
				redirected to /dev/null */
				fep_disabled = true;

				print_datastack();
				print_retainstack();
				print_callstack();
			}

			exit(1);
		}

		seen_command = true;

		if(strcmp(cmd,"d") == 0)
		{
			CELL addr = read_cell_hex();
			if(scanf(" ") < 0) break;
			CELL count = read_cell_hex();
			dump_memory(addr,addr+count);
		}
		else if(strcmp(cmd,"u") == 0)
		{
			CELL addr = read_cell_hex();
			CELL count = object_size(addr);
			dump_memory(addr,addr+count);
		}
		else if(strcmp(cmd,".") == 0)
		{
			CELL addr = read_cell_hex();
			print_obj(addr);
			print_string("\n");
		}
		else if(strcmp(cmd,"t") == 0)
			full_output = !full_output;
		else if(strcmp(cmd,"s") == 0)
			dump_memory(ds_bot,ds);
		else if(strcmp(cmd,"r") == 0)
			dump_memory(rs_bot,rs);
		else if(strcmp(cmd,".s") == 0)
			print_datastack();
		else if(strcmp(cmd,".r") == 0)
			print_retainstack();
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
			CELL addr = read_cell_hex();
			print_cell_hex((CELL)ADDR_TO_CARD(addr));
			nl();
		}
		else if(strcmp(cmd,"addr") == 0)
		{
			CELL card = read_cell_hex();
			print_cell_hex((CELL)CARD_TO_ADDR(card));
			nl();
		}
		else if(strcmp(cmd,"q") == 0)
			return;
		else if(strcmp(cmd,"x") == 0)
			exit(1);
		else if(strcmp(cmd,"im") == 0)
			save_image(STRING_LITERAL("fep.image"));
		else if(strcmp(cmd,"data") == 0)
			dump_objects(-1);
		else if(strcmp(cmd,"refs") == 0)
		{
			CELL addr = read_cell_hex();
			print_string("Data heap references:\n");
			find_data_references(addr);
			nl();
		}
		else if(strcmp(cmd,"words") == 0)
			dump_objects(WORD_TYPE);
		else if(strcmp(cmd,"tuples") == 0)
			dump_objects(TUPLE_TYPE);
		else if(strcmp(cmd,"push") == 0)
		{
			CELL addr = read_cell_hex();
			dpush(addr);
		}
		else if(strcmp(cmd,"code") == 0)
			dump_code_heap();
		else
			print_string("unknown command\n");
	}
}

void primitive_die(void)
{
	print_string("The die word was called by the library. Unless you called it yourself,\n");
	print_string("you have triggered a bug in Factor. Please report.\n");
	factorbug();
}
