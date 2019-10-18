typedef struct {
	CELL header;
	void* dll;
} DLL;

DLL* untag_dll(CELL tagged);

typedef struct {
	CELL header;
	CELL ptr;
	CELL length;
	/* local aliens are heap-allocated as strings and must be collected. */
	bool local;
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
void primitive_local_alien(void);
CELL unbox_alien(void);
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
