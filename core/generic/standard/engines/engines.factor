USING: assocs kernel namespaces quotations generic math
sequences combinators words classes.algebra ;
IN: generic.standard.engines

SYMBOL: default
SYMBOL: assumed

GENERIC: engine>quot ( engine -- quot )

M: quotation engine>quot ;

M: method-body engine>quot 1quotation ;

: engines>quots ( assoc -- assoc' )
    [ engine>quot ] assoc-map ;

: engines>quots* ( assoc -- assoc' )
    [ over assumed [ engine>quot ] with-variable ] assoc-map ;

: if-small? ( assoc true false -- )
    >r >r dup assoc-size 4 <= r> r> if ; inline

: linear-dispatch-quot ( alist -- quot )
    default get [ drop ] prepend swap
    [ >r [ dupd eq? ] curry r> \ drop prefix ] assoc-map
    alist>quot ;

: split-methods ( assoc class -- first second )
    [ [ nip class< not ] curry assoc-subset ]
    [ [ nip class<     ] curry assoc-subset ] 2bi ;

: convert-methods ( assoc class word -- assoc' )
    over >r >r split-methods dup assoc-empty? [
        r> r> 3drop
    ] [
        r> execute r> pick set-at
    ] if ; inline

SYMBOL: (dispatch#)

: (picker) ( n -- quot )
    {
        { 0 [ [ dup ] ] }
        { 1 [ [ over ] ] }
        { 2 [ [ pick ] ] }
        [ 1- (picker) [ >r ] swap [ r> swap ] 3append ]
    } case ;

: picker ( -- quot ) \ (dispatch#) get (picker) ;

GENERIC: extra-values ( generic -- n )
