namespace factor
{

static const cell image_magic = 0x0f0e0d0c;
static const cell image_version = 4;

struct image_header {
	cell magic;
	cell version;
	/* all pointers in the image file are relocated from
	   relocation_base to here when the image is loaded */
	cell data_relocation_base;
	/* size of heap */
	cell data_size;
	/* code relocation base */
	cell code_relocation_base;
	/* size of code heap */
	cell code_size;
	/* tagged pointer to t singleton */
	cell t;
	/* tagged pointer to bignum 0 */
	cell bignum_zero;
	/* tagged pointer to bignum 1 */
	cell bignum_pos_one;
	/* tagged pointer to bignum -1 */
	cell bignum_neg_one;
	/* Initial user environment */
	cell userenv[USER_ENV];
};

struct vm_parameters {
	const vm_char *image_path;
	const vm_char *executable_path;
	cell ds_size, rs_size;
	cell gen_count, young_size, aging_size, tenured_size;
	cell code_size;
	bool secure_gc;
	bool fep;
	bool console;
	bool stack_traces;
	cell max_pic_size;
};

}
