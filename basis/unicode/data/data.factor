! Copyright (C) 2008, 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit assocs math kernel sequences
io.files hashtables quotations splitting grouping arrays io
math.parser hash2 math.order byte-arrays namespaces
compiler.units parser io.encodings.ascii values interval-maps
ascii sets combinators locals math.ranges sorting make
strings.parser io.encodings.utf8 memoize simple-flat-file ;
IN: unicode.data

<PRIVATE

VALUE: simple-lower
VALUE: simple-upper
VALUE: simple-title
VALUE: canonical-map
VALUE: combine-map
VALUE: class-map
VALUE: compatibility-map
VALUE: category-map
VALUE: special-casing
VALUE: properties

PRIVATE>

VALUE: name-map

: canonical-entry ( char -- seq ) canonical-map at ; inline
: combine-chars ( a b -- char/f ) combine-map hash2 ; inline
: compatibility-entry ( char -- seq ) compatibility-map at ; inline
: combining-class ( char -- n ) class-map at ; inline
: non-starter? ( char -- ? ) combining-class { 0 f } member? not ; inline
: name>char ( name -- char ) name-map at ; inline
: char>name ( char -- name ) name-map value-at ; inline
: property? ( char property -- ? ) properties at interval-key? ; inline
: ch>lower ( ch -- lower ) simple-lower at-default ; inline
: ch>upper ( ch -- upper ) simple-upper at-default ; inline
: ch>title ( ch -- title ) simple-title at-default ; inline
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

CONSTANT: num-chars HEX: 2FA1E

PRIVATE>

: category# ( char -- n )
    ! There are a few characters that should be Cn
    ! that this gives Cf or Mn
    ! Cf = 26; Mn = 5; Cn = 29
    ! Use a compressed array instead?
    dup category-map ?nth [ ] [
        dup HEX: E0001 HEX: E007F between?
        [ drop 26 ] [
            HEX: E0100 HEX: E01EF between?  5 29 ?
        ] if
    ] ?if ;

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
    (process-data) [ hex> ] assoc-map [ nip ] assoc-filter >hashtable ;

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
    [ "#" split1 drop [ blank? ] trim-tail hex> ] map harvest ;

: remove-exclusions ( alist -- alist )
    exclusions [ dup ] H{ } map>assoc assoc-diff ;

: process-canonical ( data -- hash2 hash )
    (process-decomposed) [ first* ] filter
    [
        [ second length 2 = ] filter remove-exclusions
        ! using 1009 as the size, the maximum load is 4
        [ first2 first2 rot 3array ] map 1009 alist>hash2
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

: ?set-nth ( val index seq -- )
    2dup bounds-check? [ set-nth ] [ 3drop ] if ;

:: fill-ranges ( table -- table )
    name-map >alist sort-values keys
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
        >lower { { CHAR: \s CHAR: - } } substitute swap
    ] H{ } assoc-map-as ;

: multihex ( hexstring -- string )
    " " split [ hex> ] map sift ;

PRIVATE>

TUPLE: code-point lower title upper ;

C: <code-point> code-point

<PRIVATE

: set-code-point ( seq -- )
    4 head [ multihex ] map first4
    <code-point> swap first set ;

! Extra properties
: parse-properties ( -- {{[a,b],prop}} )
    "vocab:unicode/data/PropList.txt" data [
        [
            ".." split1 [ dup ] unless*
            [ hex> ] bi@ 2array
        ] dip
    ] assoc-map ;

: properties>intervals ( properties -- assoc[str,interval] )
    dup values prune [ f ] H{ } map>assoc
    [ [ push-at ] curry assoc-each ] keep
    [ <interval-set> ] assoc-map ;

: load-properties ( -- assoc )
    parse-properties properties>intervals ;

! Special casing data
: load-special-casing ( -- special-casing )
    "vocab:unicode/data/SpecialCasing.txt" data
    [ length 5 = ] filter
    [ [ set-code-point ] each ] H{ } make-assoc ;

load-data {
    [ process-names to: name-map ]
    [ 13 swap process-data to: simple-lower ]
    [ 12 swap process-data to: simple-upper ]
    [ 14 swap process-data simple-upper assoc-union to: simple-title ]
    [ process-combining to: class-map ]
    [ process-canonical to: canonical-map to: combine-map ]
    [ process-compatibility to: compatibility-map ]
    [ process-category to: category-map ]
} cleave

: postprocess-class ( -- )
    combine-map [ [ second ] map ] map concat
    [ combining-class not ] filter
    [ 0 swap class-map set-at ] each ;

postprocess-class

load-special-casing to: special-casing

load-properties to: properties

[ name>char [ "Invalid character" throw ] unless* ]
name>char-hook set-global
