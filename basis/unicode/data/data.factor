! Copyright (C) 2008, 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit assocs math kernel sequences
io.files hashtables quotations splitting grouping arrays io
math.parser math.order byte-arrays namespaces math.bitwise
compiler.units parser io.encodings.ascii interval-maps
ascii sets combinators locals math.ranges sorting make
strings.parser io.encodings.utf8 memoize simple-flat-file
sequences.private ;
IN: unicode.data

<PRIVATE

CONSTANT: simple-lower H{ }
CONSTANT: simple-upper H{ }
CONSTANT: simple-title H{ }
CONSTANT: canonical-map H{ }
CONSTANT: combine-map H{ }
CONSTANT: class-map H{ }
CONSTANT: compatibility-map H{ }
SYMBOL: category-map ! B{ }
CONSTANT: special-casing H{ }
CONSTANT: properties H{ }

: >2ch ( a b -- c ) [ 21 shift ] dip + ;
: 2ch> ( c -- a b ) [ -21 shift ] [ 21 on-bits mask ] bi ;

PRIVATE>

CONSTANT: name-map H{ }

: canonical-entry ( char -- seq ) canonical-map at ; inline
: combine-chars ( a b -- char/f ) >2ch combine-map at ; inline
: compatibility-entry ( char -- seq ) compatibility-map at ; inline
: combining-class ( char -- n ) class-map at ; inline
: non-starter? ( char -- ? ) combining-class { 0 f } member? not ; inline
: name>char ( name -- char ) name-map at ; inline
: char>name ( char -- name ) name-map value-at ; inline
: property? ( char property -- ? ) properties at interval-key? ; inline
: ch>lower ( ch -- lower ) simple-lower ?at drop ; inline
: ch>upper ( ch -- upper ) simple-upper ?at drop ; inline
: ch>title ( ch -- title ) simple-title ?at drop ; inline
: special-case ( ch -- casing-tuple ) special-casing at ; inline

! For non-existent characters, use Cn
CONSTANT: categories
    { "Cn"
      "Lu" "Ll" "Lt" "Lm" "Lo"
      "Mn" "Mc" "Me"
      "Nd" "Nl" "No"
      "Pc" "Pd" "Ps" "Pe" "Pi" "Pf" "Po"
      "Sm" "Sc" "Sk" "So"
      "Zs" "Zl" "Zp"
      "Cc" "Cf" "Cs" "Co" }

<PRIVATE

MEMO: categories-map ( -- hashtable )
    categories <enum> [ swap ] H{ } assoc-map-as ;

CONSTANT: num-chars 0x2FA1E

PRIVATE>

: category# ( char -- n )
    ! There are a few characters that should be Cn
    ! that this gives Cf or Mn
    ! Cf = 26; Mn = 5; Cn = 29
    ! Use a compressed array instead?
    dup category-map get-global ?nth [ ] [
        dup 0xE0001 0xE007F between?
        [ drop 26 ] [
            0xE0100 0xE01EF between?  5 29 ?
        ] if
    ] ?if ; inline

: category ( char -- category )
    category# categories nth ;

<PRIVATE

! Loading data from UnicodeData.txt

: load-data ( -- data )
    "vocab:unicode/data/UnicodeData.txt" data ;

: (process-data) ( index data -- newdata )
    [ [ nth ] keep first swap ] with { } map>assoc
    [ [ hex> ] dip ] assoc-map ;

: process-data ( index data -- hash )
    (process-data) [ hex> ] assoc-map [ nip ] H{ } assoc-filter-as ;

: (chain-decomposed) ( hash value -- newvalue )
    [
        2dup swap at
        [ (chain-decomposed) ] [ 1array nip ] ?if
    ] with map concat ;

: chain-decomposed ( hash -- newhash )
    dup [ swap (chain-decomposed) ] curry assoc-map ;

: first* ( seq -- ? )
    second { [ empty? ] [ first ] } 1|| ;

: (process-decomposed) ( data -- alist )
    5 swap (process-data)
    [ " " split [ hex> ] map ] assoc-map ;

: exclusions-file ( -- filename )
    "vocab:unicode/data/CompositionExclusions.txt" ;

: exclusions ( -- set )
    exclusions-file utf8 file-lines
    [ "#" split1 drop [ blank? ] trim-tail hex> ] map
    [ 0 = not ] filter ;

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
    [ second empty? not ] filter
    >hashtable chain-decomposed ;

: process-combining ( data -- hash )
    3 swap (process-data)
    [ string>number ] assoc-map
    [ nip zero? not ] assoc-filter
    >hashtable ;

! the maximum unicode char in the first 3 planes

: ?set-nth ( elt n seq -- )
    2dup bounds-check? [ set-nth-unsafe ] [ 3drop ] if ; inline

:: fill-ranges ( table -- table )
    name-map sort-values keys
    [ { [ "first>" tail? ] [ "last>" tail? ] } 1|| ] filter
    2 group [
        [ name>char ] bi@ [ [a,b] ] [ table ?nth ] bi
        [ swap table ?set-nth ] curry each
    ] assoc-each table ;

:: process-category ( data -- category-listing )
    num-chars <byte-array> :> table
    2 data (process-data) [| char cat |
        cat categories-map at char table ?set-nth
    ] assoc-each table fill-ranges ;

: process-names ( data -- names-hash )
    1 swap (process-data) [
        >lower H{ { CHAR: \s CHAR: - } } substitute swap
    ] H{ } assoc-map-as ;

: multihex ( hexstring -- string )
    " " split [ hex> ] map sift ;

PRIVATE>

TUPLE: code-point lower title upper ;

C: <code-point> code-point

<PRIVATE

: set-code-point ( seq -- )
    4 head [ multihex ] map first4
    <code-point> swap first ,, ;

! Extra properties
: parse-properties ( -- {{[a,b],prop}} )
    "vocab:unicode/data/PropList.txt" data [
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
    "vocab:unicode/data/SpecialCasing.txt" data
    [ length 5 = ] filter
    [ [ set-code-point ] each ] H{ } make ;

load-data {
    [ process-names name-map swap assoc-union! drop ]
    [ 13 swap process-data simple-lower swap assoc-union! drop ]
    [ 12 swap process-data simple-upper swap assoc-union! drop ]
    [ 14 swap process-data simple-upper assoc-union simple-title swap assoc-union! drop ]
    [ process-combining class-map swap assoc-union! drop ]
    [ process-canonical canonical-map swap assoc-union! drop combine-map swap assoc-union! drop ]
    [ process-compatibility compatibility-map swap assoc-union! drop ]
    [ process-category category-map set-global ]
} cleave

combine-map keys [ 2ch> nip ] map
[ combining-class not ] filter
[ 0 swap class-map set-at ] each

load-special-casing special-casing swap assoc-union! drop

load-properties properties swap assoc-union! drop

[ name>char [ "Invalid character" throw ] unless* ]
name>char-hook set-global
