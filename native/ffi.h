typedef struct {
	CELL header;
	/* tagged string */
	CELL path;
	/* OS-specific handle */
	void* dll;
} DLL;

DLL* untag_dll(CELL tagged);

typedef struct {
	CELL header;
	CELL ptr;
	/* local aliens are heap-allocated as strings and must be collected. */
	bool local;
} ALIEN;

INLINE ALIEN* untag_alien(CELL tagged)
{
	type_check(ALIEN_TYPE,tagged);
	return (ALIEN*)UNTAG(tagged);
}

void ffi_dlopen(DLL *dll);
void *ffi_dlsym(DLL *dll, F_STRING *symbol);
void ffi_dlclose(DLL *dll);

void primitive_dlopen(void);
void primitive_dlsym(void);
void primitive_dlclose(void);
void primitive_alien(void);
void primitive_local_alien(void);
DLLEXPORT CELL unbox_alien(void);
DLLEXPORT void box_alien(CELL ptr);
void primitive_local_alienp(void);
void primitive_alien_address(void);
void primitive_alien_cell(void);
void primitive_set_alien_cell(void);
void primitive_alien_4(void);
void primitive_set_alien_4(void);
void primitive_alien_2(void);
void primitive_set_alien_2(void);
void primitive_alien_1(void);
void primitive_set_alien_1(void);
void fixup_dll(DLL* dll);
void fixup_alien(ALIEN* alien);
void collect_alien(ALIEN* alien);
