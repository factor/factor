#include "master.hpp"

namespace factor
{

static bool fep_disabled;
static bool full_output;

void print_chars(string* str)
{
	cell i;
	for(i = 0; i < string_capacity(str); i++)
		putchar(string_nth(str,i));
}

void print_word(word* word, cell nesting)
{
	if(tagged<object>(word->vocabulary).type_p(STRING_TYPE))
	{
		print_chars(untag<string>(word->vocabulary));
		print_string(":");
	}

	if(tagged<object>(word->name).type_p(STRING_TYPE))
		print_chars(untag<string>(word->name));
	else
	{
		print_string("#<not a string: ");
		print_nested_obj(word->name,nesting);
		print_string(">");
	}
}

void print_factor_string(string* str)
{
	putchar('"');
	print_chars(str);
	putchar('"');
}

void print_array(array* array, cell nesting)
{
	cell length = array_capacity(array);
	cell i;
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

void print_tuple(tuple *tuple, cell nesting)
{
	tuple_layout *layout = untag<tuple_layout>(tuple->layout);
	cell length = to_fixnum(layout->size);

	print_string(" ");
	print_nested_obj(layout->klass,nesting);

	cell i;
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
		print_nested_obj(tuple->data()[i],nesting);
	}

	if(trimmed)
		print_string("...");
}

void print_nested_obj(cell obj, fixnum nesting)
{
	if(nesting <= 0 && !full_output)
	{
		print_string(" ... ");
		return;
	}

	quotation *quot;

	switch(tagged<object>(obj).type())
	{
	case FIXNUM_TYPE:
		print_fixnum(untag_fixnum(obj));
		break;
	case WORD_TYPE:
		print_word(untag<word>(obj),nesting - 1);
		break;
	case STRING_TYPE:
		print_factor_string(untag<string>(obj));
		break;
	case F_TYPE:
		print_string("f");
		break;
	case TUPLE_TYPE:
		print_string("T{");
		print_tuple(untag<tuple>(obj),nesting - 1);
		print_string(" }");
		break;
	case ARRAY_TYPE:
		print_string("{");
		print_array(untag<array>(obj),nesting - 1);
		print_string(" }");
		break;
	case QUOTATION_TYPE:
		print_string("[");
		quot = untag<quotation>(obj);
		print_array(untag<array>(quot->array),nesting - 1);
		print_string(" ]");
		break;
	default:
		print_string("#<type ");
		print_cell(tagged<object>(obj).type());
		print_string(" @ ");
		print_cell_hex(obj);
		print_string(">");
		break;
	}
}

void print_obj(cell obj)
{
	print_nested_obj(obj,10);
}

void print_objects(cell *start, cell *end)
{
	for(; start <= end; start++)
	{
		print_obj(*start);
		nl();
	}
}

void print_datastack()
{
	print_string("==== DATA STACK:\n");
	print_objects((cell *)ds_bot,(cell *)ds);
}

void print_retainstack()
{
	print_string("==== RETAIN STACK:\n");
	print_objects((cell *)rs_bot,(cell *)rs);
}

void print_stack_frame(stack_frame *frame)
{
	print_obj(frame_executing(frame));
	print_string("\n");
	print_obj(frame_scan(frame));
	print_string("\n");
	print_cell_hex((cell)frame_executing(frame));
	print_string(" ");
	print_cell_hex((cell)frame->xt);
	print_string("\n");
}

void print_callstack()
{
	print_string("==== CALL STACK:\n");
	cell bottom = (cell)stack_chain->callstack_bottom;
	cell top = (cell)stack_chain->callstack_top;
	iterate_callstack(top,bottom,print_stack_frame);
}

void dump_cell(cell x)
{
	print_cell_hex_pad(x); print_string(": ");
	x = *(cell *)x;
	print_cell_hex_pad(x); print_string(" tag "); print_cell(TAG(x));
	nl();
}

void dump_memory(cell from, cell to)
{
	from = UNTAG(from);

	for(; from <= to; from += sizeof(cell))
		dump_cell(from);
}

void dump_zone(zone *z)
{
	print_string("Start="); print_cell(z->start);
	print_string(", size="); print_cell(z->size);
	print_string(", here="); print_cell(z->here - z->start); nl();
}

void dump_generations()
{
	cell i;

	print_string("Nursery: ");
	dump_zone(&nursery);
	
	for(i = 1; i < data->gen_count; i++)
	{
		print_string("Generation "); print_cell(i); print_string(": ");
		dump_zone(&data->generations[i]);
	}

	for(i = 0; i < data->gen_count; i++)
	{
		print_string("Semispace "); print_cell(i); print_string(": ");
		dump_zone(&data->semispaces[i]);
	}

	print_string("Cards: base=");
	print_cell((cell)data->cards);
	print_string(", size=");
	print_cell((cell)(data->cards_end - data->cards));
	nl();
}

void dump_objects(cell type)
{
	gc();
	begin_scan();

	cell obj;
	while((obj = next_object()) != F)
	{
		if(type == TYPE_COUNT || tagged<object>(obj).type_p(type))
		{
			print_cell_hex_pad(obj);
			print_string(" ");
			print_nested_obj(obj,2);
			nl();
		}
	}

	end_scan();
}

cell look_for;
cell obj;

void find_data_references_step(cell *scan)
{
	if(look_for == *scan)
	{
		print_cell_hex_pad(obj);
		print_string(" ");
		print_nested_obj(obj,2);
		nl();
	}
}

void find_data_references(cell look_for_)
{
	look_for = look_for_;

	begin_scan();

	while((obj = next_object()) != F)
		do_slots(UNTAG(obj),find_data_references_step);

	end_scan();
}

/* Dump all code blocks for debugging */
void dump_code_heap()
{
	cell reloc_size = 0, literal_size = 0;

	heap_block *scan = first_block(&code);

	while(scan)
	{
		const char *status;
		switch(scan->status)
		{
		case B_FREE:
			status = "free";
			break;
		case B_ALLOCATED:
			reloc_size += object_size(((code_block *)scan)->relocation);
			literal_size += object_size(((code_block *)scan)->literals);
			status = "allocated";
			break;
		case B_MARKED:
			reloc_size += object_size(((code_block *)scan)->relocation);
			literal_size += object_size(((code_block *)scan)->literals);
			status = "marked";
			break;
		default:
			status = "invalid";
			break;
		}

		print_cell_hex((cell)scan); print_string(" ");
		print_cell_hex(scan->size); print_string(" ");
		print_string(status); print_string("\n");

		scan = next_block(&code,scan);
	}
	
	print_cell(reloc_size); print_string(" bytes of relocation data\n");
	print_cell(literal_size); print_string(" bytes of literal data\n");
}

void factorbug()
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
			cell addr = read_cell_hex();
			if(scanf(" ") < 0) break;
			cell count = read_cell_hex();
			dump_memory(addr,addr+count);
		}
		else if(strcmp(cmd,"u") == 0)
		{
			cell addr = read_cell_hex();
			cell count = object_size(addr);
			dump_memory(addr,addr+count);
		}
		else if(strcmp(cmd,".") == 0)
		{
			cell addr = read_cell_hex();
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
				dump_cell((cell)&userenv[i]);
		}
		else if(strcmp(cmd,"g") == 0)
			dump_generations();
		else if(strcmp(cmd,"card") == 0)
		{
			cell addr = read_cell_hex();
			print_cell_hex((cell)addr_to_card(addr));
			nl();
		}
		else if(strcmp(cmd,"addr") == 0)
		{
			card *ptr = (card *)read_cell_hex();
			print_cell_hex(card_to_addr(ptr));
			nl();
		}
		else if(strcmp(cmd,"q") == 0)
			return;
		else if(strcmp(cmd,"x") == 0)
			exit(1);
		else if(strcmp(cmd,"im") == 0)
			save_image(STRING_LITERAL("fep.image"));
		else if(strcmp(cmd,"data") == 0)
			dump_objects(TYPE_COUNT);
		else if(strcmp(cmd,"refs") == 0)
		{
			cell addr = read_cell_hex();
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
			cell addr = read_cell_hex();
			dpush(addr);
		}
		else if(strcmp(cmd,"code") == 0)
			dump_code_heap();
		else
			print_string("unknown command\n");
	}
}

PRIMITIVE(die)
{
	print_string("The die word was called by the library. Unless you called it yourself,\n");
	print_string("you have triggered a bug in Factor. Please report.\n");
	factorbug();
}

}
