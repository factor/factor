USING:
    alien alien.c-types alien.data alien.libraries alien.syntax
    classes.struct
    combinators
    system ;
IN: pcre

<< {
    { [ os unix? ] [ "libpcre" "libpcre.so" cdecl add-library ] }
} cond >>

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

FUNCTION: pcre_extra* pcre_study ( void* pcre, int options, char** errptr ) ;

FUNCTION: c-string pcre_version ( ) ;

FUNCTION: uchar* pcre_maketables ( ) ;

: <pcre> ( expr -- pcre err-message err-offset )
    0 { c-string int } [ f pcre_compile ] with-out-parameters ;

: info ( pcre -- x x x )
    { int int } [ pcre_info ] with-out-parameters ;

: study ( pcre -- pcre-extra err-message )
    0 { c-string } [ pcre_study ] with-out-parameters ;
