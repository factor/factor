! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs combinators combinators.short-circuit
formatting hashtables io io.streams.string kernel make math
namespaces quoting sequences splitting strings strings.parser ;

IN: ini-file

<PRIVATE

: escape ( ch -- ch' )
    H{
        { ch'a   ch'\a }
        { ch'b   ch'\b }
        { ch'f   ch'\f }
        { ch'n   ch'\n }
        { ch'r   ch'\r }
        { ch't   ch'\t }
        { ch'v   ch'\v }
        { ch'\'   ch'\' }
        { ch'\"   ch'\" }
        { ch'\\  ch'\\ }
        { ch'?   ch'? }
        { ch'\;   ch'\; }
        { ch'\[   ch'\[ }
        { ch'\]   ch'\] }
        { ch'=   ch'= }
    } ?at [ bad-escape ] unless ;

: (unescape-string) ( str -- )
    ch'\\ over index [
        cut-slice [ % ] dip rest-slice
        dup empty? [ "Missing escape code" throw ] when
        unclip-slice escape , (unescape-string)
    ] [ % ] if* ;

: unescape-string ( str -- str' )
    [ (unescape-string) ] "" make ;

USE: xml.entities

: escape-string ( str -- str' )
    H{
        { ch'\a   "\\a"  }
        { 0x08    "\\b"  }
        { 0x0c    "\\f"  }
        { ch'\n   "\\n"  }
        { ch'\r   "\\r"  }
        { ch'\t   "\\t"  }
        { 0x0b    "\\v"  }
        { ch'\'    "\\'"  }
        { ch'\"    "\\\"" }
        { ch'\\   "\\\\" }
        { ch'?    "\\?"  }
        { ch'\;    "\\;"  }
        { ch'\[    "\\["  }
        { ch'\]    "\\]"  }
        { ch'=    "\\="  }
    } escape-string-by ;

: space? ( ch -- ? )
    {
        [ ch'\s = ]
        [ ch'\t = ]
        [ ch'\n = ]
        [ ch'\r = ]
        [ 0x0c = ] ! \f
        [ 0x0b = ] ! \v
    } 1|| ;

: unspace ( str -- str' )
    [ space? ] trim ;

: unwrap ( str -- str' )
    1 swap [ length 1 - ] keep subseq ;

: uncomment ( str -- str' )
    ";#" [ over index [ head ] when* ] each ;

: cleanup-string ( str -- str' )
    unspace unquote unescape-string ;

SYMBOL: section
SYMBOL: option

: section? ( line -- index/f )
    {
        [ length 1 > ]
        [ first ch'\[ = ]
        [ ch'\] swap last-index ]
    } 1&& ;

: line-continues? ( line -- ? )
    { [ empty? not ] [ last ch'\\ = ] } 1&& ;

: section, ( -- )
    section get [ , ] when* ;

: option, ( name value -- )
    section get [ second swapd set-at ] [ 2array , ] if* ;

: [section] ( line -- )
    unwrap cleanup-string H{ } clone 2array section set ;

: name=value ( line -- )
    option [
        [ swap [ first2 ] dip ] [
            "=" split1 [ cleanup-string "" ] [ "" or ] bi*
        ] if*
        dup line-continues? [
            dup length 1 - head cleanup-string
            dup last space? [ " " append ] unless append 2array
        ] [
            cleanup-string append option, f
        ] if
    ] change ;

: parse-line ( line -- )
    uncomment unspace dup section? [
        section, 1 + cut [ [section] ] [ unspace ] bi*
    ] when* [ name=value ] unless-empty ;

PRIVATE>

: read-ini ( -- assoc )
    section off option off
    [ [ parse-line ] each-line section, ] { } make
    >hashtable ;

: write-ini ( assoc -- )
    [
        dup string?
        [ [ escape-string ] bi@ "%s=%s\n" printf ]
        [
            [ escape-string "[%s]\n" printf ] dip
            [ [ escape-string ] bi@ "%s=%s\n" printf ]
            assoc-each nl
        ] if
    ] assoc-each ;

! FIXME: escaped comments "\;" don't work

: string>ini ( str -- assoc )
    [ read-ini ] with-string-reader ;

: ini>string ( assoc -- str )
    [ write-ini ] with-string-writer ;
