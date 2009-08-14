! Based on Clojure's PersistentHashMap by Rich Hickey.

USING: math math.bitwise arrays kernel accessors locals sequences
sequences.private
persistent.sequences
persistent.hashtables.config
persistent.hashtables.nodes ;
IN: persistent.hashtables.nodes.bitmap

: index ( bit bitmap -- n ) [ 1 - ] dip bitand bit-count ; inline

M:: bitmap-node (entry-at) ( key hashcode bitmap-node -- entry )
    [let* | shift [ bitmap-node shift>> ]
            bit [ hashcode shift bitpos ]
            bitmap [ bitmap-node bitmap>> ]
            nodes [ bitmap-node nodes>> ] |
       bitmap bit bitand 0 eq? [ f ] [
           key hashcode
           bit bitmap index nodes nth-unsafe
           (entry-at)
        ] if
    ] ;

M:: bitmap-node (new-at) ( shift value key hashcode bitmap-node -- node' added-leaf )
    [let* | shift [ bitmap-node shift>> ]
            bit [ hashcode shift bitpos ]
            bitmap [ bitmap-node bitmap>> ]
            idx [ bit bitmap index ]
            nodes [ bitmap-node nodes>> ] |
        bitmap bit bitand 0 eq? [
            [let | new-leaf [ value key hashcode <leaf-node> ] |
                bitmap bit bitor
                new-leaf idx nodes insert-nth
                shift
                <bitmap-node>
                new-leaf
            ]
        ] [
            [let | n [ idx nodes nth ] |
                shift radix-bits + value key hashcode n (new-at)
                [let | new-leaf [ ] n' [ ] |
                    n n' eq? [
                        bitmap-node
                    ] [
                        bitmap
                        n' idx nodes new-nth
                        shift
                        <bitmap-node>
                    ] if
                    new-leaf
                ]
            ]
        ] if
    ] ;

M:: bitmap-node (pluck-at) ( key hashcode bitmap-node -- node' )
    [let | bit [ hashcode bitmap-node shift>> bitpos ]
           bitmap [ bitmap-node bitmap>> ]
           nodes [ bitmap-node nodes>> ]
           shift [ bitmap-node shift>> ] |
           bit bitmap bitand 0 eq? [ bitmap-node ] [
            [let* | idx [ bit bitmap index ]
                    n [ idx nodes nth-unsafe ]
                    n' [ key hashcode n (pluck-at) ] |
                n n' eq? [
                    bitmap-node
                ] [
                    n' [
                        bitmap
                        n' idx nodes new-nth
                        shift
                        <bitmap-node>
                    ] [
                        bitmap bit eq? [ f ] [
                            bitmap bit bitnot bitand
                            idx nodes remove-nth
                            shift
                            <bitmap-node>
                        ] if
                    ] if
                ] if
            ]
        ] if
    ] ;

M: bitmap-node >alist% ( node -- ) nodes>> >alist-each% ;
