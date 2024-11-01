USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators system ;
IN: pcre.ffi

C-LIBRARY: pcre cdecl {
    { windows "pcre.dll" }
    { macos "libpcre.dylib" }
    { unix "libpcre.so" }
}

LIBRARY: pcre

CONSTANT: PCRE_CASELESS           0x00000001
CONSTANT: PCRE_MULTILINE          0x00000002
CONSTANT: PCRE_DOTALL             0x00000004
CONSTANT: PCRE_EXTENDED           0x00000008
CONSTANT: PCRE_ANCHORED           0x00000010
CONSTANT: PCRE_DOLLAR_ENDONLY     0x00000020
CONSTANT: PCRE_EXTRA              0x00000040
CONSTANT: PCRE_NOTBOL             0x00000080
CONSTANT: PCRE_NOTEOL             0x00000100
CONSTANT: PCRE_UNGREEDY           0x00000200
CONSTANT: PCRE_NOTEMPTY           0x00000400
CONSTANT: PCRE_UTF8               0x00000800
CONSTANT: PCRE_NO_AUTO_CAPTURE    0x00001000
CONSTANT: PCRE_NO_UTF8_CHECK      0x00002000
CONSTANT: PCRE_AUTO_CALLOUT       0x00004000
CONSTANT: PCRE_PARTIAL_SOFT       0x00008000
CONSTANT: PCRE_PARTIAL            0x00008000
CONSTANT: PCRE_DFA_SHORTEST       0x00010000
CONSTANT: PCRE_DFA_RESTART        0x00020000
CONSTANT: PCRE_FIRSTLINE          0x00040000
CONSTANT: PCRE_DUPNAMES           0x00080000
CONSTANT: PCRE_NEWLINE_CR         0x00100000
CONSTANT: PCRE_NEWLINE_LF         0x00200000
CONSTANT: PCRE_NEWLINE_CRLF       0x00300000
CONSTANT: PCRE_NEWLINE_ANY        0x00400000
CONSTANT: PCRE_NEWLINE_ANYCRLF    0x00500000
CONSTANT: PCRE_BSR_ANYCRLF        0x00800000
CONSTANT: PCRE_BSR_UNICODE        0x01000000
CONSTANT: PCRE_JAVASCRIPT_COMPAT  0x02000000
CONSTANT: PCRE_NO_START_OPTIMIZE  0x04000000
CONSTANT: PCRE_NO_START_OPTIMISE  0x04000000
CONSTANT: PCRE_PARTIAL_HARD       0x08000000
CONSTANT: PCRE_NOTEMPTY_ATSTART   0x10000000
! New in 8.10
CONSTANT: PCRE_UCP                0x20000000

ENUM: PCRE_ERRORS
    { PCRE_ERROR_NOMATCH         -1 }
    { PCRE_ERROR_NULL            -2 }
    { PCRE_ERROR_BADOPTION       -3 }
    { PCRE_ERROR_BADMAGIC        -4 }
    { PCRE_ERROR_UNKNOWN_OPCODE  -5 }
    { PCRE_ERROR_UNKNOWN_NODE    -5 }
    { PCRE_ERROR_NOMEMORY        -6 }
    { PCRE_ERROR_NOSUBSTRING     -7 }
    { PCRE_ERROR_MATCHLIMIT      -8 }
    { PCRE_ERROR_CALLOUT         -9 }
    { PCRE_ERROR_BADUTF8        -10 }
    { PCRE_ERROR_BADUTF8_OFFSET -11 }
    { PCRE_ERROR_PARTIAL        -12 }
    { PCRE_ERROR_BADPARTIAL     -13 }
    { PCRE_ERROR_INTERNAL       -14 }
    { PCRE_ERROR_BADCOUNT       -15 }
    { PCRE_ERROR_DFA_UITEM      -16 }
    { PCRE_ERROR_DFA_UCOND      -17 }
    { PCRE_ERROR_DFA_UMLIMIT    -18 }
    { PCRE_ERROR_DFA_WSSIZE     -19 }
    { PCRE_ERROR_DFA_RECURSE    -20 }
    { PCRE_ERROR_RECURSIONLIMIT -21 }
    { PCRE_ERROR_NULLWSLIMIT    -22 }
    { PCRE_ERROR_BADNEWLINE     -23 }
    { PCRE_ERROR_BADOFFSET      -24 }
    { PCRE_ERROR_SHORTUTF8      -25 } ;

CONSTANT: PCRE_INFO_OPTIONS            0
CONSTANT: PCRE_INFO_SIZE               1
CONSTANT: PCRE_INFO_CAPTURECOUNT       2
CONSTANT: PCRE_INFO_BACKREFMAX         3
CONSTANT: PCRE_INFO_FIRSTBYTE          4
CONSTANT: PCRE_INFO_FIRSTCHAR          4
CONSTANT: PCRE_INFO_FIRSTTABLE         5
CONSTANT: PCRE_INFO_LASTLITERAL        6
CONSTANT: PCRE_INFO_NAMEENTRYSIZE      7
CONSTANT: PCRE_INFO_NAMECOUNT          8
CONSTANT: PCRE_INFO_NAMETABLE          9
CONSTANT: PCRE_INFO_STUDYSIZE         10
CONSTANT: PCRE_INFO_DEFAULT_TABLES    11
CONSTANT: PCRE_INFO_OKPARTIAL         12
CONSTANT: PCRE_INFO_JCHANGED          13
CONSTANT: PCRE_INFO_HASCRORLF         14
CONSTANT: PCRE_INFO_MINLENGTH         15

CONSTANT: PCRE_CONFIG_UTF8                    0
CONSTANT: PCRE_CONFIG_NEWLINE                 1
CONSTANT: PCRE_CONFIG_LINK_SIZE               2
CONSTANT: PCRE_CONFIG_POSIX_MALLOC_THRESHOLD  3
CONSTANT: PCRE_CONFIG_MATCH_LIMIT             4
CONSTANT: PCRE_CONFIG_STACKRECURSE            5
CONSTANT: PCRE_CONFIG_UNICODE_PROPERTIES      6
CONSTANT: PCRE_CONFIG_MATCH_LIMIT_RECURSION   7
CONSTANT: PCRE_CONFIG_BSR                     8
CONSTANT: PCRE_CONFIG_JIT                     9
CONSTANT: PCRE_CONFIG_UTF16                  10
CONSTANT: PCRE_CONFIG_JITTARGET              11
CONSTANT: PCRE_CONFIG_UTF32                  12

STRUCT: pcre_extra
    { flags ulonglong }
    { study_data void* }
    { match_limit ulonglong }
    { callout_data void* }
    { tables uchar* }
    { match_limit_recursion ulonglong }
    { mark uchar** }
    { executable_jit void* } ;

FUNCTION: int pcre_config ( int what, void* where )

FUNCTION: void* pcre_compile ( c-string pattern,
                               int options,
                               char** errptr,
                               int* erroffset,
                               char* tableptr )

FUNCTION: void* pcre_compile2 ( c-string pattern,
                                int options,
                                int* errcodeptr,
                                char** errptr,
                                int* erroffset,
                                char* tableptr )

FUNCTION: int pcre_info ( void* pcre, int* optptr, int* first_byte )
FUNCTION: int pcre_fullinfo ( void* pcre,
                              pcre_extra* extra,
                              int what, void *where )

FUNCTION: pcre_extra* pcre_study ( void* pcre, int options, char** errptr )
FUNCTION: int pcre_exec ( void* pcre,
                          pcre_extra* extra,
                          c-string subject,
                          int length,
                          int startoffset,
                          int options,
                          int* ovector,
                          int ovecsize )

FUNCTION: int pcre_get_stringnumber ( void* pcre, c-string name )

FUNCTION: int pcre_get_substring ( c-string subject,
                                   int* ovector,
                                   int stringcount,
                                   int stringnumber,
                                   void *stringptr )

FUNCTION: int pcre_get_substring_list ( c-string subject,
                                        int* ovector,
                                        int stringcount,
                                        void *stringptr )

FUNCTION: c-string pcre_version ( )

FUNCTION: uchar* pcre_maketables ( )

FUNCTION: void pcre_free ( void* pcre )
