USING: assocs math kernel sequences io.files hashtables quotations
splitting arrays math.parser combinators.lib hash2 byte-arrays words
namespaces words ;
IN: unicode.data

! Convenience functions
: 1+* ( n/f _ -- n+1 )
    drop [ 1+ ] [ 0 ] if* ;

: define-value ( value word -- )
    swap 1quotation define ;

: ?between? ( n/f from to -- ? )
    pick [ between? ] [ 3drop f ] if ;

! Loading data from UnicodeData.txt

: data ( filename -- data )
    file-lines [ ";" split ] map ;

: load-data ( -- data )
    "extra/unicode/UnicodeData.txt" resource-path data ;

: (process-data) ( index data -- newdata )
    [ [ nth ] keep first swap 2array ] with map
    [ second empty? not ] subset
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
    second [ empty? ] [ first ] either ;

: (process-decomposed) ( data -- alist )
    5 swap (process-data)
    [ " " split [ hex> ] map ] assoc-map ;

: process-canonical ( data -- hash2 hash )
    (process-decomposed) [ first* ] subset
    [
        [ second length 2 = ] subset
        ! using 1009 as the size, the maximum load is 4
        [ first2 first2 rot 3array ] map 1009 alist>hash2
    ] keep
    >hashtable chain-decomposed ;

: process-compat ( data -- hash )
    (process-decomposed)
    [ dup first* [ first2 1 tail 2array ] unless ] map
    >hashtable chain-decomposed ;

: process-combining ( data -- hash )
    3 swap (process-data)
    [ string>number ] assoc-map
    [ nip 0 = not ] assoc-subset
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

: replace ( seq old new -- newseq )
    swap rot [ 2dup = [ drop over ] when ] map 2nip ;

: process-names ( data -- names-hash )
    1 swap (process-data)
    [ ascii-lower CHAR: \s CHAR: - replace swap ] assoc-map
    >hashtable ;

: multihex ( hexstring -- string )
    " " split [ hex> ] map [ ] subset ;

TUPLE: code-point lower title upper ;

C: <code-point> code-point

: set-code-point ( seq -- )
    4 head [ multihex ] map first4
    <code-point> swap first set ;

DEFER: simple-lower
DEFER: simple-upper
DEFER: simple-title
DEFER: canonical-map
DEFER: combine-map
DEFER: class-map
DEFER: compat-map
DEFER: category-map
DEFER: name-map

<<
    load-data
    dup process-names \ name-map define-value
    13 over process-data \ simple-lower define-value
    12 over process-data tuck \ simple-upper define-value
    14 over process-data swapd union \ simple-title define-value
    dup process-combining \ class-map define-value
    dup process-canonical \ canonical-map define-value
        \ combine-map define-value
    dup process-compat \ compat-map define-value
    process-category \ category-map define-value
>>

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
    [ length 5 = ] subset
    [ [ set-code-point ] each ] H{ } make-assoc ;

DEFER: special-casing

<< load-special-casing \ special-casing define-value >>
