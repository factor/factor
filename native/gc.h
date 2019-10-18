/* generational copying GC divides memory into zones */
typedef struct {
	/* start of zone */
	CELL base;
	/* allocation pointer */
	CELL here;
	/* only for nursery: when it gets this full, call GC */
	CELL alarm;
	/* end of zone */
	CELL limit;
} ZONE;

/* total number of generations. */
CELL gen_count;

/* the 0th generation is where new objects are allocated. */
#define NURSERY 0
/* the oldest generation */
#define TENURED (gen_count-1)

DLLEXPORT ZONE *generations;

/* used during garbage collection only */
ZONE *newspace;

#define tenured generations[TENURED]
#define nursery generations[NURSERY]

/* spare semi-space; rotates with tenured. */
ZONE prior;

INLINE bool in_zone(ZONE* z, CELL pointer)
{
	return pointer >= z->base && pointer < z->limit;
}

CELL init_zone(ZONE *z, CELL size, CELL base);

void init_arena(CELL gen_count, CELL young_size, CELL aging_size);

/* statistics */
s64 gc_time;
CELL minor_collections;
CELL cards_scanned;

/* only meaningful during a GC */
CELL collecting_gen;
CELL collecting_gen_start;

/* test if the pointer is in generation being collected, or a younger one.
init_arena() arranges things so that the older generations are first,
so we have to check that the pointer occurs after the beginning of
the requested generation. */
#define COLLECTING_GEN(ptr) (collecting_gen_start <= ptr)

/* #define GC_DEBUG */

INLINE void gc_debug(char* msg, CELL x) {
#ifdef GC_DEBUG
	printf("%s %ld\n",msg,x);
#endif
}

INLINE bool should_copy(CELL untagged)
{
	if(collecting_gen == TENURED)
		return !in_zone(newspace,untagged);
	else
		return(in_zone(&prior,untagged) || COLLECTING_GEN(untagged));
}

CELL copy_object(CELL pointer);
#define COPY_OBJECT(lvalue) if(should_copy(lvalue)) lvalue = copy_object(lvalue)

INLINE void copy_handle(CELL *handle)
{
	COPY_OBJECT(*handle);
}

/* in case a generation fills up in the middle of a gc, we jump back
up to try collecting the next generation. */
jmp_buf gc_jmp;

/* A heap walk allows useful things to be done, like finding all
references to an object for debugging purposes. */
CELL heap_scan_ptr;

/* GC is off during heap walking */
bool heap_scan;

INLINE void *allot_zone(ZONE *z, CELL a)
{
	CELL h = z->here;
	z->here = h + align8(a);
	if(z->here > z->limit)
	{
		fprintf(stderr,"Nursery space exhausted\n");
		factorbug();
	}

	allot_barrier(h);
	return (void*)h;
}

INLINE void *allot(CELL a)
{
	return allot_zone(&nursery,a);
}

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
INLINE void* allot_object(CELL type, CELL length)
{
	CELL* object = allot(length);
	*object = tag_header(type);
	return object;
}

void update_cards_offset(void);
CELL collect_next(CELL scan);
void garbage_collection(CELL gen);
void primitive_gc(void);
void maybe_gc(CELL size);
DLLEXPORT void simple_gc(void);
void primitive_gc_time(void);
