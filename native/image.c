#include "factor.h"

void load_image(char* filename)
{
	FILE* file;
	HEADER h;
	CELL size;
	
	printf("Loading %s\n",filename);
	
	file = fopen(filename,"rb");

	fread(&h,sizeof(HEADER),1,file);

	if(h.magic != IMAGE_MAGIC)
		fatal_error("Bad magic number",h.magic);
	if(h.version != IMAGE_VERSION)
		fatal_error("Bad version number",h.version);

	allot(h.size);

	size = h.size / CELLS;

	if(size != fread((void*)active->base,sizeof(CELL),size,file))
		fatal_error("Wrong image length",h.size);

	active->here = active->base + h.size;
	fclose(file);

	clear_environment();

	env.boot = h.boot;

	env.user[GLOBAL_ENV] = h.global;
	relocate(h.relocation_base);
}

bool save_image(char* filename)
{
	FILE* file;
	HEADER h;

	printf("Saving %s\n",filename);
	
	file = fopen(filename,"wb");

	h.magic = IMAGE_MAGIC;
	h.version = IMAGE_VERSION;
	h.relocation_base = active->base;
	h.boot = env.boot;
	h.size = (active->here - active->base);
	h.global = env.user[GLOBAL_ENV];

	fwrite(&h,sizeof(HEADER),1,file);
	fwrite((void*)active->base,h.size,1,file);

	fclose(file);

	return true;
}

void primitive_save_image(void)
{
	STRING* filename = untag_string(env.dt);
	env.dt = dpop();
	
	save_image(to_c_string(filename));
}
