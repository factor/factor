typedef struct {
	CELL header;
	/* tagged string */
	CELL path;
	/* OS-specific handle */
	void* dll;
} DLL;

DLL* untag_dll(CELL tagged);

void ffi_dlopen(DLL *dll);
void *ffi_dlsym(DLL *dll, F_STRING *symbol);
void ffi_dlclose(DLL *dll);

void primitive_dlopen(void);
void primitive_dlsym(void);
void primitive_dlclose(void);

void fixup_dll(DLL* dll);
void collect_dll(DLL* dll);
