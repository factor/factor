#include "factor.h"

void init_objects(HEADER *h)
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

void load_image(const char* filename, int literal_table)
{
	FILE* file;
	HEADER h;
	HEADER_2 ext_h;

	file = fopen(filename,"rb");
	if(file == NULL)
	{
		fprintf(stderr,"Cannot open image file: %s\n",filename);
		fprintf(stderr,"%s\n",strerror(errno));
		exit(1);
	}

	printf("Loading %s...",filename);

	/* read header */
	{
		/* read it in native byte order */
		fread(&h,sizeof(HEADER)/sizeof(CELL),sizeof(CELL),file);

		if(h.magic != IMAGE_MAGIC)
			fatal_error("Bad magic number",h.magic);

		if(h.version == IMAGE_VERSION)
			fread(&ext_h,sizeof(HEADER_2)/sizeof(CELL),sizeof(CELL),file);
		else if(h.version == IMAGE_VERSION_0)
		{
			ext_h.size = literal_table;
			ext_h.literal_top = 0;
			ext_h.literal_max = literal_table;
			ext_h.relocation_base = compiling.base;
		}
		else
			fatal_error("Bad version number",h.version);
	}

	/* read data heap */
	{
		CELL size = h.size / CELLS;
		allot(h.size);

		if(size != fread((void*)tenured.base,sizeof(CELL),size,file))
			fatal_error("Wrong data heap length",h.size);

		tenured.here = tenured.base + h.size;
		data_relocation_base = h.relocation_base;
	}

	/* read code heap */
	{
		CELL size = ext_h.size;
		if(size + compiling.base >= compiling.limit)
			fatal_error("Code heap too large",ext_h.size);

		if(h.version == IMAGE_VERSION
			&& size != fread((void*)compiling.base,1,size,file))
			fatal_error("Wrong code heap length",ext_h.size);

		compiling.here = compiling.base + ext_h.size;
		literal_top = compiling.base + ext_h.literal_top;
		literal_max = compiling.base + ext_h.literal_max;
		compiling.here = compiling.base + ext_h.size;
		code_relocation_base = ext_h.relocation_base;
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

bool save_image(const char* filename)
{
	FILE* file;
	HEADER h;
	HEADER_2 ext_h;

	fprintf(stderr,"Saving %s...\n",filename);

	file = fopen(filename,"wb");
	if(file == NULL)
		fatal_error("Cannot open image for writing",errno);

	h.magic = IMAGE_MAGIC;
	h.version = IMAGE_VERSION;
	h.relocation_base = tenured.base;
	h.boot = userenv[BOOT_ENV];
	h.size = tenured.here - tenured.base;
	h.global = userenv[GLOBAL_ENV];
	h.t = T;
	h.bignum_zero = bignum_zero;
	h.bignum_pos_one = bignum_pos_one;
	h.bignum_neg_one = bignum_neg_one;
	fwrite(&h,sizeof(HEADER),1,file);

	ext_h.size = compiling.here - compiling.base;
	ext_h.literal_top = literal_top - compiling.base;
	ext_h.literal_max = literal_max - compiling.base;
	ext_h.relocation_base = compiling.base;
	fwrite(&ext_h,sizeof(HEADER_2),1,file);

	fwrite((void*)tenured.base,h.size,1,file);
	fwrite((void*)compiling.base,ext_h.size,1,file);

	fclose(file);

	return true;
}

void primitive_save_image(void)
{
	F_STRING* filename;
	/* do a full GC to push everything into tenured space */
	garbage_collection(TENURED);
	filename = untag_string(dpop());
	save_image(to_char_string(filename,true));
}

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
		ffi_dlopen((DLL*)relocating,false);
		break;
	case ALIEN_TYPE:
		fixup_alien((ALIEN*)relocating);
		break;
	}
}

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

	for(relocating = compiling.base;
		relocating < literal_top;
		relocating += CELLS)
	{
		data_fixup((CELL*)relocating);
	}
}

void undefined_symbol(void)
{
	general_error(ERROR_UNDEFINED_SYMBOL,F,F,true);
}

CELL get_rel_symbol(F_REL* rel)
{
	CELL arg = REL_ARGUMENT(rel);
	F_ARRAY *pair = untag_array(get(compiling.base + arg * CELLS));
	F_STRING *symbol = untag_string(get(AREF(pair,0)));
	CELL library = get(AREF(pair,1));
	DLL *dll = (library == F ? NULL : untag_dll(library));
	CELL sym;

	if(dll != NULL && !dll->dll)
		return (CELL)undefined_symbol;

	sym = (CELL)ffi_dlsym(dll,symbol,false);

	if(!sym)
		return (CELL)undefined_symbol;

	return sym;
}

INLINE CELL compute_code_rel(F_REL *rel, CELL original)
{
	switch(REL_TYPE(rel))
	{
	case F_PRIMITIVE:
		return primitive_to_xt(REL_ARGUMENT(rel));
	case F_DLSYM:
		return get_rel_symbol(rel);
	case F_ABSOLUTE:
		return original + (compiling.base - code_relocation_base);
	case F_CARDS:
		return cards_offset;
	default:
		critical_error("Unsupported rel type",rel->type);
		return -1;
	}
}

INLINE CELL relocate_code_next(CELL relocating)
{
	F_COMPILED* compiled = (F_COMPILED*)relocating;

	F_REL* rel = (F_REL*)(
		relocating + sizeof(F_COMPILED)
		+ compiled->code_length);

	F_REL* rel_end = (F_REL*)(
		relocating + sizeof(F_COMPILED)
		+ compiled->code_length
		+ compiled->reloc_length);

	if(compiled->header != COMPILED_HEADER)
		critical_error("Wrong compiled header",relocating);

	while(rel < rel_end)
	{
		CELL original;
		CELL new_value;

		code_fixup(&rel->offset);
		
		switch(REL_CLASS(rel))
		{
		case REL_ABSOLUTE_CELL:
			original = get(rel->offset);
			break;
		case REL_ABSOLUTE:
			original = *(u32*)rel->offset;
			break;
		case REL_RELATIVE:
			original = *(u32*)rel->offset - (rel->offset + sizeof(u32));
			break;
		case REL_2_2:
			original = reloc_get_2_2(rel->offset);
			break;
		default:
			critical_error("Unsupported rel class",REL_CLASS(rel));
			return -1;
		}

		/* to_c_string can fill up the heap */
		maybe_gc(0);
		new_value = compute_code_rel(rel,original);

		switch(REL_CLASS(rel))
		{
		case REL_ABSOLUTE_CELL:
			put(rel->offset,new_value);
			break;
		case REL_ABSOLUTE:
			*(u32*)rel->offset = new_value;
			break;
		case REL_RELATIVE:
			*(u32*)rel->offset = new_value - (rel->offset + CELLS);
			break;
		case REL_2_2:
			reloc_set_2_2(rel->offset,new_value);
			break;
		default:
			critical_error("Unsupported rel class",REL_CLASS(rel));
			return -1;
		}

		rel++;
	}

	return (CELL)rel_end;
}

void relocate_code()
{
	/* start relocating from the end of the space reserved for literals */
	CELL relocating = literal_max;
	while(relocating < compiling.here)
		relocating = relocate_code_next(relocating);
}
