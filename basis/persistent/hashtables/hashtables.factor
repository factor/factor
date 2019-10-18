! Based on Clojure's PersistentHashMap by Rich Hickey.

USING: kernel math accessors assocs fry combinators parser
prettyprint.custom locals make
persistent.assocs
persistent.hashtables.nodes
persistent.hashtables.nodes.empty
persistent.hashtables.nodes.leaf
persistent.hashtables.nodes.full
persistent.hashtables.nodes.bitmap
persistent.hashtables.nodes.collision ;
IN: persistent.hashtables

TUPLE: persistent-hash
{ root read-only initial: empty-node }
{ count fixnum read-only } ;

M: persistent-hash assoc-size count>> ;

M: persistent-hash at*
     [ dup hashcode >fixnum ] [ root>> ] bi* (entry-at)
     dup [ value>> t ] [ f ] if ;

M: persistent-hash new-at ( value key assoc -- assoc' )
    [
        { [ 0 ] [ ] [ dup hashcode >fixnum ] [ root>> ] } spread
        (new-at) 1 0 ?
    ] [ count>> ] bi +
    persistent-hash boa ;

M: persistent-hash pluck-at
    [ [ dup hashcode >fixnum ] [ root>> ] bi* (pluck-at) ] keep
    {
        { [ 2dup root>> eq? ] [ nip ] }
        { [ over not ] [ 2drop T{ persistent-hash } ] }
        [ count>> 1 - persistent-hash boa ]
    } cond ;

M: persistent-hash >alist [ root>> >alist% ] { } make ;

:: >persistent-hash ( assoc -- phash )
    T{ persistent-hash } assoc [| ph k v | v k ph new-at ] assoc-each ;

M: persistent-hash equal?
    over persistent-hash? [ assoc= ] [ 2drop f ] if ;

M: persistent-hash hashcode* nip assoc-size ;

M: persistent-hash clone ;

SYNTAX: PH{ \ } [ >persistent-hash ] parse-literal ;

M: persistent-hash pprint-delims drop \ PH{ \ } ;
M: persistent-hash >pprint-sequence >alist ;
M: persistent-hash pprint* pprint-object ;

: passociate ( value key -- phash )
    T{ persistent-hash } new-at ; inline
