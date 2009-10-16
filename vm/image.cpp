#include "master.hpp"

namespace factor
{

/* Certain special objects in the image are known to the runtime */
void factor_vm::init_objects(image_header *h)
{
	memcpy(userenv,h->userenv,sizeof(userenv));

	T = h->t;
	bignum_zero = h->bignum_zero;
	bignum_pos_one = h->bignum_pos_one;
	bignum_neg_one = h->bignum_neg_one;
}

void factor_vm::load_data_heap(FILE *file, image_header *h, vm_parameters *p)
{
	cell good_size = h->data_size + (1 << 20);

	if(good_size > p->tenured_size)
		p->tenured_size = good_size;

	init_data_heap(p->young_size,
		p->aging_size,
		p->tenured_size,
		p->secure_gc);

	clear_gc_stats();

	fixnum bytes_read = fread((void*)data->tenured->start,1,h->data_size,file);

	if((cell)bytes_read != h->data_size)
	{
		print_string("truncated image: ");
		print_fixnum(bytes_read);
		print_string(" bytes read, ");
		print_cell(h->data_size);
		print_string(" bytes expected\n");
		fatal_error("load_data_heap failed",0);
	}

	data->tenured->here = data->tenured->start + h->data_size;
}

void factor_vm::load_code_heap(FILE *file, image_header *h, vm_parameters *p)
{
	if(h->code_size > p->code_size)
		fatal_error("Code heap too small to fit image",h->code_size);

	init_code_heap(p->code_size);

	if(h->code_size != 0)
	{
		size_t bytes_read = fread(code->first_block(),1,h->code_size,file);
		if(bytes_read != h->code_size)
		{
			print_string("truncated image: ");
			print_fixnum(bytes_read);
			print_string(" bytes read, ");
			print_cell(h->code_size);
			print_string(" bytes expected\n");
			fatal_error("load_code_heap failed",0);
		}
	}

	code->build_free_list(h->code_size);
}

void factor_vm::data_fixup(cell *handle, cell data_relocation_base)
{
	if(immediate_p(*handle))
		return;

	*handle += (data->tenured->start - data_relocation_base);
}

template<typename Type> void factor_vm::code_fixup(Type **handle, cell code_relocation_base)
{
	Type *ptr = *handle;
	Type *new_ptr = (Type *)(((cell)ptr) + (code->seg->start - code_relocation_base));
	*handle = new_ptr;
}

void factor_vm::fixup_word(word *word, cell code_relocation_base)
{
	if(word->code)
		code_fixup(&word->code,code_relocation_base);
	if(word->profiling)
		code_fixup(&word->profiling,code_relocation_base);
	code_fixup(&word->xt,code_relocation_base);
}

void factor_vm::fixup_quotation(quotation *quot, cell code_relocation_base)
{
	if(quot->code)
	{
		code_fixup(&quot->xt,code_relocation_base);
		code_fixup(&quot->code,code_relocation_base);
	}
	else
		quot->xt = (void *)lazy_jit_compile;
}

void factor_vm::fixup_alien(alien *d)
{
	if(d->base == F) d->expired = T;
}

struct stack_frame_fixupper {
	factor_vm *myvm;
	cell code_relocation_base;

	explicit stack_frame_fixupper(factor_vm *myvm_, cell code_relocation_base_) :
		myvm(myvm_), code_relocation_base(code_relocation_base_) {}
	void operator()(stack_frame *frame)
	{
		myvm->code_fixup(&frame->xt,code_relocation_base);
		myvm->code_fixup(&FRAME_RETURN_ADDRESS(frame,myvm),code_relocation_base);
	}
};

void factor_vm::fixup_callstack_object(callstack *stack, cell code_relocation_base)
{
	stack_frame_fixupper fixupper(this,code_relocation_base);
	iterate_callstack_object(stack,fixupper);
}

struct object_fixupper {
	factor_vm *myvm;
	cell data_relocation_base;

	explicit object_fixupper(factor_vm *myvm_, cell data_relocation_base_) :
		myvm(myvm_), data_relocation_base(data_relocation_base_) { }

	void operator()(cell *scan)
	{
		myvm->data_fixup(scan,data_relocation_base);
	}
};

/* Initialize an object in a newly-loaded image */
void factor_vm::relocate_object(object *object,
	cell data_relocation_base,
	cell code_relocation_base)
{
	cell hi_tag = object->h.hi_tag();
	
	/* Tuple relocation is a bit trickier; we have to fix up the
	layout object before we can get the tuple size, so do_slots is
	out of the question */
	if(hi_tag == TUPLE_TYPE)
	{
		tuple *t = (tuple *)object;
		data_fixup(&t->layout,data_relocation_base);

		cell *scan = t->data();
		cell *end = (cell *)((cell)object + untagged_object_size(object));

		for(; scan < end; scan++)
			data_fixup(scan,data_relocation_base);
	}
	else
	{
		object_fixupper fixupper(this,data_relocation_base);
		do_slots((cell)object,fixupper);

		switch(hi_tag)
		{
		case WORD_TYPE:
			fixup_word((word *)object,code_relocation_base);
			break;
		case QUOTATION_TYPE:
			fixup_quotation((quotation *)object,code_relocation_base);
			break;
		case DLL_TYPE:
			ffi_dlopen((dll *)object);
			break;
		case ALIEN_TYPE:
			fixup_alien((alien *)object);
			break;
		case CALLSTACK_TYPE:
			fixup_callstack_object((callstack *)object,code_relocation_base);
			break;
		}
	}
}

/* Since the image might have been saved with a different base address than
where it is loaded, we need to fix up pointers in the image. */
void factor_vm::relocate_data(cell data_relocation_base, cell code_relocation_base)
{
	for(cell i = 0; i < USER_ENV; i++)
		data_fixup(&userenv[i],data_relocation_base);

	data_fixup(&T,data_relocation_base);
	data_fixup(&bignum_zero,data_relocation_base);
	data_fixup(&bignum_pos_one,data_relocation_base);
	data_fixup(&bignum_neg_one,data_relocation_base);

	cell obj = data->tenured->start;

	while(obj)
	{
		relocate_object((object *)obj,data_relocation_base,code_relocation_base);
		data->tenured->record_object_start_offset((object *)obj);
		obj = data->tenured->next_object_after(this,obj);
	}
}

void factor_vm::fixup_code_block(code_block *compiled, cell data_relocation_base)
{
	/* relocate literal table data */
	data_fixup(&compiled->owner,data_relocation_base);
	data_fixup(&compiled->literals,data_relocation_base);
	data_fixup(&compiled->relocation,data_relocation_base);

	relocate_code_block(compiled);
}

struct code_block_fixupper {
	factor_vm *myvm;
	cell data_relocation_base;

	code_block_fixupper(factor_vm *myvm_, cell data_relocation_base_) :
		myvm(myvm_), data_relocation_base(data_relocation_base_) { }

	void operator()(code_block *compiled)
	{
		myvm->fixup_code_block(compiled,data_relocation_base);
	}
};

void factor_vm::relocate_code(cell data_relocation_base)
{
	code_block_fixupper fixupper(this,data_relocation_base);
	iterate_code_heap(fixupper);
}

/* Read an image file from disk, only done once during startup */
/* This function also initializes the data and code heaps */
void factor_vm::load_image(vm_parameters *p)
{
	FILE *file = OPEN_READ(p->image_path);
	if(file == NULL)
	{
		print_string("Cannot open image file: "); print_native_string(p->image_path); nl();
		print_string(strerror(errno)); nl();
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

	relocate_data(h.data_relocation_base,h.code_relocation_base);
	relocate_code(h.data_relocation_base);

	/* Store image path name */
	userenv[IMAGE_ENV] = allot_alien(F,(cell)p->image_path);
}

/* Save the current image to disk */
bool factor_vm::save_image(const vm_char *filename)
{
	FILE* file;
	image_header h;

	file = OPEN_WRITE(filename);
	if(file == NULL)
	{
		print_string("Cannot open image file: "); print_native_string(filename); nl();
		print_string(strerror(errno)); nl();
		return false;
	}

	h.magic = image_magic;
	h.version = image_version;
	h.data_relocation_base = data->tenured->start;
	h.data_size = data->tenured->here - data->tenured->start;
	h.code_relocation_base = code->seg->start;
	h.code_size = code->heap_size();

	h.t = T;
	h.bignum_zero = bignum_zero;
	h.bignum_pos_one = bignum_pos_one;
	h.bignum_neg_one = bignum_neg_one;

	for(cell i = 0; i < USER_ENV; i++)
		h.userenv[i] = (save_env_p(i) ? userenv[i] : F);

	bool ok = true;

	if(fwrite(&h,sizeof(image_header),1,file) != 1) ok = false;
	if(fwrite((void*)data->tenured->start,h.data_size,1,file) != 1) ok = false;
	if(fwrite(code->first_block(),h.code_size,1,file) != 1) ok = false;
	if(fclose(file)) ok = false;

	if(!ok)
	{
		print_string("save-image failed: "); print_string(strerror(errno)); nl();
	}

	return ok;
}

void factor_vm::primitive_save_image()
{
	/* do a full GC to push everything into tenured space */
	primitive_compact_gc();

	gc_root<byte_array> path(dpop(),this);
	path.untag_check(this);
	save_image((vm_char *)(path.untagged() + 1));
}

void factor_vm::primitive_save_image_and_exit()
{
	/* We unbox this before doing anything else. This is the only point
	where we might throw an error, so we have to throw an error here since
	later steps destroy the current image. */
	gc_root<byte_array> path(dpop(),this);
	path.untag_check(this);

	/* strip out userenv data which is set on startup anyway */
	for(cell i = 0; i < USER_ENV; i++)
	{
		if(!save_env_p(i)) userenv[i] = F;
	}

	gc(collect_full_op,
		0, /* requested size */
		false, /* discard objects only reachable from stacks */
		true /* compact the code heap */);

	/* Save the image */
	if(save_image((vm_char *)(path.untagged() + 1)))
		exit(0);
	else
		exit(1);
}

}
