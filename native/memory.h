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

void init_arena(CELL size);
void flip_zones();

CELL allot(CELL a);

INLINE CELL align8(CELL a)
{
	return ((a & 7) == 0) ? a : ((a + 8) & ~7);
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
