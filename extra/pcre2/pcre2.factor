! Copyright (C) 2009 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.data alien.strings arrays
assocs byte-arrays combinators combinators.short-circuit
destructors endian grouping io.encodings.string
io.encodings.utf8 kernel literals make math pcre2.ffi regexp
sequences sorting specialized-arrays splitting strings ;

SPECIALIZED-ARRAY: PCRE2_SIZE

IN: pcre2

ERROR: pcre2-error number offset ;

TUPLE: pcre2 < disposable handle ;

M: pcre2 dispose* handle>> pcre2_code_free ;

ERROR: bad-option what ;

<PRIVATE

: replace-all ( seq subseqs new -- seq )
    swapd '[ _ replace ] reduce ;

: split-subseqs ( seq subseqs -- seqs )
    dup first [ replace-all ] keep split-subseq [ >string ] map harvest ;

: check-bad-option ( err value what -- value )
    rot 0 = [ drop ] [ bad-option ] if ;

: pcre2-config-string ( what length -- string )
    <byte-array> [ pcre2_config ] keep utf8 alien>string nip ;

: pcre2-config-number ( what -- n )
    [
        { uint32_t } [ pcre2_config ] with-out-parameters
    ] keep check-bad-option ;

: pcre2-config ( what -- value )
    dup {
        { PCRE2_CONFIG_UNICODE_VERSION [ 24 pcre2-config-string ] }
        { PCRE2_CONFIG_VERSION [ 24 pcre2-config-string ] }
        [ drop pcre2-config-number ]
    } case ;

: pcre2-unicode-version ( -- string )
    PCRE2_CONFIG_UNICODE_VERSION pcre2-config ;

: pcre2-version ( -- string )
    PCRE2_CONFIG_VERSION pcre2-config ;

: <pcre2> ( expr -- pcre2 )
    utf8 encode dup length 0
    { int PCRE2_SIZE } [ f pcre2_compile ] with-out-parameters
    pick [
        2drop pcre2 new-disposable swap >>handle
    ] [
        [ int deref ] [ PCRE2_SIZE deref ] bi* pcre2-error
    ] if ;

: pcre2-pattern-info-ptr ( handle what -- where )
    [
        { void* } [ pcre2_pattern_info ] with-out-parameters
    ] keep check-bad-option ;

: pcre2-pattern-info-number ( handle what -- where )
    [
        { uint32_t } [ pcre2_pattern_info ] with-out-parameters
    ] keep check-bad-option ;

: pcre2-name-count ( handle -- n )
    PCRE2_INFO_NAMECOUNT pcre2-pattern-info-number ;

: pcre2-name-table ( handle -- ptr )
    PCRE2_INFO_NAMETABLE pcre2-pattern-info-ptr ;

: pcre2-name-entry-size ( handle -- n )
    PCRE2_INFO_NAMEENTRYSIZE pcre2-pattern-info-number ;

: pcre2-utf? ( handle -- ? )
    PCRE2_INFO_ALLOPTIONS pcre2-pattern-info-number
    PCRE2_UTF bitand zero? not ;

: pcre2-crlf? ( handle -- ? )
    PCRE2_INFO_NEWLINE pcre2-pattern-info-number ${
        PCRE2_NEWLINE_ANY PCRE2_NEWLINE_CRLF PCRE2_NEWLINE_ANYCRLF
    } member? ;

PRIVATE>

GENERIC: findall ( subject obj -- matches )

M:: pcre2 findall ( subject obj -- matches )
    [
        subject utf8 encode :> subject_bytes
        subject_bytes length :> subject_length

        obj handle>> :> re

        re pcre2-utf? :> utf?
        re pcre2-crlf? :> crlf?

        re f pcre2_match_data_create_from_pattern
        &pcre2_match_data_free :> match_data

        0 :> start_offset!
        0 :> options!

        re
        subject_bytes
        subject_length
        start_offset
        options
        match_data
        f
        pcre2_match :> rc

        re pcre2-name-count :> name_count
        name_count [
            f
        ] [
            re pcre2-name-table
            re pcre2-name-entry-size
            [ rot * memory>byte-array ] [ <groups> ] bi
            [ 2 cut [ be> ] [ utf8 alien>string ] bi* ] map>alist
            sort-keys
        ] if-zero :> name_table

        rc 0 < [
            rc {
                { PCRE2_ERROR_NOMATCH [ { } ] }
                [ throw ]
            } case
        ] [
            match_data pcre2_get_ovector_pointer
            rc assert-positive 2 * PCRE2_SIZE <c-direct-array> :> ovector

            [
                [
                    f ovector first2 subject subseq 2array ,
                    name_table [
                        ovector rot 2 * tail-slice first2 subject
                        subseq 2array ,
                    ] assoc-each
                ] { } make ,

                [
                    f :> break?!

                    0 options!
                    ovector second start_offset!

                    ovector first2 = [
                        ovector first subject_length =
                        flags{ PCRE2_NOTEMPTY_ATSTART PCRE2_ANCHORED }
                        options!
                    ] [
                        match_data pcre2_get_startchar :> startchar
                        start_offset startchar <= [
                            startchar subject_length >=
                            startchar 1 + start_offset!
                            utf? [
                                [
                                    {
                                        [ start_offset subject_length < ]
                                        [ start_offset subject_bytes nth 0xc0 bitand 0x80 = ]
                                        [ start_offset 1 + start_offset! t ]
                                    } 0&&
                                ] loop
                            ] when
                        ] [
                            f
                        ] if
                    ] if

                    [ f ] [
                        re
                        subject_bytes
                        subject_length
                        start_offset
                        options
                        match_data
                        f
                        pcre2_match :> rc

                        rc PCRE2_ERROR_NOMATCH = [
                            options zero? break?!

                            start_offset 1 + 1 ovector set-nth
                            {
                                [ crlf? ]
                                [ start_offset subject_length 1 - < ]
                                [ start_offset subject_bytes nth CHAR: \r = ]
                                [ start_offset 1 + subject_bytes nth CHAR: \n = ]
                            } 0&& [
                                1 ovector [ 1 + ] change-nth
                            ] [
                                utf? [
                                    [
                                        ovector second {
                                            [ subject_length < ]
                                            [ subject_bytes nth 0xc0 bitand 0x80 = ]
                                        } 1&&
                                    ] [
                                        1 ovector [ 1 + ] change-nth
                                    ] while
                                ] when
                            ] if

                            f
                        ] [
                            [
                                f ovector first2 subject subseq 2array ,
                                name_table [
                                    ovector rot 2 * tail-slice first2 subject
                                    subseq 2array ,
                                ] assoc-each
                            ] { } make ,
                            t
                        ] if
                    ] if
                ] loop
            ] { } make
        ] if
    ] with-destructors ;

M: string findall <pcre2> [ findall ] with-disposal ;

M: regexp findall raw>> findall ;

: matches? ( subject obj -- ? )
    dupd findall [ nip length 1 = ] [ ?first ?first ?last = ] 2bi and ;

: split ( subject obj -- strings )
    dupd findall [ first second ] map split-subseqs ;
