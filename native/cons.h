typedef struct {
	CELL car;
	CELL cdr;
} F_CONS;

INLINE F_CONS* untag_cons(CELL tagged)
{
	type_check(CONS_TYPE,tagged);
	return (F_CONS*)UNTAG(tagged);
}

INLINE CELL tag_cons(F_CONS* cons)
{
	return RETAG(cons,CONS_TYPE);
}

CELL cons(CELL car, CELL cdr);

INLINE CELL car(CELL cons)
{
	return untag_cons(cons)->car;
}

INLINE CELL cdr(CELL cons)
{
	return untag_cons(cons)->cdr;
}

void primitive_cons(void);
