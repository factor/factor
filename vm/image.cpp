#include "master.hpp"

namespace factor
{

/* Certain special objects in the image are known to the runtime */
void factor_vm::init_objects(image_header *h)
{
	memcpy(special_objects,h->special_objects,sizeof(special_objects));

	true_object = h->true_object;
	bignum_zero = h->bignum_zero;
	bignum_pos_one = h->bignum_pos_one;
	bignum_neg_one = h->bignum_neg_one;
}

void factor_vm::load_data_heap(FILE *file, image_header *h, vm_parameters *p)
{
	p->tenured_size = std::max((h->data_size * 3) / 2,p->tenured_size);

	init_data_heap(p->young_size,
		p->aging_size,
		p->tenured_size);

	fixnum bytes_read = safe_fread((void*)data->tenured->start,1,h->data_size,file);

	if((cell)bytes_read != h->data_size)
	{
		std::cout << "truncated image: " << bytes_read << " bytes read, ";
		std::cout << h->data_size << " bytes expected\n";
		fatal_error("load_data_heap failed",0);
	}

	data->tenured->initial_free_list(h->data_size);
}

void factor_vm::load_code_heap(FILE *file, image_header *h, vm_parameters *p)
{
	if(h->code_size > p->code_size)
		fatal_error("Code heap too small to fit image",h->code_size);

	init_code_heap(p->code_size);

	if(h->code_size != 0)
	{
		size_t bytes_read = safe_fread(code->allocator->first_block(),1,h->code_size,file);
		if(bytes_read != h->code_size)
		{
			std::cout << "truncated image: " << bytes_read << " bytes read, ";
			std::cout << h->code_size << " bytes expected\n";
			fatal_error("load_code_heap failed",0);
		}
	}

	code->allocator->initial_free_list(h->code_size);
}

struct startup_fixup {
	cell data_offset;
	cell code_offset;

	explicit startup_fixup(cell data_offset_, cell code_offset_) :
		data_offset(data_offset_), code_offset(code_offset_) {}

	object *fixup_data(object *obj)
	{
		return (object *)((cell)obj + data_offset);
	}

	code_block *fixup_code(code_block *obj)
	{
		return (code_block *)((cell)obj + code_offset);
	}

	object *translate_data(const object *obj)
	{
		return fixup_data((object *)obj);
	}

	code_block *translate_code(const code_block *compiled)
	{
		return fixup_code((code_block *)compiled);
	}

	cell size(const object *obj)
	{
		return obj->size(*this);
	}

	cell size(code_block *compiled)
	{
		return compiled->size(*this);
	}
};

struct start_object_updater {
	factor_vm *parent;
	startup_fixup fixup;
	slot_visitor<startup_fixup> data_visitor;
	code_block_visitor<startup_fixup> code_visitor;

	start_object_updater(factor_vm *parent_, startup_fixup fixup_) :
		parent(parent_),
		fixup(fixup_),
		data_visitor(slot_visitor<startup_fixup>(parent_,fixup_)),
		code_visitor(code_block_visitor<startup_fixup>(parent_,fixup_)) {}

	void operator()(object *obj, cell size)
	{
		parent->data->tenured->starts.record_object_start_offset(obj);

		data_visitor.visit_slots(obj);

		switch(obj->type())
		{
		case ALIEN_TYPE:
			{

				alien *ptr = (alien *)obj;

				if(to_boolean(ptr->base))
					ptr->update_address();
				else
					ptr->expired = parent->true_object;
				break;
			}
		case DLL_TYPE:
			{
				parent->ffi_dlopen((dll *)obj);
				break;
			}
		default:
			{
				code_visitor.visit_object_code_block(obj);
				break;
			}
		}
	}
};

void factor_vm::fixup_data(cell data_offset, cell code_offset)
{
	startup_fixup fixup(data_offset,code_offset);
	slot_visitor<startup_fixup> data_workhorse(this,fixup);
	data_workhorse.visit_roots();

	start_object_updater updater(this,fixup);
	data->tenured->iterate(updater,fixup);
}

struct startup_code_block_relocation_visitor {
	factor_vm *parent;
	startup_fixup fixup;
	slot_visitor<startup_fixup> data_visitor;

	startup_code_block_relocation_visitor(factor_vm *parent_, startup_fixup fixup_) :
		parent(parent_),
		fixup(fixup_),
		data_visitor(slot_visitor<startup_fixup>(parent_,fixup_)) {}

	void operator()(instruction_operand op)
	{
		code_block *compiled = op.parent_code_block();
		cell old_offset = op.rel_offset() + (cell)compiled->entry_point() - fixup.code_offset;

		switch(op.rel_type())
		{
		case RT_LITERAL:
			{
				cell value = op.load_value(old_offset);
				if(immediate_p(value))
					op.store_value(value);
				else
					op.store_value(RETAG(fixup.fixup_data(untag<object>(value)),TAG(value)));
				break;
			}
		case RT_ENTRY_POINT:
		case RT_ENTRY_POINT_PIC:
		case RT_ENTRY_POINT_PIC_TAIL:
		case RT_HERE:
			{
				cell value = op.load_value(old_offset);
				cell offset = value & (data_alignment - 1);
				op.store_value((cell)fixup.fixup_code((code_block *)value) + offset);
				break;
			}
		case RT_UNTAGGED:
			break;
		default:
			parent->store_external_address(op);
			break;
		}
	}
};

struct startup_code_block_updater {
	factor_vm *parent;
	startup_fixup fixup;

	startup_code_block_updater(factor_vm *parent_, startup_fixup fixup_) :
		parent(parent_), fixup(fixup_) {}

	void operator()(code_block *compiled, cell size)
	{
		slot_visitor<startup_fixup> data_visitor(parent,fixup);
		data_visitor.visit_code_block_objects(compiled);

		startup_code_block_relocation_visitor code_visitor(parent,fixup);
		compiled->each_instruction_operand(code_visitor);
	}
};

void factor_vm::fixup_code(cell data_offset, cell code_offset)
{
	startup_fixup fixup(data_offset,code_offset);
	startup_code_block_updater updater(this,fixup);
	code->allocator->iterate(updater,fixup);
}

/* Read an image file from disk, only done once during startup */
/* This function also initializes the data and code heaps */
void factor_vm::load_image(vm_parameters *p)
{
	FILE *file = OPEN_READ(p->image_path);
	if(file == NULL)
	{
		std::cout << "Cannot open image file: " << p->image_path << std::endl;
		std::cout << strerror(errno) << std::endl;
		exit(1);
	}

	image_header h;
	if(safe_fread(&h,sizeof(image_header),1,file) != 1)
		fatal_error("Cannot read image header",0);

	if(h.magic != image_magic)
		fatal_error("Bad image: magic number check failed",h.magic);

	if(h.version != image_version)
		fatal_error("Bad image: version number check failed",h.version);
	
	load_data_heap(file,&h,p);
	load_code_heap(file,&h,p);

	safe_fclose(file);

	init_objects(&h);

	cell data_offset = data->tenured->start - h.data_relocation_base;
	cell code_offset = code->allocator->start - h.code_relocation_base;

	fixup_data(data_offset,code_offset);
	fixup_code(data_offset,code_offset);

	/* Store image path name */
	special_objects[OBJ_IMAGE] = allot_alien(false_object,(cell)p->image_path);
}

/* Save the current image to disk */
bool factor_vm::save_image(const vm_char *saving_filename, const vm_char *filename)
{
	FILE* file;
	image_header h;

	file = OPEN_WRITE(saving_filename);
	if(file == NULL)
	{
		std::cout << "Cannot open image file: " << saving_filename << std::endl;
		std::cout << strerror(errno) << std::endl;
		return false;
	}

	h.magic = image_magic;
	h.version = image_version;
	h.data_relocation_base = data->tenured->start;
	h.data_size = data->tenured->occupied_space();
	h.code_relocation_base = code->allocator->start;
	h.code_size = code->allocator->occupied_space();

	h.true_object = true_object;
	h.bignum_zero = bignum_zero;
	h.bignum_pos_one = bignum_pos_one;
	h.bignum_neg_one = bignum_neg_one;

	for(cell i = 0; i < special_object_count; i++)
		h.special_objects[i] = (save_special_p(i) ? special_objects[i] : false_object);

	bool ok = true;

	if(safe_fwrite(&h,sizeof(image_header),1,file) != 1) ok = false;
	if(safe_fwrite((void*)data->tenured->start,h.data_size,1,file) != 1) ok = false;
	if(safe_fwrite(code->allocator->first_block(),h.code_size,1,file) != 1) ok = false;
	safe_fclose(file);

	if(!ok)
		std::cout << "save-image failed: " << strerror(errno) << std::endl;
	else
		move_file(saving_filename,filename); 

	return ok;
}

void factor_vm::primitive_save_image()
{
	/* do a full GC to push everything into tenured space */
	primitive_compact_gc();

	data_root<byte_array> path2(ctx->pop(),this);
	path2.untag_check(this);
	data_root<byte_array> path1(ctx->pop(),this);
	path1.untag_check(this);
	save_image((vm_char *)(path1.untagged() + 1 ),(vm_char *)(path2.untagged() + 1));
}

void factor_vm::primitive_save_image_and_exit()
{
	/* We unbox this before doing anything else. This is the only point
	where we might throw an error, so we have to throw an error here since
	later steps destroy the current image. */
	data_root<byte_array> path2(ctx->pop(),this);
	path2.untag_check(this);
	data_root<byte_array> path1(ctx->pop(),this);
	path1.untag_check(this);

	/* strip out special_objects data which is set on startup anyway */
	for(cell i = 0; i < special_object_count; i++)
		if(!save_special_p(i)) special_objects[i] = false_object;

	gc(collect_compact_op,
		0, /* requested size */
		false /* discard objects only reachable from stacks */);

	/* Save the image */
	if(save_image((vm_char *)(path1.untagged() + 1), (vm_char *)(path2.untagged() + 1)))
		exit(0);
	else
		exit(1);
}

}
