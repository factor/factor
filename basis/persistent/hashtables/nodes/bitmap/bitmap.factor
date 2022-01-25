! Based on Clojure's PersistentHashMap by Rich Hickey.

USING: accessors kernel math math.bitwise
persistent.hashtables.config persistent.hashtables.nodes
persistent.sequences sequences sequences.private ;
IN: persistent.hashtables.nodes.bitmap

: index ( bit bitmap -- n ) [ 1 - ] dip bitand bit-count ; inline

M:: bitmap-node (entry-at) ( key hashcode bitmap-node -- entry )
    bitmap-node shift>> :> shift
    hashcode shift bitpos :> bit
    bitmap-node bitmap>> :> bitmap
    bitmap-node nodes>> :> nodes
    bitmap bit bitand 0 eq? [ f ] [
        key hashcode
        bit bitmap index nodes nth-unsafe
        (entry-at)
    ] if ;

M:: bitmap-node (new-at) ( shift value key hashcode bitmap-node -- node' added-leaf )
    bitmap-node shift>> :> shift
    hashcode shift bitpos :> bit
    bitmap-node bitmap>> :> bitmap
    bit bitmap index :> idx
    bitmap-node nodes>> :> nodes

    bitmap bit bitand 0 eq? [
        value key hashcode <leaf-node> :> new-leaf
        bitmap bit bitor
        new-leaf idx nodes insert-nth
        shift
        <bitmap-node>
        new-leaf
    ] [
        idx nodes nth :> n
        shift radix-bits + value key hashcode n (new-at) :> ( n' new-leaf )
        n n' eq? [
            bitmap-node
        ] [
            bitmap
            n' idx nodes new-nth
            shift
            <bitmap-node>
        ] if
        new-leaf
    ] if ;

M:: bitmap-node (pluck-at) ( key hashcode bitmap-node -- node' )
    hashcode bitmap-node shift>> bitpos :> bit
    bitmap-node bitmap>> :> bitmap
    bitmap-node nodes>> :> nodes
    bitmap-node shift>> :> shift
    bit bitmap bitand 0 eq? [ bitmap-node ] [
        bit bitmap index :> idx
        idx nodes nth-unsafe :> n
        key hashcode n (pluck-at) :> n'
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
    ] if ;

M: bitmap-node >alist% nodes>> >alist-each% ;
