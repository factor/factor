typedef struct {
	CELL header;
	/* tagged string */
	CELL path;
	/* OS-specific handle */
	void* dll;
} DLL;

INLINE DLL *untag_dll(CELL tagged)
{
	type_check(DLL_TYPE,tagged);
	return (DLL*)UNTAG(tagged);
}

void init_ffi(void);

void ffi_dlopen(DLL *dll, bool error);
void *ffi_dlsym(DLL *dll, F_STRING *symbol, bool error);
void ffi_dlclose(DLL *dll);

void primitive_dlopen(void);
void primitive_dlsym(void);
void primitive_dlclose(void);

void fixup_dll(DLL* dll);
void collect_dll(DLL* dll);
