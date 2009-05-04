#include "master.hpp"

namespace factor
{

/* Certain special objects in the image are known to the runtime */
static void init_objects(image_header *h)
{
	memcpy(userenv,h->userenv,sizeof(userenv));

	T = h->t;
	bignum_zero = h->bignum_zero;
	bignum_pos_one = h->bignum_pos_one;
	bignum_neg_one = h->bignum_neg_one;
}

cell data_relocation_base;

static void load_data_heap(FILE *file, image_header *h, vm_parameters *p)
{
	cell good_size = h->data_size + (1 << 20);

	if(good_size > p->tenured_size)
		p->tenured_size = good_size;

	init_data_heap(p->gen_count,
		p->young_size,
		p->aging_size,
		p->tenured_size,
		p->secure_gc);

	clear_gc_stats();

	zone *tenured = &data->generations[TENURED];

	fixnum bytes_read = fread((void*)tenured->start,1,h->data_size,file);

	if((cell)bytes_read != h->data_size)
	{
		print_string("truncated image: ");
		print_fixnum(bytes_read);
		print_string(" bytes read, ");
		print_cell(h->data_size);
		print_string(" bytes expected\n");
		fatal_error("load_data_heap failed",0);
	}

	tenured->here = tenured->start + h->data_size;
	data_relocation_base = h->data_relocation_base;
}

cell code_relocation_base;

static void load_code_heap(FILE *file, image_header *h, vm_parameters *p)
{
	cell good_size = h->code_size + (1 << 19);

	if(good_size > p->code_size)
		p->code_size = good_size;

	init_code_heap(p->code_size);

	if(h->code_size != 0)
	{
		size_t bytes_read = fread(first_block(&code),1,h->code_size,file);
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

	code_relocation_base = h->code_relocation_base;
	build_free_list(&code,h->code_size);
}

/* Save the current image to disk */
bool save_image(const vm_char *filename)
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

	zone *tenured = &data->generations[TENURED];

	h.magic = IMAGE_MAGIC;
	h.version = IMAGE_VERSION;
	h.data_relocation_base = tenured->start;
	h.data_size = tenured->here - tenured->start;
	h.code_relocation_base = code.seg->start;
	h.code_size = heap_size(&code);

	h.t = T;
	h.bignum_zero = bignum_zero;
	h.bignum_pos_one = bignum_pos_one;
	h.bignum_neg_one = bignum_neg_one;

	cell i;
	for(i = 0; i < USER_ENV; i++)
	{
		if(i < FIRST_SAVE_ENV)
			h.userenv[i] = F;
		else
			h.userenv[i] = userenv[i];
	}

	bool ok = true;

	if(fwrite(&h,sizeof(image_header),1,file) != 1) ok = false;
	if(fwrite((void*)tenured->start,h.data_size,1,file) != 1) ok = false;
	if(fwrite(first_block(&code),h.code_size,1,file) != 1) ok = false;
	if(fclose(file)) ok = false;

	if(!ok)
	{
		print_string("save-image failed: "); print_string(strerror(errno)); nl();
	}

	return ok;
}

PRIMITIVE(save_image)
{
	/* do a full GC to push everything into tenured space */
	gc();

	gc_root<byte_array> path(dpop());
	path.untag_check();
	save_image((vm_char *)(path.untagged() + 1));
}

PRIMITIVE(save_image_and_exit)
{	
	/* We unbox this before doing anything else. This is the only point
	where we might throw an error, so we have to throw an error here since
	later steps destroy the current image. */
	gc_root<byte_array> path(dpop());
	path.untag_check();

	/* strip out userenv data which is set on startup anyway */
	cell i;
	for(i = 0; i < FIRST_SAVE_ENV; i++)
		userenv[i] = F;

	for(i = LAST_SAVE_ENV + 1; i < STACK_TRACES_ENV; i++)
		userenv[i] = F;

	/* do a full GC + code heap compaction */
	performing_compaction = true;
	compact_code_heap();
	performing_compaction = false;

	/* Save the image */
	if(save_image((vm_char *)(path.untagged() + 1)))
		exit(0);
	else
		exit(1);
}

static void data_fixup(cell *cell)
{
	if(immediate_p(*cell))
		return;

	zone *tenured = &data->generations[TENURED];
	*cell += (tenured->start - data_relocation_base);
}

template <typename T> void code_fixup(T **handle)
{
	T *ptr = *handle;
	T *new_ptr = (T *)(((cell)ptr) + (code.seg->start - code_relocation_base));
	*handle = new_ptr;
}

static void fixup_word(word *word)
{
	if(word->code)
		code_fixup(&word->code);
	if(word->profiling)
		code_fixup(&word->profiling);
	code_fixup(&word->xt);
}

static void fixup_quotation(quotation *quot)
{
	if(quot->compiledp == F)
		quot->xt = (void *)lazy_jit_compile;
	else
	{
		code_fixup(&quot->xt);
		code_fixup(&quot->code);
	}
}

static void fixup_alien(alien *d)
{
	d->expired = T;
}

static void fixup_stack_frame(stack_frame *frame)
{
	code_fixup(&frame->xt);
	code_fixup(&FRAME_RETURN_ADDRESS(frame));
}

static void fixup_callstack_object(callstack *stack)
{
	iterate_callstack_object(stack,fixup_stack_frame);
}

/* Initialize an object in a newly-loaded image */
static void relocate_object(object *object)
{
	cell hi_tag = object->h.hi_tag();
	
	/* Tuple relocation is a bit trickier; we have to fix up the
	layout object before we can get the tuple size, so do_slots is
	out of the question */
	if(hi_tag == TUPLE_TYPE)
	{
		tuple *t = (tuple *)object;
		data_fixup(&t->layout);

		cell *scan = t->data();
		cell *end = (cell *)((cell)object + untagged_object_size(object));

		for(; scan < end; scan++)
			data_fixup(scan);
	}
	else
	{
		do_slots((cell)object,data_fixup);

		switch(hi_tag)
		{
		case WORD_TYPE:
			fixup_word((word *)object);
			break;
		case QUOTATION_TYPE:
			fixup_quotation((quotation *)object);
			break;
		case DLL_TYPE:
			ffi_dlopen((dll *)object);
			break;
		case ALIEN_TYPE:
			fixup_alien((alien *)object);
			break;
		case CALLSTACK_TYPE:
			fixup_callstack_object((callstack *)object);
			break;
		}
	}
}

/* Since the image might have been saved with a different base address than
where it is loaded, we need to fix up pointers in the image. */
void relocate_data()
{
	cell relocating;

	cell i;
	for(i = 0; i < USER_ENV; i++)
		data_fixup(&userenv[i]);

	data_fixup(&T);
	data_fixup(&bignum_zero);
	data_fixup(&bignum_pos_one);
	data_fixup(&bignum_neg_one);

	zone *tenured = &data->generations[TENURED];

	for(relocating = tenured->start;
		relocating < tenured->here;
		relocating += untagged_object_size((object *)relocating))
	{
		object *obj = (object *)relocating;
		allot_barrier(obj);
		relocate_object(obj);
	}
}

static void fixup_code_block(code_block *compiled)
{
	/* relocate literal table data */
	data_fixup(&compiled->relocation);
	data_fixup(&compiled->literals);

	relocate_code_block(compiled);
}

void relocate_code()
{
	iterate_code_heap(fixup_code_block);
}

/* Read an image file from disk, only done once during startup */
/* This function also initializes the data and code heaps */
void load_image(vm_parameters *p)
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

	if(h.magic != IMAGE_MAGIC)
		fatal_error("Bad image: magic number check failed",h.magic);

	if(h.version != IMAGE_VERSION)
		fatal_error("Bad image: version number check failed",h.version);
	
	load_data_heap(file,&h,p);
	load_code_heap(file,&h,p);

	fclose(file);

	init_objects(&h);

	relocate_data();
	relocate_code();

	/* Store image path name */
	userenv[IMAGE_ENV] = allot_alien(F,(cell)p->image_path);
}

}
