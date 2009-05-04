#define IMAGE_MAGIC 0x0f0e0d0c
#define IMAGE_VERSION 4

struct F_IMAGE_HEADER {
	CELL magic;
	CELL version;
	/* all pointers in the image file are relocated from
	   relocation_base to here when the image is loaded */
	CELL data_relocation_base;
	/* size of heap */
	CELL data_size;
	/* code relocation base */
	CELL code_relocation_base;
	/* size of code heap */
	CELL code_size;
	/* tagged pointer to t singleton */
	CELL t;
	/* tagged pointer to bignum 0 */
	CELL bignum_zero;
	/* tagged pointer to bignum 1 */
	CELL bignum_pos_one;
	/* tagged pointer to bignum -1 */
	CELL bignum_neg_one;
	/* Initial user environment */
	CELL userenv[USER_ENV];
};

struct F_PARAMETERS {
	const F_CHAR *image_path;
	const F_CHAR *executable_path;
	CELL ds_size, rs_size;
	CELL gen_count, young_size, aging_size, tenured_size;
	CELL code_size;
	bool secure_gc;
	bool fep;
	bool console;
	bool stack_traces;
	CELL max_pic_size;
};

void load_image(F_PARAMETERS *p);
bool save_image(const F_CHAR *file);

PRIMITIVE(save_image);
PRIMITIVE(save_image_and_exit);
