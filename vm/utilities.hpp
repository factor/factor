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

void *fill_function_descriptor(void *ptr, void *code);
void *function_descriptor_field(void *ptr, size_t idx);

vm_char *safe_strdup(const vm_char *str);
cell read_cell_hex();
VM_C_API void *factor_memcpy(void *dst, void *src, size_t len);

#if defined(WINDOWS)

	#if defined(FACTOR_64)

		#define FACTOR_ATOMIC_CAS(ptr, old_val, new_val) \
			(InterlockedCompareExchange64(ptr, new_val, old_val) == old_val)

		#define FACTOR_ATOMIC_ADD(ptr, val) \
			InterlockedAdd64(ptr, val)

		#define FACTOR_ATOMIC_SUB(ptr, val) \
			InterlockedSub64(ptr, val)

	#else

		#define FACTOR_ATOMIC_CAS(ptr, old_val, new_val) \
			(InterlockedCompareExchange(ptr, new_val, old_val) == old_val)

		#define FACTOR_ATOMIC_ADD(ptr, val) \
			InterlockedAdd(ptr, val)

		#define FACTOR_ATOMIC_SUB(ptr, val) \
			InterlockedSub(ptr, val)

	#endif

	#define FACTOR_MEMORY_BARRIER() \
		MemoryBarrier()

#elif defined(__GNUC__) || defined(__clang__)

	#define FACTOR_ATOMIC_CAS(ptr, old_val, new_val) \
		__sync_bool_compare_and_swap(ptr, old_val, new_val)

	#define FACTOR_ATOMIC_ADD(ptr, val) \
		__sync_add_and_fetch(ptr, val)

	#define FACTOR_ATOMIC_SUB(ptr, val) \
		__sync_sub_and_fetch(ptr, val)

	#define FACTOR_MEMORY_BARRIER() \
		__sync_synchronize()

#else
	#error "Unsupported compiler"
#endif

}
