typedef struct {
	CELL header;
	void* dll;
} DLL;

INLINE DLL* untag_dll(CELL tagged)
{
	type_check(DLL_TYPE,tagged);
	return (DLL*)UNTAG(tagged);
}

void primitive_dlopen(void);
void primitive_dlsym(void);
void primitive_dlsym_self(void);
void primitive_dlclose(void);
