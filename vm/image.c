#include "factor.h"

/* Certain special objects in the image are known to the runtime */
void init_objects(F_HEADER *h)
{
	int i;
	for(i = 0; i < USER_ENV; i++)
		userenv[i] = F;
	userenv[GLOBAL_ENV] = h->global;
	userenv[BOOT_ENV] = h->boot;
	T = h->t;
	bignum_zero = h->bignum_zero;
	bignum_pos_one = h->bignum_pos_one;
	bignum_neg_one = h->bignum_neg_one;
}

/* Read an image file from disk, only done once during startup */
void load_image(const char* filename)
{
	FILE* file;
	F_HEADER h;

	file = fopen(filename,"rb");
	if(file == NULL)
	{
		fprintf(stderr,"Cannot open image file: %s\n",filename);
		fprintf(stderr,"%s\n",strerror(errno));
		exit(1);
	}

	printf("Loading %s...",filename);

	/* read it in native byte order */
	fread(&h,sizeof(F_HEADER)/sizeof(CELL),sizeof(CELL),file);

	if(h.magic != IMAGE_MAGIC)
		fatal_error("Bad magic number",h.magic);

	if(h.version != IMAGE_VERSION)
		fatal_error("Bad version number",h.version);

	/* read data heap */
	{
		CELL size = h.data_size / CELLS;
		if(size + tenured.base >= tenured.limit)
			fatal_error("Data heap too large",h.code_size);

		if(size != fread((void*)tenured.base,sizeof(CELL),size,file))
			fatal_error("Wrong data heap length",h.data_size);

		tenured.here = tenured.base + h.data_size;
		data_relocation_base = h.data_relocation_base;
	}

	/* read code heap */
	{
		CELL size = h.code_size;
		if(size + compiling.base > compiling.limit)
			fatal_error("Code heap too large",h.code_size);

		if(h.version == IMAGE_VERSION
			&& size != fread((void*)compiling.base,1,size,file))
			fatal_error("Wrong code heap length",h.code_size);

		code_relocation_base = h.code_relocation_base;

		build_free_list(&compiling,size);
	}

	fclose(file);

	printf(" relocating...");
	fflush(stdout);

	init_objects(&h);

	relocate_data();
	relocate_code();

	printf(" done\n");
	fflush(stdout);
}

/* Save the current image to disk */
bool save_image(const char* filename)
{
	FILE* file;
	F_HEADER h;

	fprintf(stderr,"Saving %s...\n",filename);

	file = fopen(filename,"wb");
	if(file == NULL)
		fatal_error("Cannot open image for writing",errno);

	h.magic = IMAGE_MAGIC;
	h.version = IMAGE_VERSION;
	h.data_relocation_base = tenured.base;
	h.boot = userenv[BOOT_ENV];
	h.data_size = tenured.here - tenured.base;
	h.global = userenv[GLOBAL_ENV];
	h.t = T;
	h.bignum_zero = bignum_zero;
	h.bignum_pos_one = bignum_pos_one;
	h.bignum_neg_one = bignum_neg_one;
	h.code_size = heap_size(&compiling);
	h.code_relocation_base = compiling.base;
	fwrite(&h,sizeof(F_HEADER),1,file);

	fwrite((void*)tenured.base,h.data_size,1,file);
	fwrite((void*)compiling.base,h.code_size,1,file);

	fclose(file);

	return true;
}

void primitive_save_image(void)
{
	F_STRING* filename;
	/* do a full GC to push everything into tenured space */
	garbage_collection(TENURED,true);
	filename = untag_string(dpop());
	save_image(to_char_string(filename,true));
}

/* Initialize an object in a newly-loaded image */
void relocate_object(CELL relocating)
{
	CELL scan = relocating;
	CELL payload_start = binary_payload_start(scan);
	CELL end = scan + payload_start;

	scan += CELLS;

	while(scan < end)
	{
		data_fixup((CELL*)scan);
		scan += CELLS;
	}

	switch(untag_header(get(relocating)))
	{
	case WORD_TYPE:
		fixup_word((F_WORD*)relocating);
		break;
	case STRING_TYPE:
		rehash_string((F_STRING*)relocating);
		break;
	case DLL_TYPE:
		ffi_dlopen((F_DLL*)relocating,false);
		break;
	case ALIEN_TYPE:
		fixup_alien((F_ALIEN*)relocating);
		break;
	}
}

/* Since the image might have been saved with a different base address than
where it is loaded, we need to fix up pointers in the image. */
void relocate_data()
{
	CELL relocating;

	data_fixup(&userenv[BOOT_ENV]);
	data_fixup(&userenv[GLOBAL_ENV]);
	data_fixup(&T);
	data_fixup(&bignum_zero);
	data_fixup(&bignum_pos_one);
	data_fixup(&bignum_neg_one);

	for(relocating = tenured.base;
		relocating < tenured.here;
		relocating += untagged_object_size(relocating))
	{
		allot_barrier(relocating);
		relocate_object(relocating);
	}
}

void fixup_code_block(F_COMPILED *relocating, CELL code_start,
	CELL reloc_start, CELL literal_start, CELL words_start, CELL words_end)
{
	/* relocate literal table data */
	CELL scan;
	CELL literal_end = literal_start + relocating->literal_length;

	for(scan = literal_start; scan < literal_end; scan += CELLS)
		data_fixup((CELL*)scan);

	for(scan = words_start; scan < words_end; scan += CELLS)
	{
		if(relocating->finalized)
			code_fixup((CELL*)scan);
		else
			data_fixup((CELL*)scan);
	}

	relocate_code_block(relocating,code_start,reloc_start,
		literal_start,words_start,words_end);
}

void relocate_code()
{
	iterate_code_heap(fixup_code_block);
}
