typedef struct {
	CELL car;
	CELL cdr;
} CONS;

INLINE CONS* untag_cons(CELL tagged)
{
	type_check(CONS_TYPE,tagged);
	return (CONS*)UNTAG(tagged);
}

INLINE CELL tag_cons(CONS* cons)
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

void primitive_consp(void);
void primitive_cons(void);
void primitive_car(void);
void primitive_cdr(void);
void primitive_set_car(void);
void primitive_set_cdr(void);
