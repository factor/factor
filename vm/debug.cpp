#include "master.hpp"

namespace factor
{

void factor_vm::print_chars(string* str)
{
	cell i;
	for(i = 0; i < string_capacity(str); i++)
		putchar(string_nth(str,i));
}

void factor_vm::print_word(word* word, cell nesting)
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

void factor_vm::print_factor_string(string* str)
{
	putchar('"');
	print_chars(str);
	putchar('"');
}

void factor_vm::print_array(array* array, cell nesting)
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

void factor_vm::print_tuple(tuple *tuple, cell nesting)
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

void factor_vm::print_nested_obj(cell obj, fixnum nesting)
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

void factor_vm::print_obj(cell obj)
{
	print_nested_obj(obj,10);
}

void factor_vm::print_objects(cell *start, cell *end)
{
	for(; start <= end; start++)
	{
		print_obj(*start);
		nl();
	}
}

void factor_vm::print_datastack()
{
	print_string("==== DATA STACK:\n");
	print_objects((cell *)ds_bot,(cell *)ds);
}

void factor_vm::print_retainstack()
{
	print_string("==== RETAIN STACK:\n");
	print_objects((cell *)rs_bot,(cell *)rs);
}

struct stack_frame_printer {
	factor_vm *parent;

	explicit stack_frame_printer(factor_vm *parent_) : parent(parent_) {}
	void operator()(stack_frame *frame)
	{
		parent->print_obj(parent->frame_executing(frame));
		print_string("\n");
		parent->print_obj(parent->frame_scan(frame));
		print_string("\n");
		print_string("word/quot addr: ");
		print_cell_hex((cell)parent->frame_executing(frame));
		print_string("\n");
		print_string("word/quot xt: ");
		print_cell_hex((cell)frame->xt);
		print_string("\n");
		print_string("return address: ");
		print_cell_hex((cell)FRAME_RETURN_ADDRESS(frame,parent));
		print_string("\n");
	}
};

void factor_vm::print_callstack()
{
	print_string("==== CALL STACK:\n");
	stack_frame_printer printer(this);
	iterate_callstack(ctx,printer);
}

void factor_vm::dump_cell(cell x)
{
	print_cell_hex_pad(x); print_string(": ");
	x = *(cell *)x;
	print_cell_hex_pad(x); print_string(" tag "); print_cell(TAG(x));
	nl();
}

void factor_vm::dump_memory(cell from, cell to)
{
	from = UNTAG(from);

	for(; from <= to; from += sizeof(cell))
		dump_cell(from);
}

void factor_vm::dump_zone(const char *name, zone *z)
{
	print_string(name); print_string(": ");
	print_string("Start="); print_cell(z->start);
	print_string(", size="); print_cell(z->size);
	print_string(", here="); print_cell(z->here - z->start); nl();
}

void factor_vm::dump_generations()
{
	dump_zone("Nursery",&nursery);
	dump_zone("Aging",data->aging);
	dump_zone("Tenured",data->tenured);

	print_string("Cards: base=");
	print_cell((cell)data->cards);
	print_string(", size=");
	print_cell((cell)(data->cards_end - data->cards));
	nl();
}

void factor_vm::dump_objects(cell type)
{
	primitive_full_gc();
	begin_scan();

	cell obj;
	while(to_boolean(obj = next_object()))
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

struct data_references_finder {
	cell look_for, obj;
	factor_vm *parent;

	explicit data_references_finder(cell look_for_, cell obj_, factor_vm *parent_)
		: look_for(look_for_), obj(obj_), parent(parent_) { }

	void operator()(cell *scan)
	{
		if(look_for == *scan)
		{
			print_cell_hex_pad(obj);
			print_string(" ");
			parent->print_nested_obj(obj,2);
			nl();
		}
	}
};

void factor_vm::find_data_references(cell look_for)
{
	begin_scan();

	cell obj;

	while(to_boolean(obj = next_object()))
	{
		data_references_finder finder(look_for,obj,this);
		do_slots(UNTAG(obj),finder);
	}

	end_scan();
}

struct code_block_printer {
	factor_vm *parent;
	cell reloc_size, literal_size;

	code_block_printer(factor_vm *parent_) :
		parent(parent_), reloc_size(0), literal_size(0) {}

	void operator()(heap_block *scan, cell size)
	{
		const char *status;
		if(scan->free_p())
			status = "free";
		else if(parent->code->state->is_marked_p(scan))
		{
			reloc_size += parent->object_size(((code_block *)scan)->relocation);
			literal_size += parent->object_size(((code_block *)scan)->literals);
			status = "marked";
		}
		else
		{
			reloc_size += parent->object_size(((code_block *)scan)->relocation);
			literal_size += parent->object_size(((code_block *)scan)->literals);
			status = "allocated";
		}

		print_cell_hex((cell)scan); print_string(" ");
		print_cell_hex(size); print_string(" ");
		print_string(status); print_string("\n");
	}
};

/* Dump all code blocks for debugging */
void factor_vm::dump_code_heap()
{
	code_block_printer printer(this);
	code->iterate_heap(printer);
	print_cell(printer.reloc_size); print_string(" bytes of relocation data\n");
	print_cell(printer.literal_size); print_string(" bytes of literal data\n");
}

void factor_vm::factorbug()
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

void factor_vm::primitive_die()
{
	print_string("The die word was called by the library. Unless you called it yourself,\n");
	print_string("you have triggered a bug in Factor. Please report.\n");
	factorbug();
}

}
