#include "master.h"

/* Certain special objects in the image are known to the runtime */
void init_objects(F_HEADER *h)
{
	memcpy(userenv,h->userenv,sizeof(userenv));

	T = h->t;
	bignum_zero = h->bignum_zero;
	bignum_pos_one = h->bignum_pos_one;
	bignum_neg_one = h->bignum_neg_one;

	stage2 = (userenv[STAGE2_ENV] != F);
}

INLINE void load_data_heap(FILE *file, F_HEADER *h, F_PARAMETERS *p)
{
	CELL good_size = h->data_size + (1 << 20);

	if(good_size > p->tenured_size)
		p->tenured_size = good_size;

	init_data_heap(p->gen_count,
		p->young_size,
		p->aging_size,
		p->tenured_size,
		p->secure_gc);

	clear_gc_stats();

	F_ZONE *tenured = &data_heap->generations[TENURED];

	F_FIXNUM bytes_read = fread((void*)tenured->start,1,h->data_size,file);

	if(bytes_read != h->data_size)
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

INLINE void load_code_heap(FILE *file, F_HEADER *h, F_PARAMETERS *p)
{
	CELL good_size = h->code_size + (1 << 19);

	if(good_size > p->code_size)
		p->code_size = good_size;

	init_code_heap(p->code_size);

	if(h->code_size != 0)
	{
		F_FIXNUM bytes_read = fread(first_block(&code_heap),1,h->code_size,file);
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
	build_free_list(&code_heap,h->code_size);
}

/* Read an image file from disk, only done once during startup */
/* This function also initializes the data and code heaps */
void load_image(F_PARAMETERS *p)
{
	FILE *file = OPEN_READ(p->image_path);
	if(file == NULL)
	{
		print_string("Cannot open image file: "); print_native_string(p->image_path); nl();
		print_string(strerror(errno)); nl();
		exit(1);
	}

	F_HEADER h;
	if(fread(&h,sizeof(F_HEADER),1,file) != 1)
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
	userenv[IMAGE_ENV] = tag_object(from_native_string(p->image_path));
}

/* Save the current image to disk */
bool save_image(const F_CHAR *filename)
{
	FILE* file;
	F_HEADER h;

	file = OPEN_WRITE(filename);
	if(file == NULL)
	{
		print_string("Cannot open image file: "); print_native_string(filename); nl();
		print_string(strerror(errno)); nl();
		return false;
	}

	F_ZONE *tenured = &data_heap->generations[TENURED];

	h.magic = IMAGE_MAGIC;
	h.version = IMAGE_VERSION;
	h.data_relocation_base = tenured->start;
	h.data_size = tenured->here - tenured->start;
	h.code_relocation_base = code_heap.segment->start;
	h.code_size = heap_size(&code_heap);

	h.t = T;
	h.bignum_zero = bignum_zero;
	h.bignum_pos_one = bignum_pos_one;
	h.bignum_neg_one = bignum_neg_one;

	CELL i;
	for(i = 0; i < USER_ENV; i++)
	{
		if(i < FIRST_SAVE_ENV)
			h.userenv[i] = F;
		else
			h.userenv[i] = userenv[i];
	}

	bool ok = true;

	if(fwrite(&h,sizeof(F_HEADER),1,file) != 1) ok = false;
	if(fwrite((void*)tenured->start,h.data_size,1,file) != 1) ok = false;
	if(fwrite(first_block(&code_heap),h.code_size,1,file) != 1) ok = false;
	if(fclose(file)) ok = false;

	if(!ok)
	{
		print_string("save-image failed: "); print_string(strerror(errno)); nl();
	}

	return ok;
}

void primitive_save_image(void)
{
	/* do a full GC to push everything into tenured space */
	gc();

	save_image(unbox_native_string());
}

void primitive_save_image_and_exit(void)
{
	/* We unbox this before doing anything else. This is the only point
	where we might throw an error, so we have to throw an error here since
	later steps destroy the current image. */
	F_CHAR *path = unbox_native_string();

	REGISTER_C_STRING(path);

	/* strip out userenv data which is set on startup anyway */
	CELL i;
	for(i = 0; i < FIRST_SAVE_ENV; i++)
		userenv[i] = F;

	for(i = LAST_SAVE_ENV + 1; i < STACK_TRACES_ENV; i++)
		userenv[i] = F;

	/* do a full GC + code heap compaction */
	performing_compaction = true;
	compact_code_heap();
	performing_compaction = false;

	UNREGISTER_C_STRING(path);

	/* Save the image */
	if(save_image(path))
		exit(0);
	else
		exit(1);
}

void fixup_word(F_WORD *word)
{
	if(stage2)
	{
		code_fixup((CELL)&word->code);
		if(word->profiling) code_fixup((CELL)&word->profiling);
		code_fixup((CELL)&word->xt);
	}
}

void fixup_quotation(F_QUOTATION *quot)
{
	if(quot->compiledp == F)
		quot->xt = lazy_jit_compile;
	else
	{
		code_fixup((CELL)&quot->xt);
		code_fixup((CELL)&quot->code);
	}
}

void fixup_alien(F_ALIEN *d)
{
	d->expired = T;
}

void fixup_stack_frame(F_STACK_FRAME *frame)
{
	code_fixup((CELL)&frame->xt);
	code_fixup((CELL)&FRAME_RETURN_ADDRESS(frame));
}

void fixup_callstack_object(F_CALLSTACK *stack)
{
	iterate_callstack_object(stack,fixup_stack_frame);
}

/* Initialize an object in a newly-loaded image */
void relocate_object(CELL relocating)
{
	/* Tuple relocation is a bit trickier; we have to fix up the
	fixup object before we can get the tuple size, so do_slots is
	out of the question */
	if(untag_header(get(relocating)) == TUPLE_TYPE)
	{
		data_fixup((CELL *)relocating + 1);

		CELL scan = relocating + 2 * CELLS;
		CELL size = untagged_object_size(relocating);
		CELL end = relocating + size;

		while(scan < end)
		{
			data_fixup((CELL *)scan);
			scan += CELLS;
		}
	}
	else
	{
		do_slots(relocating,data_fixup);

		switch(untag_header(get(relocating)))
		{
		case WORD_TYPE:
			fixup_word((F_WORD *)relocating);
			break;
		case QUOTATION_TYPE:
			fixup_quotation((F_QUOTATION *)relocating);
			break;
		case DLL_TYPE:
			ffi_dlopen((F_DLL *)relocating);
			break;
		case ALIEN_TYPE:
			fixup_alien((F_ALIEN *)relocating);
			break;
		case CALLSTACK_TYPE:
			fixup_callstack_object((F_CALLSTACK *)relocating);
			break;
		}
	}
}

/* Since the image might have been saved with a different base address than
where it is loaded, we need to fix up pointers in the image. */
void relocate_data()
{
	CELL relocating;

	CELL i;
	for(i = 0; i < USER_ENV; i++)
		data_fixup(&userenv[i]);

	data_fixup(&T);
	data_fixup(&bignum_zero);
	data_fixup(&bignum_pos_one);
	data_fixup(&bignum_neg_one);

	F_ZONE *tenured = &data_heap->generations[TENURED];

	for(relocating = tenured->start;
		relocating < tenured->here;
		relocating += untagged_object_size(relocating))
	{
		allot_barrier(relocating);
		relocate_object(relocating);
	}
}

void fixup_code_block(F_CODE_BLOCK *compiled)
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
