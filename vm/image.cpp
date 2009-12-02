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

	fixnum bytes_read = fread((void*)data->tenured->start,1,h->data_size,file);

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
		size_t bytes_read = fread(code->allocator->first_block(),1,h->code_size,file);
		if(bytes_read != h->code_size)
		{
			std::cout << "truncated image: " << bytes_read << " bytes read, ";
			std::cout << h->code_size << " bytes expected\n";
			fatal_error("load_code_heap failed",0);
		}
	}

	code->allocator->initial_free_list(h->code_size);
}

struct data_fixupper {
	cell offset;

	explicit data_fixupper(cell offset_) : offset(offset_) {}

	object *operator()(object *obj)
	{
		return (object *)((char *)obj + offset);
	}
};

struct code_fixupper {
	cell offset;

	explicit code_fixupper(cell offset_) : offset(offset_) {}

	code_block *operator()(code_block *compiled)
	{
		return (code_block *)((char *)compiled + offset);
	}
};

static inline cell tuple_size_with_fixup(cell offset, object *obj)
{
	tuple_layout *layout = (tuple_layout *)((char *)UNTAG(((tuple *)obj)->layout) + offset);
	return tuple_size(layout);
}

struct fixup_sizer {
	cell offset;

	explicit fixup_sizer(cell offset_) : offset(offset_) {}

	cell operator()(object *obj)
	{
		if(obj->type() == TUPLE_TYPE)
			return align(tuple_size_with_fixup(offset,obj),data_alignment);
		else
			return obj->size();
	}
};

struct object_fixupper {
	factor_vm *parent;
	cell data_offset;
	slot_visitor<data_fixupper> data_visitor;
	code_block_visitor<code_fixupper> code_visitor;

	object_fixupper(factor_vm *parent_, cell data_offset_, cell code_offset_) :
		parent(parent_),
		data_offset(data_offset_),
		data_visitor(slot_visitor<data_fixupper>(parent_,data_fixupper(data_offset_))),
		code_visitor(code_block_visitor<code_fixupper>(parent_,code_fixupper(code_offset_))) {}

	void operator()(object *obj, cell size)
	{
		parent->data->tenured->starts.record_object_start_offset(obj);

		switch(obj->type())
		{
		case ALIEN_TYPE:
			{
				cell payload_start = obj->binary_payload_start();
				data_visitor.visit_slots(obj,payload_start);

				alien *ptr = (alien *)obj;

				if(to_boolean(ptr->base))
					ptr->update_address();
				else
					ptr->expired = parent->true_object;
				break;
			}
		case DLL_TYPE:
			{
				cell payload_start = obj->binary_payload_start();
				data_visitor.visit_slots(obj,payload_start);

				parent->ffi_dlopen((dll *)obj);
				break;
			}
		case TUPLE_TYPE:
			{
				cell payload_start = tuple_size_with_fixup(data_offset,obj);
				data_visitor.visit_slots(obj,payload_start);
				break;
			}
		default:
			{
				cell payload_start = obj->binary_payload_start();
				data_visitor.visit_slots(obj,payload_start);
				code_visitor.visit_object_code_block(obj);
				break;
			}
		}
	}
};

void factor_vm::fixup_data(cell data_offset, cell code_offset)
{
	slot_visitor<data_fixupper> data_workhorse(this,data_fixupper(data_offset));
	data_workhorse.visit_roots();

	object_fixupper fixupper(this,data_offset,code_offset);
	fixup_sizer sizer(data_offset);
	data->tenured->iterate(fixupper,sizer);
}

struct code_block_fixup_relocation_visitor {
	factor_vm *parent;
	cell code_offset;
	slot_visitor<data_fixupper> data_visitor;
	code_fixupper code_visitor;

	code_block_fixup_relocation_visitor(factor_vm *parent_, cell data_offset_, cell code_offset_) :
		parent(parent_),
		code_offset(code_offset_),
		data_visitor(slot_visitor<data_fixupper>(parent_,data_fixupper(data_offset_))),
		code_visitor(code_fixupper(code_offset_)) {}

	void operator()(instruction_operand op)
	{
		code_block *compiled = op.parent_code_block();
		cell old_offset = op.rel_offset() + (cell)compiled->xt() - code_offset;

		switch(op.rel_type())
		{
		case RT_IMMEDIATE:
			op.store_value(data_visitor.visit_pointer(op.load_value(old_offset)));
			break;
		case RT_XT:
		case RT_XT_PIC:
		case RT_XT_PIC_TAIL:
			op.store_code_block(code_visitor(op.load_code_block(old_offset)));
			break;
		case RT_HERE:
			op.store_value(op.load_value(old_offset) + code_offset);
			break;
		case RT_UNTAGGED:
			break;
		default:
			parent->store_external_address(op);
			break;
		}
	}
};

struct code_block_fixupper {
	factor_vm *parent;
	cell data_offset;
	cell code_offset;

	code_block_fixupper(factor_vm *parent_, cell data_offset_, cell code_offset_) :
		parent(parent_),
		data_offset(data_offset_),
		code_offset(code_offset_) {}

	void operator()(code_block *compiled, cell size)
	{
		slot_visitor<data_fixupper> data_visitor(parent,data_fixupper(data_offset));
		data_visitor.visit_code_block_objects(compiled);

		code_block_fixup_relocation_visitor code_visitor(parent,data_offset,code_offset);
		compiled->each_instruction_operand(code_visitor);
	}
};

void factor_vm::fixup_code(cell data_offset, cell code_offset)
{
	code_block_fixupper fixupper(this,data_offset,code_offset);
	code->allocator->iterate(fixupper);
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
	if(fread(&h,sizeof(image_header),1,file) != 1)
		fatal_error("Cannot read image header",0);

	if(h.magic != image_magic)
		fatal_error("Bad image: magic number check failed",h.magic);

	if(h.version != image_version)
		fatal_error("Bad image: version number check failed",h.version);
	
	load_data_heap(file,&h,p);
	load_code_heap(file,&h,p);

	fclose(file);

	init_objects(&h);

	cell data_offset = data->tenured->start - h.data_relocation_base;
	cell code_offset = code->seg->start - h.code_relocation_base;

	fixup_data(data_offset,code_offset);
	fixup_code(data_offset,code_offset);

	/* Store image path name */
	special_objects[OBJ_IMAGE] = allot_alien(false_object,(cell)p->image_path);
}

/* Save the current image to disk */
bool factor_vm::save_image(const vm_char *filename)
{
	FILE* file;
	image_header h;

	file = OPEN_WRITE(filename);
	if(file == NULL)
	{
		std::cout << "Cannot open image file: " << filename << std::endl;
		std::cout << strerror(errno) << std::endl;
		return false;
	}

	h.magic = image_magic;
	h.version = image_version;
	h.data_relocation_base = data->tenured->start;
	h.data_size = data->tenured->occupied_space();
	h.code_relocation_base = code->seg->start;
	h.code_size = code->allocator->occupied_space();

	h.true_object = true_object;
	h.bignum_zero = bignum_zero;
	h.bignum_pos_one = bignum_pos_one;
	h.bignum_neg_one = bignum_neg_one;

	for(cell i = 0; i < special_object_count; i++)
		h.special_objects[i] = (save_special_p(i) ? special_objects[i] : false_object);

	bool ok = true;

	if(fwrite(&h,sizeof(image_header),1,file) != 1) ok = false;
	if(fwrite((void*)data->tenured->start,h.data_size,1,file) != 1) ok = false;
	if(fwrite(code->allocator->first_block(),h.code_size,1,file) != 1) ok = false;
	if(fclose(file)) ok = false;

	if(!ok)
		std::cout << "save-image failed: " << strerror(errno) << std::endl;

	return ok;
}

void factor_vm::primitive_save_image()
{
	/* do a full GC to push everything into tenured space */
	primitive_compact_gc();

	data_root<byte_array> path(dpop(),this);
	path.untag_check(this);
	save_image((vm_char *)(path.untagged() + 1));
}

void factor_vm::primitive_save_image_and_exit()
{
	/* We unbox this before doing anything else. This is the only point
	where we might throw an error, so we have to throw an error here since
	later steps destroy the current image. */
	data_root<byte_array> path(dpop(),this);
	path.untag_check(this);

	/* strip out special_objects data which is set on startup anyway */
	for(cell i = 0; i < special_object_count; i++)
		if(!save_special_p(i)) special_objects[i] = false_object;

	gc(collect_compact_op,
		0, /* requested size */
		false /* discard objects only reachable from stacks */);

	/* Save the image */
	if(save_image((vm_char *)(path.untagged() + 1)))
		exit(0);
	else
		exit(1);
}

}
