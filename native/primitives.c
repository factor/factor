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
	primitive_or,                           /* 41 */
	primitive_xor,                          /* 42 */
	primitive_not,                          /* 43 */
	primitive_shiftleft,                    /* 44 */
	primitive_shiftright,                   /* 45 */
	primitive_less,                         /* 46 */
	primitive_lesseq,                       /* 47 */
	primitive_greater,                      /* 48 */
	primitive_greatereq,                    /* 49 */
	primitive_wordp,                        /* 50 */
	primitive_word,                         /* 51 */
	primitive_word_primitive,               /* 52 */
	primitive_set_word_primitive,           /* 53 */
	primitive_word_parameter,               /* 54 */
	primitive_set_word_parameter,           /* 55 */
	primitive_word_plist,                   /* 56 */
	primitive_set_word_plist,               /* 57 */
	primitive_drop,                         /* 58 */
	primitive_dup,                          /* 59 */
	primitive_swap,                         /* 60 */
	primitive_over,                         /* 61 */
	primitive_pick,                         /* 62 */
	primitive_nip,                          /* 63 */
	primitive_tuck,                         /* 64 */
	primitive_rot,                          /* 65 */
	primitive_to_r,                         /* 66 */
	primitive_from_r,                       /* 67 */
	primitive_eq,                           /* 68 */
	primitive_getenv,                       /* 69 */
	primitive_setenv,                       /* 70 */
	primitive_open_file,                    /* 71 */
	primitive_gc,                           /* 72 */
	primitive_save_image,                   /* 73 */
	primitive_datastack,                    /* 74 */
	primitive_callstack,                    /* 75 */
	primitive_set_datastack,                /* 76 */
	primitive_set_callstack,                /* 77 */
	primitive_handlep,                      /* 78 */
	primitive_exit,                         /* 79 */
	primitive_server_socket,                /* 80 */
	primitive_close_fd,                     /* 81 */
	primitive_accept_fd,                    /* 82 */
	primitive_read_line_fd_8,               /* 83 */
	primitive_write_fd_8,                   /* 84 */
	primitive_flush_fd,                     /* 85 */
	primitive_shutdown_fd,                  /* 86 */
	primitive_room                          /* 87 */
};

CELL primitive_to_xt(CELL primitive)
{
	XT xt;

	if(primitive < 0 || primitive >= PRIMITIVE_COUNT)
		general_error(ERROR_BAD_PRIMITIVE,tag_fixnum(primitive));
	
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
