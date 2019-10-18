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

: shorter? ( seq1 seq2 -- ? ) >r length r> length < ;

: head? ( seq begin -- ? )
    2dup shorter? [
        2drop f
    ] [
        tuck length head-slice sequence=
    ] if ;

: ?head ( seq begin -- newseq ? )
    2dup head? [ length tail t ] [ drop f ] if ;

: tail? ( seq end -- ? )
    2dup shorter? [
        2drop f
    ] [
        tuck length tail-slice* sequence=
    ] if ;

: ?tail ( seq end -- newseq ? )
    2dup tail? [ length head* t ] [ drop f ] if ;

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

: subseq? ( subseq seq -- ? ) start >boolean ;

: split1 ( seq subseq -- before after )
    dup pick start dup [
        [ >r over r> head -rot length ] keep + tail
    ] [
        2drop f
    ] if ;

: last-split1 ( seq subseq -- before after )
    >r <reversed> r> split1 [ reverse ] 2apply swap ;

: (split) ( separators n seq -- )
    [ [ swap member? ] find-with* drop ] 3keep roll
    [ [ swap subseq , ] 2keep 1+ swap (split) ]
    [ swap dup zero? [ drop ] [ tail ] if , drop ] if* ;

: split, ( seq separators -- ) 0 rot (split) ;

: split ( seq separators -- pieces ) [ split, ] { } make ;

: drop-prefix ( seq1 seq2 -- slice1 slice2 )
    2dup mismatch [ 2dup min-length ] unless*
    tuck tail-slice >r tail-slice r> ;

: unclip ( seq -- rest first ) dup 1 tail swap first ;
