typedef struct {
	CELL header;
	void* dll;
} DLL;

INLINE DLL* untag_dll(CELL tagged)
{
	type_check(DLL_TYPE,tagged);
	return (DLL*)UNTAG(tagged);
}

typedef struct {
	CELL header;
	CELL ptr;
	CELL length;
} ALIEN;

INLINE ALIEN* untag_alien(CELL tagged)
{
	type_check(ALIEN_TYPE,tagged);
	return (ALIEN*)UNTAG(tagged);
}

void primitive_dlopen(void);
void primitive_dlsym(void);
void primitive_dlsym_self(void);
void primitive_dlclose(void);
void primitive_alien(void);
void primitive_alien_cell(void);
void primitive_set_alien_cell(void);
void primitive_alien_4(void);
void primitive_set_alien_4(void);
void primitive_alien_1(void);
void primitive_set_alien_1(void);
