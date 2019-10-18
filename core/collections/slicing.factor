! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences-internals
USING: generic kernel math namespaces strings vectors errors
sequences ;

: (start) ( subseq seq n -- subseq seq ? )
    pick length [
        >r 3dup r> [ + swap nth-unsafe ] keep rot nth-unsafe =
    ] all? nip ; inline

: (head) 0 swap rot ; inline
: (tail) over length rot ; inline
: from-end >r dup length r> - ; inline

IN: sequences

: head-slice ( seq n -- slice ) (head) <slice> ;
: tail-slice ( seq n -- slice ) (tail) <slice> ;
: head-slice* ( seq n -- slice ) from-end head-slice ;
: tail-slice* ( seq n -- slice ) from-end tail-slice ;
: head ( seq n -- headseq ) (head) subseq ;
: tail ( seq n -- tailseq ) (tail) subseq ;
: head* ( seq n -- headseq ) from-end head ;
: tail* ( seq n -- tailseq ) from-end tail ;

: head? ( seq begin -- ? )
    2dup [ length ] 2apply < [
        2drop f
    ] [
        [ length head-slice ] keep sequence=
    ] if ;

: ?head ( seq begin -- newseq ? )
    2dup head? [ length tail t ] [ drop f ] if ;

: tail? ( seq end -- ? )
    2dup [ length ] 2apply < [
        2drop f
    ] [
        [ length tail-slice* ] keep sequence=
    ] if ;

: ?tail ( seq end -- newseq ? )
    2dup tail? [ length head* t ] [ drop f ] if ;

: replace-slice ( new m n seq -- replaced )
    tuck swap tail-slice >r swap head-slice swap r> 3append ;

: remove-nth ( n seq -- newseq )
    >r f swap dup 1+ r> replace-slice ;

: cut-slice ( n seq -- before after )
    swap [ head ] 2keep tail-slice ;

: cut ( n seq -- before after )
    swap [ head ] 2keep tail ;

: cut* ( n seq -- before after )
    swap [ head* ] 2keep tail* ;

: start* ( subseq seq n -- i )
    pick length pick length swap - 1+
    [ (start) ] find*
    swap >r 3drop r> ;

: start ( subseq seq -- i ) 0 start* ; inline

: subseq? ( subseq seq -- ? ) start -1 > ;

: split1-slice ( seq subseq -- before after )
    dup pick start dup -1 = [
        2drop dup like f
    ] [
        [ >r over r> head -rot length ] keep + tail-slice
    ] if ;

: split1 ( seq subseq -- before after )
    over >r split1-slice dup [ r> like ] [ r> drop ] if ;

: split, building get peek push ;

: split-next, V{ } clone , ;

: (split) ( quot elt -- )
    swap keep swap
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
