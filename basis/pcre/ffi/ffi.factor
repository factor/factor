USING:
    alien alien.c-types alien.data alien.libraries alien.syntax
    classes.struct
    combinators
    system ;
IN: pcre.ffi

<< {
    { [ os unix? ] [ "libpcre" "libpcre.so" cdecl add-library ] }
} cond >>

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

STRUCT: pcre_extra
    { flags int }
    { study_data void* }
    { match_limit long }
    { callout_data void* }
    { tables uchar* }
    { match_limit_recursion int }
    { mark uchar** } ;

FUNCTION: void* pcre_compile ( c-string pattern,
                               int options,
                               char** errptr,
                               int* erroffset,
                               char* tableptr ) ;

FUNCTION: int pcre_info ( void* pcre, int* optptr, int* first_byte ) ;
FUNCTION: int pcre_fullinfo ( void* pcre, pcre_extra* extra, int what, void *where ) ;

FUNCTION: pcre_extra* pcre_study ( void* pcre, int options, char** errptr ) ;
FUNCTION: int pcre_exec ( void* pcre,
                          pcre_extra* extra,
                          c-string subject,
                          int length,
                          int startoffset,
                          int options,
                          int* ovector,
                          int ovecsize ) ;

FUNCTION: int pcre_get_substring ( c-string subject,
                                   int* ovector,
                                   int stringcount,
                                   int stringnumber,
                                   void *stringptr ) ;

FUNCTION: c-string pcre_version ( ) ;

FUNCTION: uchar* pcre_maketables ( ) ;
