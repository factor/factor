namespace factor
{

inline static void memset_2(void *dst, u16 pattern, size_t size)
{
#ifdef __APPLE__
	cell cell_pattern = (pattern | (pattern << 16));
	memset_pattern4(dst,&cell_pattern,size);
#else
	if(pattern == 0)
		memset(dst,0,size);
	else
	{
		u16 *start = (u16 *)dst;
		u16 *end = (u16 *)((cell)dst + size);
		while(start < end)
		{
			*start = pattern;
			start++;
		}
	}
#endif
}

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
cell read_cell_hex();
VM_C_API void *factor_memcpy(void *dst, void *src, size_t len);

}
