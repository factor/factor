! Based on Clojure's PersistentHashMap by Rich Hickey.

USING: accessors kernel math persistent.hashtables.config
persistent.hashtables.nodes persistent.sequences sequences
sequences.private ;
IN: persistent.hashtables.nodes.full

M:: full-node (new-at) ( shift value key hashcode full-node -- node' added-leaf )
    full-node nodes>> :> nodes
    hashcode full-node shift>> mask :> idx
    idx nodes nth-unsafe :> n

    shift radix-bits + value key hashcode n (new-at) :> ( n' new-leaf )
    n n' eq? [
        full-node
    ] [
        n' idx nodes new-nth shift <full-node>
    ] if
    new-leaf ;

M:: full-node (pluck-at) ( key hashcode full-node -- node' )
    hashcode full-node shift>> mask :> idx
    idx full-node nodes>> nth :> n
    key hashcode n (pluck-at) :> n'

    n n' eq? [
        full-node
    ] [
        n' [
            n' idx full-node nodes>> new-nth
            full-node shift>>
            <full-node>
        ] [
            hashcode full-node shift>> bitpos bitnot full-bitmap-mask bitand
            idx full-node nodes>> remove-nth
            full-node shift>>
            <bitmap-node>
        ] if
    ] if ;

M:: full-node (entry-at) ( key hashcode full-node -- node' )
    key hashcode
    hashcode full-node shift>> mask
    full-node nodes>> nth-unsafe
    (entry-at) ;

M: full-node >alist% nodes>> >alist-each% ;
