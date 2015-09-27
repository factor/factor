namespace factor {

// Poor mans range-based for loops.
#define FACTOR_FOR_EACH(iterable)                               \
  for (auto iter = (iterable).begin(),    \
           _end = (iterable).end();                             \
       iter != _end;                                            \
       iter++)

inline static void memset_2(void* dst, uint16_t pattern, size_t size) {
#ifdef __APPLE__
  cell cell_pattern = (pattern | (pattern << 16));
  memset_pattern4(dst, &cell_pattern, size);
#else
  if (pattern == 0)
    memset(dst, 0, size);
  else {
    uint16_t* start = (uint16_t*)dst;
    uint16_t* end = (uint16_t*)((cell)dst + size);
    while (start < end) {
      *start = pattern;
      start++;
    }
  }
#endif
}

inline static void memset_cell(void* dst, cell pattern, size_t size) {
#ifdef __APPLE__
#ifdef FACTOR_64
  memset_pattern8(dst, &pattern, size);
#else
  memset_pattern4(dst, &pattern, size);
#endif
#else
  if (pattern == 0)
    memset(dst, 0, size);
  else {
    cell* start = (cell*)dst;
    cell* end = (cell*)((cell)dst + size);
    while (start < end) {
      *start = pattern;
      start++;
    }
  }
#endif
}

void* fill_function_descriptor(void* ptr, void* code);
void* function_descriptor_field(void* ptr, size_t idx);

vm_char* safe_strdup(const vm_char* str);
cell read_cell_hex();
VM_C_API void* factor_memcpy(void* dst, void* src, size_t len);

}
