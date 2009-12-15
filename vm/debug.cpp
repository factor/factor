#include "master.hpp"

namespace factor
{

std::ostream &operator<<(std::ostream &out, const string *str)
{
	for(cell i = 0; i < string_capacity(str); i++)
		out << (char)str->nth(i);
	return out;
}

void factor_vm::print_word(word *word, cell nesting)
{
	if(tagged<object>(word->vocabulary).type_p(STRING_TYPE))
		std::cout << untag<string>(word->vocabulary) << ":";

	if(tagged<object>(word->name).type_p(STRING_TYPE))
		std::cout << untag<string>(word->name);
	else
	{
		std::cout << "#<not a string: ";
		print_nested_obj(word->name,nesting);
		std::cout << ">";
	}
}

void factor_vm::print_factor_string(string *str)
{
	std::cout << '"' << str << '"';
}

void factor_vm::print_array(array *array, cell nesting)
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
		std::cout << " ";
		print_nested_obj(array_nth(array,i),nesting);
	}

	if(trimmed)
		std::cout << "...";
}

void factor_vm::print_tuple(tuple *tuple, cell nesting)
{
	tuple_layout *layout = untag<tuple_layout>(tuple->layout);
	cell length = to_fixnum(layout->size);

	std::cout << " ";
	print_nested_obj(layout->klass,nesting);

	bool trimmed;
	if(length > 10 && !full_output)
	{
		trimmed = true;
		length = 10;
	}
	else
		trimmed = false;

	for(cell i = 0; i < length; i++)
	{
		std::cout << " ";
		print_nested_obj(tuple->data()[i],nesting);
	}

	if(trimmed)
		std::cout << "...";
}

void factor_vm::print_nested_obj(cell obj, fixnum nesting)
{
	if(nesting <= 0 && !full_output)
	{
		std::cout << " ... ";
		return;
	}

	quotation *quot;

	switch(tagged<object>(obj).type())
	{
	case FIXNUM_TYPE:
		std::cout << untag_fixnum(obj);
		break;
	case WORD_TYPE:
		print_word(untag<word>(obj),nesting - 1);
		break;
	case STRING_TYPE:
		print_factor_string(untag<string>(obj));
		break;
	case F_TYPE:
		std::cout << "f";
		break;
	case TUPLE_TYPE:
		std::cout << "T{";
		print_tuple(untag<tuple>(obj),nesting - 1);
		std::cout << " }";
		break;
	case ARRAY_TYPE:
		std::cout << "{";
		print_array(untag<array>(obj),nesting - 1);
		std::cout << " }";
		break;
	case QUOTATION_TYPE:
		std::cout << "[";
		quot = untag<quotation>(obj);
		print_array(untag<array>(quot->array),nesting - 1);
		std::cout << " ]";
		break;
	default:
		std::cout << "#<type " << tagged<object>(obj).type() << " @ ";
		std::cout << std::hex << obj << std::dec << ">";
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
		std::cout << std::endl;
	}
}

void factor_vm::print_datastack()
{
	std::cout << "==== DATA STACK:\n";
	print_objects((cell *)ds_bot,(cell *)ds);
}

void factor_vm::print_retainstack()
{
	std::cout << "==== RETAIN STACK:\n";
	print_objects((cell *)rs_bot,(cell *)rs);
}

struct stack_frame_printer {
	factor_vm *parent;

	explicit stack_frame_printer(factor_vm *parent_) : parent(parent_) {}
	void operator()(stack_frame *frame)
	{
		std::cout << "frame: " << std::hex << (cell)frame << std::dec << std::endl;
		std::cout << "executing: ";
		parent->print_obj(parent->frame_executing(frame));
		std::cout << std::endl;
		std::cout << "scan: ";
		parent->print_obj(parent->frame_scan(frame));
		std::cout << std::endl;
		std::cout << "word/quot addr: ";
		std::cout << std::hex << (cell)parent->frame_executing(frame) << std::dec;
		std::cout << std::endl;
		std::cout << "word/quot xt: ";
		std::cout << std::hex << (cell)frame->xt << std::dec;
		std::cout << std::endl;
		std::cout << "return address: ";
		std::cout << std::hex << (cell)FRAME_RETURN_ADDRESS(frame,parent) << std::dec;
		std::cout << std::endl;
	}
};

void factor_vm::print_callstack()
{
	std::cout << "==== CALL STACK:\n";
	stack_frame_printer printer(this);
	iterate_callstack(ctx,printer);
}

struct padded_address {
	cell value;

	explicit padded_address(cell value_) : value(value_) {}
};

std::ostream &operator<<(std::ostream &out, const padded_address &value)
{
	char prev = out.fill('0');
	out.width(sizeof(cell) * 2);
	out << std::hex << value.value << std::dec;
	out.fill(prev);
	return out;
}

void factor_vm::dump_cell(cell x)
{
	std::cout << padded_address(x) << ": ";
	x = *(cell *)x;
	std::cout << padded_address(x) << " tag " << TAG(x) << std::endl;
}

void factor_vm::dump_memory(cell from, cell to)
{
	from = UNTAG(from);

	for(; from <= to; from += sizeof(cell))
		dump_cell(from);
}

template<typename Generation>
void factor_vm::dump_generation(const char *name, Generation *gen)
{
	std::cout << name << ": ";
	std::cout << "Start=" << gen->start;
	std::cout << ", size=" << gen->size;
	std::cout << ", end=" << gen->end;
	std::cout << std::endl;
}

void factor_vm::dump_generations()
{
	dump_generation("Nursery",&nursery);
	dump_generation("Aging",data->aging);
	dump_generation("Tenured",data->tenured);

	std::cout << "Cards:";
	std::cout << "base=" << (cell)data->cards << ", ";
	std::cout << "size=" << (cell)(data->cards_end - data->cards) << std::endl;
}

struct object_dumper {
	factor_vm *parent;
	cell type;

	explicit object_dumper(factor_vm *parent_, cell type_) :
		parent(parent_), type(type_) {}

	void operator()(object *obj)
	{
		if(type == TYPE_COUNT || obj->type() == type)
		{
			std::cout << padded_address((cell)obj) << " ";
			parent->print_nested_obj(tag_dynamic(obj),2);
			std::cout << std::endl;
		}
	}
};

void factor_vm::dump_objects(cell type)
{
	primitive_full_gc();
	object_dumper dumper(this,type);
	each_object(dumper);
}

struct data_reference_slot_visitor {
	cell look_for;
	object *obj;
	factor_vm *parent;

	explicit data_reference_slot_visitor(cell look_for_, object *obj_, factor_vm *parent_) :
		look_for(look_for_), obj(obj_), parent(parent_) { }

	void operator()(cell *scan)
	{
		if(look_for == *scan)
		{
			std::cout << padded_address((cell)obj) << " ";
			parent->print_nested_obj(tag_dynamic(obj),2);
			std::cout << std::endl;
		}
	}
};

struct data_reference_object_visitor {
	cell look_for;
	factor_vm *parent;

	explicit data_reference_object_visitor(cell look_for_, factor_vm *parent_) :
		look_for(look_for_), parent(parent_) {}

	void operator()(object *obj)
	{
		data_reference_slot_visitor visitor(look_for,obj,parent);
		obj->each_slot(visitor);
	}
};

void factor_vm::find_data_references(cell look_for)
{
	data_reference_object_visitor visitor(look_for,this);
	each_object(visitor);
}

struct code_block_printer {
	factor_vm *parent;
	cell reloc_size, parameter_size;

	explicit code_block_printer(factor_vm *parent_) :
		parent(parent_), reloc_size(0), parameter_size(0) {}

	void operator()(code_block *scan, cell size)
	{
		const char *status;
		if(scan->free_p())
			status = "free";
		else
		{
			reloc_size += parent->object_size(scan->relocation);
			parameter_size += parent->object_size(scan->parameters);

			if(parent->code->marked_p(scan))
				status = "marked";
			else
				status = "allocated";

			std::cout << std::hex << (cell)scan << std::dec << " ";
			std::cout << std::hex << size << std::dec << " ";
			std::cout << status << std::endl;
		}
	}
};

/* Dump all code blocks for debugging */
void factor_vm::dump_code_heap()
{
	code_block_printer printer(this);
	code->allocator->iterate(printer);
	std::cout << printer.reloc_size << " bytes used by relocation tables\n";
	std::cout << printer.parameter_size << " bytes used by parameter tables\n";
}

void factor_vm::factorbug()
{
	if(fep_disabled)
	{
		std::cout << "Low level debugger disabled\n";
		exit(1);
	}

	/* open_console(); */

	std::cout << "Starting low level debugger...\n";
	std::cout << "  Basic commands:\n";
	std::cout << "q                -- continue executing Factor - NOT SAFE\n";
	std::cout << "im               -- save image to fep.image\n";
	std::cout << "x                -- exit Factor\n";
	std::cout << "  Advanced commands:\n";
	std::cout << "d <addr> <count> -- dump memory\n";
	std::cout << "u <addr>         -- dump object at tagged <addr>\n";
	std::cout << ". <addr>         -- print object at tagged <addr>\n";
	std::cout << "t                -- toggle output trimming\n";
	std::cout << "s r              -- dump data, retain stacks\n";
	std::cout << ".s .r .c         -- print data, retain, call stacks\n";
	std::cout << "e                -- dump environment\n";
	std::cout << "g                -- dump generations\n";
	std::cout << "data             -- data heap dump\n";
	std::cout << "words            -- words dump\n";
	std::cout << "tuples           -- tuples dump\n";
	std::cout << "refs <addr>      -- find data heap references to object\n";
	std::cout << "push <addr>      -- push object on data stack - NOT SAFE\n";
	std::cout << "code             -- code heap dump\n";

	bool seen_command = false;

	for(;;)
	{
		char cmd[1024];

		std::cout << "READY\n";
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
			std::cout << std::endl;
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
			for(cell i = 0; i < special_object_count; i++)
				dump_cell((cell)&special_objects[i]);
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
			std::cout << "Data heap references:\n";
			find_data_references(addr);
			std::cout << std::endl;
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
			std::cout << "unknown command\n";
	}
}

void factor_vm::primitive_die()
{
	std::cout << "The die word was called by the library. Unless you called it yourself,\n";
	std::cout << "you have triggered a bug in Factor. Please report.\n";
	factorbug();
}

}
