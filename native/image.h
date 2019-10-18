#define IMAGE_MAGIC 0x0f0e0d0c
#define IMAGE_VERSION 0

typedef struct {
	CELL magic;
	CELL version;
	/* all pointers in the image file are relocated from
	   relocation_base to here when the image is loaded */
	CELL relocation_base;
	/* tagged pointer to bootstrap quotation */
	CELL boot;
	/* tagged pointer to global namespace */
	CELL global;
	/* size of heap */
	CELL size;
} HEADER;

void load_image(char* file);
bool save_image(char* file);
void primitive_save_image(void);
