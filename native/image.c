#include "factor.h"

void load_image(char* filename)
{
	FILE* file;
	HEADER h;
	HEADER_2 ext_h;

	printf("Loading %s...",filename);

	file = fopen(filename,"rb");
	if(file == NULL)
		fatal_error("Cannot open image for reading",errno);

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
			ext_h.size = LITERAL_TABLE;
			ext_h.literal_top = 0;
			ext_h.literal_max = LITERAL_TABLE;
			ext_h.relocation_base = compiling.base;
		}
		else
			fatal_error("Bad version number",h.version);
	}

	/* read data heap */
	{
		CELL size = h.size / CELLS;
		allot(h.size);

		if(size != fread((void*)active.base,sizeof(CELL),size,file))
			fatal_error("Wrong data heap length",h.size);

		active.here = active.base + h.size;
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

	clear_environment();

	userenv[GLOBAL_ENV] = h.global;
	userenv[BOOT_ENV] = h.boot;

	relocate_data();
	relocate_code();

	printf(" done\n");
	fflush(stdout);
}

bool save_image(char* filename)
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
	h.relocation_base = active.base;
	h.boot = userenv[BOOT_ENV];
	h.size = active.here - active.base;
	h.global = userenv[GLOBAL_ENV];
	fwrite(&h,sizeof(HEADER),1,file);

	ext_h.size = compiling.here - compiling.base;
	ext_h.literal_top = literal_top - compiling.base;
	ext_h.literal_max = literal_max - compiling.base;
	ext_h.relocation_base = compiling.base;
	fwrite(&ext_h,sizeof(HEADER_2),1,file);

	fwrite((void*)active.base,h.size,1,file);
	fwrite((void*)compiling.base,ext_h.size,1,file);

	fclose(file);

	return true;
}

void primitive_save_image(void)
{
	F_STRING* filename = untag_string(dpop());
	save_image(to_c_string(filename));
}
