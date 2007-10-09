#define IMAGE_MAGIC 0x0f0e0d0c
#define IMAGE_VERSION 4

typedef struct {
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
} F_HEADER;

typedef struct {
	const F_CHAR* image;
	CELL ds_size, rs_size;
	CELL gen_count, young_size, aging_size;
	CELL code_size;
	bool secure_gc;
	bool fep;
} F_PARAMETERS;

void load_image(F_PARAMETERS *p);
void init_objects(F_HEADER *h);
bool save_image(const F_CHAR *file);

DECLARE_PRIMITIVE(save_image);
DECLARE_PRIMITIVE(save_image_and_exit);

/* relocation base of currently loaded image's data heap */
CELL data_relocation_base;

INLINE void data_fixup(CELL *cell)
{
	if(immediate_p(*cell))
		return;

	F_ZONE *tenured = &data_heap->generations[TENURED];
	*cell += (tenured->start - data_relocation_base);
}

CELL code_relocation_base;

INLINE void code_fixup(XT *cell)
{
	CELL value = (CELL)*cell;
	value += (code_heap.segment->start - code_relocation_base);
	*cell = (XT)value;
}

void relocate_data();
void relocate_code();
