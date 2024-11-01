! Copyright (C) 2010 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.libraries
alien.syntax classes.struct combinators kernel libc math
namespaces system unix.types ;
IN: readline.ffi

C-LIBRARY: readline {
    { windows "readline.dll" }
    { macos "libreadline.dylib" }
    { unix "libreadline.so" }
}

LIBRARY: readline

TYPEDEF: void* histdata_t

STRUCT: HIST_ENTRY
    { line      c-string   }
    { timestamp c-string   }
    { data      histdata_t } ;

: HISTENT_BYTES ( hs -- n )
    [ line>> strlen ] [ timestamp>> strlen ] bi + ; inline

STRUCT: HISTORY_STATE
    { entries HIST_ENTRY** }
    { offset  int          }
    { length  int          }
    { size    int          }
    { flags   int          } ;

CONSTANT: HS_STIFLED 1

FUNCTION: void using_history ( )
FUNCTION: HISTORY_STATE* history_get_history_state ( )
FUNCTION: void history_set_history_state ( HISTORY_STATE* arg1 )
FUNCTION: void add_history ( c-string arg1 )
FUNCTION: void add_history_time ( c-string arg1 )
FUNCTION: HIST_ENTRY* remove_history ( int arg1 )
FUNCTION: histdata_t free_history_entry ( HIST_ENTRY* arg1 )
FUNCTION: HIST_ENTRY* replace_history_entry ( int arg1, c-string
                                             arg2, histdata_t
                                             arg3 )
FUNCTION: void clear_history ( )
FUNCTION: void stifle_history ( int arg1 )
FUNCTION: int unstifle_history ( )
FUNCTION: int history_is_stifled ( )
FUNCTION: HIST_ENTRY** history_list ( )
FUNCTION: int where_history ( )
FUNCTION: HIST_ENTRY* current_history ( )
FUNCTION: HIST_ENTRY* history_get ( int arg1 )
FUNCTION: time_t history_get_time ( HIST_ENTRY* arg1 )
FUNCTION: int history_total_bytes ( )
FUNCTION: int history_set_pos ( int arg1 )
FUNCTION: HIST_ENTRY* previous_history ( )
FUNCTION: HIST_ENTRY* next_history ( )
FUNCTION: int history_search ( c-string arg1, int arg2 )
FUNCTION: int history_search_prefix ( c-string arg1, int arg2 )
FUNCTION: int history_search_pos ( c-string arg1, int arg2, int
                                  arg3 )
FUNCTION: int read_history ( c-string arg1 )
FUNCTION: int read_history_range ( c-string arg1, int arg2, int
                                  arg3 )
FUNCTION: int write_history ( c-string arg1 )
FUNCTION: int append_history ( int arg1, c-string arg2 )
FUNCTION: int history_expand ( c-string arg1, char** arg2 )
FUNCTION: c-string history_arg_extract ( int arg1, int arg2,
                                        c-string arg3 )
FUNCTION: c-string get_history_event ( c-string arg1, int* arg2,
                                      int arg3 )
FUNCTION: char** history_tokenize ( c-string arg1 )

CALLBACK: int rl_command_func_t ( int arg1, int arg2 )
CALLBACK: char* rl_compentry_func_t ( c-string arg1, int arg2 )
CALLBACK: char** rl_completion_func_t ( c-string arg1, int arg2,
                                       int arg3 )

CALLBACK: c-string rl_quote_func_t ( c-string arg1, int arg2,
                                    c-string arg3 )
CALLBACK: c-string rl_dequote_func_t ( c-string arg1, int arg2 )
CALLBACK: int rl_compignore_func_t ( char** arg1 )
CALLBACK: void rl_compdisp_func_t ( char** arg1, int arg2, int
                                   arg3 )
CALLBACK: int rl_hook_func_t ( )
CALLBACK: int rl_getc_func_t ( FILE* arg1 )
CALLBACK: int rl_linebuf_func_t ( c-string arg1, int arg2 )

STRUCT: KEYMAP_ENTRY
    { type     char               }
    { function rl_command_func_t* } ;

CONSTANT: KEYMAP_SIZE 257
CONSTANT: ANYOTHERKEY 256

TYPEDEF: KEYMAP_ENTRY[257] KEYMAP_ENTRY_ARRAY
TYPEDEF: KEYMAP_ENTRY*     Keymap

CONSTANT: ISFUNC 0
CONSTANT: ISKMAP 1
CONSTANT: ISMACR 2

C-GLOBAL: KEYMAP_ENTRY_ARRAY emacs_standard_keymap
C-GLOBAL: KEYMAP_ENTRY_ARRAY emacs_meta_keymap
C-GLOBAL: KEYMAP_ENTRY_ARRAY emacs_ctlx_keymap
C-GLOBAL: KEYMAP_ENTRY_ARRAY vi_insertion_keymap
C-GLOBAL: KEYMAP_ENTRY_ARRAY vi_movement_keymap

FUNCTION: Keymap rl_copy_keymap ( Keymap k )
FUNCTION: Keymap rl_make_keymap ( )
FUNCTION: void rl_discard_keymap ( Keymap k )

CALLBACK: c-string tilde_hook_func_t ( c-string s )

C-GLOBAL: tilde_hook_func_t* tilde_expansion_preexpansion_hook
C-GLOBAL: tilde_hook_func_t* tilde_expansion_failure_hook
C-GLOBAL: char**             tilde_additional_prefixes
C-GLOBAL: char**             tilde_additional_suffixes

FUNCTION: c-string tilde_expand ( c-string s )
FUNCTION: c-string tilde_expand_word ( c-string s )
FUNCTION: c-string tilde_find_word ( c-string arg1, int arg2,
                                    int* arg3 )

C-GLOBAL: int history_base
C-GLOBAL: int history_length
C-GLOBAL: int history_max_entries
C-GLOBAL: char history_expansion_char
C-GLOBAL: char history_subst_char
C-GLOBAL: c-string history_word_delimiters
C-GLOBAL: char history_comment_char
C-GLOBAL: c-string history_no_expand_chars
C-GLOBAL: c-string history_search_delimiter_chars
C-GLOBAL: int history_quotes_inhibit_expansion
C-GLOBAL: int history_write_timestamps
C-GLOBAL: int max_input_history
C-GLOBAL: rl_linebuf_func_t* history_inhibit_expansion_function

CALLBACK: int rl_intfunc_t ( int i )
CALLBACK: int rl_icpfunc_t ( c-string s )
CALLBACK: int rl_icppfunc_t ( char** s )

CALLBACK: void rl_voidfunc_t ( )
CALLBACK: void rl_vintfunc_t ( int i )
CALLBACK: void rl_vcpfunc_t ( c-string s )
CALLBACK: void rl_vcppfunc_t ( char** s )

CALLBACK: c-string rl_cpvfunc_t ( )
CALLBACK: c-string rl_cpifunc_t ( int i )
CALLBACK: c-string rl_cpcpfunc_t ( c-string s )
CALLBACK: c-string rl_cpcppfunc_t ( char** s )

ENUM: undo_code UNDO_DELETE UNDO_INSERT UNDO_BEGIN UNDO_END ;

STRUCT: UNDO_LIST
    { next      UNDO_LIST* }
    { start     int        }
    { end       int        }
    { text      char*      }
    { what      undo_code  } ;

C-GLOBAL: UNDO_LIST* rl_undo_list

STRUCT: FUNMAP
    { name     c-string           }
    { function rl_command_func_t* } ;

C-GLOBAL: FUNMAP** funmap

FUNCTION: int rl_digit_argument ( int arg1, int arg2 )
FUNCTION: int rl_universal_argument ( int arg, int arg )

FUNCTION: int rl_forward_byte ( int arg1, int arg2 )
FUNCTION: int rl_forward_char ( int arg1, int arg2 )
FUNCTION: int rl_forward ( int arg1, int arg2 )
FUNCTION: int rl_backward_byte ( int arg1, int arg2 )
FUNCTION: int rl_backward_char ( int arg1, int arg2 )
FUNCTION: int rl_backward ( int arg1, int arg2 )
FUNCTION: int rl_beg_of_line ( int arg1, int arg2 )
FUNCTION: int rl_end_of_line ( int arg1, int arg2 )
FUNCTION: int rl_forward_word ( int arg1, int arg2 )
FUNCTION: int rl_backward_word ( int arg1, int arg2 )
FUNCTION: int rl_refresh_line ( int arg1, int arg2 )
FUNCTION: int rl_clear_screen ( int arg1, int arg2 )
FUNCTION: int rl_skip_csi_sequence ( int arg1, int arg2 )
FUNCTION: int rl_arrow_keys ( int arg1, int arg2 )

FUNCTION: int rl_insert ( int arg1, int arg2 )
FUNCTION: int rl_quoted_insert ( int arg1, int arg2 )
FUNCTION: int rl_tab_insert ( int arg1, int arg2 )
FUNCTION: int rl_newline ( int arg1, int arg2 )
FUNCTION: int rl_do_lowercase_version ( int arg1, int arg2 )
FUNCTION: int rl_rubout ( int arg1, int arg2 )
FUNCTION: int rl_delete ( int arg1, int arg2 )
FUNCTION: int rl_rubout_or_delete ( int arg1, int arg2 )
FUNCTION: int rl_delete_horizontal_space ( int arg1, int arg2 )
FUNCTION: int rl_delete_or_show_completions ( int arg1, int arg2 )
FUNCTION: int rl_insert_comment ( int arg1, int arg2 )

FUNCTION: int rl_upcase_word ( int arg1, int arg2 )
FUNCTION: int rl_downcase_word ( int arg1, int arg2 )
FUNCTION: int rl_capitalize_word ( int arg1, int arg2 )

FUNCTION: int rl_transpose_words ( int arg1, int arg2 )
FUNCTION: int rl_transpose_chars ( int arg1, int arg2 )

FUNCTION: int rl_char_search ( int arg1, int arg2 )
FUNCTION: int rl_backward_char_search ( int arg1, int arg2 )

FUNCTION: int rl_beginning_of_history ( int arg1, int arg2 )
FUNCTION: int rl_end_of_history ( int arg1, int arg2 )
FUNCTION: int rl_get_next_history ( int arg1, int arg2 )
FUNCTION: int rl_get_previous_history ( int arg1, int arg2 )

FUNCTION: int rl_set_mark ( int arg1, int arg2 )
FUNCTION: int rl_exchange_point_and_mark ( int arg1, int arg2 )

FUNCTION: int rl_vi_editing_mode ( int arg1, int arg2 )
FUNCTION: int rl_emacs_editing_mode ( int arg1, int arg2 )

FUNCTION: int rl_overwrite_mode ( int arg1, int arg2 )

FUNCTION: int rl_re_read_init_file ( int arg1, int arg2 )
FUNCTION: int rl_dump_functions ( int arg1, int arg2 )
FUNCTION: int rl_dump_macros ( int arg1, int arg2 )
FUNCTION: int rl_dump_variables ( int arg1, int arg2 )

FUNCTION: int rl_complete ( int arg1, int arg2 )
FUNCTION: int rl_possible_completions ( int arg1, int arg2 )
FUNCTION: int rl_insert_completions ( int arg1, int arg2 )
FUNCTION: int rl_old_menu_complete ( int arg1, int arg2 )
FUNCTION: int rl_menu_complete ( int arg1, int arg2 )
FUNCTION: int rl_backward_menu_complete ( int arg1, int arg2 )

FUNCTION: int rl_kill_word ( int arg1, int arg2 )
FUNCTION: int rl_backward_kill_word ( int arg1, int arg2 )
FUNCTION: int rl_kill_line ( int arg1, int arg2 )
FUNCTION: int rl_backward_kill_line ( int arg1, int arg2 )
FUNCTION: int rl_kill_full_line ( int arg1, int arg2 )
FUNCTION: int rl_unix_word_rubout ( int arg1, int arg2 )
FUNCTION: int rl_unix_filename_rubout ( int arg1, int arg2 )
FUNCTION: int rl_unix_line_discard ( int arg1, int arg2 )
FUNCTION: int rl_copy_region_to_kill ( int arg1, int arg2 )
FUNCTION: int rl_kill_region ( int arg1, int arg2 )
FUNCTION: int rl_copy_forward_word ( int arg1, int arg2 )
FUNCTION: int rl_copy_backward_word ( int arg1, int arg2 )
FUNCTION: int rl_yank ( int arg1, int arg2 )
FUNCTION: int rl_yank_pop ( int arg1, int arg2 )
FUNCTION: int rl_yank_nth_arg ( int arg1, int arg2 )
FUNCTION: int rl_yank_last_arg ( int arg1, int arg2 )

FUNCTION: int rl_reverse_search_history ( int arg1, int arg2 )
FUNCTION: int rl_forward_search_history ( int arg1, int arg2 )

FUNCTION: int rl_start_kbd_macro ( int arg1, int arg2 )
FUNCTION: int rl_end_kbd_macro ( int arg1, int arg2 )
FUNCTION: int rl_call_last_kbd_macro ( int arg1, int arg2 )

FUNCTION: int rl_revert_line ( int arg1, int arg2 )
FUNCTION: int rl_undo_command ( int arg1, int arg2 )

FUNCTION: int rl_tilde_expand ( int arg1, int arg2 )

FUNCTION: int rl_restart_output ( int arg1, int arg2 )
FUNCTION: int rl_stop_output ( int arg1, int arg2 )

FUNCTION: int rl_abort ( int arg1, int arg2 )
FUNCTION: int rl_tty_status ( int arg1, int arg2 )

FUNCTION: int rl_history_search_forward ( int arg1, int arg2 )
FUNCTION: int rl_history_search_backward ( int arg1, int arg2 )
FUNCTION: int rl_noninc_forward_search ( int arg1, int arg2 )
FUNCTION: int rl_noninc_reverse_search ( int arg1, int arg2 )
FUNCTION: int rl_noninc_forward_search_again ( int arg1, int arg2 )
FUNCTION: int rl_noninc_reverse_search_again ( int arg1, int arg2 )

FUNCTION: int rl_insert_close ( int arg1, int arg2 )

FUNCTION: void rl_callback_handler_install ( c-string arg1,
                                            rl_vcpfunc_t* arg2 )
FUNCTION: void rl_callback_read_char ( )
FUNCTION: void rl_callback_handler_remove ( )

FUNCTION: int rl_vi_redo ( int arg1, int arg2 )
FUNCTION: int rl_vi_undo ( int arg1, int arg2 )
FUNCTION: int rl_vi_yank_arg ( int arg1, int arg2 )
FUNCTION: int rl_vi_fetch_history ( int arg1, int arg2 )
FUNCTION: int rl_vi_search_again ( int arg1, int arg2 )
FUNCTION: int rl_vi_search ( int arg1, int arg2 )
FUNCTION: int rl_vi_complete ( int arg1, int arg2 )
FUNCTION: int rl_vi_tilde_expand ( int arg1, int arg2 )
FUNCTION: int rl_vi_prev_word ( int arg1, int arg2 )
FUNCTION: int rl_vi_next_word ( int arg1, int arg2 )
FUNCTION: int rl_vi_end_word ( int arg1, int arg2 )
FUNCTION: int rl_vi_insert_beg ( int arg1, int arg2 )
FUNCTION: int rl_vi_append_mode ( int arg1, int arg2 )
FUNCTION: int rl_vi_append_eol ( int arg1, int arg2 )
FUNCTION: int rl_vi_eof_maybe ( int arg1, int arg2 )
FUNCTION: int rl_vi_insertion_mode ( int arg1, int arg2 )
FUNCTION: int rl_vi_insert_mode ( int arg1, int arg2 )
FUNCTION: int rl_vi_movement_mode ( int arg1, int arg2 )
FUNCTION: int rl_vi_arg_digit ( int arg1, int arg2 )
FUNCTION: int rl_vi_change_case ( int arg1, int arg2 )
FUNCTION: int rl_vi_put ( int arg1, int arg2 )
FUNCTION: int rl_vi_column ( int arg1, int arg2 )
FUNCTION: int rl_vi_delete_to ( int arg1, int arg2 )
FUNCTION: int rl_vi_change_to ( int arg1, int arg2 )
FUNCTION: int rl_vi_yank_to ( int arg1, int arg2 )
FUNCTION: int rl_vi_rubout ( int arg1, int arg2 )
FUNCTION: int rl_vi_delete ( int arg1, int arg2 )
FUNCTION: int rl_vi_back_to_indent ( int arg1, int arg2 )
FUNCTION: int rl_vi_first_print ( int arg1, int arg2 )
FUNCTION: int rl_vi_char_search ( int arg1, int arg2 )
FUNCTION: int rl_vi_match ( int arg1, int arg2 )
FUNCTION: int rl_vi_change_char ( int arg1, int arg2 )
FUNCTION: int rl_vi_subst ( int arg1, int arg2 )
FUNCTION: int rl_vi_overstrike ( int arg1, int arg2 )
FUNCTION: int rl_vi_overstrike_delete ( int arg1, int arg2 )
FUNCTION: int rl_vi_replace ( int arg1, int arg2 )
FUNCTION: int rl_vi_set_mark ( int arg1, int arg2 )
FUNCTION: int rl_vi_goto_mark ( int arg1, int arg2 )

FUNCTION: int rl_vi_check ( )
FUNCTION: int rl_vi_domove ( int arg1, int* arg2 )
FUNCTION: int rl_vi_bracktype ( int i )

FUNCTION: void rl_vi_start_inserting ( int arg1, int arg2, int
                                      arg3 )

FUNCTION: int rl_vi_fWord ( int arg1, int arg2 )
FUNCTION: int rl_vi_bWord ( int arg1, int arg2 )
FUNCTION: int rl_vi_eWord ( int arg1, int arg2 )
FUNCTION: int rl_vi_fword ( int arg1, int arg2 )
FUNCTION: int rl_vi_bword ( int arg1, int arg2 )
FUNCTION: int rl_vi_eword ( int arg1, int arg2 )

FUNCTION: char* readline ( c-string s )

FUNCTION: int rl_set_prompt ( c-string s )
FUNCTION: int rl_expand_prompt ( c-string s )

FUNCTION: int rl_initialize ( )

FUNCTION: int rl_discard_argument ( )

FUNCTION: int rl_add_defun ( c-string arg1, rl_command_func_t*
                            arg2, int arg3 )
FUNCTION: int rl_bind_key ( int arg1, rl_command_func_t* arg2 )
FUNCTION: int rl_bind_key_in_map ( int arg1, rl_command_func_t*
                                  arg2, Keymap arg3 )
FUNCTION: int rl_unbind_key ( int i )
FUNCTION: int rl_unbind_key_in_map ( int arg1, Keymap arg2 )
FUNCTION: int rl_bind_key_if_unbound ( int arg1,
                                      rl_command_func_t* arg2 )
FUNCTION: int rl_bind_key_if_unbound_in_map ( int arg1,
                                             rl_command_func_t*
                                             arg2, Keymap arg3 )
FUNCTION: int rl_unbind_function_in_map ( rl_command_func_t*
                                         arg1, Keymap arg2 )
FUNCTION: int rl_unbind_command_in_map ( c-string arg1, Keymap
                                        arg2 )
FUNCTION: int rl_bind_keyseq ( c-string arg1, rl_command_func_t*
                              arg2 )
FUNCTION: int rl_bind_keyseq_in_map ( c-string arg1,
                                     rl_command_func_t* arg2, Keymap
                                     arg3 )
FUNCTION: int rl_bind_keyseq_if_unbound ( c-string arg1,
                                         rl_command_func_t* arg2 )
FUNCTION: int rl_bind_keyseq_if_unbound_in_map ( c-string arg1,
                                                rl_command_func_t*
                                                arg2, Keymap
                                                arg3 )
FUNCTION: int rl_generic_bind ( int arg1, c-string arg2,
                               c-string arg3, Keymap arg4 )

FUNCTION: c-string rl_variable_value ( c-string s )
FUNCTION: int rl_variable_bind ( c-string arg1, c-string arg2 )

FUNCTION: int rl_set_key ( c-string arg1, rl_command_func_t*
                          arg2, Keymap arg3 )
FUNCTION: int rl_macro_bind ( c-string arg1, c-string arg2,
                             Keymap arg3 )
FUNCTION: int rl_translate_keyseq ( c-string arg1, c-string
                                   arg2, int* arg3 )
FUNCTION: c-string rl_untranslate_keyseq ( int i )
FUNCTION: rl_command_func_t* rl_named_function ( c-string s )
FUNCTION: rl_command_func_t* rl_function_of_keyseq ( c-string arg1,
                                                    Keymap arg2,
                                                    int* arg3 )

FUNCTION: void rl_list_funmap_names ( )
FUNCTION: char** rl_invoking_keyseqs_in_map ( rl_command_func_t*
                                             arg1, Keymap arg2 )
FUNCTION: char** rl_invoking_keyseqs ( rl_command_func_t* f )

FUNCTION: void rl_function_dumper ( int i )
FUNCTION: void rl_macro_dumper ( int i )
FUNCTION: void rl_variable_dumper ( int i )

FUNCTION: int rl_read_init_file ( c-string s )
FUNCTION: int rl_parse_and_bind ( c-string s )

FUNCTION: Keymap rl_make_bare_keymap ( )

FUNCTION: Keymap rl_get_keymap_by_name ( c-string s )
FUNCTION: c-string rl_get_keymap_name ( Keymap k )
FUNCTION: void rl_set_keymap ( Keymap k )
FUNCTION: Keymap rl_get_keymap ( )
FUNCTION: void rl_set_keymap_from_edit_mode ( )
FUNCTION: c-string rl_get_keymap_name_from_edit_mode ( )

FUNCTION: int rl_add_funmap_entry ( c-string arg1,
                                   rl_command_func_t* arg2 )
FUNCTION: char** rl_funmap_names ( )
FUNCTION: void rl_initialize_funmap ( )

FUNCTION: void rl_push_macro_input ( c-string s )

FUNCTION: void rl_add_undo ( undo_code arg1, int arg2, int
                            arga3, c-string arg4 )
FUNCTION: void rl_free_undo_list ( )
FUNCTION: int rl_do_undo ( )
FUNCTION: int rl_begin_undo_group ( )
FUNCTION: int rl_end_undo_group ( )
FUNCTION: int rl_modifying ( int arg1, int arg2 )

FUNCTION: void rl_redisplay ( )
FUNCTION: int rl_on_new_line ( )
FUNCTION: int rl_on_new_line_with_prompt ( )
FUNCTION: int rl_forced_update_display ( )
FUNCTION: int rl_clear_message ( )
FUNCTION: int rl_reset_line_state ( )
FUNCTION: int rl_crlf ( )

! FUNCTION: int rl_message ( c-string arg1, ... )
FUNCTION: int rl_show_char ( int i )

FUNCTION: int rl_character_len ( int arg1, int arg2 )

FUNCTION: void rl_save_prompt ( )
FUNCTION: void rl_restore_prompt ( )

FUNCTION: void rl_replace_line ( c-string arg1, int arg2 )
FUNCTION: int rl_insert_text ( c-string arg1 )
FUNCTION: int rl_delete_text ( int arg1, int arg2 )
FUNCTION: int rl_kill_text ( int arg1, int arg2 )
FUNCTION: c-string rl_copy_text ( int arg1, int arg2 )

FUNCTION: void rl_prep_terminal ( int i )
FUNCTION: void rl_deprep_terminal ( )
FUNCTION: void rl_tty_set_default_bindings ( Keymap k )
FUNCTION: void rl_tty_unset_default_bindings ( Keymap k )

FUNCTION: int rl_reset_terminal ( c-string s )
FUNCTION: void rl_resize_terminal ( )
FUNCTION: void rl_set_screen_size ( int arg1, int arg2 )
FUNCTION: void rl_get_screen_size ( int* arg1, int* arg2 )
FUNCTION: void rl_reset_screen_size ( )

FUNCTION: c-string rl_get_termcap ( c-string s )

FUNCTION: int rl_stuff_char ( int i )
FUNCTION: int rl_execute_next ( int i )
FUNCTION: int rl_clear_pending_input ( )
FUNCTION: int rl_read_key ( )
FUNCTION: int rl_getc ( FILE* f )
FUNCTION: int rl_set_keyboard_input_timeout ( int i )

FUNCTION: void rl_extend_line_buffer ( int i )
FUNCTION: int rl_ding ( )
FUNCTION: int rl_alphabetic ( int i )
FUNCTION: void rl_free ( void* p )

FUNCTION: int rl_set_signals ( )
FUNCTION: int rl_clear_signals ( )
FUNCTION: void rl_cleanup_after_signal ( )
FUNCTION: void rl_reset_after_signal ( )
FUNCTION: void rl_free_line_state ( )

FUNCTION: void rl_echo_signal_char ( int i )

FUNCTION: int rl_set_paren_blink_timeout ( int i )

FUNCTION: int rl_maybe_save_line ( )
FUNCTION: int rl_maybe_unsave_line ( )
FUNCTION: int rl_maybe_replace_line ( )

FUNCTION: int rl_complete_internal ( int i )
FUNCTION: void rl_display_match_list ( char** arg1, int arg2,
                                      int arg3 )

FUNCTION: char** rl_completion_matches ( c-string arg1,
                                        rl_compentry_func_t*
                                        arg2 )
FUNCTION: c-string rl_username_completion_function ( c-string
                                                    arg1, int
                                                    arg2 )
FUNCTION: c-string rl_filename_completion_function ( c-string
                                                    arg1, int
                                                    arg2 )

FUNCTION: int rl_completion_mode ( rl_command_func_t* p )

C-GLOBAL: c-string rl_library_version
C-GLOBAL: int rl_readline_version
C-GLOBAL: int rl_gnu_readline_p
C-GLOBAL: int rl_readline_state
C-GLOBAL: int rl_editing_mode
C-GLOBAL: int rl_insert_mode
C-GLOBAL: c-string rl_readline_name
C-GLOBAL: c-string rl_prompt
C-GLOBAL: c-string rl_display_prompt
C-GLOBAL: c-string rl_line_buffer
C-GLOBAL: int rl_point
C-GLOBAL: int rl_end
C-GLOBAL: int rl_mark
C-GLOBAL: int rl_done
C-GLOBAL: int rl_pending_input
C-GLOBAL: int rl_dispatching
C-GLOBAL: int rl_explicit_arg
C-GLOBAL: int rl_numeric_arg
C-GLOBAL: rl_command_func_t* rl_last_func
C-GLOBAL: c-string rl_terminal_name

C-GLOBAL: FILE* rl_instream
C-GLOBAL: FILE* rl_outstream

C-GLOBAL: int rl_prefer_env_winsize

C-GLOBAL: rl_hook_func_t* rl_startup_hook
C-GLOBAL: rl_hook_func_t* rl_pre_input_hook
C-GLOBAL: rl_hook_func_t* rl_event_hook

C-GLOBAL: rl_getc_func_t* rl_getc_function
C-GLOBAL: rl_voidfunc_t* rl_redisplay_function
C-GLOBAL: rl_vintfunc_t* rl_prep_term_function
C-GLOBAL: rl_voidfunc_t* rl_deprep_term_function

C-GLOBAL: Keymap rl_executing_keymap
C-GLOBAL: Keymap rl_binding_keymap

C-GLOBAL: int rl_erase_empty_line
C-GLOBAL: int rl_already_prompted
C-GLOBAL: int rl_num_chars_to_read
C-GLOBAL: c-string rl_executing_macro

C-GLOBAL: int rl_catch_signals
C-GLOBAL: int rl_catch_sigwinch
C-GLOBAL: rl_compentry_func_t* rl_completion_entry_function
C-GLOBAL: rl_compentry_func_t* rl_menu_completion_entry_function
C-GLOBAL: rl_compignore_func_t* rl_ignore_some_completions_function
C-GLOBAL: rl_completion_func_t* rl_attempted_completion_function
C-GLOBAL: c-string rl_basic_word_break_characters
C-GLOBAL: c-string rl_completer_word_break_characters
C-GLOBAL: rl_cpvfunc_t* rl_completion_word_break_hook

C-GLOBAL: c-string rl_completer_quote_characters
C-GLOBAL: c-string rl_basic_quote_characters
C-GLOBAL: c-string rl_filename_quote_characters
C-GLOBAL: c-string rl_special_prefixes
C-GLOBAL: rl_icppfunc_t* rl_directory_completion_hook

C-GLOBAL: rl_icppfunc_t* rl_directory_rewrite_hook
C-GLOBAL: rl_dequote_func_t* rl_filename_rewrite_hook
C-GLOBAL: rl_compdisp_func_t* rl_completion_display_matches_hook
C-GLOBAL: int rl_filename_completion_desired
C-GLOBAL: int rl_filename_quoting_desired
C-GLOBAL: rl_quote_func_t* rl_filename_quoting_function
C-GLOBAL: rl_dequote_func_t* rl_filename_dequoting_function
C-GLOBAL: rl_linebuf_func_t* rl_char_is_quoted_p
C-GLOBAL: int rl_attempted_completion_over
C-GLOBAL: int rl_completion_type
C-GLOBAL: int rl_completion_invoking_key
C-GLOBAL: int rl_completion_query_items
C-GLOBAL: int rl_completion_append_character
C-GLOBAL: int rl_completion_suppress_append
C-GLOBAL: int rl_completion_quote_character
C-GLOBAL: int rl_completion_found_quote
C-GLOBAL: int rl_completion_suppress_quote
C-GLOBAL: int rl_sort_completion_matches
C-GLOBAL: int rl_completion_mark_symlink_dirs

C-GLOBAL: int rl_ignore_completion_duplicates
C-GLOBAL: int rl_inhibit_completion

CONSTANT: READERR -2

CONSTANT: RL_PROMPT_START_IGNORE 1
CONSTANT: RL_PROMPT_END_IGNORE   2

CONSTANT: NO_MATCH        0
CONSTANT: SINGLE_MATCH    1
CONSTANT: MULT_MATCH      2

CONSTANT: RL_STATE_NONE         0x0000000
CONSTANT: RL_STATE_INITIALIZING 0x0000001
CONSTANT: RL_STATE_INITIALIZED  0x0000002
CONSTANT: RL_STATE_TERMPREPPED  0x0000004
CONSTANT: RL_STATE_READCMD      0x0000008
CONSTANT: RL_STATE_METANEXT     0x0000010
CONSTANT: RL_STATE_DISPATCHING  0x0000020
CONSTANT: RL_STATE_MOREINPUT    0x0000040
CONSTANT: RL_STATE_ISEARCH      0x0000080
CONSTANT: RL_STATE_NSEARCH      0x0000100
CONSTANT: RL_STATE_SEARCH       0x0000200
CONSTANT: RL_STATE_NUMERICARG   0x0000400
CONSTANT: RL_STATE_MACROINPUT   0x0000800
CONSTANT: RL_STATE_MACRODEF     0x0001000
CONSTANT: RL_STATE_OVERWRITE    0x0002000
CONSTANT: RL_STATE_COMPLETING   0x0004000
CONSTANT: RL_STATE_SIGHANDLER   0x0008000
CONSTANT: RL_STATE_UNDOING      0x0010000
CONSTANT: RL_STATE_INPUTPENDING 0x0020000
CONSTANT: RL_STATE_TTYCSAVED    0x0040000
CONSTANT: RL_STATE_CALLBACK     0x0080000
CONSTANT: RL_STATE_VIMOTION     0x0100000
CONSTANT: RL_STATE_MULTIKEY     0x0200000
CONSTANT: RL_STATE_VICMDONCE    0x0400000
CONSTANT: RL_STATE_REDISPLAYING 0x0800000
CONSTANT: RL_STATE_DONE         0x1000000

: RL_SETSTATE   ( x -- ) rl_readline_state get bitor rl_readline_state set ; inline
: RL_UNSETSTATE ( x -- ) not rl_readline_state get bitand rl_readline_state set ; inline
: RL_ISSTATE    ( x -- ? ) rl_readline_state get bitand 0 = not ; inline

STRUCT: readline_state
    { point         int                }
    { end           int                }
    { mark          int                }
    { buffer        char*              }
    { buflen        int                }
    { ul            UNDO_LIST*         }
    { prompt        char*              }
    { rlstate       int                }
    { done          int                }
    { kmap          Keymap             }
    { lastfunc      rl_command_func_t* }
    { insmode       int                }
    { edmode        int                }
    { kseqlen       int                }
    { inf           FILE*              }
    { outf          FILE*              }
    { pendingin     int                }
    { macro         char*              }
    { catchsigs     int                }
    { catchsigwinch int                }
    { reserved      char[64]           } ;

FUNCTION: int rl_save_state ( readline_state* p )
FUNCTION: int rl_restore_state ( readline_state* p )
