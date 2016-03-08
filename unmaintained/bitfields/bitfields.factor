USING: parser lexer kernel math sequences namespaces make assocs
summary words splitting math.parser arrays sequences.next
mirrors generalizations compiler.units ;
IN: bitfields

! Example:
! BITFIELD: blah short:16 char:8 nothing:5 ;
! defines <blah> blah-short blah-char blah-nothing.

! An efficient bitfield has a sum of 29 bits or less
! so it can fit in a fixnum.
! No class is defined and there is no overflow checking.
! The first field is the most significant.

: >ranges ( slots/sizes -- slots/ranges )
    ! range is { start length }
    reverse 0 swap [
        swap >r tuck >r [ + ] keep r> 2array r> swap
    ] assoc-map nip reverse ;

SYMBOL: safe-bitfields? ! default f; set at parsetime

TUPLE: check< number bound ;
M: check< summary drop "Number exceeds upper bound" ;

: check< ( num cmp -- num )
    2dup < [ drop ] [ \ check< boa throw ] if ;

: ?check ( length -- )
    safe-bitfields? get [ 2^ , \ check< , ] [ drop ] if ;

: put-together ( lengths -- )
    ! messy because of bounds checking
    dup length 1- [ \ >r , ] times [ 0 swap ] % [
        ?check [ \ bitor , , [ shift r> ] % ] when*
    ] each-next \ bitor , ;

: padding-name? ( string -- ? )
    [ "10" member? ] all? ;

: pad ( i name -- )
    bin> , , \ -nrot , ;

: add-padding ( names -- ) 
    <enum>
    [ dup padding-name? [ pad ] [ 2drop ] if ] assoc-each ;

: [constructor] ( names lengths -- quot )
    [ swap add-padding put-together ] [ ] make ;

: define-constructor ( classname slots -- )
    [ keys ] keep values [constructor]
    >r in get constructor-word dup save-location r>
    define ;

: range>accessor ( range -- quot )
    [
        dup first neg , \ shift ,
        second 2^ 1- , \ bitand ,
    ] [ ] make ;

: [accessors] ( lengths -- accessors )
    [ range>accessor ] map ;

: clear-range ( range -- num )
    first2 dupd + [ 2^ 1- ] bi@ bitnot bitor ;

: range>setter ( range -- quot )
    [
        \ >r , dup second ?check \ r> ,
        dup clear-range ,
        [ bitand >r ] %
        first , [ shift r> bitor ] %
    ] [ ] make ;

: [setters] ( lengths -- setters )
    [ range>setter ] map ;

: parse-slots ( slotspecs -- slots )
    [ ":" split1 string>number [ dup length ] unless* ] { } map>assoc ;

: define-slots ( prefix names quots -- )
    >r [ "-" glue create-in ] with map r>
    [ define ] 2each ;

: define-accessors ( classname slots -- )
    dup values [accessors]
    >r keys r> define-slots ;

: define-setters ( classname slots -- )
    >r "with-" prepend r>
    dup values [setters]
    >r keys r> define-slots ;

: filter-pad ( slots -- slots )
    [ drop padding-name? not ] assoc-filter ;

: define-bitfield ( classname slots -- ) 
    [
        [ define-constructor ] 2keep
        >ranges filter-pad [ define-setters ] 2keep define-accessors
    ] with-compilation-unit ;

: parse-bitfield ( -- )
    scan ";" parse-tokens parse-slots define-bitfield ;

: BITFIELD:
    parse-bitfield ; parsing

: SAFE-BITFIELD:
    [ safe-bitfields? on parse-bitfield ] with-scope ; parsing
