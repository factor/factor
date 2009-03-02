! Copyright (C) 2008, 2009 Daniel Ehrenberg, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math splitting make fry locals math.ranges
accessors arrays ;
IN: regexp.matchers

! For now, a matcher is just something with a method to do the
! equivalent of match.

GENERIC: match-index-from ( i string matcher -- index/f )

: match-index-head ( string matcher -- index/f )
    [ 0 ] 2dip match-index-from ;

: match-slice ( i string matcher -- slice/f )
    [ 2dup ] dip match-index-from
    [ swap <slice> ] [ 2drop f ] if* ;

: matches? ( string matcher -- ? )
    dupd match-index-head
    [ swap length = ] [ drop f ] if* ;

: map-find ( seq quot -- result elt )
    [ f ] 2dip
    '[ nip @ dup ] find
    [ [ drop f ] unless ] dip ; inline

:: match-from ( i string matcher -- slice/f )
    i string length [a,b)
    [ string matcher match-slice ] map-find drop ;

: match-head ( str matcher -- slice/f )
    [ 0 ] 2dip match-from ;

<PRIVATE

: next-match ( i string matcher -- i match/f )
    match-from [ dup [ to>> ] when ] keep ;

PRIVATE>

:: all-matches ( string matcher -- seq )
    0 [ dup ] [ string matcher next-match ] [ ] produce nip but-last ;

: count-matches ( string matcher -- n )
    all-matches length ;

<PRIVATE

:: split-slices ( string slices -- new-slices )
    slices [ to>> ] map 0 prefix
    slices [ from>> ] map string length suffix
    [ string <slice> ] 2map ;

PRIVATE>

: re-split1 ( string matcher -- before after/f )
    dupd match-head [ 1array split-slices first2 ] [ f ] if* ;

: re-split ( string matcher -- seq )
    dupd all-matches split-slices ;

: re-replace ( string matcher replacement -- result )
    [ re-split ] dip join ;
