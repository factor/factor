USING: kernel sequences words math math.functions arrays 
shuffle quotations parser math.parser strings namespaces 
splitting effects ;
IN: shufflers

: shuffle>string ( names shuffle -- string )
    swap [ [ nth ] curry map ] curry map
    first2 "-" swap 3append >string ;

: translate ( n alphabet out-len -- seq )
    [ drop /mod ] curry* map nip  ;

: (combinations) ( alphabet out-len -- seq[seq] )
    [ ^ ] 2keep [ translate ] 2curry map ;

: combinations ( n max-out -- seq[seq] )
    ! This returns a seq of length O(n^m)
    ! where and m is max-out
    1+ [ (combinations) ] curry* map concat ;

: make-shuffles ( max-out max-in -- shuffles )
    [ 1+ dup rot combinations [ 2array ] curry* map ]
    curry* map concat ;

: shuffle>quot ( shuffle -- quot )
    [
        first2 2dup [ - ] curry* map
        reverse [ , \ npick , \ >r , ] each
        swap , \ ndrop , length [ \ r> , ] times
    ] [ ] make ;

: put-effect ( word -- )
    dup word-name "-" split1
    [ >array [ 1string ] map ] 2apply
    <effect> "declared-effect" set-word-prop ;

: in-shuffle ( -- ) in get ".shuffle" append set-in ;
: out-shuffle ( -- ) in get ".shuffle" ?tail drop set-in ;

: define-shuffles ( names max-out -- )
    in-shuffle over length make-shuffles [
        [ shuffle>string create-in ] keep
        shuffle>quot dupd define-compound put-effect
    ] curry* each out-shuffle ;

: SHUFFLE:
    scan scan string>number define-shuffles ; parsing
