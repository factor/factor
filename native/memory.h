typedef struct {
	CELL base;
	CELL here;
	CELL alarm;
	CELL limit;
} ZONE;

ZONE active;
ZONE prior;

bool allot_profiling;

void* alloc_guarded(CELL size);
void init_zone(ZONE* zone, CELL size);
void init_arena(CELL size);
void flip_zones();

void allot_profile_step(CELL a);

INLINE CELL align8(CELL a)
{
	return ((a & 7) == 0) ? a : ((a + 8) & ~7);
}

INLINE void* allot(CELL a)
{
	CELL h = active.here;
	active.here += align8(a);
	if(allot_profiling)
		allot_profile_step(align8(a));
	return (void*)h;
}

INLINE CELL get(CELL where)
{
	return *((CELL*)where);
}

INLINE void put(CELL where, CELL what)
{
	*((CELL*)where) = what;
}

INLINE u16 cget(CELL where)
{
	return *((u16*)where);
}

INLINE void cput(CELL where, u16 what)
{
	*((u16*)where) = what;
}

INLINE BYTE bget(CELL where)
{
	return *((BYTE*)where);
}

INLINE void bput(CELL where, BYTE what)
{
	*((BYTE*)where) = what;
}

bool in_zone(ZONE* z, CELL pointer);

void primitive_room(void);
void primitive_allot_profiling(void);
void primitive_address(void);
void primitive_size(void);

/* A heap walk allows useful things to be done, like finding all
references to an object for debugging purposes. */
CELL heap_scan_ptr;

/* End of heap when walk was started; prevents infinite loop if
walk consing */
CELL heap_scan_end;

void primitive_begin_scan(void);
void primitive_next_object(void);
void primitive_end_scan(void);
