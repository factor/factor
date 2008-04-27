USING: assocs math kernel sequences io.files hashtables
quotations splitting arrays math.parser hash2 math.order
byte-arrays words namespaces words compiler.units parser
io.encodings.ascii ;
IN: unicode.data

<<
: VALUE:
    CREATE-WORD { f } clone [ first ] curry define ; parsing

: set-value ( value word -- )
    word-def first set-first ;
>>

! Convenience functions
: ?between? ( n/f from to -- ? )
    pick [ between? ] [ 3drop f ] if ;

! Loading data from UnicodeData.txt

: data ( filename -- data )
    ascii file-lines [ ";" split ] map ;

: load-data ( -- data )
    "extra/unicode/UnicodeData.txt" resource-path data ;

: (process-data) ( index data -- newdata )
    [ [ nth ] keep first swap 2array ] with map
    [ second empty? not ] filter
    [ >r hex> r> ] assoc-map ;

: process-data ( index data -- hash )
    (process-data) [ hex> ] assoc-map >hashtable ;

: (chain-decomposed) ( hash value -- newvalue )
    [
        2dup swap at
        [ (chain-decomposed) ] [ 1array nip ] ?if
    ] with map concat ;

: chain-decomposed ( hash -- newhash )
    dup [ swap (chain-decomposed) ] curry assoc-map ;

: first* ( seq -- ? )
    second dup empty? [ ] [ first ] ?if ;

: (process-decomposed) ( data -- alist )
    5 swap (process-data)
    [ " " split [ hex> ] map ] assoc-map ;

: process-canonical ( data -- hash2 hash )
    (process-decomposed) [ first* ] filter
    [
        [ second length 2 = ] filter
        ! using 1009 as the size, the maximum load is 4
        [ first2 first2 rot 3array ] map 1009 alist>hash2
    ] keep
    >hashtable chain-decomposed ;

: process-compat ( data -- hash )
    (process-decomposed)
    [ dup first* [ first2 rest 2array ] unless ] map
    >hashtable chain-decomposed ;

: process-combining ( data -- hash )
    3 swap (process-data)
    [ string>number ] assoc-map
    [ nip zero? not ] assoc-filter
    >hashtable ;

: categories ( -- names )
    ! For non-existent characters, use Cn
    { "Lu" "Ll" "Lt" "Lm" "Lo"
      "Mn" "Mc" "Me"
      "Nd" "Nl" "No"
      "Pc" "Pd" "Ps" "Pe" "Pi" "Pf" "Po"
      "Sm" "Sc" "Sk" "So"
      "Zs" "Zl" "Zp"
      "Cc" "Cf" "Cs" "Co" "Cn" } ;

: unicode-chars HEX: 2FA1E ;
! the maximum unicode char in the first 3 planes

: process-category ( data -- category-listing )
    2 swap (process-data)
    unicode-chars <byte-array> swap dupd swap [
        >r over unicode-chars >= [ r> 3drop ]
        [ categories index swap r> set-nth ] if
    ] curry assoc-each ;

: ascii-lower ( string -- lower )
    [ dup CHAR: A CHAR: Z between? [ HEX: 20 + ] when ] map ;

: process-names ( data -- names-hash )
    1 swap (process-data) [
        ascii-lower { { CHAR: \s CHAR: - } } substitute swap
    ] assoc-map >hashtable ;

: multihex ( hexstring -- string )
    " " split [ hex> ] map [ ] filter ;

TUPLE: code-point lower title upper ;

C: <code-point> code-point

: set-code-point ( seq -- )
    4 head [ multihex ] map first4
    <code-point> swap first set ;

VALUE: simple-lower
VALUE: simple-upper
VALUE: simple-title
VALUE: canonical-map
VALUE: combine-map
VALUE: class-map
VALUE: compat-map
VALUE: category-map
VALUE: name-map
VALUE: special-casing

: canonical-entry ( char -- seq ) canonical-map at ;
: combine-chars ( a b -- char/f ) combine-map hash2 ;
: compat-entry ( char -- seq ) compat-map at  ;
: combining-class ( char -- n ) class-map at ;
: non-starter? ( char -- ? ) class-map key? ;
: name>char ( string -- char ) name-map at ;
: char>name ( char -- string ) name-map value-at ;

! Special casing data
: load-special-casing ( -- special-casing )
    "extra/unicode/SpecialCasing.txt" resource-path data
    [ length 5 = ] filter
    [ [ set-code-point ] each ] H{ } make-assoc ;

load-data
dup process-names \ name-map set-value
13 over process-data \ simple-lower set-value
12 over process-data tuck \ simple-upper set-value
14 over process-data swapd assoc-union \ simple-title set-value
dup process-combining \ class-map set-value
dup process-canonical \ canonical-map set-value
    \ combine-map set-value
dup process-compat \ compat-map set-value
process-category \ category-map set-value
load-special-casing \ special-casing set-value
