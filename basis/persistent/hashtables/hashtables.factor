! Based on Clojure's PersistentHashMap by Rich Hickey.

USING: accessors assocs combinators kernel make math
parser persistent.assocs persistent.hashtables.nodes
prettyprint.custom ;

! Use these explicitly because they define needed methods which are not loaded
! otherwise
USE: persistent.hashtables.nodes.empty
USE: persistent.hashtables.nodes.leaf
USE: persistent.hashtables.nodes.full
USE: persistent.hashtables.nodes.bitmap
USE: persistent.hashtables.nodes.collision

IN: persistent.hashtables

TUPLE: persistent-hash
    { root read-only initial: empty-node }
    { count fixnum read-only } ;

M: persistent-hash assoc-size count>> ;

M: persistent-hash at*
    [ dup hashcode >fixnum ] [ root>> ] bi* (entry-at)
    dup [ value>> t ] [ f ] if ;

M: persistent-hash new-at
    [
        [ 0 ] 3dip
        [ dup hashcode >fixnum ] [ root>> ] bi* (new-at) 1 0 ?
    ] [ count>> ] bi + persistent-hash boa ;

M: persistent-hash pluck-at
    [ [ dup hashcode >fixnum ] [ root>> ] bi* (pluck-at) ] keep
    {
        { [ 2dup root>> eq? ] [ nip ] }
        { [ over not ] [ 2drop T{ persistent-hash } ] }
        [ count>> 1 - persistent-hash boa ]
    } cond ;

M: persistent-hash >alist [ root>> >alist% ] { } make ;

M: persistent-hash keys >alist keys ;

M: persistent-hash values >alist values ;

: >persistent-hash ( assoc -- phash )
    T{ persistent-hash } swap [ spin new-at ] assoc-each ;

M: persistent-hash equal?
    over persistent-hash? [ assoc= ] [ 2drop f ] if ;

M: persistent-hash hashcode* nip assoc-size ;

M: persistent-hash clone ;

SYNTAX: PH{ \ } [ >persistent-hash ] parse-literal ;

M: persistent-hash pprint-delims drop \ PH{ \ } ;
M: persistent-hash >pprint-sequence >alist ;
M: persistent-hash pprint*
    [ pprint-object ] with-extra-nesting-level ;

: passociate ( value key -- phash )
    T{ persistent-hash } new-at ; inline
