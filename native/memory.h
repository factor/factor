typedef struct {
	CELL base;
	CELL here;
	CELL alarm;
	CELL limit;
} ZONE;

ZONE* z1;
ZONE* z2;
ZONE* active; /* either z1 or z2 */
ZONE* prior; /* if active==z1, z2; if active==z2, z1 */

bool allot_profiling;

void* alloc_guarded(CELL size);
ZONE* zalloc(CELL size);
void init_arena(CELL size);
void flip_zones();

void check_memory(void);
void allot_profile_step(CELL a);

INLINE CELL align8(CELL a)
{
	return ((a & 7) == 0) ? a : ((a + 8) & ~7);
}

INLINE void* allot(CELL a)
{
	CELL h = active->here;
	active->here += align8(a);
#ifdef FACTOR_PROFILER
	if(allot_profiling)
		allot_profile_step(align8(a));
#endif
	check_memory();
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

INLINE CHAR cget(CELL where)
{
	return *((CHAR*)where);
}

INLINE void cput(CELL where, CHAR what)
{
	*((CHAR*)where) = what;
}

INLINE char bget(CELL where)
{
	return *((char*)where);
}

INLINE void bput(CELL where, char what)
{
	*((char*)where) = what;
}

bool in_zone(ZONE* z, CELL pointer);

void primitive_room(void);
void primitive_allot_profiling(void);
