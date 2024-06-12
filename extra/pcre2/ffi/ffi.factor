USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax combinators system ;

IN: pcre2.ffi

<< "pcre2" {
    { [ os windows? ] [ "pcre2-8.dll" ] }
    { [ os macosx? ] [ "libpcre2-8.dylib" ] }
    { [ os unix? ] [ "libpcre2-8.so" ] }
} cond cdecl add-library >>

LIBRARY: pcre2

CONSTANT: PCRE2_ANCHORED            0x80000000
CONSTANT: PCRE2_NO_UTF_CHECK        0x40000000
CONSTANT: PCRE2_ENDANCHORED         0x20000000

CONSTANT: PCRE2_ALLOW_EMPTY_CLASS   0x00000001
CONSTANT: PCRE2_ALT_BSUX            0x00000002
CONSTANT: PCRE2_AUTO_CALLOUT        0x00000004
CONSTANT: PCRE2_CASELESS            0x00000008
CONSTANT: PCRE2_DOLLAR_ENDONLY      0x00000010
CONSTANT: PCRE2_DOTALL              0x00000020
CONSTANT: PCRE2_DUPNAMES            0x00000040
CONSTANT: PCRE2_EXTENDED            0x00000080
CONSTANT: PCRE2_FIRSTLINE           0x00000100
CONSTANT: PCRE2_MATCH_UNSET_BACKREF 0x00000200
CONSTANT: PCRE2_MULTILINE           0x00000400
CONSTANT: PCRE2_NEVER_UCP           0x00000800
CONSTANT: PCRE2_NEVER_UTF           0x00001000
CONSTANT: PCRE2_NO_AUTO_CAPTURE     0x00002000
CONSTANT: PCRE2_NO_AUTO_POSSESS     0x00004000
CONSTANT: PCRE2_NO_DOTSTAR_ANCHOR   0x00008000
CONSTANT: PCRE2_NO_START_OPTIMIZE   0x00010000
CONSTANT: PCRE2_UCP                 0x00020000
CONSTANT: PCRE2_UNGREEDY            0x00040000
CONSTANT: PCRE2_UTF                 0x00080000
CONSTANT: PCRE2_NEVER_BACKSLASH_C   0x00100000
CONSTANT: PCRE2_ALT_CIRCUMFLEX      0x00200000
CONSTANT: PCRE2_ALT_VERBNAMES       0x00400000
CONSTANT: PCRE2_USE_OFFSET_LIMIT    0x00800000
CONSTANT: PCRE2_EXTENDED_MORE       0x01000000
CONSTANT: PCRE2_LITERAL             0x02000000
CONSTANT: PCRE2_MATCH_INVALID_UTF   0x04000000


CONSTANT: PCRE2_EXTRA_ALLOW_SURROGATE_ESCAPES  0x00000001
CONSTANT: PCRE2_EXTRA_BAD_ESCAPE_IS_LITERAL    0x00000002
CONSTANT: PCRE2_EXTRA_MATCH_WORD               0x00000004
CONSTANT: PCRE2_EXTRA_MATCH_LINE               0x00000008
CONSTANT: PCRE2_EXTRA_ESCAPED_CR_IS_LF         0x00000010
CONSTANT: PCRE2_EXTRA_ALT_BSUX                 0x00000020
CONSTANT: PCRE2_EXTRA_ALLOW_LOOKAROUND_BSK     0x00000040

CONSTANT: PCRE2_JIT_COMPLETE        0x00000001
CONSTANT: PCRE2_JIT_PARTIAL_SOFT    0x00000002
CONSTANT: PCRE2_JIT_PARTIAL_HARD    0x00000004
CONSTANT: PCRE2_JIT_INVALID_UTF     0x00000100

CONSTANT: PCRE2_NOTBOL                      0x00000001
CONSTANT: PCRE2_NOTEOL                      0x00000002
CONSTANT: PCRE2_NOTEMPTY                    0x00000004
CONSTANT: PCRE2_NOTEMPTY_ATSTART            0x00000008
CONSTANT: PCRE2_PARTIAL_SOFT                0x00000010
CONSTANT: PCRE2_PARTIAL_HARD                0x00000020
CONSTANT: PCRE2_DFA_RESTART                 0x00000040
CONSTANT: PCRE2_DFA_SHORTEST                0x00000080
CONSTANT: PCRE2_SUBSTITUTE_GLOBAL           0x00000100
CONSTANT: PCRE2_SUBSTITUTE_EXTENDED         0x00000200
CONSTANT: PCRE2_SUBSTITUTE_UNSET_EMPTY      0x00000400
CONSTANT: PCRE2_SUBSTITUTE_UNKNOWN_UNSET    0x00000800
CONSTANT: PCRE2_SUBSTITUTE_OVERFLOW_LENGTH  0x00001000
CONSTANT: PCRE2_NO_JIT                      0x00002000
CONSTANT: PCRE2_COPY_MATCHED_SUBJECT        0x00004000
CONSTANT: PCRE2_SUBSTITUTE_LITERAL          0x00008000
CONSTANT: PCRE2_SUBSTITUTE_MATCHED          0x00010000
CONSTANT: PCRE2_SUBSTITUTE_REPLACEMENT_ONLY 0x00020000

CONSTANT: PCRE2_CONVERT_UTF                    0x00000001
CONSTANT: PCRE2_CONVERT_NO_UTF_CHECK           0x00000002
CONSTANT: PCRE2_CONVERT_POSIX_BASIC            0x00000004
CONSTANT: PCRE2_CONVERT_POSIX_EXTENDED         0x00000008
CONSTANT: PCRE2_CONVERT_GLOB                   0x00000010
CONSTANT: PCRE2_CONVERT_GLOB_NO_WILD_SEPARATOR 0x00000030
CONSTANT: PCRE2_CONVERT_GLOB_NO_STARSTAR       0x00000050

CONSTANT: PCRE2_NEWLINE_CR          1
CONSTANT: PCRE2_NEWLINE_LF          2
CONSTANT: PCRE2_NEWLINE_CRLF        3
CONSTANT: PCRE2_NEWLINE_ANY         4
CONSTANT: PCRE2_NEWLINE_ANYCRLF     5
CONSTANT: PCRE2_NEWLINE_NUL         6

CONSTANT: PCRE2_BSR_UNICODE         1
CONSTANT: PCRE2_BSR_ANYCRLF         2

CONSTANT: PCRE2_ERROR_END_BACKSLASH                  101
CONSTANT: PCRE2_ERROR_END_BACKSLASH_C                102
CONSTANT: PCRE2_ERROR_UNKNOWN_ESCAPE                 103
CONSTANT: PCRE2_ERROR_QUANTIFIER_OUT_OF_ORDER        104
CONSTANT: PCRE2_ERROR_QUANTIFIER_TOO_BIG             105
CONSTANT: PCRE2_ERROR_MISSING_SQUARE_BRACKET         106
CONSTANT: PCRE2_ERROR_ESCAPE_INVALID_IN_CLASS        107
CONSTANT: PCRE2_ERROR_CLASS_RANGE_ORDER              108
CONSTANT: PCRE2_ERROR_QUANTIFIER_INVALID             109
CONSTANT: PCRE2_ERROR_INTERNAL_UNEXPECTED_REPEAT     110
CONSTANT: PCRE2_ERROR_INVALID_AFTER_PARENS_QUERY     111
CONSTANT: PCRE2_ERROR_POSIX_CLASS_NOT_IN_CLASS       112
CONSTANT: PCRE2_ERROR_POSIX_NO_SUPPORT_COLLATING     113
CONSTANT: PCRE2_ERROR_MISSING_CLOSING_PARENTHESIS    114
CONSTANT: PCRE2_ERROR_BAD_SUBPATTERN_REFERENCE       115
CONSTANT: PCRE2_ERROR_NULL_PATTERN                   116
CONSTANT: PCRE2_ERROR_BAD_OPTIONS                    117
CONSTANT: PCRE2_ERROR_MISSING_COMMENT_CLOSING        118
CONSTANT: PCRE2_ERROR_PARENTHESES_NEST_TOO_DEEP      119
CONSTANT: PCRE2_ERROR_PATTERN_TOO_LARGE              120
CONSTANT: PCRE2_ERROR_HEAP_FAILED                    121
CONSTANT: PCRE2_ERROR_UNMATCHED_CLOSING_PARENTHESIS  122
CONSTANT: PCRE2_ERROR_INTERNAL_CODE_OVERFLOW         123
CONSTANT: PCRE2_ERROR_MISSING_CONDITION_CLOSING      124
CONSTANT: PCRE2_ERROR_LOOKBEHIND_NOT_FIXED_LENGTH    125
CONSTANT: PCRE2_ERROR_ZERO_RELATIVE_REFERENCE        126
CONSTANT: PCRE2_ERROR_TOO_MANY_CONDITION_BRANCHES    127
CONSTANT: PCRE2_ERROR_CONDITION_ASSERTION_EXPECTED   128
CONSTANT: PCRE2_ERROR_BAD_RELATIVE_REFERENCE         129
CONSTANT: PCRE2_ERROR_UNKNOWN_POSIX_CLASS            130
CONSTANT: PCRE2_ERROR_INTERNAL_STUDY_ERROR           131
CONSTANT: PCRE2_ERROR_UNICODE_NOT_SUPPORTED          132
CONSTANT: PCRE2_ERROR_PARENTHESES_STACK_CHECK        133
CONSTANT: PCRE2_ERROR_CODE_POINT_TOO_BIG             134
CONSTANT: PCRE2_ERROR_LOOKBEHIND_TOO_COMPLICATED     135
CONSTANT: PCRE2_ERROR_LOOKBEHIND_INVALID_BACKSLASH_C 136
CONSTANT: PCRE2_ERROR_UNSUPPORTED_ESCAPE_SEQUENCE    137
CONSTANT: PCRE2_ERROR_CALLOUT_NUMBER_TOO_BIG         138
CONSTANT: PCRE2_ERROR_MISSING_CALLOUT_CLOSING        139
CONSTANT: PCRE2_ERROR_ESCAPE_INVALID_IN_VERB         140
CONSTANT: PCRE2_ERROR_UNRECOGNIZED_AFTER_QUERY_P     141
CONSTANT: PCRE2_ERROR_MISSING_NAME_TERMINATOR        142
CONSTANT: PCRE2_ERROR_DUPLICATE_SUBPATTERN_NAME      143
CONSTANT: PCRE2_ERROR_INVALID_SUBPATTERN_NAME        144
CONSTANT: PCRE2_ERROR_UNICODE_PROPERTIES_UNAVAILABLE 145
CONSTANT: PCRE2_ERROR_MALFORMED_UNICODE_PROPERTY     146
CONSTANT: PCRE2_ERROR_UNKNOWN_UNICODE_PROPERTY       147
CONSTANT: PCRE2_ERROR_SUBPATTERN_NAME_TOO_LONG       148
CONSTANT: PCRE2_ERROR_TOO_MANY_NAMED_SUBPATTERNS     149
CONSTANT: PCRE2_ERROR_CLASS_INVALID_RANGE            150
CONSTANT: PCRE2_ERROR_OCTAL_BYTE_TOO_BIG             151
CONSTANT: PCRE2_ERROR_INTERNAL_OVERRAN_WORKSPACE     152
CONSTANT: PCRE2_ERROR_INTERNAL_MISSING_SUBPATTERN    153
CONSTANT: PCRE2_ERROR_DEFINE_TOO_MANY_BRANCHES       154
CONSTANT: PCRE2_ERROR_BACKSLASH_O_MISSING_BRACE      155
CONSTANT: PCRE2_ERROR_INTERNAL_UNKNOWN_NEWLINE       156
CONSTANT: PCRE2_ERROR_BACKSLASH_G_SYNTAX             157
CONSTANT: PCRE2_ERROR_PARENS_QUERY_R_MISSING_CLOSING 158
CONSTANT: PCRE2_ERROR_VERB_ARGUMENT_NOT_ALLOWED      159
CONSTANT: PCRE2_ERROR_VERB_UNKNOWN                   160
CONSTANT: PCRE2_ERROR_SUBPATTERN_NUMBER_TOO_BIG      161
CONSTANT: PCRE2_ERROR_SUBPATTERN_NAME_EXPECTED       162
CONSTANT: PCRE2_ERROR_INTERNAL_PARSED_OVERFLOW       163
CONSTANT: PCRE2_ERROR_INVALID_OCTAL                  164
CONSTANT: PCRE2_ERROR_SUBPATTERN_NAMES_MISMATCH      165
CONSTANT: PCRE2_ERROR_MARK_MISSING_ARGUMENT          166
CONSTANT: PCRE2_ERROR_INVALID_HEXADECIMAL            167
CONSTANT: PCRE2_ERROR_BACKSLASH_C_SYNTAX             168
CONSTANT: PCRE2_ERROR_BACKSLASH_K_SYNTAX             169
CONSTANT: PCRE2_ERROR_INTERNAL_BAD_CODE_LOOKBEHINDS  170
CONSTANT: PCRE2_ERROR_BACKSLASH_N_IN_CLASS           171
CONSTANT: PCRE2_ERROR_CALLOUT_STRING_TOO_LONG        172
CONSTANT: PCRE2_ERROR_UNICODE_DISALLOWED_CODE_POINT  173
CONSTANT: PCRE2_ERROR_UTF_IS_DISABLED                174
CONSTANT: PCRE2_ERROR_UCP_IS_DISABLED                175
CONSTANT: PCRE2_ERROR_VERB_NAME_TOO_LONG             176
CONSTANT: PCRE2_ERROR_BACKSLASH_U_CODE_POINT_TOO_BIG 177
CONSTANT: PCRE2_ERROR_MISSING_OCTAL_OR_HEX_DIGITS    178
CONSTANT: PCRE2_ERROR_VERSION_CONDITION_SYNTAX       179
CONSTANT: PCRE2_ERROR_INTERNAL_BAD_CODE_AUTO_POSSESS 180
CONSTANT: PCRE2_ERROR_CALLOUT_NO_STRING_DELIMITER    181
CONSTANT: PCRE2_ERROR_CALLOUT_BAD_STRING_DELIMITER   182
CONSTANT: PCRE2_ERROR_BACKSLASH_C_CALLER_DISABLED    183
CONSTANT: PCRE2_ERROR_QUERY_BARJX_NEST_TOO_DEEP      184
CONSTANT: PCRE2_ERROR_BACKSLASH_C_LIBRARY_DISABLED   185
CONSTANT: PCRE2_ERROR_PATTERN_TOO_COMPLICATED        186
CONSTANT: PCRE2_ERROR_LOOKBEHIND_TOO_LONG            187
CONSTANT: PCRE2_ERROR_PATTERN_STRING_TOO_LONG        188
CONSTANT: PCRE2_ERROR_INTERNAL_BAD_CODE              189
CONSTANT: PCRE2_ERROR_INTERNAL_BAD_CODE_IN_SKIP      190
CONSTANT: PCRE2_ERROR_NO_SURROGATES_IN_UTF16         191
CONSTANT: PCRE2_ERROR_BAD_LITERAL_OPTIONS            192
CONSTANT: PCRE2_ERROR_SUPPORTED_ONLY_IN_UNICODE      193
CONSTANT: PCRE2_ERROR_INVALID_HYPHEN_IN_OPTIONS      194
CONSTANT: PCRE2_ERROR_ALPHA_ASSERTION_UNKNOWN        195
CONSTANT: PCRE2_ERROR_SCRIPT_RUN_NOT_AVAILABLE       196
CONSTANT: PCRE2_ERROR_TOO_MANY_CAPTURES              197
CONSTANT: PCRE2_ERROR_CONDITION_ATOMIC_ASSERTION_EXPECTED  198
CONSTANT: PCRE2_ERROR_BACKSLASH_K_IN_LOOKAROUND      199

CONSTANT: PCRE2_ERROR_NOMATCH            -1
CONSTANT: PCRE2_ERROR_PARTIAL            -2
CONSTANT: PCRE2_ERROR_UTF8_ERR1          -3
CONSTANT: PCRE2_ERROR_UTF8_ERR2          -4
CONSTANT: PCRE2_ERROR_UTF8_ERR3          -5
CONSTANT: PCRE2_ERROR_UTF8_ERR4          -6
CONSTANT: PCRE2_ERROR_UTF8_ERR5          -7
CONSTANT: PCRE2_ERROR_UTF8_ERR6          -8
CONSTANT: PCRE2_ERROR_UTF8_ERR7          -9
CONSTANT: PCRE2_ERROR_UTF8_ERR8         -10
CONSTANT: PCRE2_ERROR_UTF8_ERR9         -11
CONSTANT: PCRE2_ERROR_UTF8_ERR10        -12
CONSTANT: PCRE2_ERROR_UTF8_ERR11        -13
CONSTANT: PCRE2_ERROR_UTF8_ERR12        -14
CONSTANT: PCRE2_ERROR_UTF8_ERR13        -15
CONSTANT: PCRE2_ERROR_UTF8_ERR14        -16
CONSTANT: PCRE2_ERROR_UTF8_ERR15        -17
CONSTANT: PCRE2_ERROR_UTF8_ERR16        -18
CONSTANT: PCRE2_ERROR_UTF8_ERR17        -19
CONSTANT: PCRE2_ERROR_UTF8_ERR18        -20
CONSTANT: PCRE2_ERROR_UTF8_ERR19        -21
CONSTANT: PCRE2_ERROR_UTF8_ERR20        -22
CONSTANT: PCRE2_ERROR_UTF8_ERR21        -23
CONSTANT: PCRE2_ERROR_UTF16_ERR1        -24
CONSTANT: PCRE2_ERROR_UTF16_ERR2        -25
CONSTANT: PCRE2_ERROR_UTF16_ERR3        -26
CONSTANT: PCRE2_ERROR_UTF32_ERR1        -27
CONSTANT: PCRE2_ERROR_UTF32_ERR2        -28
CONSTANT: PCRE2_ERROR_BADDATA           -29
CONSTANT: PCRE2_ERROR_MIXEDTABLES       -30
CONSTANT: PCRE2_ERROR_BADMAGIC          -31
CONSTANT: PCRE2_ERROR_BADMODE           -32
CONSTANT: PCRE2_ERROR_BADOFFSET         -33
CONSTANT: PCRE2_ERROR_BADOPTION         -34
CONSTANT: PCRE2_ERROR_BADREPLACEMENT    -35
CONSTANT: PCRE2_ERROR_BADUTFOFFSET      -36
CONSTANT: PCRE2_ERROR_CALLOUT           -37
CONSTANT: PCRE2_ERROR_DFA_BADRESTART    -38
CONSTANT: PCRE2_ERROR_DFA_RECURSE       -39
CONSTANT: PCRE2_ERROR_DFA_UCOND         -40
CONSTANT: PCRE2_ERROR_DFA_UFUNC         -41
CONSTANT: PCRE2_ERROR_DFA_UITEM         -42
CONSTANT: PCRE2_ERROR_DFA_WSSIZE        -43
CONSTANT: PCRE2_ERROR_INTERNAL          -44
CONSTANT: PCRE2_ERROR_JIT_BADOPTION     -45
CONSTANT: PCRE2_ERROR_JIT_STACKLIMIT    -46
CONSTANT: PCRE2_ERROR_MATCHLIMIT        -47
CONSTANT: PCRE2_ERROR_NOMEMORY          -48
CONSTANT: PCRE2_ERROR_NOSUBSTRING       -49
CONSTANT: PCRE2_ERROR_NOUNIQUESUBSTRING -50
CONSTANT: PCRE2_ERROR_NULL              -51
CONSTANT: PCRE2_ERROR_RECURSELOOP       -52
CONSTANT: PCRE2_ERROR_DEPTHLIMIT        -53
CONSTANT: PCRE2_ERROR_RECURSIONLIMIT    -53
CONSTANT: PCRE2_ERROR_UNAVAILABLE       -54
CONSTANT: PCRE2_ERROR_UNSET             -55
CONSTANT: PCRE2_ERROR_BADOFFSETLIMIT    -56
CONSTANT: PCRE2_ERROR_BADREPESCAPE      -57
CONSTANT: PCRE2_ERROR_REPMISSINGBRACE   -58
CONSTANT: PCRE2_ERROR_BADSUBSTITUTION   -59
CONSTANT: PCRE2_ERROR_BADSUBSPATTERN    -60
CONSTANT: PCRE2_ERROR_TOOMANYREPLACE    -61
CONSTANT: PCRE2_ERROR_BADSERIALIZEDDATA -62
CONSTANT: PCRE2_ERROR_HEAPLIMIT         -63
CONSTANT: PCRE2_ERROR_CONVERT_SYNTAX    -64
CONSTANT: PCRE2_ERROR_INTERNAL_DUPMATCH -65
CONSTANT: PCRE2_ERROR_DFA_UINVALID_UTF  -66

CONSTANT: PCRE2_INFO_ALLOPTIONS            0
CONSTANT: PCRE2_INFO_ARGOPTIONS            1
CONSTANT: PCRE2_INFO_BACKREFMAX            2
CONSTANT: PCRE2_INFO_BSR                   3
CONSTANT: PCRE2_INFO_CAPTURECOUNT          4
CONSTANT: PCRE2_INFO_FIRSTCODEUNIT         5
CONSTANT: PCRE2_INFO_FIRSTCODETYPE         6
CONSTANT: PCRE2_INFO_FIRSTBITMAP           7
CONSTANT: PCRE2_INFO_HASCRORLF             8
CONSTANT: PCRE2_INFO_JCHANGED              9
CONSTANT: PCRE2_INFO_JITSIZE              10
CONSTANT: PCRE2_INFO_LASTCODEUNIT         11
CONSTANT: PCRE2_INFO_LASTCODETYPE         12
CONSTANT: PCRE2_INFO_MATCHEMPTY           13
CONSTANT: PCRE2_INFO_MATCHLIMIT           14
CONSTANT: PCRE2_INFO_MAXLOOKBEHIND        15
CONSTANT: PCRE2_INFO_MINLENGTH            16
CONSTANT: PCRE2_INFO_NAMECOUNT            17
CONSTANT: PCRE2_INFO_NAMEENTRYSIZE        18
CONSTANT: PCRE2_INFO_NAMETABLE            19
CONSTANT: PCRE2_INFO_NEWLINE              20
CONSTANT: PCRE2_INFO_DEPTHLIMIT           21
CONSTANT: PCRE2_INFO_RECURSIONLIMIT       21
CONSTANT: PCRE2_INFO_SIZE                 22
CONSTANT: PCRE2_INFO_HASBACKSLASHC        23
CONSTANT: PCRE2_INFO_FRAMESIZE            24
CONSTANT: PCRE2_INFO_HEAPLIMIT            25
CONSTANT: PCRE2_INFO_EXTRAOPTIONS         26

CONSTANT: PCRE2_CONFIG_BSR                     0
CONSTANT: PCRE2_CONFIG_JIT                     1
CONSTANT: PCRE2_CONFIG_JITTARGET               2
CONSTANT: PCRE2_CONFIG_LINKSIZE                3
CONSTANT: PCRE2_CONFIG_MATCHLIMIT              4
CONSTANT: PCRE2_CONFIG_NEWLINE                 5
CONSTANT: PCRE2_CONFIG_PARENSLIMIT             6
CONSTANT: PCRE2_CONFIG_DEPTHLIMIT              7
CONSTANT: PCRE2_CONFIG_RECURSIONLIMIT          7
CONSTANT: PCRE2_CONFIG_STACKRECURSE            8
CONSTANT: PCRE2_CONFIG_UNICODE                 9
CONSTANT: PCRE2_CONFIG_UNICODE_VERSION        10
CONSTANT: PCRE2_CONFIG_VERSION                11
CONSTANT: PCRE2_CONFIG_HEAPLIMIT              12
CONSTANT: PCRE2_CONFIG_NEVER_BACKSLASH_C      13
CONSTANT: PCRE2_CONFIG_COMPILED_WIDTHS        14
CONSTANT: PCRE2_CONFIG_TABLES_LENGTH          15

TYPEDEF: uint8_t PCRE2_UCHAR8
TYPEDEF: uint16_t PCRE2_UCHAR16
TYPEDEF: uint32_t PCRE2_UCHAR32

TYPEDEF: PCRE2_UCHAR8* PCRE2_SPTR8
TYPEDEF: PCRE2_UCHAR16* PCRE2_SPTR16
TYPEDEF: PCRE2_UCHAR32* PCRE2_SPTR32

TYPEDEF: PCRE2_UCHAR8 PCRE2_UCHAR
TYPEDEF: PCRE2_SPTR8 PCRE2_SPTR

TYPEDEF: size_t PCRE2_SIZE

TYPEDEF: void pcre2_general_context
TYPEDEF: void pcre2_compile_context
TYPEDEF: void pcre2_match_context
TYPEDEF: void pcre2_convert_context
TYPEDEF: void pcre2_code
TYPEDEF: void pcre2_match_data
TYPEDEF: void pcre2_jit_stack


FUNCTION-ALIAS: pcre2_compile
    pcre2_code* pcre2_compile_8 ( PCRE2_SPTR pattern, PCRE2_SIZE length, uint32_t options, int* errorcode, PCRE2_SIZE* erroroffset, pcre2_compile_context* ccontext )

FUNCTION-ALIAS: pcre2_code_free
    void pcre2_code_free_8 ( pcre2_code* code )

DESTRUCTOR: pcre2_code_free

FUNCTION-ALIAS: pcre2_match_data_create
    pcre2_match_data* pcre2_match_data_create_8 ( uint32_t ovecsize, pcre2_general_context* gcontext )

FUNCTION-ALIAS: pcre2_match_data_create_from_pattern
    pcre2_match_data* pcre2_match_data_create_from_pattern_8 ( pcre2_code* code, pcre2_general_context* gcontext )

FUNCTION-ALIAS: pcre2_match
    int pcre2_match_8 ( pcre2_code* code, PCRE2_SPTR subject, PCRE2_SIZE length, PCRE2_SIZE startoffset, uint32_t options, pcre2_match_data* match_data, pcre2_match_context* mcontext )

FUNCTION-ALIAS: pcre2_dfa_match
    int pcre2_dfa_match_8 ( pcre2_code* code, PCRE2_SPTR subject, PCRE2_SIZE length, PCRE2_SIZE startoffset, uint32_t options, pcre2_match_data* match_data, pcre2_match_context* mcontext, int* workspace, PCRE2_SIZE wscount )

FUNCTION-ALIAS: pcre2_match_data_free
    void pcre2_match_data_free_8 ( pcre2_match_data* match_data )

DESTRUCTOR: pcre2_match_data_free

FUNCTION-ALIAS: pcre2_get_mark
    PCRE2_SPTR pcre2_get_mark_8 ( pcre2_match_data* match_data )

FUNCTION-ALIAS: pcre2_get_ovector_count
    uint32_t pcre2_get_ovector_count_8 ( pcre2_match_data* match_data )

FUNCTION-ALIAS: pcre2_get_ovector_pointer
    PCRE2_SIZE* pcre2_get_ovector_pointer_8 ( pcre2_match_data* match_data )

FUNCTION-ALIAS: pcre2_get_startchar
    PCRE2_SIZE pcre2_get_startchar_8 ( pcre2_match_data* match_data )

FUNCTION-ALIAS: pcre2_general_context_create
    pcre2_general_context* pcre2_general_context_create_8 ( void* private_malloc, void* private_free, void* memory_data )

FUNCTION-ALIAS: pcre2_general_context_copy
    pcre2_general_context* pcre2_general_context_copy_8 ( pcre2_general_context* gcontext )

FUNCTION-ALIAS: pcre2_general_context_free
    void pcre2_general_context_free_8 ( pcre2_general_context* gcontext )

DESTRUCTOR: pcre2_general_context_free

FUNCTION-ALIAS: pcre2_compile_context_create
    pcre2_compile_context* pcre2_compile_context_create_8 ( pcre2_general_context* gcontext )

FUNCTION-ALIAS: pcre2_compile_context_copy
    pcre2_compile_context* pcre2_compile_context_copy_8 ( pcre2_compile_context* ccontext )

FUNCTION-ALIAS: pcre2_compile_context_free
    void pcre2_compile_context_free_8 ( pcre2_compile_context* ccontext )

DESTRUCTOR: pcre2_compile_context_free

FUNCTION-ALIAS: pcre2_set_bsr
    int pcre2_set_bsr_8 ( pcre2_compile_context* ccontext, uint32_t value )

FUNCTION-ALIAS: pcre2_set_character_tables
    int pcre2_set_character_tables_8 ( pcre2_compile_context* ccontext, uint8_t* tables )

FUNCTION-ALIAS: pcre2_set_compile_extra_options
    int pcre2_set_compile_extra_options_8 ( pcre2_compile_context* ccontext, uint32_t extra_options )

FUNCTION-ALIAS: pcre2_set_max_pattern_length
    int pcre2_set_max_pattern_length_8 ( pcre2_compile_context* ccontext, PCRE2_SIZE value )

FUNCTION-ALIAS: pcre2_set_newline
    int pcre2_set_newline_8 ( pcre2_compile_context* ccontext, uint32_t value )

FUNCTION-ALIAS: pcre2_set_parens_nest_limit
    int pcre2_set_parens_nest_limit_8 ( pcre2_compile_context* ccontext, uint32_t value )

FUNCTION-ALIAS: pcre2_set_compile_recursion_guard
    int pcre2_set_compile_recursion_guard_8 ( pcre2_compile_context* ccontext, void* 1guard_function, void* user_data )

FUNCTION-ALIAS: pcre2_match_context_create
    pcre2_match_context* pcre2_match_context_create_8 ( pcre2_general_context* gcontext )

FUNCTION-ALIAS: pcre2_match_context_copy
    pcre2_match_context* pcre2_match_context_copy_8 ( pcre2_match_context* mcontext )

FUNCTION-ALIAS: pcre2_match_context_free
    void pcre2_match_context_free_8 ( pcre2_match_context* mcontext )

DESTRUCTOR: pcre2_match_context_free

FUNCTION-ALIAS: pcre2_set_callout
    int pcre2_set_callout_8 ( pcre2_match_context* mcontext, void* callout_function, void* callout_data )

FUNCTION-ALIAS: pcre2_set_substitute_callout
    int pcre2_set_substitute_callout_8 ( pcre2_match_context* mcontext, void* callout_function, void* callout_data )

FUNCTION-ALIAS: pcre2_set_offset_limit
    int pcre2_set_offset_limit_8 ( pcre2_match_context* mcontext, PCRE2_SIZE value )

FUNCTION-ALIAS: pcre2_set_heap_limit
    int pcre2_set_heap_limit_8 ( pcre2_match_context* mcontext, uint32_t value )

FUNCTION-ALIAS: pcre2_set_match_limit
    int pcre2_set_match_limit_8 ( pcre2_match_context* mcontext, uint32_t value )

FUNCTION-ALIAS: pcre2_set_depth_limit
    int pcre2_set_depth_limit_8 ( pcre2_match_context* mcontext, uint32_t value )

FUNCTION-ALIAS: pcre2_substring_copy_byname
    int pcre2_substring_copy_byname_8 ( pcre2_match_data* match_data, PCRE2_SPTR name, PCRE2_UCHAR* buffer, PCRE2_SIZE* bufflen )

FUNCTION-ALIAS: pcre2_substring_copy_bynumber
    int pcre2_substring_copy_bynumber_8 ( pcre2_match_data* match_data, uint32_t number, PCRE2_UCHAR* buffer, PCRE2_SIZE* bufflen )

FUNCTION-ALIAS: pcre2_substring_free
    void pcre2_substring_free_8 ( PCRE2_UCHAR* buffer )

DESTRUCTOR: pcre2_substring_free

FUNCTION-ALIAS: pcre2_substring_get_byname
    int pcre2_substring_get_byname_8 ( pcre2_match_data* match_data, PCRE2_SPTR name, PCRE2_UCHAR** bufferptr, PCRE2_SIZE* bufflen )

FUNCTION-ALIAS: pcre2_substring_get_bynumber
    int pcre2_substring_get_bynumber_8 ( pcre2_match_data* match_data, uint32_t number, PCRE2_UCHAR** bufferptr, PCRE2_SIZE* bufflen )

FUNCTION-ALIAS: pcre2_substring_length_byname
    int pcre2_substring_length_byname_8 ( pcre2_match_data* match_data, PCRE2_SPTR name, PCRE2_SIZE* length )

FUNCTION-ALIAS: pcre2_substring_length_bynumber
    int pcre2_substring_length_bynumber_8 ( pcre2_match_data* match_data, uint32_t number, PCRE2_SIZE* length )

FUNCTION-ALIAS: pcre2_substring_nametable_scan
    int pcre2_substring_nametable_scan_8 ( pcre2_code* code, PCRE2_SPTR name, PCRE2_SPTR* first, PCRE2_SPTR* last )

FUNCTION-ALIAS: pcre2_substring_number_from_name
    int pcre2_substring_number_from_name_8 ( pcre2_code* code, PCRE2_SPTR name )

FUNCTION-ALIAS: pcre2_substring_list_free
    void pcre2_substring_list_free_8 ( PCRE2_SPTR* list )

DESTRUCTOR: pcre2_substring_list_free

FUNCTION-ALIAS: pcre2_substring_list_get
    int pcre2_substring_list_get_8 ( pcre2_match_data* match_data, PCRE2_UCHAR*** listptr, PCRE2_SIZE** lengthsptr )

FUNCTION-ALIAS: pcre2_substitute
    int pcre2_substitute_8 ( pcre2_code* code, PCRE2_SPTR subject, PCRE2_SIZE length, PCRE2_SIZE startoffset, uint32_t options, pcre2_match_data* match_data, pcre2_match_context* mcontext, PCRE2_SPTR replacementz, PCRE2_SIZE rlength, PCRE2_UCHAR* outputbuffer, PCRE2_SIZE* outlengthptr )

FUNCTION-ALIAS: pcre2_jit_compile
    int pcre2_jit_compile_8 ( pcre2_code* code, uint32_t options )

FUNCTION-ALIAS: pcre2_jit_match
    int pcre2_jit_match_8 ( pcre2_code* code, PCRE2_SPTR subject, PCRE2_SIZE length, PCRE2_SIZE startoffset, uint32_t options, pcre2_match_data* match_data, pcre2_match_context* mcontext )

FUNCTION-ALIAS: pcre2_jit_free_unused_memory
    void pcre2_jit_free_unused_memory_8 ( pcre2_general_context* gcontext )

FUNCTION-ALIAS: pcre2_jit_stack_create
    pcre2_jit_stack* pcre2_jit_stack_create_8 ( PCRE2_SIZE startsize, PCRE2_SIZE maxsize, pcre2_general_context* gcontext )

FUNCTION-ALIAS: pcre2_jit_stack_assign
    void pcre2_jit_stack_assign_8 ( pcre2_match_context* mcontext, void* callback_function, void* callback_data )

FUNCTION-ALIAS: pcre2_jit_stack_free
    void pcre2_jit_stack_free_8 ( pcre2_jit_stack* jit_stack )

DESTRUCTOR: pcre2_jit_stack_free

FUNCTION-ALIAS: pcre2_serialize_decode
    int32_t pcre2_serialize_decode_8 ( pcre2_code** codes, int32_t number_of_codes, uint8_t* bytes, pcre2_general_context* gcontext )

FUNCTION-ALIAS: pcre2_serialize_encode
    int32_t pcre2_serialize_encode_8 ( pcre2_code** codes, int32_t number_of_codes, uint8_t** serialized_bytes, PCRE2_SIZE* serialized_size, pcre2_general_context* gcontext )

FUNCTION-ALIAS: pcre2_serialize_free
    void pcre2_serialize_free_8 ( uint8_t* bytes )

FUNCTION-ALIAS: pcre2_serialize_get_number_of_codes
    int32_t pcre2_serialize_get_number_of_codes_8 ( uint8_t* bytes )

FUNCTION-ALIAS: pcre2_code_copy
    pcre2_code* pcre2_code_copy_8 ( pcre2_code* code )

FUNCTION-ALIAS: pcre2_code_copy_with_tables
    pcre2_code* pcre2_code_copy_with_tables_8 ( pcre2_code* code )

FUNCTION-ALIAS: pcre2_get_error_message
    int pcre2_get_error_message_8 ( int errorcode, PCRE2_UCHAR* buffer, PCRE2_SIZE bufflen )

FUNCTION-ALIAS: pcre2_maketables
    uint8_t* pcre2_maketables_8 ( pcre2_general_context* gcontext )

FUNCTION-ALIAS: pcre2_maketables_free
    void pcre2_maketables_free_8 ( pcre2_general_context* gcontext, uint8_t* tables )

FUNCTION-ALIAS: pcre2_pattern_info
    int pcre2_pattern_info_8 ( pcre2_code* code, uint32_t what, void* where )

FUNCTION-ALIAS: pcre2_callout_enumerate
    int pcre2_callout_enumerate_8 ( pcre2_code* code, void* callback, void* user_data )

FUNCTION-ALIAS: pcre2_config
    int pcre2_config_8 ( uint32_t what, void* where )
