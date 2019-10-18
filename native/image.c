#include "factor.h"

void init_objects(HEADER *h)
{
	int i;
	for(i = 0; i < USER_ENV; i++)
		userenv[i] = F;
	executing = F;
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
		usage();
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
	save_image(to_c_string(filename,true));
}
