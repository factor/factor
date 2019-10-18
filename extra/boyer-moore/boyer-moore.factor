! Copyright (C) 2010 Dmitry Shubin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs kernel locals math math.order
math.ranges sequences sequences.private z-algorithm ;
IN: boyer-moore

<PRIVATE

:: (normal-suffixes) ( i zs ss -- )
    i zs nth-unsafe ss
    [ [ i ] unless* ] change-nth-unsafe ; inline

: normal-suffixes ( zs -- ss )
    [ length [ f <array> ] [ [1,b) ] bi ] keep pick
    [ (normal-suffixes) ] 2curry each ; inline

:: (partial-suffixes) ( len old elt i -- len old/new old )
    len elt i 1 + = [ len elt - ] [ old ] if old ; inline

: partial-suffixes ( zs -- ss )
    [ length dup ] [ <reversed> ] bi
    [ (partial-suffixes) ] map-index 2nip ; inline

: <gs-table> ( seq -- table )
    z-values [ partial-suffixes ] [ normal-suffixes ] bi
    [ [ nip ] when* ] 2map reverse! ; inline

: insert-bc-shift ( table elt len i -- table )
    1 + swap - swap pick 2dup key?
    [ 3drop ] [ set-at ] if ; inline

: <bc-table> ( seq -- table )
    H{ } clone swap [ length ] keep
    [ insert-bc-shift ] with each-index ; inline

TUPLE: boyer-moore pattern bc-table gs-table ;

: gs-shift ( i c bm -- s ) nip gs-table>> nth-unsafe ; inline

: bc-shift ( i c bm -- s ) bc-table>> at dup 1 ? + ; inline

: do-shift ( pos i c bm -- newpos )
    [ gs-shift ] [ bc-shift ] bi-curry 2bi max + ; inline

: match? ( i1 s1 i2 s2 -- ? ) [ nth-unsafe ] 2bi@ = ; inline

:: mismatch? ( s1 s2 pos len -- i/f )
    len 1 - [ [ pos + s1 ] keep s2 match? not ]
    find-last-integer ; inline

:: (search-from) ( seq from bm -- i/f )
    bm pattern>>      :> pat
    pat length        :> plen
    seq length plen - :> lim
    from
    [
        dup lim <=
        [
            seq pat pick plen mismatch?
            [ 2dup + seq nth-unsafe bm do-shift t ] [ f ] if*
        ] [ drop f f ] if
    ] loop ; inline

PRIVATE>

: <boyer-moore> ( pat -- bm )
    dup <reversed> [ <bc-table> ] [ <gs-table> ] bi
    boyer-moore boa ;

GENERIC: search-from ( seq from obj -- i/f )

M: sequence search-from
    [ 2drop 0 ] [ <boyer-moore> (search-from) ] if-empty ;

M: boyer-moore search-from (search-from) ;

: search ( seq obj -- i/f ) [ 0 ] dip search-from ;
