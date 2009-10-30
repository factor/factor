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
	cell true_object;
	/* tagged pointer to bignum 0 */
	cell bignum_zero;
	/* tagged pointer to bignum 1 */
	cell bignum_pos_one;
	/* tagged pointer to bignum -1 */
	cell bignum_neg_one;
	/* Initial user environment */
	cell special_objects[special_object_count];
};

struct vm_parameters {
	const vm_char *image_path;
	const vm_char *executable_path;
	cell ds_size, rs_size;
	cell young_size, aging_size, tenured_size;
	cell promotion_threshold;
	cell code_size;
	bool fep;
	bool console;
	bool signals;
	cell max_pic_size;
	cell callback_size;
};

}
