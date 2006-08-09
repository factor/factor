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

void load_image(const char* filename)
{
	FILE* file;
	HEADER h;

	file = fopen(filename,"rb");
	if(file == NULL)
	{
		fprintf(stderr,"Cannot open image file: %s\n",filename);
		fprintf(stderr,"%s\n",strerror(errno));
		exit(1);
	}

	printf("Loading %s...",filename);

	/* read it in native byte order */
	fread(&h,sizeof(HEADER)/sizeof(CELL),sizeof(CELL),file);

	if(h.magic != IMAGE_MAGIC)
		fatal_error("Bad magic number",h.magic);

	if(h.version != IMAGE_VERSION)
		fatal_error("Bad version number",h.version);

	/* read data heap */
	{
		CELL size = h.data_size / CELLS;
		allot(h.data_size);

		if(size != fread((void*)tenured.base,sizeof(CELL),size,file))
			fatal_error("Wrong data heap length",h.data_size);

		tenured.here = tenured.base + h.data_size;
		data_relocation_base = h.data_relocation_base;
	}

	/* read code heap */
	{
		CELL size = h.code_size;
		if(size + compiling.base >= compiling.limit)
			fatal_error("Code heap too large",h.code_size);

		if(h.version == IMAGE_VERSION
			&& size != fread((void*)compiling.base,1,size,file))
			fatal_error("Wrong code heap length",h.code_size);

		compiling.here = compiling.base + h.code_size;
		code_relocation_base = h.code_relocation_base;
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
	h.code_size = compiling.here - compiling.base;
	h.code_relocation_base = compiling.base;
	fwrite(&h,sizeof(HEADER),1,file);

	fwrite((void*)tenured.base,h.data_size,1,file);
	fwrite((void*)compiling.base,h.code_size,1,file);

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
}

void undefined_symbol(void)
{
	general_error(ERROR_UNDEFINED_SYMBOL,F,F,true);
}

#define LITERAL_REF(literal_start,num) ((literal_start) + CELLS * (num))

INLINE CELL get_literal(CELL literal_start, CELL num)
{
	if(!literal_start)
		critical_error("Only RT_LABEL relocations can appear in the label-relocation-table",0);

	return get(LITERAL_REF(literal_start,num));
}

CELL get_rel_symbol(F_REL *rel, CELL literal_start)
{
	CELL arg = REL_ARGUMENT(rel);
	F_ARRAY *pair = untag_array(get_literal(literal_start,arg));
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

CELL get_rel_word(F_REL *rel, CELL literal_start)
{
	CELL arg = REL_ARGUMENT(rel);
	F_WORD *word = untag_word(get_literal(literal_start,arg));
	return (CELL)word->xt;
}

INLINE CELL compute_code_rel(F_REL *rel,
	CELL code_start, CELL literal_start,
	F_VECTOR *labels)
{
	CELL offset = rel->offset + code_start;
	F_ARRAY *array = untag_array_fast(labels->array);

	switch(REL_TYPE(rel))
	{
	case RT_PRIMITIVE:
		return primitive_to_xt(REL_ARGUMENT(rel));
	case RT_DLSYM:
		return get_rel_symbol(rel,literal_start);
	case RT_HERE:
		return offset;
	case RT_CARDS:
		return cards_offset;
	case RT_LITERAL:
		return LITERAL_REF(literal_start,REL_ARGUMENT(rel));
	case RT_WORD:
		return get_rel_word(rel,literal_start);
	case RT_LABEL:
		if(labels == NULL)
			critical_error("RT_LABEL can only appear in label-relocation-table",0);

		return to_fixnum(get(AREF(array,REL_ARGUMENT(rel))))
			+ code_start;
	default:
		critical_error("Unsupported rel type",rel->type);
		return -1;
	}
}

void relocate_code_step(F_REL *rel, CELL code_start, CELL literal_start,
	F_VECTOR *labels)
{
	CELL original;
	CELL new_value;
	CELL offset = rel->offset + code_start;

	switch(REL_CLASS(rel))
	{
	case REL_ABSOLUTE_CELL:
		original = get(offset);
		break;
	case REL_ABSOLUTE:
		original = *(u32*)offset;
		break;
	case REL_RELATIVE:
		original = *(u32*)offset - (offset + sizeof(u32));
		break;
	case REL_ABSOLUTE_2_2:
		original = reloc_get_2_2(offset);
		break;
	case REL_RELATIVE_2_2:
		original = reloc_get_2_2(offset) - (offset + sizeof(u32));
		break;
	case REL_RELATIVE_2:
		original = *(u32*)offset;
		original &= REL_RELATIVE_2_MASK;
		break;
	case REL_RELATIVE_3:
		original = *(u32*)offset;
		original &= REL_RELATIVE_3_MASK;
		break;
	default:
		critical_error("Unsupported rel class",REL_CLASS(rel));
		return;
	}

	/* to_c_string can fill up the heap */
	maybe_gc(0);
	new_value = compute_code_rel(rel,code_start,literal_start,labels);

	switch(REL_CLASS(rel))
	{
	case REL_ABSOLUTE_CELL:
		put(offset,new_value);
		break;
	case REL_ABSOLUTE:
		*(u32*)offset = new_value;
		break;
	case REL_RELATIVE:
		*(u32*)offset = new_value - (offset + sizeof(u32));
		break;
	case REL_ABSOLUTE_2_2:
		reloc_set_2_2(offset,new_value);
		break;
	case REL_RELATIVE_2_2:
		reloc_set_2_2(offset,new_value - (offset + sizeof(u32)));
		break;
	case REL_RELATIVE_2:
		original = *(u32*)offset;
		original &= ~REL_RELATIVE_2_MASK;
		*(u32*)offset = (original | new_value);
		break;
	case REL_RELATIVE_3:
		original = *(u32*)offset;
		original &= ~REL_RELATIVE_3_MASK;
		*(u32*)offset = (original | new_value);
		break;
	default:
		critical_error("Unsupported rel class",REL_CLASS(rel));
		return;
	}
}

CELL relocate_code_next(CELL relocating)
{
	F_COMPILED* compiled = (F_COMPILED*)relocating;

	if(compiled->header != COMPILED_HEADER)
		critical_error("Wrong compiled header",relocating);

	CELL code_start = relocating + sizeof(F_COMPILED);
	CELL reloc_start = code_start + compiled->code_length;
	CELL literal_start = reloc_start + compiled->reloc_length;

	F_REL *rel = (F_REL *)reloc_start;
	F_REL *rel_end = (F_REL *)literal_start;

	/* apply relocations */
	while(rel < rel_end)
		relocate_code_step(rel++,code_start,literal_start,NULL);
	
	CELL *scan = (CELL*)literal_start;
	CELL *literal_end = (CELL*)(literal_start + compiled->literal_length);

	/* relocate literal table data */
	while(scan < literal_end)
		data_fixup(scan++);

	return (CELL)literal_end;
}

void relocate_code()
{
	/* start relocating from the end of the space reserved for literals */
	CELL relocating = compiling.base;
	while(relocating < compiling.here)
		relocating = relocate_code_next(relocating);
}
