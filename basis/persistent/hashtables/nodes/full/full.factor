! Based on Clojure's PersistentHashMap by Rich Hickey.

USING: math accessors kernel arrays sequences sequences.private
locals
persistent.sequences
persistent.hashtables.config
persistent.hashtables.nodes ;
IN: persistent.hashtables.nodes.full

M:: full-node (new-at) ( shift value key hashcode full-node -- node' added-leaf )
    [let* | nodes [ full-node nodes>> ] 
            idx [ hashcode full-node shift>> mask ]
            n [ idx nodes nth-unsafe ] |
        shift radix-bits + value key hashcode n (new-at)
        [let | new-leaf [ ] n' [ ] |
            n n' eq? [
                full-node
            ] [
                n' idx nodes new-nth shift <full-node>
            ] if
            new-leaf
        ]
    ] ;

M:: full-node (pluck-at) ( key hashcode full-node -- node' )
    [let* | idx [ hashcode full-node shift>> mask ]
            n [ idx full-node nodes>> nth ]
            n' [ key hashcode n (pluck-at) ] |
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
        ] if
    ] ;

M:: full-node (entry-at) ( key hashcode full-node -- node' )
    key hashcode
    hashcode full-node shift>> mask
    full-node nodes>> nth-unsafe
    (entry-at) ;

M: full-node >alist% nodes>> >alist-each% ;
