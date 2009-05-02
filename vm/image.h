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
} F_PARAMETERS;

void load_image(F_PARAMETERS *p);
void init_objects(F_HEADER *h);
bool save_image(const F_CHAR *file);

void primitive_save_image(void);
void primitive_save_image_and_exit(void);

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

INLINE void code_fixup(CELL cell)
{
	CELL value = get(cell);
	put(cell,value + (code_heap.segment->start - code_relocation_base));
}

void relocate_data();
void relocate_code();
