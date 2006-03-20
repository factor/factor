#define IMAGE_MAGIC 0x0f0e0d0c
#define IMAGE_VERSION_0 0
#define IMAGE_VERSION 1

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
	/* tagged pointer to t singleton */
	CELL t;
	/* tagged pointer to bignum 0 */
	CELL bignum_zero;
	/* tagged pointer to bignum 1 */
	CELL bignum_pos_one;
	/* tagged pointer to bignum -1 */
	CELL bignum_neg_one;
	/* size of heap */
	CELL size;
} HEADER;

/* If version is IMAGE_VERSION_1 */
typedef struct EXT_HEADER {
	/* size of code heap */
	CELL size;
	/* code relocation base */
	CELL relocation_base;
	/* end of literal table */
	CELL literal_top;
	/* maximum value of literal_top */
	CELL literal_max;
} HEADER_2;

void init_objects(HEADER *h);
void load_image(const char* file, int literal_size);
bool save_image(const char* file);
void primitive_save_image(void);
