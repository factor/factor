#include "factor.h"

void load_image(char* filename)
{
	FILE* file;
	HEADER h;
	CELL size;
	
	printf("Loading %s...",filename);

	file = fopen(filename,"rb");
	if(file == NULL)
		fatal_error("Cannot open image for reading",errno);

	/* read it in native byte order */
	fread(&h,sizeof(HEADER)/sizeof(CELL),sizeof(CELL),file);

	if(h.magic != IMAGE_MAGIC)
		fatal_error("Bad magic number",h.magic);
	if(h.version != IMAGE_VERSION)
		fatal_error("Bad version number",h.version);

	allot(h.size);

	size = h.size / CELLS;

	if(size != fread((void*)active.base,sizeof(CELL),size,file))
		fatal_error("Wrong image length",h.size);

	active.here = active.base + h.size;
	fclose(file);

	printf(" relocating...");
	fflush(stdout);

	clear_environment();

	userenv[GLOBAL_ENV] = h.global;
	userenv[BOOT_ENV] = h.boot;

	relocate(h.relocation_base);

	printf(" done\n");
	fflush(stdout);
}

bool save_image(char* filename)
{
	FILE* file;
	HEADER h;

	fprintf(stderr,"Saving %s...\n",filename);
	
	file = fopen(filename,"wb");
	if(file == NULL)
		fatal_error("Cannot open image for writing",errno);

	h.magic = IMAGE_MAGIC;
	h.version = IMAGE_VERSION;
	h.relocation_base = active.base;
	h.boot = userenv[BOOT_ENV];
	h.size = (active.here - active.base);
	h.global = userenv[GLOBAL_ENV];

	fwrite(&h,sizeof(HEADER),1,file);
	fwrite((void*)active.base,h.size,1,file);

	fclose(file);

	return true;
}

void primitive_save_image(void)
{
	STRING* filename = untag_string(dpop());
	save_image(to_c_string(filename));
}
