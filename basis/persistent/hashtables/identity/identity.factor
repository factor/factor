USING: accessors assocs combinators kernel math parser persistent.assocs
persistent.hashtables persistent.hashtables.nodes prettyprint.custom ;

IN: persistent.hashtables.identity

TUPLE: id-persistent-hash < persistent-hash ;

! XXX These constitute the actual difference, using id-hashcode instead of
! hashcode.  Would be nice to have an abstraction for this!  Note that using
! wrapped keys is also not fun.
M: id-persistent-hash at*
    [ dup identity-hashcode >fixnum ] [ root>> ] bi* (entry-at)
    dup [ value>> t ] [ f ] if ;

M: id-persistent-hash new-at
    [
        [ 0 ] 3dip
        [ dup identity-hashcode >fixnum ] [ root>> ] bi* (new-at) 1 0 ?
    ] [ count>> ] bi + id-persistent-hash boa ;

M: id-persistent-hash pluck-at
    [ [ dup identity-hashcode >fixnum ] [ root>> ] bi* (pluck-at) ] keep
    {
        { [ 2dup root>> eq? ] [ nip ] }
        { [ over not ] [ 2drop T{ id-persistent-hash } ] }
        [ count>> 1 - id-persistent-hash boa ]
    } cond ;

! XXX duplicate code from persistent.hashtables
: >id-persistent-hash ( assoc -- iphash )
    T{ id-persistent-hash } swap [ spin new-at ] assoc-each ;

! XXX duplicate code from persistent.hashtables
M: id-persistent-hash equal?
    over id-persistent-hash? [ assoc= ] [ 2drop f ] if ;

SYNTAX: IPH{ \ } [ >id-persistent-hash ] parse-literal ;

M: id-persistent-hash pprint-delims drop \ IPH{ \ } ;
M: id-persistent-hash >pprint-sequence >alist ;
M: id-persistent-hash pprint*
    [ pprint-object ] with-extra-nesting-level ;

! XXX duplicate code from persistent.hashtables
: id-passociate ( value key -- iphash )
    T{ id-persistent-hash } new-at ; inline
