! Copyright (C) 2008, 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays ascii assocs byte-arrays combinators
combinators.short-circuit grouping hashtables interval-sets
io.encodings.utf8 io.files kernel make math math.bitwise
math.order math.parser ranges namespaces sequences
sets simple-flat-file sorting splitting strings.parser ;
IN: unicode.data

<PRIVATE

CONSTANT: simple-lower H{ }
CONSTANT: simple-upper H{ }
CONSTANT: simple-title H{ }
CONSTANT: canonical-map H{ }
CONSTANT: combine-map H{ }
CONSTANT: class-map H{ }
CONSTANT: compatibility-map H{ }
CONSTANT: category-map BV{ }
CONSTANT: special-casing H{ }
CONSTANT: properties H{ }

: >2ch ( a b -- c ) [ 21 shift ] dip + ; inline
: 2ch> ( c -- a b ) [ -21 shift ] [ 21 on-bits mask ] bi ; inline

PRIVATE>

CONSTANT: name-map H{ }

: canonical-entry ( char -- seq ) canonical-map at ; inline
: compatibility-entry ( char -- seq ) compatibility-map at ; inline
: combine-chars ( a b -- char/f ) >2ch combine-map at ; inline
: combining-class ( char -- n ) class-map at ; inline
: non-starter? ( char -- ? ) combining-class { 0 f } member? not ; inline
: property ( property -- interval-map ) properties at ; foldable
: property? ( char property -- ? ) property interval-in? ; inline
: special-case ( ch -- casing-tuple ) special-casing at ; inline

! For non-existent characters, use Cn
CONSTANT: categories {
    "Cn"
    "Lu" "Ll" "Lt" "Lm" "Lo"
    "Mn" "Mc" "Me"
    "Nd" "Nl" "No"
    "Pc" "Pd" "Ps" "Pe" "Pi" "Pf" "Po"
    "Sm" "Sc" "Sk" "So"
    "Zs" "Zl" "Zp"
    "Cc" "Cf" "Cs" "Co"
}

<PRIVATE

MEMO: categories-map ( -- hashtable )
    categories H{ } zip-index-as ;

CONSTANT: NUM-CHARS 0x2FA25

PRIVATE>

: category-num ( char -- n )
    ! There are a few characters that should be Cn
    ! that this gives Cf or Mn
    ! Cf = 26; Mn = 5; Cn = 29
    ! Use a compressed array instead?
    [ category-map ?nth ] [
        dup 0xE0001 0xE007F between?
        [ drop 26 ] [
            0xE0100 0xE01EF between?  5 29 ?
        ] if
    ] ?unless ; inline

: category ( char -- category )
    category-num categories nth ;

<PRIVATE

! Loading data from UnicodeData.txt

: load-unicode-data ( -- data )
    "vocab:unicode/UnicodeData.txt" load-data-file ;

: (process-data) ( index data -- newdata )
    [ [ nth ] keep first swap ] with map>alist
    [ [ hex> ] dip ] assoc-map ;

: process-data ( index data -- hash )
    (process-data) [ hex> ] assoc-map [ nip ] H{ } assoc-filter-as ;

: (chain-decomposed) ( hash value -- newvalue )
    [
        2dup of or?
        [ (chain-decomposed) ] [ 1array nip ] if
    ] with map concat ;

: chain-decomposed ( hash -- newhash )
    dup [ swap (chain-decomposed) ] curry assoc-map ;

: first* ( seq -- ? )
    second { [ empty? ] [ first ] } 1|| ;

: (process-decomposed) ( data -- alist )
    5 swap (process-data)
    [ split-words [ hex> ] map ] assoc-map ;

: exclusions-file ( -- filename )
    "vocab:unicode/CompositionExclusions.txt" ;

: exclusions ( -- set )
    exclusions-file utf8 file-lines
    [ "#" split1 drop [ ascii:blank? ] trim-tail hex> ] map
    0 swap remove ;

: unique ( seq -- assoc )
    [ dup ] H{ } map>assoc ;

: remove-exclusions ( alist -- alist )
    exclusions unique assoc-diff ;

: process-canonical ( data -- hash hash )
    (process-decomposed) [ first* ] filter
    [
        [ second length 2 = ] filter remove-exclusions
        [ first2 >2ch swap ] H{ } assoc-map-as
    ] [ >hashtable chain-decomposed ] bi ;

: process-compatibility ( data -- hash )
    (process-decomposed)
    [ dup first* [ first2 rest 2array ] unless ] map
    [ second empty? ] reject
    >hashtable chain-decomposed ;

: process-combining ( data -- hash )
    3 swap (process-data)
    [ string>number ] assoc-map
    [ zero? ] reject-values
    >hashtable ;

! the maximum unicode char in the first 3 planes

:: fill-ranges ( table -- table )
    name-map sort-values keys
    [ { [ "first>" tail? ] [ "last>" tail? ] } 1|| ] filter
    2 group [
        [ name-map at ] bi@ [ [a..b] ] [ table ?nth ] bi
        [ swap table ?set-nth ] curry each
    ] assoc-each table ;

:: process-category ( data -- category-listing )
    NUM-CHARS <byte-array> :> table
    2 data (process-data) [| char cat |
        cat categories-map at char table ?set-nth
    ] assoc-each table fill-ranges ;

: process-names ( data -- names-hash )
    1 swap (process-data) [
        >lower H{ { CHAR: \s CHAR: - } } substitute swap
    ] H{ } assoc-map-as ;

: multihex ( hexstring -- string )
    split-words [ hex> ] map sift ;

PRIVATE>

TUPLE: code-point lower title upper ;

C: <code-point> code-point

<PRIVATE

: set-code-point ( seq -- )
    4 head [ multihex ] map first4
    <code-point> swap first ,, ;

! Extra properties {{[a,b],prop}}
: parse-properties ( -- assoc )
    "vocab:unicode/PropList.txt" load-data-file [
        [
            ".." split1 [ dup ] unless*
            [ hex> ] bi@ 2array
        ] dip
    ] assoc-map ;

: properties>intervals ( properties -- assoc[str,interval] )
    dup values members [ f ] H{ } map>assoc
    [ [ push-at ] curry assoc-each ] keep
    [ <interval-set> ] assoc-map ;

: load-properties ( -- assoc )
    parse-properties properties>intervals ;

! Special casing data
: load-special-casing ( -- special-casing )
    "vocab:unicode/SpecialCasing.txt" load-data-file
    [ length 5 = ] filter
    [ [ set-code-point ] each ] H{ } make ;

load-unicode-data {
    [ process-names name-map swap assoc-union! drop ]
    [ 13 swap process-data simple-lower swap assoc-union! drop ]
    [ 12 swap process-data simple-upper swap assoc-union! drop ]
    [ 14 swap process-data simple-upper assoc-union simple-title swap assoc-union! drop ]
    [ process-combining class-map swap assoc-union! drop ]
    [ process-canonical canonical-map swap assoc-union! drop combine-map swap assoc-union! drop ]
    [ process-compatibility compatibility-map swap assoc-union! drop ]
    [ process-category category-map push-all ]
} cleave

combine-map keys [ 2ch> nip ] map
[ class-map at ] reject
[ 0 swap class-map set-at ] each

load-special-casing special-casing swap assoc-union! drop

load-properties properties swap assoc-union! drop

PRIVATE>

ERROR: invalid-unicode-character name ;

[
    name-map ?at [ invalid-unicode-character ] unless
] name>char-hook set-global
