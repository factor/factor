! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: generic kernel kernel-internals math namespaces
strings vectors ;

: head-slice ( seq n -- slice ) 0 swap rot <slice> ;

: tail-slice ( seq n -- slice ) over length rot <slice> ;

: (slice*) >r dup length r> - ;

: head-slice* ( seq n -- slice ) (slice*) head-slice ;

: tail-slice* ( seq n -- slice ) (slice*) tail-slice ;

: subseq ( from to seq -- subseq ) [ <slice> ] keep like ;

: head ( seq n -- headseq ) dupd head-slice swap like ;

: head* ( seq n -- headseq ) dupd head-slice* swap like ;

: tail ( seq n -- tailseq ) dupd tail-slice swap like ;

: tail* ( seq n -- tailseq ) dupd tail-slice* swap like ;

: head? ( seq begin -- ? )
    2dup [ length ] 2apply < [
        2drop f
    ] [
        [ length head-slice ] keep sequence=
    ] if ;

: ?head ( seq begin -- newseq ? )
    2dup head? [ length tail t ] [ drop f ] if ;

: tail? ( seq end -- newseq ? )
    2dup [ length ] 2apply < [
        2drop f
    ] [
        [ length tail-slice* ] keep sequence=
    ] if ;

: ?tail ( seq end -- newseq ? )
    2dup tail? [ length head* t ] [ drop f ] if ;

: replace-slice ( new m n seq -- replaced )
    tuck swap tail-slice >r swap head-slice swap r> append3 ;

: remove-nth ( n seq -- newseq )
    >r f swap dup 1+ r> replace-slice ;

: (cut) ( n seq -- before after )
    swap [ head ] 2keep tail-slice ;

: cut ( n seq -- before after )
    swap [ head ] 2keep tail ;

: cut* ( n seq -- before after )
    swap [ head* ] 2keep tail* ;

: (group) ( n seq -- )
    2dup length >= [
        dup empty? [ 2drop ] [ dup like , drop ] if
    ] [
        dupd (cut) >r , r> (group)
    ] if ;

: group ( seq n -- groups ) [ swap (group) ] { } make ;

: start-step ( subseq seq n -- subseq slice )
    pick length dupd + rot <slice> ;

: start* ( subseq seq i -- n )
    pick length pick length pick - > [
        3drop -1
    ] [
        2dup >r >r start-step dupd sequence= [
            r> 2drop r>
        ] [
            r> r> 1+ start*
        ] if
    ] if ;

: start ( subseq seq -- n ) 0 start* ;

: subseq? ( subseq seq -- ? ) start -1 > ;

: split1 ( seq subseq -- before after )
    dup pick start dup -1 = [
        2drop dup like f
    ] [
        [ >r over r> head -rot length ] keep + tail
    ] if ;

: split, building get peek push ;

: split-next, V{ } clone , ;

: (split) ( quot elt -- )
    [ swap call ] keep swap
    [ drop split-next, ] [ split, ] if ; inline

: split* ( seq quot -- pieces )
    over >r
    [ split-next, swap [ (split) ] each-with ]
    { } make r> swap [ swap like ] map-with ; inline

: split ( seq separators -- pieces )
    swap [ over member? ] split* nip ;

: drop-prefix ( seq1 seq2 -- slice1 slice2 )
    2dup mismatch dup -1 = [ drop 2dup min-length ] when
    tuck tail-slice >r tail-slice r> ;

: unclip ( seq -- rest first ) dup 1 tail swap first ;
