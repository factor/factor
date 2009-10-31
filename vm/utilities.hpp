namespace factor
{

inline static void memset_cell(void *dst, cell pattern, size_t size)
{
#ifdef __APPLE__
	#ifdef FACTOR_64
		memset_pattern8(dst,&pattern,size);
	#else
		memset_pattern4(dst,&pattern,size);
	#endif
#else
	if(pattern == 0)
		memset(dst,0,size);
	else
	{
		cell *start = (cell *)dst;
		cell *end = (cell *)((cell)dst + size);
		while(start < end)
		{
			*start = pattern;
			start++;
		}
	}
#endif
}

vm_char *safe_strdup(const vm_char *str);
void print_string(const char *str);
void nl();
void print_cell(cell x);
void print_cell_hex(cell x);
void print_cell_hex_pad(cell x);
void print_fixnum(fixnum x);
cell read_cell_hex();

}
