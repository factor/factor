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
	primitive_set_car,                      /* 9 */
	primitive_set_cdr,                      /* 10 */
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
	primitive_numberp,                      /* 33 */
	primitive_to_fixnum,                    /* 34 */
	primitive_to_bignum,                    /* 35 */
	primitive_number_eq,                    /* 36 */
	primitive_fixnump,                      /* 37 */
	primitive_bignump,                      /* 38 */
	primitive_add,                          /* 39 */
	primitive_subtract,                     /* 40 */
	primitive_multiply,                     /* 41 */
	primitive_divide,                       /* 42 */
	primitive_mod,                          /* 43 */
	primitive_divmod,                       /* 44 */
	primitive_and,                          /* 45 */
	primitive_or,                           /* 46 */
	primitive_xor,                          /* 47 */
	primitive_not,                          /* 48 */
	primitive_shiftleft,                    /* 49 */
	primitive_shiftright,                   /* 50 */
	primitive_less,                         /* 51 */
	primitive_lesseq,                       /* 52 */
	primitive_greater,                      /* 53 */
	primitive_greatereq,                    /* 54 */
	primitive_wordp,                        /* 55 */
	primitive_word,                         /* 56 */
	primitive_word_primitive,               /* 57 */
	primitive_set_word_primitive,           /* 58 */
	primitive_word_parameter,               /* 59 */
	primitive_set_word_parameter,           /* 60 */
	primitive_word_plist,                   /* 61 */
	primitive_set_word_plist,               /* 62 */
	primitive_drop,                         /* 63 */
	primitive_dup,                          /* 64 */
	primitive_swap,                         /* 65 */
	primitive_over,                         /* 66 */
	primitive_pick,                         /* 67 */
	primitive_nip,                          /* 68 */
	primitive_tuck,                         /* 69 */
	primitive_rot,                          /* 70 */
	primitive_to_r,                         /* 71 */
	primitive_from_r,                       /* 72 */
	primitive_eq,                           /* 73 */
	primitive_getenv,                       /* 74 */
	primitive_setenv,                       /* 75 */
	primitive_open_file,                    /* 76 */
	primitive_gc,                           /* 77 */
	primitive_save_image,                   /* 78 */
	primitive_datastack,                    /* 79 */
	primitive_callstack,                    /* 80 */
	primitive_set_datastack,                /* 81 */
	primitive_set_callstack,                /* 82 */
	primitive_handlep,                      /* 83 */
	primitive_exit,                         /* 84 */
	primitive_server_socket,                /* 85 */
	primitive_close_fd,                     /* 86 */
	primitive_accept_fd,                    /* 87 */
	primitive_read_line_fd_8,               /* 88 */
	primitive_write_fd_8,                   /* 89 */
	primitive_flush_fd,                     /* 90 */
	primitive_shutdown_fd,                  /* 91 */
	primitive_room,                         /* 92 */
	primitive_os_env,                       /* 93 */
	primitive_millis,                       /* 94 */
	primitive_init_random,                  /* 95 */
	primitive_random_int                    /* 96 */
};

CELL primitive_to_xt(CELL primitive)
{
	if(primitive < 0 || primitive >= PRIMITIVE_COUNT)
		general_error(ERROR_BAD_PRIMITIVE,tag_fixnum(primitive));
	
	return (CELL)primitives[primitive];
}
