#include "factor.h"

XT primitives[] = {
	undefined,                              /* 0 */
	call,                                   /* 1 */
	primitive_execute,                      /* 2 */
	primitive_call,                         /* 3 */
	primitive_ifte,                         /* 4 */
	primitive_consp,                        /* 5 */
	primitive_cons,                         /* 6 */
	primitive_car,                          /* 7 */
	primitive_cdr,                          /* 8 */
	primitive_rplaca,                       /* 9 */
	primitive_rplacd,                       /* 10 */
	primitive_vectorp,                      /* 11 */
	primitive_vector,                       /* 12 */
	primitive_vector_length,                /* 13 */
	primitive_set_vector_length,            /* 14 */
	primitive_vector_nth,                   /* 15 */
	primitive_set_vector_nth,               /* 16 */
	primitive_stringp,                      /* 17 */
	primitive_string_length,                /* 18 */
	primitive_string_nth,                   /* 19 */
	primitive_string_compare,               /* 20 */
	primitive_string_eq,                    /* 21 */
	primitive_string_hashcode,              /* 22 */
	primitive_index_of,                     /* 23 */
	primitive_substring,                    /* 24 */
	primitive_sbufp,                        /* 25 */
	primitive_sbuf,                         /* 26 */
	primitive_sbuf_length,                  /* 27 */
	primitive_set_sbuf_length,              /* 28 */
	primitive_sbuf_nth,                     /* 29 */
	primitive_set_sbuf_nth,                 /* 30 */
	primitive_sbuf_append,                  /* 31 */
	primitive_sbuf_to_string,               /* 32 */
	primitive_fixnump,                      /* 33 */
	primitive_add,                          /* 34 */
	primitive_subtract,                     /* 35 */
	primitive_multiply,                     /* 36 */
	primitive_divide,                       /* 37 */
	primitive_mod,                          /* 38 */
	primitive_divmod,                       /* 39 */
	primitive_and,                          /* 40 */
	primitive_xor,                          /* 41 */
	primitive_less,                         /* 42 */
	primitive_lesseq,                       /* 43 */
	primitive_greater,                      /* 44 */
	primitive_greatereq,                    /* 45 */
	primitive_wordp,                        /* 46 */
	primitive_word,                         /* 47 */
	primitive_word_primitive,               /* 48 */
	primitive_set_word_primitive,           /* 49 */
	primitive_word_parameter,               /* 50 */
	primitive_set_word_parameter,           /* 51 */
	primitive_word_plist,                   /* 52 */
	primitive_set_word_plist,               /* 53 */
	primitive_drop,                         /* 54 */
	primitive_dup,                          /* 55 */
	primitive_swap,                         /* 56 */
	primitive_over,                         /* 57 */
	primitive_pick,                         /* 58 */
	primitive_nip,                          /* 59 */
	primitive_tuck,                         /* 60 */
	primitive_rot,                          /* 61 */
	primitive_to_r,                         /* 62 */
	primitive_from_r,                       /* 63 */
	primitive_eq,                           /* 64 */
	primitive_getenv,                       /* 65 */
	primitive_setenv,                       /* 66 */
	primitive_read_line_8,                  /* 67 */
	primitive_write_8,                      /* 68 */
	primitive_gc,                           /* 69 */
	primitive_save_image,                   /* 70 */
	primitive_datastack,                    /* 71 */
	primitive_callstack,                    /* 72 */
	primitive_set_datastack,                /* 73 */
	primitive_set_callstack,                /* 74 */
	primitive_handlep,                      /* 75 */
	primitive_exit                          /* 76 */
};

CELL primitive_to_xt(CELL primitive)
{
	XT xt;

	if(primitive < 0 || primitive >= PRIMITIVE_COUNT)
		fatal_error("Invalid primitive",primitive);
	
	xt = primitives[primitive];
	if((CELL)xt % 8 != 0)
		fatal_error("compile with -falign-functions=8",xt);
	
	return RETAG(xt,XT_TYPE);
}

void primitive_eq(void)
{
	check_non_empty(env.dt);
	check_non_empty(dpeek());
	env.dt = tag_boolean(dpop() == env.dt);
}
